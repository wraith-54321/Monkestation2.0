/datum/antagonist/bloodsucker
	name = "\improper Bloodsucker"
	show_in_antagpanel = TRUE
	roundend_category = "bloodsuckers"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "bloodsucker"
	show_name_in_check_antagonists = TRUE
	can_coexist_with_others = FALSE
	hijack_speed = 0.5
	hud_icon = 'monkestation/icons/bloodsuckers/bloodsucker_icons.dmi'
	ui_name = "AntagInfoBloodsucker"
	preview_outfit = /datum/outfit/bloodsucker_outfit
	stinger_sound = 'monkestation/sound/bloodsuckers/BloodsuckerAlert.ogg'
	/// How much blood we have, starting off at default blood levels.
	var/bloodsucker_blood_volume = BLOOD_VOLUME_NORMAL
	/// How much blood we can have at once, increases per level.
	var/max_blood_volume = 600

	var/datum/bloodsucker_clan/my_clan

	// TIMERS //
	///Timer between alerts for Burn messages
	COOLDOWN_DECLARE(bloodsucker_spam_sol_burn)
	///Timer between alerts for Healing messages
	COOLDOWN_DECLARE(bloodsucker_spam_healing)
	/// Cooldown for bloodsuckers going into Frenzy.
	COOLDOWN_DECLARE(bloodsucker_frenzy_cooldown)
	//Timer to track how long the bloodsucker has been in torpor
	COOLDOWN_DECLARE(bloodsucker_torpor_max_time)
	///Used for assigning your name
	var/bloodsucker_name
	///Used for assigning your title
	var/bloodsucker_title
	///Used for assigning your reputation
	var/bloodsucker_reputation

	///Amount of Humanity lost
	var/humanity_lost = 0
	///Have we been broken the Masquerade?
	var/broke_masquerade = FALSE
	///How many Masquerade Infractions do we have?
	var/masquerade_infractions = 0
	///Blood required to enter Frenzy
	var/frenzy_threshold = FRENZY_THRESHOLD_ENTER
	///If we are currently in a Frenzy
	var/frenzied = FALSE
	/// Whether the death handling code is active or not.
	var/handling_death = FALSE
	/// If this bloodsucker has suffered final death.
	var/final_death = FALSE
	///ALL Powers currently owned
	var/list/datum/action/cooldown/bloodsucker/powers = list()

	///Vassals under my control. Periodically remove the dead ones.
	var/list/datum/antagonist/vassal/vassals = list()
	///Special vassals I own, to not have double of the same type.
	var/list/datum/antagonist/vassal/special_vassals = list()

	var/bloodsucker_level = 0
	var/bloodsucker_level_unspent = 1
	var/sol_levels_remaining = 3
	var/additional_regen
	var/blood_over_cap = 0
	var/bloodsucker_regen_rate = 0.3

	// Used for Bloodsucker Objectives
	var/area/bloodsucker_lair_area
	var/obj/structure/closet/crate/coffin
	var/total_blood_drank = 0

	/// Used for Bloodsuckers gaining levels from drinking blood
	var/blood_level_gain = 0
	var/blood_level_gain_amount = 0

	///Blood display HUD
	var/atom/movable/screen/bloodsucker/blood_counter/blood_display
	///Vampire level display HUD
	var/atom/movable/screen/bloodsucker/rank_counter/vamprank_display
	///Sunlight timer HUD
	var/atom/movable/screen/bloodsucker/sunlight_counter/sunlight_display

	var/obj/effect/abstract/bloodsucker_tracker_holder/tracker

	/// List of limbs we've applied additional punch damage to.
	var/list/affected_limbs = list(
		BODY_ZONE_L_ARM = null,
		BODY_ZONE_R_ARM = null,
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

	/// Static typecache of all bloodsucker powers.
	var/static/list/all_bloodsucker_powers = typecacheof(/datum/action/cooldown/bloodsucker, ignore_root_path = TRUE)
	/// Antagonists that cannot be Vassalized no matter what
	var/static/list/vassal_banned_antags = list(
		/datum/antagonist/bloodsucker,
		/datum/antagonist/monsterhunter,
		/datum/antagonist/changeling,
		/datum/antagonist/cult,
	)
	/// Traits that don't get removed by Masquerade
	var/static/list/always_traits = list(
		TRAIT_NO_MINDSWAP, // mindswapping bloodsuckers is buggy af and I'm too lazy to properly fix it. ~Absolucy
		TRAIT_NO_DNA_COPY, // no, you can't cheat your curse with a cloner.
		TRAIT_OOZELING_NO_CANNIBALIZE, // prevents weird softlocks
	)
	///Default Bloodsucker traits
	var/static/list/bloodsucker_traits = list(
		TRAIT_AGEUSIA,
		TRAIT_COLD_BLOODED,
		TRAIT_ETHEREAL_NO_OVERCHARGE,
		TRAIT_GENELESS,
		TRAIT_HARDLY_WOUNDED,
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_NO_BLEED_WARN,
		TRAIT_NO_MIRROR_REFLECTION,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STABLEHEART,
		TRAIT_STABLELIVER,
		TRAIT_TOXIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		// they eject zombie tumors and xeno larvae during eepy time anyways
		TRAIT_NO_ZOMBIFY, // they're already undead lol
		TRAIT_XENO_IMMUNE, // something something facehuggers only latch onto living things
	)
	/// Traits applied during Torpor.
	var/static/list/torpor_traits = list(
		TRAIT_DEATHCOMA,
		TRAIT_FAKEDEATH,
		TRAIT_NODEATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)
	/// Traits applied while inside of a coffin.
	var/static/list/coffin_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)
	/// A typecache of organs we'll expel during Torpor.
	var/static/list/yucky_organ_typecache = typecacheof(list(
		/obj/item/organ/internal/body_egg,
		/obj/item/organ/internal/zombie_infection,
	))

