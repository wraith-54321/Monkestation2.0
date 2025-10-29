/**
 * Bloodsucker clans
 *
 * Handles everything related to clans.
 * the entire idea of datumizing this came to me in a dream.
 */
/datum/bloodsucker_clan
	///The bloodsucker datum that owns this clan. Use this over 'source', because while it's the same thing, this is more consistent (and used for deletion).
	var/datum/antagonist/bloodsucker/bloodsuckerdatum
	///The name of the clan we're in.
	var/name = CLAN_NONE
	///Description of what the clan is, given when joining and through your antag UI.
	var/description = "The Caitiff is as basic as you can get with Bloodsuckers. \n\
		Entirely Clan-less, they are blissfully unaware of who they really are. \n\
		No additional abilities is gained, nothing is lost, if you want a plain Bloodsucker, this is it. \n\
		The Favorite Vassal will gain the Brawn ability, to help in combat."
	///The clan objective that is required to greentext.
	var/datum/objective/bloodsucker/clan_objective
	///The icon of the radial icon to join this clan.
	var/join_icon = 'monkestation/icons/bloodsuckers/clan_icons.dmi'
	///Same as join_icon, but the state
	var/join_icon_state = "caitiff"
	///Description shown when trying to join the clan.
	var/join_description = "The default, Classic Bloodsucker."
	///Whether the clan can be joined by players. FALSE for flavortext-only clans.
	var/joinable_clan = TRUE
	///Whether this clan should be in the Archive of the Kindred or not.
	var/display_in_archive = TRUE

	///How we will drink blood using Feed.
	var/blood_drink_type = BLOODSUCKER_DRINK_NORMAL

	/// A list of typepaths of powers that will never be eligible for ranks.
	var/list/banned_powers

/datum/bloodsucker_clan/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	src.bloodsuckerdatum = owner_datum

	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_ON_LIFETICK, PROC_REF(handle_clan_life))
	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_RANK_UP, PROC_REF(on_spend_rank))

	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_INTERACT_WITH_VASSAL, PROC_REF(on_interact_with_vassal))
	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_MAKE_FAVORITE, PROC_REF(on_favorite_vassal))

	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_MADE_VASSAL, PROC_REF(on_vassal_made))
	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_EXIT_TORPOR, PROC_REF(on_exit_torpor))
	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_FINAL_DEATH, PROC_REF(on_final_death))

	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_ENTERS_FRENZY, PROC_REF(on_enter_frenzy))
	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_EXITS_FRENZY, PROC_REF(on_exit_frenzy))

	give_clan_objective()
	give_starting_clan_powers()

	for(var/banned_power in banned_powers)
		var/datum/action/power = locate(banned_power) in bloodsuckerdatum.powers
		if(power)
			bloodsuckerdatum.RemovePower(power)

	SEND_SIGNAL(owner_datum.owner, COMSIG_BLOODSUCKER_CLAN_CHOSEN, owner_datum, src)

/datum/bloodsucker_clan/proc/give_starting_clan_powers()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if((initial(power.purchase_flags) & BLOODSUCKER_CAN_BUY))
			bloodsuckerdatum.BuyPower(new power)

/datum/bloodsucker_clan/Destroy(force)
	UnregisterSignal(bloodsuckerdatum, list(
		COMSIG_BLOODSUCKER_ON_LIFETICK,
		COMSIG_BLOODSUCKER_RANK_UP,
		COMSIG_BLOODSUCKER_INTERACT_WITH_VASSAL,
		COMSIG_BLOODSUCKER_MAKE_FAVORITE,
		COMSIG_BLOODSUCKER_MADE_VASSAL,
		COMSIG_BLOODSUCKER_EXIT_TORPOR,
		COMSIG_BLOODSUCKER_FINAL_DEATH,
		COMSIG_BLOODSUCKER_ENTERS_FRENZY,
		COMSIG_BLOODSUCKER_EXITS_FRENZY,
	))
	remove_clan_objective()
	bloodsuckerdatum = null
	return ..()

