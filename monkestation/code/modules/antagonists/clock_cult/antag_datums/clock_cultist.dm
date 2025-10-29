/datum/antagonist/clock_cultist
	name = "\improper Servant of Ratvar"
	antagpanel_category = "Clock Cultist"
	preview_outfit = /datum/outfit/clock/preview
	job_rank = ROLE_CLOCK_CULTIST
	antag_moodlet = /datum/mood_event/cult
	suicide_cry = ",r For Ratvar!!!"
	ui_name = "AntagInfoClock"
	show_to_ghosts = TRUE
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_TEAM
	antag_hud_name = "clockwork"
	stinger_sound = 'sound/magic/clockwork/scripture_tier_up.ogg'
	antag_count_points = 4
	/// Ref to the cultist's communication ability
	var/datum/action/innate/clockcult/comm/communicate = new
	/// Ref to the cultist's slab recall ability
	var/datum/action/innate/clockcult/recall_slab/recall = new
	///our cult team
	var/datum/team/clock_cult/clock_team
	///should we directly give them a slab or not
	var/give_slab = TRUE
	///ref to our turf_healing component, used for deletion when deconverted
	var/datum/component/turf_healing/owner_turf_healing
	///used for holy water deconversion, slightly easier to have this here then on the team, might want to refactor this to an assoc global list
	var/static/list/servant_deconversion_phrases = list("spoken" = list("VG OHEAF!", "SBE GUR TYBEL-BS ENGINE!", "Gur yvtug jvyy fuvar.", "Whfgv`pne fnir zr.", "Gur Nex zhfg abg snyy.",
																		"Rzvarapr V pnyy gur`r!", "Lbh frr bayl qnexarff.", "Guv`f vf abg gur raq.", "Gv`px, Gbpx"),

														"seizure" = list("Your failure shall not delay my freedom.", "The blind will see only darkness.",
																		 "Then my ark will feed upon your vitality.", "Do not forget your servitude."))

/datum/antagonist/clock_cultist/Destroy()
	QDEL_NULL(communicate)
	QDEL_NULL(recall)
	return ..()

/datum/antagonist/clock_cultist/on_gain()
	var/mob/living/current = owner.current
	objectives |= clock_team.objectives
	if(give_slab && ishuman(current))
		give_clockwork_slab(current)
	current.log_message("has been converted to the cult of Ratvar!", LOG_ATTACK, color="#960000")
	if(issilicon(current))
		handle_silicon_conversion(current)
	. = ..() //have to call down here so objectives display correctly
	ADD_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))

/datum/antagonist/clock_cultist/greet()
	. = ..()
	to_chat(owner.current, span_ratvar("HEY"))
	to_chat(owner.current, span_boldwarning("Dont forget, your structures are by default off and must be clicked on to be turned on. Structures that are turned on have passive power use."))
	to_chat(owner.current, span_boldwarning("YOUR CLOCKWORK SLAB UI HAS A MORE IN DEPTH GUIDE IN ITS BOTTOM RIGHT HAND SIDE. \
											YOU CAN HOVER YOUR MOUSE POINTER OVER SCRIPTURE BUTTONS FOR EXTRA INFO."))

//given_clock_team is provided by conversion methods, although we never use it due to wanting to just set their team to the main clock cult
/datum/antagonist/clock_cultist/create_team(datum/team/clock_cult/given_clock_team)
	spawn_reebe()
	if(!given_clock_team)
		if(GLOB.main_clock_cult)
			clock_team = GLOB.main_clock_cult
			return
		clock_team = new /datum/team/clock_cult
		clock_team.setup_objectives()
		return

	if(!istype(given_clock_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	clock_team = given_clock_team

/datum/antagonist/clock_cultist/get_team()
	return clock_team

/datum/antagonist/clock_cultist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= FACTION_CLOCK
	current.grant_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)
	current.throw_alert("clockinfo", /atom/movable/screen/alert/clockwork/clocksense)
	if(!iseminence(current))
		add_team_hud(current)
		communicate.Grant(current)
		if(ishuman(current) || iscogscarab(current)) //only human and cogscarabs would need a recall ability
			recall.Grant(current)

		owner_turf_healing = current.AddComponent(/datum/component/turf_healing, healing_types = list(TOX = (iscarbon(current) ? 4 : 1)), healing_turfs = GLOB.clock_turf_types)
		RegisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED, PROC_REF(switch_recall_slab))
		handle_clown_mutation(current, mob_override ? null : "The light of Ratvar allows you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
		add_forbearance(current)

/datum/antagonist/clock_cultist/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.faction -= FACTION_CLOCK
	current.remove_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)
	current.clear_alert("clockinfo")
	current.remove_filter("forbearance")
	if(!iseminence(current))
		communicate.Remove(current)
		recall.Remove(current)
		UnregisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED)
		QDEL_NULL(owner_turf_healing)
		handle_clown_mutation(current, removing = FALSE)

/datum/antagonist/clock_cultist/ui_data(mob/user)
	var/list/data = list()
	data["marked_areas"] = english_list(SSthe_ark.marked_areas)
	return data

/datum/antagonist/clock_cultist/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_cult(new_owner.current, for_clock_cult = TRUE)