/**
 * Apply innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_gain is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/bloodsucker/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	RegisterSignal(current_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(current_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(current_mob, COMSIG_ATOM_AFTER_EXPOSE_REAGENTS, PROC_REF(after_expose_reagents))
	RegisterSignal(current_mob, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_items))
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(life_tick))
	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(current_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(current_mob, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(handle_blood))
	RegisterSignal(current_mob, SIGNAL_REMOVETRAIT(TRAIT_SHADED), PROC_REF(handle_sol))
	handle_clown_mutation(current_mob, mob_override ? null : "As a vampiric clown, you are no longer a danger to yourself. Your clownish nature has been subdued by your thirst for blood.")
	add_team_hud(current_mob)
	current_mob.clear_mood_event("vampcandle")
	current_mob.grant_language(/datum/language/vampiric, source = LANGUAGE_BLOODSUCKER)

	if(current_mob.hud_used)
		on_hud_created()
	else
		RegisterSignal(current_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

	ensure_brain_nonvital(current_mob)
	setup_limbs(current_mob)
	setup_tracker(current_mob)

#ifdef BLOODSUCKER_TESTING
	var/turf/user_loc = get_turf(current_mob)
	new /obj/structure/closet/crate/coffin(user_loc)
	new /obj/structure/bloodsucker/vassalrack(user_loc)
#endif


/**
 * Remove innate effects is everything given to the mob
 * When a body is tranferred, this is called on the old mob.
 * while on_removal is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/bloodsucker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_AFTER_EXPOSE_REAGENTS, COMSIG_MOB_GET_STATUS_TAB_ITEMS, COMSIG_LIVING_LIFE, COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_HUMAN_ON_HANDLE_BLOOD, SIGNAL_REMOVETRAIT(TRAIT_SHADED), COMSIG_MOB_LOGIN))
	handle_clown_mutation(current_mob, removing = FALSE)
	current_mob.remove_language(/datum/language/vampiric, source = LANGUAGE_BLOODSUCKER)

	cleanup_tracker()
	cleanup_limbs(current_mob)

	if(current_mob.hud_used)
		var/datum/hud/hud_used = current_mob.hud_used
		hud_used.infodisplay -= blood_display
		hud_used.infodisplay -= vamprank_display
		hud_used.infodisplay -= sunlight_display
		QDEL_NULL(blood_display)
		QDEL_NULL(vamprank_display)
		QDEL_NULL(sunlight_display)

/datum/antagonist/bloodsucker/after_body_transfer(mob/living/old_body, mob/living/new_body)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/antagonist, add_team_hud), new_body), 0.5 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE) //i don't trust this to not act weird

/datum/antagonist/bloodsucker/proc/get_status_tab_items(datum/source, list/items)
	SIGNAL_HANDLER
	items += "Blood Drank: [total_blood_drank]"
	items += "Maximum blood: [max_blood_volume]"
	items += "Blood Thickening: [blood_level_gain] / [get_level_cost()]"

/datum/antagonist/bloodsucker/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/datum/hud/bloodsucker_hud = owner.current.hud_used

	blood_display = new /atom/movable/screen/bloodsucker/blood_counter(null, bloodsucker_hud)
	bloodsucker_hud.infodisplay += blood_display

	vamprank_display = new /atom/movable/screen/bloodsucker/rank_counter(null, bloodsucker_hud)
	bloodsucker_hud.infodisplay += vamprank_display

	sunlight_display = new /atom/movable/screen/bloodsucker/sunlight_counter(null, bloodsucker_hud)
	bloodsucker_hud.infodisplay += sunlight_display

	bloodsucker_hud.show_hud(bloodsucker_hud.hud_version)
	UnregisterSignal(owner.current, COMSIG_MOB_HUD_CREATED)

/datum/antagonist/bloodsucker/get_admin_commands()
	. = ..()
	.["Give Level"] = CALLBACK(src, PROC_REF(RankUp))
	if(bloodsucker_level_unspent >= 1)
		.["Remove Level"] = CALLBACK(src, PROC_REF(RankDown))

	if(broke_masquerade)
		.["Fix Masquerade"] = CALLBACK(src, PROC_REF(fix_masquerade))
	else
		.["Break Masquerade"] = CALLBACK(src, PROC_REF(break_masquerade))

	if(my_clan)
		.["Remove Clan"] = CALLBACK(src, PROC_REF(remove_clan))
	else
		.["Add Clan"] = CALLBACK(src, PROC_REF(admin_set_clan))

///Called when you get the antag datum, called only ONCE per antagonist.
/datum/antagonist/bloodsucker/on_gain()
	RegisterSignal(SSsol, COMSIG_SOL_RANKUP_BLOODSUCKERS, PROC_REF(sol_rank_up))
	RegisterSignal(SSsol, COMSIG_SOL_NEAR_START, PROC_REF(sol_near_start))
	RegisterSignal(SSsol, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(SSsol, COMSIG_SOL_RISE_TICK, PROC_REF(handle_sol))
	RegisterSignal(SSsol, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	ADD_TRAIT(owner, TRAIT_BLOODSUCKER_ALIGNED, REF(src))

	if(IS_FAVORITE_VASSAL(owner.current)) // Vassals shouldnt be getting the same benefits as Bloodsuckers.
		bloodsucker_level_unspent = 0
		show_in_roundend = FALSE
	else
		// Start Sunlight if first Bloodsucker
		check_start_sunlight()
		// Name and Titles
		SelectFirstName()
		SelectTitle(am_fledgling = TRUE)
		SelectReputation(am_fledgling = TRUE)
		// Objectives
		forge_bloodsucker_objectives()

	. = ..()
	// Assign Powers
	give_starting_powers()
	assign_starting_stats()

	owner.current.persistent_client?.remove_challenge(/datum/challenge/no_heals)

/// Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/bloodsucker/on_removal()
	REMOVE_TRAIT(owner, TRAIT_BLOODSUCKER_ALIGNED, REF(src))
	UnregisterSignal(SSsol, list(COMSIG_SOL_RANKUP_BLOODSUCKERS, COMSIG_SOL_NEAR_START, COMSIG_SOL_END, COMSIG_SOL_RISE_TICK, COMSIG_SOL_WARNING_GIVEN))
	clear_powers_and_stats()
	check_cancel_sunlight() //check if sunlight should end
	owner.special_role = null
	if(!iscarbon(owner.current))
		return
	var/mob/living/carbon/carbon_owner = owner.current
	var/obj/item/organ/internal/brain/not_vamp_brain = carbon_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(not_vamp_brain && (not_vamp_brain.decoy_override != initial(not_vamp_brain.decoy_override)))
		not_vamp_brain.organ_flags |= ORGAN_VITAL
		not_vamp_brain.decoy_override = FALSE
	return ..()

/datum/antagonist/bloodsucker/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		if(old_body)
			all_powers.Remove(old_body)
		all_powers.Grant(new_body)

	//Give Bloodsucker Traits
	old_body?.remove_traits(bloodsucker_traits + always_traits, BLOODSUCKER_TRAIT)
	new_body.add_traits(bloodsucker_traits + always_traits, BLOODSUCKER_TRAIT)

/datum/antagonist/bloodsucker/greet()
	if(silent) // don't bother calling ..(), we don't need the duplicate "You are the Bloodsucker!" message
		return
	var/fullname = return_full_name()
	to_chat(owner, span_userdanger("You are [fullname], a strain of vampire known as a Bloodsucker!"))
	owner.announce_objectives()
	if(bloodsucker_level_unspent >= 2)
		to_chat(owner, span_announce("As a latejoiner, you have [bloodsucker_level_unspent] bonus Ranks, entering your claimed coffin allows you to spend a Rank."))
	antag_memory += "Although you were born a mortal, in undeath you earned the name <b>[fullname]</b>.<br>"
	play_stinger()

/datum/antagonist/bloodsucker/farewell()
	to_chat(owner.current, span_userdanger("<FONT size = 3>With a snap, your curse has ended. You are no longer a Bloodsucker. You live once more!</FONT>"))
	// Refill with Blood so they don't instantly die.
	if(!HAS_TRAIT(owner.current, TRAIT_NOBLOOD))
		owner.current.blood_volume = max(owner.current.blood_volume, BLOOD_VOLUME_NORMAL)

// Called when using admin tools to give antag status
/datum/antagonist/bloodsucker/admin_add(datum/mind/new_owner, mob/admin)
	var/levels = input("How many unspent Ranks would you like [new_owner] to have?","Bloodsucker Rank", bloodsucker_level_unspent) as null | num
	var/msg = " made [key_name_admin(new_owner)] into \a [name]"
	if(levels > 1)
		bloodsucker_level_unspent = levels
		msg += " with [levels] extra unspent Ranks."
	message_admins("[key_name_admin(usr)][msg]")
	log_admin("[key_name(usr)][msg]")
	new_owner.add_antag_datum(src)

/datum/antagonist/bloodsucker/get_preview_icon()

	var/icon/final_icon = render_preview_outfit(/datum/outfit/bloodsucker_outfit)
	final_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/bloodsucker/ui_static_data(mob/user)
	. = ..()
	if(my_clan)
		.["clan"] = list(
			"name" = my_clan.name,
			"desc" = my_clan.description,
			"icon" = my_clan.join_icon,
			"icon_state" = my_clan.join_icon_state,
		)

	.["powers"] = list()
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		.["powers"] += list(list(
			"name" = power.name,
			"explanation" = power.html_power_explanation(),
			"icon" = power.button_icon,
			"icon_state" = power.button_icon_state,
		))

/datum/antagonist/bloodsucker/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("join_clan")
			if(my_clan)
				return
			assign_clan_and_bane()
			ui.send_full_update(force = TRUE)
			return TRUE

/datum/antagonist/bloodsucker/roundend_report()
	var/list/report = list()

	// Vamp name
	report += "<br><span class='header'><b>\[[return_full_name()]\]</b></span>"
	report += printplayer(owner)
	if(my_clan)
		report += "They were part of the <b>[my_clan.name]</b>!"

	// Default Report
	var/objectives_complete = TRUE
	if(length(objectives))
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(objective.objective_name == "Optional Objective")
				continue
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	// Now list their vassals
	if(length(vassals))
		report +=  span_header("Their Vassals were...")
		for(var/datum/antagonist/vassal/all_vassals as anything in vassals)
			if(QDELETED(all_vassals?.owner))
				continue
			var/list/vassal_report = list()
			vassal_report += "<b>[all_vassals.owner.name]</b>"

			if(all_vassals.owner.assigned_role)
				vassal_report += " the [all_vassals.owner.assigned_role.title]"
			if(IS_FAVORITE_VASSAL(all_vassals.owner.current))
				vassal_report += " and was the <b>Favorite Vassal</b>"
			else if(IS_REVENGE_VASSAL(all_vassals.owner.current))
				vassal_report += " and was the <b>Revenge Vassal</b>"
			report += vassal_report.Join()

	if(!length(objectives) || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

/// "Oh, well, that's step one. What about two through ten?"
/// Beheading bloodsuckers is kinda buggy and results in them being dead-dead without actually being final deathed, which is NOT something that's desired.
/// Just stake them. No shortcuts.
/datum/antagonist/bloodsucker/proc/ensure_brain_nonvital(mob/living/mob_override)
	var/mob/living/carbon/carbon_owner = mob_override || owner.current
	if(!iscarbon(carbon_owner) || isoozeling(carbon_owner))
		return
	var/obj/item/organ/internal/brain/brain = carbon_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return
	brain.organ_flags &= ~ORGAN_VITAL
	brain.decoy_override = TRUE

/datum/antagonist/bloodsucker/proc/give_starting_powers()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in all_bloodsucker_powers)
		if(!(initial(all_powers.purchase_flags) & BLOODSUCKER_DEFAULT_POWER))
			continue
		BuyPower(new all_powers)

/datum/antagonist/bloodsucker/proc/assign_starting_stats()
	//Traits: Species
	var/mob/living/carbon/human/user = owner.current
	if(ishuman(owner.current))
		var/datum/species/user_species = user.dna.species
		user_species.inherent_traits += TRAIT_DRINKS_BLOOD
		user.dna?.remove_all_mutations()
	//Give Bloodsucker Traits
	owner.current.add_traits(bloodsucker_traits + always_traits, BLOODSUCKER_TRAIT)
	//Clear Addictions
	for(var/addiction_type in subtypesof(/datum/addiction))
		owner.current.mind.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS)
	//No Skittish "People" allowed
	if(HAS_TRAIT(owner.current, TRAIT_SKITTISH))
		REMOVE_TRAIT(owner.current, TRAIT_SKITTISH, ROUNDSTART_TRAIT)
	/// Clear Disabilities & Organs
	heal_vampire_organs()

/**
 * ##clear_power_and_stats()
 *
 * Removes all Bloodsucker related Powers/Stats changes, setting them back to pre-Bloodsucker
 * Order of steps and reason why:
 * Remove clan - Clans like Nosferatu give Powers on removal, we have to make sure this is given before removing Powers.
 * Powers - Remove all Powers, so things like Masquerade are off.
 * Species traits, Traits, MaxHealth, Language - Misc stuff, has no priority.
 * Organs - At the bottom to ensure everything that changes them has reverted themselves already.
 * Update Sight - Done after Eyes are regenerated.
 */