/datum/bloodsucker_clan/proc/on_enter_frenzy(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_bloodsucker = bloodsuckerdatum.owner.current
	if(!istype(human_bloodsucker))
		return
	human_bloodsucker.physiology.stamina_mod *= 0.4

/datum/bloodsucker_clan/proc/on_exit_frenzy(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_bloodsucker = bloodsuckerdatum.owner.current
	if(!istype(human_bloodsucker))
		return
	human_bloodsucker.set_timed_status_effect(3 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)
	human_bloodsucker.Paralyze(2 SECONDS)
	human_bloodsucker.physiology.stamina_mod /= 0.4

/datum/bloodsucker_clan/proc/give_clan_objective()
	if(isnull(clan_objective))
		return
	clan_objective = new clan_objective(null, bloodsuckerdatum.owner)
	clan_objective.objective_name = "Clan Objective"
	bloodsuckerdatum.objectives += clan_objective
	bloodsuckerdatum.owner.announce_objectives()

/datum/bloodsucker_clan/proc/remove_clan_objective()
	bloodsuckerdatum.objectives -= clan_objective
	QDEL_NULL(clan_objective)
	bloodsuckerdatum.owner.announce_objectives()

/**
 * Called when a Bloodsucker exits Torpor
 * args:
 * source - the Bloodsucker exiting Torpor
 */
/datum/bloodsucker_clan/proc/on_exit_torpor(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER

/**
 * Called when a Bloodsucker enters Final Death
 * args:
 * source - the Bloodsucker exiting Torpor
 */
/datum/bloodsucker_clan/proc/on_final_death(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER
	return FALSE

/**
 * Called during Bloodsucker's life_tick
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker running this.
 */
/datum/bloodsucker_clan/proc/handle_clan_life(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER

/**
 * Called when a Bloodsucker successfully Vassalizes someone.
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker running this.
 */
/datum/bloodsucker_clan/proc/on_vassal_made(datum/antagonist/bloodsucker/source, mob/living/user, mob/living/target)
	SIGNAL_HANDLER
	user.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, TRUE)
	target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	target.set_timed_status_effect(15 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "laugh")

/**
 * Called when a Bloodsucker successfully starts spending their Rank
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker running this.
 * target - The Vassal (if any) we are upgrading.
 * cost_rank - TRUE/FALSE on whether this will cost us a rank when we go through with it.
 * blood_cost - A number saying how much it costs to rank up.
 */
/datum/bloodsucker_clan/proc/on_spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(spend_rank), bloodsuckerdatum, target, cost_rank, blood_cost)

/datum/bloodsucker_clan/proc/spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	// Upgrade Power Prompt
	var/list/options = list()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.powers)
		if (name == CLAN_TREMERE)
			if (!(power::purchase_flags & TREMERE_CAN_BUY))
				continue
		else if (!(power::purchase_flags & BLOODSUCKER_CAN_BUY))
			continue

		if (power::purchase_flags & BLOODSUCKER_DEFAULT_POWER)
			continue
		if(power in banned_powers)
			continue
		options[power::name] = power

	if(length(options) < 1)
		to_chat(bloodsuckerdatum.owner.current, span_notice("You grow more ancient by the night!"))
	else
		// Give them the UI to upgrade a power.
		var/choice = tgui_input_list(bloodsuckerdatum.owner.current, "You have the opportunity to grow more ancient. Select a power to upgrade.[blood_cost > 0 ? " Spend [round(blood_cost, 1)] blood to advance your rank" : ""]", "Your Blood Thickens...", options)
		// Prevent Bloodsuckers from closing/reopening their coffin to spam Levels.
		if(cost_rank && bloodsuckerdatum.bloodsucker_level_unspent <= 0)
			return
		// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(bloodsuckerdatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return
		// Prevent Bloodsuckers from upgrading a power while outside of their Coffin.
		if(!istype(bloodsuckerdatum.owner.current.loc, /obj/structure/closet/crate/coffin))
			to_chat(bloodsuckerdatum.owner.current, span_warning("You must be in your Coffin to upgrade Powers."))
			return

		// Good to go - Upgrade Power!
		var/datum/action/cooldown/bloodsucker/upgraded_power = options[choice]
		upgraded_power.upgrade_power()
		bloodsuckerdatum.owner.current.balloon_alert(bloodsuckerdatum.owner.current, "upgraded [choice]!")
		to_chat(bloodsuckerdatum.owner.current, span_notice("You have upgraded [choice]!"))

	finalize_spend_rank(bloodsuckerdatum, cost_rank, blood_cost)

	//Recursively allows you to rank up multiple times (if you want) without having to open and close coffin door.
	if (bloodsuckerdatum.bloodsucker_level_unspent > 0)
		spend_rank(source, target, cost_rank, blood_cost)

/datum/bloodsucker_clan/proc/finalize_spend_rank(datum/antagonist/bloodsucker/source, cost_rank = TRUE, blood_cost)
	SHOULD_CALL_PARENT(TRUE)

	for(var/datum/action/cooldown/bloodsucker/power as anything in source.powers)
		if(power.purchase_flags & BLOODSUCKER_DEFAULT_POWER)
			power.upgrade_power()

	bloodsuckerdatum.bloodsucker_regen_rate += BLOODSUCKER_REGEN_INCREASE_ON_RANKUP
	bloodsuckerdatum.max_blood_volume += BLOODSUCKER_MAX_BLOOD_INCREASE_ON_RANKUP

	for(var/limb_slot in bloodsuckerdatum.affected_limbs)
		var/obj/item/bodypart/limb = bloodsuckerdatum.affected_limbs[limb_slot]
		if(QDELETED(limb))
			continue
		// This affects the hitting power of regular unarmed attacks and Brawn.
		limb.unarmed_damage_low += BLOODSUCKER_UNARMED_DMG_INCREASE_ON_RANKUP
		limb.unarmed_damage_high += BLOODSUCKER_UNARMED_DMG_INCREASE_ON_RANKUP

	// We're almost done - Spend your Rank now.
	bloodsuckerdatum.bloodsucker_level++
	if(cost_rank)
		bloodsuckerdatum.bloodsucker_level_unspent--
	if(blood_cost)
		bloodsuckerdatum.AddBloodVolume(-blood_cost)

	// Ranked up enough to get your true Reputation?
	if(bloodsuckerdatum.bloodsucker_level == 4)
		bloodsuckerdatum.SelectReputation(am_fledgling = FALSE, forced = TRUE)

	to_chat(bloodsuckerdatum.owner.current, span_notice("You are now a rank [bloodsuckerdatum.bloodsucker_level] Bloodsucker. \
		Your strength, feed rate, regen rate, and maximum blood capacity have all increased!"))
	bloodsuckerdatum.owner.current.playsound_local(null, 'sound/effects/pope_entry.ogg', 25, TRUE, pressure_affected = FALSE)
	bloodsuckerdatum.update_hud()

/**
 * Called when we are trying to turn someone into a Favorite Vassal
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker performing this.
 * vassaldatum - the antagonist datum of the Vassal being offered up.
 */
/datum/bloodsucker_clan/proc/on_interact_with_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(interact_with_vassal), bloodsuckerdatum, vassaldatum)

/datum/bloodsucker_clan/proc/interact_with_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	if(vassaldatum.special_type)
		to_chat(bloodsuckerdatum.owner.current, span_notice("This Vassal was already assigned a special position."))
		return FALSE
	if(!vassaldatum.owner.can_make_special(creator = bloodsuckerdatum.owner))
		to_chat(bloodsuckerdatum.owner.current, span_notice("This Vassal is unable to gain a Special rank due to innate features."))
		return FALSE

	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/antagonist/vassal/vassaldatums as anything in subtypesof(/datum/antagonist/vassal))
		if(bloodsuckerdatum.special_vassals[initial(vassaldatums.special_type)])
			continue
		options[initial(vassaldatums.name)] = vassaldatums

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(vassaldatums.hud_icon), icon_state = initial(vassaldatums.antag_hud_name))
		option.info = "[initial(vassaldatums.name)] - [span_boldnotice(initial(vassaldatums.vassal_description))]"
		radial_display[initial(vassaldatums.name)] = option

	if(!length(options))
		return

	to_chat(bloodsuckerdatum.owner.current, span_notice("You can change who this Vassal is, who are they to you?"))
	var/vassal_response = show_radial_menu(bloodsuckerdatum.owner.current, vassaldatum.owner.current, radial_display, autopick_single_option = FALSE)
	if(!vassal_response)
		return
	vassal_response = options[vassal_response]
	if(QDELETED(src) || QDELETED(bloodsuckerdatum.owner.current) || QDELETED(vassaldatum.owner.current))
		return FALSE
	vassaldatum.make_special(vassal_response)
	bloodsuckerdatum.bloodsucker_blood_volume -= 150
	return TRUE

/**
 * Called when we are successfully turn a Vassal into a Favorite Vassal
 * args:
 * bloodsuckerdatum - antagonist datum of the Bloodsucker who turned them into a Vassal.
 * vassaldatum - the antagonist datum of the Vassal being offered up.
 */
/datum/bloodsucker_clan/proc/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	SIGNAL_HANDLER
	vassaldatum.BuyPower(new /datum/action/cooldown/bloodsucker/targeted/brawn)
