#define DAMAGE_WATER_STACKS 5
#define REGEN_WATER_STACKS 1
#define HEALTH_HEALED 2.5

/datum/species/oozeling
	name = "\improper Oozeling"
	plural_form = "Oozelings"
	id = SPECIES_OOZELING
	examine_limb_id = SPECIES_OOZELING
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	hair_color = "mutcolor"
	hair_alpha = 160

	mutantliver = /obj/item/organ/internal/liver/slime
	mutantstomach = /obj/item/organ/internal/stomach/slime
	mutantbrain = /obj/item/organ/internal/brain/slime
	mutantears = /obj/item/organ/internal/ears/jelly
	mutantlungs = /obj/item/organ/internal/lungs/slime
	mutanttongue = /obj/item/organ/internal/tongue/jelly
	mutantheart = /obj/item/organ/internal/heart/slime
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_SPLEENLESS_METABOLISM,
		TRAIT_FOOD_ABSORPTION,
	)

	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_bloodtype = /datum/blood_type/slime
	inert_mutation = /datum/mutation/acid_touch
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	inherent_factions = list(FACTION_SLIME) //an oozeling wont be eaten by their brethren
	species_language_holder = /datum/language_holder/oozeling
	//swimming_component = /datum/component/swimming/dissolve

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/oozeling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/oozeling,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/oozeling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/oozeling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/oozeling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/oozeling,
	)

	/// Typepaths of the default oozeling actions to give.
	var/static/list/default_actions = list(
		/datum/action/cooldown/slime_washing,
		/datum/action/cooldown/slime_hydrophobia,
		/datum/action/innate/core_signal,
	)
	/// Typepaths of extra actions to give to all oozelings.
	var/list/extra_actions = list()
	/// Instances of all actions given to this oozeling.
	var/list/actions_given = list()
	/// Cooldown for balloon alerts when being melted from water exposure.
	COOLDOWN_DECLARE(water_alert_cooldown)
	/// Cooldown for balloon alerts when being melted from starvation.
	COOLDOWN_DECLARE(starvation_alert_cooldown)
	/// Cooldown for balloon alerts when being melted from being dripping wet.
	COOLDOWN_DECLARE(wet_alert_cooldown)


/datum/species/oozeling/Destroy(force)
	QDEL_LIST(actions_given)
	return ..()

/datum/species/oozeling/on_species_gain(mob/living/carbon/slime, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(slime, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_reagent_expose))
	for(var/action_type in default_actions + extra_actions)
		var/datum/action/action = new action_type(src)
		action.Grant(slime)
		actions_given += action
	// oozelings will always start at least fed, so they don't have to immediately eat to avoid melting
	if(pref_load && slime.nutrition < NUTRITION_LEVEL_FED)
		slime.set_nutrition(rand(NUTRITION_LEVEL_FED, NUTRITION_LEVEL_START_MAX))

/datum/species/oozeling/on_species_loss(mob/living/carbon/human/former_slime, datum/species/new_species, pref_load)
	UnregisterSignal(former_slime, COMSIG_ATOM_EXPOSE_REAGENTS)
	QDEL_LIST(actions_given)
	. = ..()
	former_slime.blood_volume = clamp(former_slime.blood_volume, BLOOD_VOLUME_SAFE, BLOOD_VOLUME_NORMAL)

/datum/species/oozeling/get_species_description()
	return "A species of sentient semi-solids. \
		They require nutriment in order to maintain their body mass."

/datum/species/oozeling/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.oozeling_first_names)]"
	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.oozeling_last_names)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

//////
/// HEALING SECTION
/// Handles passive healing and water damage.

/datum/species/oozeling/spec_life(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	. = ..()
	if(HAS_TRAIT(slime, TRAIT_GODMODE) || slime.blood_volume <= 0)
		return
	if(!HAS_TRAIT(slime, TRAIT_NOHUNGER) && slime.nutrition <= NUTRITION_LEVEL_HUNGRY && !IS_BLOODSUCKER(slime)) // bloodsuckers have snowflake nutrition handling
		spec_slime_hunger(slime, seconds_per_tick)
	if(!HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA))
		spec_slime_wetness(slime, seconds_per_tick)