/datum/antagonist/bloodsucker/proc/clear_powers_and_stats()
	// Remove clan first
	if(my_clan)
		QDEL_NULL(my_clan)
	// Powers
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		RemovePower(all_powers)
	/// Stats
	if(ishuman(owner.current))
		var/mob/living/carbon/human/user = owner.current
		var/datum/species/user_species = user.dna.species
		user_species.inherent_traits -= TRAIT_DRINKS_BLOOD
	// Remove all bloodsucker traits
	owner.current.remove_traits(bloodsucker_traits + always_traits, BLOODSUCKER_TRAIT)
	// Update Health
	owner.current.setMaxHealth(initial(owner.current.maxHealth))
	// Language
	owner.current.remove_language(/datum/language/vampiric)
	// Heart & Eyes
	var/mob/living/carbon/user = owner.current
	var/obj/item/organ/internal/heart/newheart = owner.current.get_organ_slot(ORGAN_SLOT_HEART)
	if(newheart)
		newheart.beating = initial(newheart.beating)
	var/obj/item/organ/internal/eyes/user_eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	if(user_eyes)
		user_eyes.flash_protect = initial(user_eyes.flash_protect)
		user_eyes.lighting_cutoff = initial(user_eyes.lighting_cutoff)
		user_eyes.color_cutoffs = initial(user_eyes.color_cutoffs)
		user_eyes.sight_flags = initial(user_eyes.sight_flags)
	user.update_sight()

