/datum/antagonist/gang_member
	name = "\improper Syndicate gang member"
	roundend_category = "gangs"
	job_rank = ROLE_GANG_MEMBER
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	antagpanel_category = "Gang"
	antag_hud_name = "hud_gangster"
	///Ref to our team
	var/datum/team/gang/gang_team
	///What is our rank
	var/rank = GANG_RANK_MEMBER
	///Ref to our uplink handler
	var/datum/uplink_handler/gang/handler

/datum/antagonist/gang_member/create_team(datum/team/team)
	if(!team)
		gang_team = new()
		return
	gang_team = team

/datum/antagonist/gang_member/get_team()
	return gang_team

/datum/antagonist/gang_member/on_gain()
	var/list/member_list = gang_team.member_datums_by_rank["[rank]"]
	if(!member_list)
		member_list = list()
		gang_team.member_datums_by_rank["[rank]"] = member_list
	member_list += src

	objectives += gang_team.objectives
	handler.can_take_objectives = !!rank //return it as a bool
	handler.maximum_active_objectives = 1 * rank //this actually just works, but if you for some reason ever mess with ranks this will break
	handler.maximum_potential_objectives = 3 * rank
	if(handler.maximum_potential_objectives)
		handler.generate_objectives()

	hud_keys = gang_team.tag
	if(owner?.current)
		add_team_hud(owner.current)
	. = ..()
//I need to handle body transfer
/datum/antagonist/gang_member/apply_innate_effects(mob/living/mob_override)
	. = ..()
	owner?.current?.faction += "[REF(gang_team)]"

/datum/antagonist/gang_member/on_removal(obj/item/implant/uplink/gang/our_implant)
	handler = null
	if(!our_implant)
		our_implant = locate() in owner?.current?.contents

	. = ..()
	gang_team.member_datums_by_rank["[rank]"] -= src
	if(our_implant)
		UnregisterSignal(our_implant, list(COMSIG_IMPLANT_REMOVED, COMSIG_PRE_IMPLANT_REMOVED))

/datum/antagonist/gang_member/remove_innate_effects(mob/living/mob_override)
	. = ..()
	owner?.current?.faction -= "[REF(gang_team)]"

///Change our datum type to a different one
/datum/antagonist/gang_member/proc/change_rank(datum/antagonist/gang_member/new_datum)
	if(ispath(new_datum))
		new_datum = new new_datum()

	silent = TRUE
	var/obj/item/implant/uplink/gang/our_implant = locate() in owner?.current?.contents
	new_datum.handler = handler
	on_removal(our_implant)
	owner?.add_antag_datum(new_datum, gang_team)
	if(our_implant)
		new_datum.RegisterSignal(our_implant, COMSIG_PRE_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_pre_implant_removal))
		new_datum.RegisterSignal(our_implant, COMSIG_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_implant_removal))

///Block implant removal if we are a lieutenant or higher
/datum/antagonist/gang_member/proc/handle_pre_implant_removal(datum/source, mob/living/mob_source, silent, special)
	SIGNAL_HANDLER
	if(rank >= GANG_RANK_LIEUTENANT)
		return COMPONENT_STOP_IMPLANT_REMOVAL

/datum/antagonist/gang_member/proc/handle_implant_removal(datum/source, mob/living/mob_source, silent, special)
	SIGNAL_HANDLER
	on_removal(source)

/datum/antagonist/gang_member/boss
	name = "\improper Syndicate Gang Boss"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_hud_name = "gang_boss"
	rank = GANG_RANK_BOSS

/datum/antagonist/gang_member/lieutenant
	name = "\improper Syndicate Gang Lieutenant"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_hud_name = "gang_lieutenant"
	rank = GANG_RANK_LIEUTENANT
