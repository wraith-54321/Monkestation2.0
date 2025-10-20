///How much Blood it costs to live.
#define BLOODSUCKER_PASSIVE_BLOOD_DRAIN 0.1

/// Runs from COMSIG_LIVING_LIFE, handles Bloodsucker constant proccesses.
/datum/antagonist/bloodsucker/proc/life_tick(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(isbrain(owner?.current))
		return
	if(QDELETED(owner))
		INVOKE_ASYNC(src, PROC_REF(handle_death))
		return
	if(is_in_torpor())
		check_end_torpor()
	// Deduct Blood
	if(owner.current.stat == CONSCIOUS && !HAS_TRAIT(owner.current, TRAIT_IMMOBILIZED) && !is_in_torpor())
		INVOKE_ASYNC(src, PROC_REF(AddBloodVolume), -BLOODSUCKER_PASSIVE_BLOOD_DRAIN) // -.1 currently
	if(HandleHealing())
		if((COOLDOWN_FINISHED(src, bloodsucker_spam_healing)) && bloodsucker_blood_volume > 0)
			to_chat(owner.current, span_notice("The power of your blood begins knitting your wounds..."))
			COOLDOWN_START(src, bloodsucker_spam_healing, BLOODSUCKER_SPAM_HEALING)
	// Standard Updates

	SEND_SIGNAL(src, COMSIG_BLOODSUCKER_ON_LIFETICK)
	INVOKE_ASYNC(src, PROC_REF(update_hud))

/datum/antagonist/bloodsucker/proc/handle_blood()
	SIGNAL_HANDLER
	update_blood()
	handle_starving()
	return HANDLE_BLOOD_NO_NUTRITION_DRAIN | HANDLE_BLOOD_NO_EFFECTS

/datum/antagonist/bloodsucker/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(source.stat != DEAD) // weirdness shield
		return
	INVOKE_ASYNC(src, PROC_REF(handle_death))

/**
 * ## BLOOD STUFF
 */
/datum/antagonist/bloodsucker/proc/AddBloodVolume(value)
	bloodsucker_blood_volume = clamp(bloodsucker_blood_volume + value, 0, max_blood_volume * 2)
	blood_over_cap = max(bloodsucker_blood_volume - max_blood_volume, 0) // Gets how much blood we have over the cap.

/datum/antagonist/bloodsucker/proc/AddHumanityLost(value)
	if(humanity_lost >= 500)
		to_chat(owner.current, span_warning("You hit the maximum amount of lost Humanty, you are far from Human."))
		return
	humanity_lost += value
	to_chat(owner.current, span_warning("You feel as if you lost some of your humanity, you will now enter Frenzy at [FRENZY_THRESHOLD_ENTER + (humanity_lost * 5)] Blood."))

/// mult: SILENT feed is 1/3 the amount
/datum/antagonist/bloodsucker/proc/handle_feeding(mob/living/carbon/target, mult=1, power_level)
	// Starts at 15 (now 8 since we doubled the Feed time)
	var/feed_amount = 15 + (power_level * 2)
	var/blood_taken = min(feed_amount, target.blood_volume) * mult
	target.blood_volume -= blood_taken

	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	owner.current.bodytemperature = ((bloodsucker_blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (bloodsucker_blood_volume + blood_taken)
	// our volume * temp, + their volume * temp, / total volume
	///////////
	// Reduce Value Quantity
	if(target.stat == DEAD) // Penalty for Dead Blood
		blood_taken /= 3
	if(!ishuman(target)) // Penalty for Non-Human Blood
		blood_taken /= 2
	//if (!iscarbon(target)) // Penalty for Animals (they're junk food)
	// Apply to Volume
	AddBloodVolume(blood_taken)
	OverfeedHealing(blood_taken)
	// Reagents (NOT Blood!)
	if(target.reagents?.total_volume)
		target.reagents.trans_to(owner.current, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', vol = 40, vary = TRUE) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
	total_blood_drank += blood_taken
	if(target.mind) // Checks if the target has a mind
		if(IS_VASSAL(target)) // Checks if the target is a vassal
			blood_level_gain += blood_taken / 4
		else
			blood_level_gain += blood_taken
	return blood_taken

/**
 * ## HEALING
 */

/// Constantly runs on Bloodsucker's life_tick, and is increased by being in Torpor/Coffins
/datum/antagonist/bloodsucker/proc/HandleHealing(mult = 1)
	if(QDELETED(owner?.current))
		return
	var/in_torpor = is_in_torpor()
	// Don't heal if I'm staked or on Masquerade (+ not in a Coffin). Masqueraded Bloodsuckers in a Coffin however, will heal.
	if(owner.current.am_staked())
		return FALSE
	if(!in_torpor && (HAS_TRAIT(owner.current, TRAIT_MASQUERADE) || owner.current.has_status_effect(/datum/status_effect/bloodsucker_sol)))
		return FALSE
	var/in_coffin = istype(owner.current.loc, /obj/structure/closet/crate/coffin)
	var/actual_regen = bloodsucker_regen_rate + additional_regen
	owner.current.adjustCloneLoss(-1 * (actual_regen * 4) * mult)
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (actual_regen * 4) * mult) //adjustBrainLoss(-1 * (actual_regen * 4) * mult, 0)
	if(in_coffin && in_torpor) // if we're in a coffin, in torpor, stabilize our body temperature.
		owner.current.update_homeostasis_level(type, owner.current.standard_body_temperature, 10 KELVIN)
	if(!iscarbon(owner.current)) // Damage Heal: Do I have damage to ANY bodypart?
		return
	var/mob/living/carbon/user = owner.current
	var/costMult = 1 // Coffin makes it cheaper
	var/bruteheal = min(user.getBruteLoss_nonProsthetic(), actual_regen) // BRUTE: Always Heal
	var/fireheal = 0 // BURN: Heal in Coffin while Fakedeath, or when damage above maxhealth (you can never fully heal fire)
	// Checks if you're in a coffin here, additionally checks for Torpor right below it.
	if (blood_over_cap > 0)
		costMult += round(blood_over_cap / 1000, 0.1) // effectively 1 (normal) + 0.1 for every 100 blood you are over cap
	if(in_torpor)
		if(in_coffin)
			if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && (COOLDOWN_FINISHED(src, bloodsucker_spam_healing)))
				to_chat(user, span_alert("You do not heal while your Masquerade ability is active."))
				COOLDOWN_START(src, bloodsucker_spam_healing, BLOODSUCKER_SPAM_MASQUERADE)
				return
			fireheal = min(user.getFireLoss_nonProsthetic(), actual_regen)
			mult *= 5 // Increase multiplier if we're sleeping in a coffin.
			costMult /= 2 // Decrease cost if we're sleeping in a coffin.
			user.extinguish_mob()
			user.remove_all_embedded_objects() // Remove Embedded!
			if(check_limbs(costMult))
				return TRUE
		// In Torpor, but not in a Coffin? Heal faster anyways.
		else
			fireheal = min(user.getFireLoss_nonProsthetic(), actual_regen) / 1.2 // 20% slower than being in a coffin
			mult *= 3
	// Heal if Damaged
	if((bruteheal + fireheal > 0) && mult > 0) // Just a check? Don't heal/spend, and return.
		// We have damage. Let's heal (one time)
		user.heal_overall_damage(brute = bruteheal * mult, burn = fireheal * mult) // Heal BRUTE / BURN in random portions throughout the body.
		AddBloodVolume(((bruteheal * -0.5) + (fireheal * -1)) * costMult * mult) // Costs blood to heal
		return TRUE

// Manages healing if we are exceeding blood cap
/datum/antagonist/bloodsucker/proc/OverfeedHealing(drunk_blood)
	var/mob/living/carbon/user = owner.current
	if(blood_over_cap > 0) //Checks if you are over your blood cap
		var/overbruteheal = user.getBruteLoss_nonProsthetic()
		var/overfireheal = user.getFireLoss_nonProsthetic()
		var/heal_amount = drunk_blood / 3
		if(overbruteheal > 0 && heal_amount > 0)
			user.adjustBruteLoss(-heal_amount, forced=TRUE) // Heal BRUTE / BURN in random portions throughout the body; prioritising BRUTE.
			heal_amount = (heal_amount - overbruteheal) // Removes the amount of BRUTE we've healed from the heal amount
		else if(overfireheal > 0 && heal_amount > 0)
			heal_amount /= 1.5 // Burn should be more difficult to heal
			user.adjustFireLoss(-heal_amount, forced=TRUE)

/datum/antagonist/bloodsucker/proc/check_limbs(costMult = 1)
	var/limb_regen_cost = 50 * -costMult
	var/mob/living/carbon/user = owner.current
	var/list/missing = user.get_missing_limbs()
	if(length(missing) && (bloodsucker_blood_volume < limb_regen_cost + 5))
		return FALSE
	for(var/missing_limb in missing) //Find ONE Limb and regenerate it.
		user.regenerate_limb(missing_limb, FALSE)
		if(missing_limb == BODY_ZONE_HEAD)
			ensure_brain_nonvital()
		AddBloodVolume(-limb_regen_cost)
		var/obj/item/bodypart/missing_bodypart = user.get_bodypart(missing_limb) // 2) Limb returns Damaged
		missing_bodypart.brute_dam = 60
		to_chat(user, span_notice("Your flesh knits as it regrows your [missing_bodypart]!"))
		playsound(user, 'sound/magic/demon_consume.ogg', vol = 50, vary = TRUE)
		return TRUE

/*
 *	# Heal Vampire Organs
 *
 *	This is used by Bloodsuckers, these are the steps of this proc:
 *	Step 1 - Cure husking and Regenerate organs. regenerate_organs() removes their Vampire Heart & Eye augments, which leads us to...
 *	Step 2 - Repair any (shouldn't be possible) Organ damage, then return their Vampiric Heart & Eye benefits.
 *	Step 3 - Revive them, clear all wounds, remove any Tumors (If any).
 *
 *	This is called on Bloodsucker's Assign, and when they end Torpor.
 */

/datum/antagonist/bloodsucker/proc/heal_vampire_organs(mob/living/carbon/mob_override)
	var/mob/living/carbon/bloodsuckeruser = mob_override || owner.current
	if(!iscarbon(bloodsuckeruser))
		return

	bloodsuckeruser.cure_husk()
	bloodsuckeruser.regenerate_organs(regenerate_existing = FALSE)
	ensure_brain_nonvital()

	for(var/obj/item/organ/organ as anything in bloodsuckeruser.organs)
		organ.set_organ_damage(0)
	bloodsuckeruser.cure_all_traumas(TRAUMA_RESILIENCE_MAGIC) // i think vampires ARE magic, so, yeah
	if(!HAS_TRAIT(bloodsuckeruser, TRAIT_MASQUERADE))
		var/obj/item/organ/internal/heart/current_heart = bloodsuckeruser.get_organ_slot(ORGAN_SLOT_HEART)
		current_heart?.beating = FALSE
	var/obj/item/organ/internal/eyes/current_eyes = bloodsuckeruser.get_organ_slot(ORGAN_SLOT_EYES)
	if(current_eyes)
		current_eyes.flash_protect = max(initial(current_eyes.flash_protect) - 1, FLASH_PROTECTION_SENSITIVE)
		current_eyes.lighting_cutoff = LIGHTING_CUTOFF_HIGH
		current_eyes.color_cutoffs = list(25, 8, 5)
		current_eyes.sight_flags |= SEE_MOBS
	bloodsuckeruser.update_sight()

	if(bloodsuckeruser.stat == DEAD)
		bloodsuckeruser.revive(revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	for(var/datum/wound/iter_wound as anything in bloodsuckeruser.all_wounds)
		iter_wound.remove_wound()
	for(var/obj/item/organ/organ as anything in typecache_filter_list(bloodsuckeruser.organs, yucky_organ_typecache))
		organ.Remove(bloodsuckeruser)
		organ.forceMove(bloodsuckeruser.drop_location())

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			DEATH

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// A wrapper around final death code, to prevent multiple calls,
/// and to ensure any sort of weird runtimes won't result in [handling_death] being broken.
/datum/antagonist/bloodsucker/proc/handle_death()
	if(handling_death)
		return
	handling_death = TRUE
	do_handle_death()
	handling_death = FALSE

/// FINAL DEATH.
/// Don't call this directly, use handle_death().
/datum/antagonist/bloodsucker/proc/do_handle_death()
	// Not "Alive"?
	if(QDELETED(owner.current))
		final_death()
		return
	// Fire Damage? (above double health)
	if(owner.current.getFireLoss() >= (owner.current.maxHealth * 2.5))
		final_death()
		return
	// Staked while "Temp Death" or Asleep
	if(owner.current.StakeCanKillMe() && owner.current.am_staked())
		final_death()
		return
	// Temporary Death? Convert to Torpor.
	if(is_in_torpor())
		return
	to_chat(owner.current, span_userdanger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
	check_begin_torpor(TRUE)

/datum/antagonist/bloodsucker/proc/handle_starving() // I am thirsty for blood!
	// Nutrition - The amount of blood is how full we are.
	owner.current.set_nutrition(min(bloodsucker_blood_volume, NUTRITION_LEVEL_FED))

	// BLOOD_VOLUME_GOOD: [336] - Pale
//	handled in bloodsucker_integration.dm

	// BLOOD_VOLUME_EXIT: [250] - Exit Frenzy (If in one) This is high because we want enough to kill the poor soul they feed off of.
	if(bloodsucker_blood_volume >= FRENZY_THRESHOLD_EXIT && frenzied)
		owner.current.remove_status_effect(/datum/status_effect/frenzy)
	// BLOOD_VOLUME_BAD: [224] - Jitter
	if(bloodsucker_blood_volume < BLOOD_VOLUME_BAD && prob(0.5) && !is_in_torpor() && !HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		owner.current.set_timed_status_effect(3 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	// BLOOD_VOLUME_SURVIVE: [122] - Blur Vision
	if(bloodsucker_blood_volume < BLOOD_VOLUME_SURVIVE)
		owner.current.set_eye_blur_if_lower((8 - 8 * (bloodsucker_blood_volume / BLOOD_VOLUME_BAD))*2 SECONDS)

	// The more blood, the better the Regeneration, get too low blood, and you enter Frenzy.
	if(bloodsucker_blood_volume < (FRENZY_THRESHOLD_ENTER + (humanity_lost * 5)) && !frenzied && COOLDOWN_FINISHED(src, bloodsucker_frenzy_cooldown))
		owner.current.apply_status_effect(/datum/status_effect/frenzy)
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_BAD)
		additional_regen = 0.1
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_OKAY)
		additional_regen = 0.2
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_NORMAL)
		additional_regen = 0.3
	else if(bloodsucker_blood_volume < BS_BLOOD_VOLUME_MAX_REGEN)
		additional_regen = 0.4
	else if(bloodsucker_blood_volume < max_blood_volume)
		additional_regen = 0.5
	else if(bloodsucker_blood_volume > max_blood_volume)
		additional_regen = 1 + round((blood_over_cap / 1000) * 2, 0.1)
		AddBloodVolume(-1 - blood_over_cap / 100)

/// Makes your blood_volume look like your bloodsucker blood, unless you're Masquerading.
/datum/antagonist/bloodsucker/proc/update_blood()
	if(HAS_TRAIT(owner.current, TRAIT_NOBLOOD))
		return
	//If we're on Masquerade, we appear to have full blood, unless we are REALLY low, in which case we don't look as bad.
	if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		switch(bloodsucker_blood_volume)
			if(BLOOD_VOLUME_OKAY to INFINITY) // 336 and up, we are perfectly fine.
				owner.current.blood_volume = initial(bloodsucker_blood_volume)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY) // 224 to 336
				owner.current.blood_volume = BLOOD_VOLUME_SAFE
			else // 224 and below
				owner.current.blood_volume = BLOOD_VOLUME_OKAY
		return

	owner.current.blood_volume = bloodsucker_blood_volume

/// Gibs the Bloodsucker, roundremoving them.
/datum/antagonist/bloodsucker/proc/final_death()
	// If we have no body, end here.
	if(QDELETED(owner.current))
		return
	UnregisterSignal(owner.current, list(
		COMSIG_LIVING_LIFE,
		COMSIG_ATOM_EXAMINE,
		COMSIG_LIVING_DEATH,
		COMSIG_MOVABLE_MOVED,
		COMSIG_HUMAN_ON_HANDLE_BLOOD,
	))
	UnregisterSignal(SSsol, list(
		COMSIG_SOL_RANKUP_BLOODSUCKERS,
		COMSIG_SOL_NEAR_START,
		COMSIG_SOL_END,
		COMSIG_SOL_RISE_TICK,
		COMSIG_SOL_WARNING_GIVEN,
	))
	final_death = TRUE
	free_all_vassals()
	DisableAllPowers(forced = TRUE)
	if(!iscarbon(owner.current))
		owner.current.gib(TRUE, FALSE, FALSE)
		return
	// Drop anything in us and play a tune
	var/mob/living/carbon/user = owner.current
	owner.current.drop_all_held_items()
	owner.current.unequip_everything()
	user.remove_all_embedded_objects()
	playsound(owner.current, 'sound/effects/tendril_destroyed.ogg', vol = 40, vary = TRUE)

	if(SEND_SIGNAL(src, COMSIG_BLOODSUCKER_FINAL_DEATH) & DONT_DUST)
		return

	// Elders get dusted, Fledglings get gibbed.
	if(bloodsucker_level >= 4)
		user.visible_message(
			span_warning("[user]'s skin crackles and dries, their skin and bones withering to dust. A hollow cry whips from what is now a sandy pile of remains."),
			span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
			span_hear("You hear a dry, crackling sound."))
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dust)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
		return
	user.visible_message(
		span_warning("[user]'s skin bursts forth in a spray of gore and detritus. A horrible cry echoes from what is now a wet pile of decaying meat."),
		span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
		span_hear("<span class='italics'>You hear a wet, bursting sound."))
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, gib), TRUE, FALSE, FALSE), 2 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/antagonist/bloodsucker/proc/oozeling_revive(obj/item/organ/internal/brain/slime/oozeling_core)
	var/mob/living/carbon/human/new_body = oozeling_core.rebuild_body(nugget = FALSE, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	heal_vampire_organs(new_body)

#undef BLOODSUCKER_PASSIVE_BLOOD_DRAIN