/// Name shown on antag list
/datum/antagonist/bloodsucker/antag_listing_name()
	return ..() + "([return_full_name()])"

/// Whatever interesting things happened to the antag admins should know about
/// Include additional information about antag in this part
/datum/antagonist/bloodsucker/antag_listing_status()
	if(owner && !considered_alive(owner))
		return "<font color=red>Final Death</font>"
	return ..()

/datum/antagonist/bloodsucker/proc/forge_bloodsucker_objectives()
	// Claim a Lair Objective
	objectives += new /datum/objective/bloodsucker/lair(null, owner)
	// Survive Objective
	objectives += new /datum/objective/bloodsucker/survive(null, owner)

	// Conversion objective.
	// Most likely to just be "have X living vassals", but can also be "vassalize command" or "vassalize X members of Y department"
	var/static/list/weighted_objectives
	if(!weighted_objectives)
		weighted_objectives = list(/datum/objective/bloodsucker/conversion = 10)
		weighted_objectives[subtypesof(/datum/objective/bloodsucker/conversion)] = 1
	var/conversion_objective_type = pick_weight_recursive(weighted_objectives)
	var/datum/objective/bloodsucker/conversion_objective = new conversion_objective_type(null, owner)
	conversion_objective.objective_name = "Optional Objective"
	objectives += conversion_objective

