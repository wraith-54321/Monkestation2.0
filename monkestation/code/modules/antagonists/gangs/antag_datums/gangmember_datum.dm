/datum/antagonist/gang_member
	name = "\improper Syndicate gang member"
	roundend_category = "gangs"
	job_rank = ROLE_GANG_MEMBER
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5 //TODO: make hyjacking give rep to the team that does it
	antagpanel_category = "Gang"
	antag_hud_name = "hud_gangster"
	ui_name = "AntagInfoGang"
	stinger_sound = 'sound/ambience/antag/familieswork.ogg'
	///Ref to our team
	var/datum/team/gang/gang_team
	///What is our rank
	var/rank = GANG_RANK_MEMBER
	///Ref to our uplink handler
	var/datum/uplink_handler/gang/handler
	///Typepath of item to give on_gain(), set to null to give nothing
	var/given_gear_type = /obj/item/toy/crayon/spraycan/gang
	///Set to TRUE when this datum is being removed due to rank change
	var/changing_rank = FALSE
	///Ref to our gang communicator action, if we have one
	var/datum/action/innate/gang_communicate/communicate

/datum/antagonist/gang_member/New()
	. = ..()
	if(rank >= GANG_RANK_LIEUTENANT)
		set_communicate_source()

/datum/antagonist/gang_member/create_team(datum/team/team)
	if(!team)
		gang_team = new()
		return
	gang_team = team

/datum/antagonist/gang_member/get_team()
	return gang_team

/datum/antagonist/gang_member/on_gain()
	var/list/member_list = gang_team.member_datums_by_rank[rank]
	if(!member_list)
		member_list = list()
		gang_team.member_datums_by_rank[rank] = member_list
	member_list += src

	objectives += gang_team.objectives
	if(!handler.primary_objectives)
		handler.primary_objectives = objectives.Copy()
	else
		handler.primary_objectives |= objectives
	handler.can_take_objectives = !!rank //return it as a bool
	handler.maximum_active_objectives = 1 * rank //this actually just works, but if you for some reason ever mess with ranks this will break
	handler.maximum_potential_objectives = 3 * rank
	if(handler.maximum_potential_objectives)
		handler.generate_objectives()
	handler.on_update()

	hud_keys = gang_team.gang_tag
	if(owner?.current)
		add_team_hud(owner.current, /datum/antagonist/gang_member)
		if(given_gear_type)
			var/obj/item/given_item = new given_gear_type(get_turf(owner.current))
			var/mob/living/carbon/carbon_current = (iscarbon(owner.current) ? owner.current : null)
			if(!carbon_current?.equip_in_one_of_slots(given_item, list("backpack" = ITEM_SLOT_BACKPACK)))
				owner.current.put_in_hands(given_item)
	return ..()

/datum/antagonist/gang_member/on_body_transfer(mob/living/old_body, mob/living/new_body)
	var/obj/item/implant/uplink/gang/implant = locate() in old_body.implants
	if(!implant)
		return ..()

	implant.removed(old_body, special = TRUE, forced = TRUE)
	implant.implant(new_body)
	return ..()

//might need to handle body transfer
/datum/antagonist/gang_member/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		current.faction += "[REF(gang_team)]"
		communicate?.Grant(current)

/datum/antagonist/gang_member/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		current.faction -= "[REF(gang_team)]"
		communicate?.Remove(current)

/datum/antagonist/gang_member/on_removal()
	handler = null
	. = ..()
	gang_team.member_datums_by_rank[rank] -= src
	if(communicate?.source_rank < GANG_RANK_LIEUTENANT)
		QDEL_NULL(communicate)