/// Handles slimes losing blood from having wet stacks.
/datum/species/oozeling/proc/spec_slime_wetness(mob/living/carbon/human/slime, seconds_per_tick)
	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in slime.status_effects // locate should be slightly faster in theory, as this has no subtypes hopefully, so we don't need to check ids
	if(!wetness)
		return

	if(wetness.stacks > DAMAGE_WATER_STACKS)
		remove_blood_volume(slime, 2 * seconds_per_tick)
		slime.balloon_alert(slime, "too wet, dry off!")
		if(SPT_PROB(25, seconds_per_tick))
			slime.visible_message(span_danger("[slime]'s form begins to lose cohesion, seemingly diluting with the water!"), span_warning("The water starts to dilute your body, dry it off!"))
	else if(wetness.stacks > REGEN_WATER_STACKS && SPT_PROB(25, seconds_per_tick)) //Used for old healing system. Maybe use later? For now increase loss for being soaked.
		to_chat(slime, span_warning("You can't pull your body together, it is dripping wet!"))
		remove_blood_volume(slime, seconds_per_tick)
		slime.balloon_alert(slime, "you're dripping wet!")

/// Handles slimes losing blood from starving.
/datum/species/oozeling/proc/spec_slime_hunger(mob/living/carbon/human/slime, seconds_per_tick)
	// don't bother with using remove_blood_volume as this doesn't proc for bloodsuckers anyways
	if(slime.nutrition <= NUTRITION_LEVEL_STARVING)
		slime.blood_volume = max(slime.blood_volume - (4 * seconds_per_tick), 0)
		if(COOLDOWN_FINISHED(src, starvation_alert_cooldown))
			to_chat(slime, span_danger("You're starving! Get some food!"))
			slime.balloon_alert(slime, "you're starving!")
			COOLDOWN_START(src, starvation_alert_cooldown, 10 SECONDS)
	else
		if(SPT_PROB(17.5, seconds_per_tick))
			slime.blood_volume = max(slime.blood_volume - seconds_per_tick, 0)
			if(COOLDOWN_FINISHED(src, starvation_alert_cooldown))
				to_chat(slime, span_warning("You're feeling pretty hungry..."))
				slime.balloon_alert(slime, "you're pretty hungry...")
				COOLDOWN_START(src, starvation_alert_cooldown, 10 SECONDS)

/// Stupid workaround proc so that bloodsucker oozelings also have their blood volume removed
/datum/species/oozeling/proc/remove_blood_volume(mob/living/carbon/human/slime, amount)
	if(!IS_FINITE(amount))
		CRASH("Tried to remove non-finite amount of blood from an oozeling")
	var/datum/antagonist/bloodsucker/slimesucker = IS_BLOODSUCKER(slime)
	if(slimesucker)
		slimesucker.AddBloodVolume(-amount)
	else
		slime.blood_volume = max(slime.blood_volume - amount, 0)

///////
/// CHEMICAL HANDLING
/// Here's where slimes heal off plasma and where they hate drinking water.

// values shamelessly stolen from `get_insulation()`
#define WATER_PROTECTION_HEAD 0.3
#define WATER_PROTECTION_CHEST 0.2
#define WATER_PROTECTION_GROIN 0.1
#define WATER_PROTECTION_LEG (0.075 * 2)
#define WATER_PROTECTION_FOOT (0.025 * 2)
#define WATER_PROTECTION_ARM (0.075 * 2)
#define WATER_PROTECTION_HAND (0.025 * 2)

/// Multiplier for how much blood is lost when sprayed with water.
/datum/species/oozeling/proc/water_damage_multiplier(mob/living/carbon/human/slime)
	. = 1

	var/protection_flags = NONE
	for(var/obj/item/clothing/worn in slime.get_equipped_items())
		if(worn.clothing_flags & THICKMATERIAL)
			protection_flags |= worn.body_parts_covered

	if(protection_flags)
		if(protection_flags & HEAD)
			. -= WATER_PROTECTION_HEAD
		if(protection_flags & CHEST)
			. -= WATER_PROTECTION_CHEST
		if(protection_flags & GROIN)
			. -= WATER_PROTECTION_GROIN
		if(protection_flags & LEGS)
			. -= WATER_PROTECTION_LEG
		if(protection_flags & FEET)
			. -= WATER_PROTECTION_FOOT
		if(protection_flags & ARMS)
			. -= WATER_PROTECTION_ARM
		if(protection_flags & HANDS)
			. -= WATER_PROTECTION_HAND

	return clamp(FLOOR(., 0.1), 0, 1)

#undef WATER_PROTECTION_HEAD
#undef WATER_PROTECTION_CHEST
#undef WATER_PROTECTION_GROIN
#undef WATER_PROTECTION_LEG
#undef WATER_PROTECTION_FOOT
#undef WATER_PROTECTION_ARM
#undef WATER_PROTECTION_HAND