/datum/antagonist/bloodsucker/proc/on_moved(datum/source)
	SIGNAL_HANDLER
	var/mob/living/current = owner?.current
	if(QDELETED(current))
		return
	tracker?.tracking_beacon?.update_position()
	if(istype(current.loc, /obj/structure/closet/crate/coffin))
		current.add_traits(coffin_traits, BLOODSUCKER_COFFIN_TRAIT)
	else
		REMOVE_TRAITS_IN(current, BLOODSUCKER_COFFIN_TRAIT)

/datum/antagonist/bloodsucker/proc/setup_limbs(mob/living/carbon/target)
	if(!iscarbon(target))
		return
	RegisterSignal(target, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(register_limb))
	RegisterSignal(target, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(unregister_limb))
	for(var/body_part in affected_limbs)
		var/obj/item/bodypart/limb = target.get_bodypart(check_zone(body_part))
		if(limb)
			register_limb(target, limb, initial = TRUE)

/datum/antagonist/bloodsucker/proc/cleanup_limbs(mob/living/carbon/target)
	if(!iscarbon(target))
		return
	UnregisterSignal(target, list(COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_CARBON_POST_REMOVE_LIMB))
	for(var/body_part in affected_limbs)
		var/obj/item/bodypart/limb = target.get_bodypart(check_zone(body_part))
		if(limb)
			unregister_limb(target, limb)