/datum/antagonist/clock_cultist/on_removal()
	if(!silent)
		owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!"), \
									  span_userdanger("As the ticking fades from the back of your mind, you forget all memories you had as a servant of Ratvar."))
	owner.current.log_message("has renounced the cult of Ratvar!", LOG_ATTACK, color="#960000")
	handle_equipment_removal()
	REMOVE_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))
	return ..()

/datum/antagonist/clock_cultist/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)
	return finish_preview_icon(icon)

/datum/antagonist/clock_cultist/on_mindshield(mob/implanter)
	if(!silent)
		to_chat(owner.current, span_warning("You feel something pushing away the light of Ratvar, but you resist it!"))
	return

/datum/antagonist/clock_cultist/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has made [key_name_admin(new_owner)] into a servant of Ratvar.")
	log_admin("[key_name(admin)] has made [key_name(new_owner)] into a servant of Ratvar.")

/datum/antagonist/clock_cultist/admin_remove(mob/user)
	silent = TRUE
	return ..()

/datum/antagonist/clock_cultist/get_admin_commands()
	. = ..()
	.["Give Slab"] = CALLBACK(src, PROC_REF(admin_give_slab))
	.["Remove Slab"] = CALLBACK(src, PROC_REF(admin_take_slab))

/datum/antagonist/clock_cultist/proc/admin_take_slab(mob/admin)
	var/mob/living/current = owner.current
	for(var/object in current.get_all_contents())
		if(istype(object, /obj/item/clockwork/clockwork_slab))
			qdel(object)

/datum/antagonist/clock_cultist/proc/admin_give_slab(mob/admin)
	if(!give_clockwork_slab(owner.current))
		to_chat(admin, span_danger("Spawning clockwork slab failed!"))

//give a mob a slab directly into their inventory
/datum/antagonist/clock_cultist/proc/give_clockwork_slab(mob/living/carbon/human/give_to)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET)

	var/obj/item/clockwork/clockwork_slab/created_slab = new
	if(!give_to.equip_in_one_of_slots(created_slab, slots))
		to_chat(give_to, span_userdanger("Unfortunately, you weren't able to be given a [created_slab]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(give_to, span_danger("You have been given a [created_slab]."))
		return TRUE

/// Change the slab in the recall ability, if it's different from the last one.
/datum/antagonist/clock_cultist/proc/switch_recall_slab(datum/source, obj/item/clockwork/clockwork_slab/slab)
	if(slab == recall.marked_slab)
		return

	recall.unmark_item()
	recall.mark_item(slab)
	to_chat(owner.current, span_brass("You re-attune yourself to a new Clockwork Slab."))

/datum/antagonist/clock_cultist/proc/handle_silicon_conversion(mob/living/silicon/converted_silicon)
	if(isAI(converted_silicon))
		var/mob/living/silicon/ai/converted_ai = converted_silicon
		converted_ai.disconnect_shell()
		for(var/mob/living/silicon/robot/borg in converted_ai.connected_robots)
			borg.set_connected_ai(null)
		var/mutable_appearance/ai_clock = mutable_appearance('monkestation/icons/mob/clock_cult/clockwork_mobs.dmi', "aiframe")
		converted_ai.add_overlay(ai_clock)

	else if(iscyborg(converted_silicon))
		var/mob/living/silicon/robot/converted_borg = converted_silicon
		converted_borg.UnlinkSelf()
		converted_borg.set_clockwork(TRUE)

	if(converted_silicon.laws && istype(converted_silicon.laws, /datum/ai_laws/ratvar))
		return
	converted_silicon.laws = new /datum/ai_laws/ratvar
	converted_silicon.laws.associate(converted_silicon)
	converted_silicon.show_laws()

///remove clock cult items from their inventory by dropping them
/datum/antagonist/clock_cultist/proc/handle_equipment_removal()
	if(silent || !length(GLOB.types_to_drop_on_clock_deonversion))
		return

	var/mob/living/current = owner.current
	for(var/obj/item/object as anything in current.get_all_contents())
		if(object.type in GLOB.types_to_drop_on_clock_deonversion)
			current.dropItemToGround(object, TRUE, TRUE)

/datum/antagonist/clock_cultist/proc/add_forbearance(mob/apply_to)
	if(GLOB.clock_ark?.current_state >= ARK_STATE_ACTIVE)
		apply_to.add_filter("forbearance", 3, list("type" = "outline", "color" = "#FAE48E", "size" = 2, "alpha" = 100))

/datum/outfit/clock/preview
	name = "Clock Cultist (Preview only)"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/clockwork
	head = /obj/item/clothing/head/helmet/clockwork
	l_hand = /obj/item/clockwork/weapon/brass_sword

//these can just solo invoke things that normally take multiple servants
/datum/antagonist/clock_cultist/solo
	name = "Servant of Ratvar (Solo)"

//putting this here to avoid extra edits to the main file
/datum/antagonist/cult
	///used for holy water deconversion
	var/static/list/cultist_deconversion_phrases = list("spoken" = list("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones",
																		"R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"),

														"seizure" = list("Your blood is your bond - you are nothing without it", "Do not forget your place",
																		 "All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!"))