/datum/antagonist/gang_member/admin_add(datum/mind/new_owner, mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	var/static/list/implant_types_to_give
	if(!implant_types_to_give)
		implant_types_to_give = list()
		for(var/obj/item/implant/uplink/gang/implant as anything in typesof(/obj/item/implant/uplink/gang))
			implant_types_to_give[initial(implant.antag_type)] = implant

	var/datum/team/gang/selected_gang = tgui_input_list(admin, "What gang would you like them to be a part of?", "Select Gang", GLOB.all_gangs_by_tag + "New Gang")
	var/created_type = implant_types_to_give[src.type]
	var/obj/item/implant/uplink/gang/given_implant = new created_type(new_owner.current)
	given_implant.give_gear = TRUE
	given_implant.implant(new_owner.current, force = TRUE, forced_gang = GLOB.all_gangs_by_tag[selected_gang])

/datum/antagonist/gang_member/ui_static_data(mob/user)
	var/list/data = ..()
	data["gang_name"] = gang_team.name
	return data

///Change our datum type to a different one
/datum/antagonist/gang_member/proc/change_rank(datum/antagonist/gang_member/new_datum) //might want to make a specific proc for demotion
	if(ispath(new_datum))
		new_datum = new new_datum()

	silent = TRUE
	changing_rank = TRUE
	var/datum/uplink_handler/handler_ref = handler
	new_datum.handler = handler_ref
	var/obj/item/implant/uplink/gang/implant = (locate() in owner?.current?.implants)
	var/datum/component/uplink/uplink_component = implant?.GetComponent(/datum/component/uplink)
	if(MEETS_GANG_RANK(new_datum, GANG_RANK_LIEUTENANT))
		new_datum.TakeComponent(uplink_component)
		new_datum.set_communicate_source(communicate)
		communicate = null
	else if(implant)
		new_datum.RegisterSignal(implant, COMSIG_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_implant_removal))

	var/datum/mind/owner_ref = owner //we need to keep a temp ref of this to use after on_removal()
	on_removal()
	owner_ref?.add_antag_datum(new_datum, gang_team)
	var/active_length = length(handler_ref.active_objectives)
	while(active_length && handler_ref.maximum_active_objectives < active_length)
		var/datum/traitor_objective/objective = handler_ref.active_objectives[active_length]
		objective.fail_objective() //penalty is unset so it will just count as invalid
		handler_ref.complete_objective(objective)
		active_length = length(handler_ref.active_objectives)

	var/potential_length = length(handler_ref.potential_objectives)
	while(potential_length && handler_ref.maximum_potential_objectives < potential_length)
		var/datum/traitor_objective/objective = handler_ref.potential_objectives[potential_length]
		objective.handle_cleanup()
		potential_length = length(handler_ref.potential_objectives)

	handler_ref.on_update() //im gonna say its cheaper to just always run this rather than set up some kind of janky check for it

///Create our communicate action if we dont have one then set its source
/datum/antagonist/gang_member/proc/set_communicate_source(datum/action/innate/gang_communicate/commune, source = rank)
	if(!communicate)
		communicate = commune || new
		communicate.Grant(owner?.current) //if owner is the same or null then Grant() just returns, so this is safe
	communicate.source_rank = source

/datum/antagonist/gang_member/proc/handle_implant_removal(datum/source, mob/living/mob_source, silent, special)
	SIGNAL_HANDLER
	if(special) //we use special as the flag to check for being tranferred
		return

	on_removal(source)

/datum/antagonist/gang_member/lieutenant
	name = "\improper Syndicate Gang Lieutenant"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_hud_name = "gang_lieutenant"
	rank = GANG_RANK_LIEUTENANT

/datum/antagonist/gang_member/boss
	name = "\improper Syndicate Gang Boss"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_hud_name = "gang_boss"
	rank = GANG_RANK_BOSS
	given_gear_type = /obj/item/storage/box/syndicate/gang_boss_kit
	///Our TC allocation ability
	var/datum/action/innate/allocate_gang_tc/allocate = new

/datum/antagonist/gang_member/boss/on_removal(obj/item/implant/uplink/gang/implant)
	QDEL_NULL(allocate)
	return ..()

/datum/antagonist/gang_member/boss/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		allocate.Grant(current)

/datum/antagonist/gang_member/boss/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		allocate?.Remove(current)