/datum/antagonist/bloodsucker/proc/register_limb(mob/living/carbon/owner, obj/item/bodypart/new_limb, special, initial = FALSE)
	SIGNAL_HANDLER
	if(new_limb.body_zone == BODY_ZONE_HEAD || new_limb.body_zone == BODY_ZONE_CHEST)
		return

	affected_limbs[new_limb.body_zone] = new_limb
	RegisterSignal(new_limb, COMSIG_QDELETING, PROC_REF(limb_gone))

	var/extra_damage = 1 + (bloodsucker_level / 2)
	new_limb.unarmed_damage_low += extra_damage
	new_limb.unarmed_damage_high += extra_damage

/datum/antagonist/bloodsucker/proc/unregister_limb(mob/living/carbon/owner, obj/item/bodypart/lost_limb, special)
	SIGNAL_HANDLER
	if(lost_limb.body_zone == BODY_ZONE_HEAD || lost_limb.body_zone == BODY_ZONE_CHEST)
		return
	var/extra_damage = 1 + (bloodsucker_level / 2)

	affected_limbs[lost_limb.body_zone] = null
	UnregisterSignal(lost_limb, COMSIG_QDELETING)
	// safety measure in case we ever accidentally fuck up the math or something
	lost_limb.unarmed_damage_low = max(lost_limb.unarmed_damage_low - extra_damage, initial(lost_limb.unarmed_damage_low))
	lost_limb.unarmed_damage_high = max(lost_limb.unarmed_damage_high - extra_damage, initial(lost_limb.unarmed_damage_high))

/datum/antagonist/bloodsucker/proc/limb_gone(obj/item/bodypart/deleted_limb)
	SIGNAL_HANDLER
	if(affected_limbs[deleted_limb.body_zone])
		affected_limbs[deleted_limb.body_zone] = null
		UnregisterSignal(deleted_limb, COMSIG_QDELETING)

/datum/antagonist/bloodsucker/proc/after_expose_reagents(mob/source_mod, list/reagents, datum/reagents/source, methods = TOUCH, volume_modifier = 1, show_message = TRUE)
	SIGNAL_HANDLER
	var/datum/reagent/blood/blood_reagent = locate() in reagents
	if(!blood_reagent)
		return
	var/blood_volume = round(reagents[blood_reagent], 0.1)
	if(blood_volume > 0)
		bloodsucker_blood_volume = min(bloodsucker_blood_volume + blood_volume, BLOOD_VOLUME_MAXIMUM)

/datum/antagonist/bloodsucker/proc/on_login()
	SIGNAL_HANDLER
	var/mob/living/current = owner.current
	if(!QDELETED(current))
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/antagonist, add_team_hud), current), 0.5 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE) //i don't trust this to not act weird

/datum/status_effect/silver_cuffed
	id = "silver cuffed"
	alert_type = null
	remove_on_fullheal = TRUE