/datum/species/oozeling/proc/on_reagent_expose(mob/living/carbon/human/slime, list/reagents, datum/reagents/source, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	if(!(locate(/datum/reagent/water) in reagents)) // we only care if we're exposed to water (duh)
		return NONE
	if(HAS_TRAIT(slime, TRAIT_GODMODE)) // we're [title card]
		return NONE
	// thick clothing won't protect you if you just drink or inject tho
	var/check_clothes = methods & ~(INGEST|INJECT)
	if(!water_exposure(slime, check_clothes))
		return COMPONENT_NO_EXPOSE_REAGENTS
	return NONE

/datum/species/oozeling/handle_chemical(datum/reagent/chem, mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	// slimes use plasma to fix wounds, and if they have enough blood, organs
	var/static/list/organs_we_mend = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
	)
	if(chem.type == /datum/reagent/toxin/plasma || chem.type == /datum/reagent/toxin/hot_ice)
		var/brute_damage = slime.get_current_damage_of_type(damagetype = BRUTE)
		var/burn_damage = slime.get_current_damage_of_type(damagetype = BURN)
		var/remaining_heal = HEALTH_HEALED
		if(brute_damage + burn_damage > 0)
			if(!HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA) && slime.get_skin_temperature() > slime.bodytemp_cold_damage_limit)
				// Make sure to double check this later.
				remaining_heal -= abs(slime.heal_damage_type(rand(0, remaining_heal) * REM * seconds_per_tick, BRUTE))
				slime.heal_damage_type(remaining_heal * REM * seconds_per_tick, BURN)
				slime.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
			else
				to_chat(slime, span_purple("Your membrane is too viscous to mend its wounds..."))
		if(slime.blood_volume > BLOOD_VOLUME_SLIME_SPLIT)
			slime.adjustOrganLoss(
				pick(organs_we_mend),
				-2 * seconds_per_tick,
			)
		if(SPT_PROB(5, seconds_per_tick))
			to_chat(slime, span_purple("Your body's thirst for plasma is quenched, your inner and outer membrane using it to regenerate."))

	else if(chem.type == /datum/reagent/water)
		if(HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA) || HAS_TRAIT(slime, TRAIT_GODMODE) || slime.blood_volume <= 0)
			return ..()

		remove_blood_volume(slime, 3 * seconds_per_tick)
		chem.holder?.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
		if(SPT_PROB(25, seconds_per_tick))
			to_chat(slime, span_warning("The water starts to weaken and adulterate your insides!"))

		return TRUE

	return ..()

/datum/species/oozeling/proc/water_exposure(mob/living/carbon/human/slime, check_clothes = TRUE, quiet_if_protected = FALSE)
	var/water_multiplier = 1
	// thick clothing won't protect you if you just drink or inject tho
	if(check_clothes)
		// if all your limbs are covered by thickmaterial clothing, then it will protect you from water.
		water_multiplier = water_damage_multiplier(slime)
		if(water_multiplier <= 0)
			if(!quiet_if_protected)
				to_chat(slime, span_warning("The water fails to penetrate your thick clothing!"))
			return FALSE
	if(HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA))
		if(!quiet_if_protected)
			to_chat(slime, span_warning("Water splashes against your oily membrane and rolls right off your body!"))
		return FALSE
	remove_blood_volume(slime, 30 * water_multiplier)
	if(COOLDOWN_FINISHED(src, water_alert_cooldown))
		slime.visible_message(
			span_warning("[slime]'s form melts away from the water!"),
			span_danger("The water causes you to melt away!"),
		)
		slime.balloon_alert(slime, "water melts you!")
		COOLDOWN_START(src, water_alert_cooldown, 1 SECONDS)
	return TRUE

/datum/species/oozeling/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Plasma Respiration",
			SPECIES_PERK_DESC = "[plural_form] can breathe plasma, and restore blood by doing so.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "Incombustible",
			SPECIES_PERK_DESC = "[plural_form] cannot be set aflame.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Fire Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to flames, and burn damage.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-shield",
			SPECIES_PERK_NAME = "Soft Landing",
			SPECIES_PERK_DESC = "[plural_form] body allows them to safely land on the ground after a long fall.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Limb Manipulation",
			SPECIES_PERK_DESC = "[plural_form] are able to consume and regrow their limbs at will, if they have enough blood to do so.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Anaerobic Lineage",
			SPECIES_PERK_DESC = "[plural_form] don't require much oxygen to live."
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Self-Consumption",
			SPECIES_PERK_DESC = "Once hungry enough, [plural_form] will begin to consume their own blood and limbs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Water Soluble",
			SPECIES_PERK_DESC = "[plural_form] will dissolve away when in contact with water.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Oozeling Biology",
			SPECIES_PERK_DESC = "[plural_form] take specialized medical knowledge to be \
				treated. Do not expect speedy revival, if you are lucky enough to get \
				one at all.",
		),
	)

	return to_add
