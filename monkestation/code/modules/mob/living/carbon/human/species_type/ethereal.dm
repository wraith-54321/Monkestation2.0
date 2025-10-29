/datum/species/ethereal
	name = "\improper Ethereal"
	id = SPECIES_ETHEREAL
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantlungs = /obj/item/organ/internal/lungs/ethereal
	mutantstomach = /obj/item/organ/internal/stomach/ethereal
	mutanteyes = /obj/item/organ/internal/eyes/ethereal
	mutanttongue = /obj/item/organ/internal/tongue/ethereal
	mutantheart = /obj/item/organ/internal/heart/ethereal
	mutantspleen = null
	external_organs = list(
		/obj/item/organ/external/ethereal_horns = "None",
		/obj/item/organ/external/tail/ethereal = "None")
	exotic_bloodtype = /datum/blood_type/crew/ethereal
	inert_mutation = /datum/mutation/overload

	// Body temperature for ethereals is much higher then humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	temperature_homeostasis_speed = 3
	temperature_normalization_speed = 1

	siemens_coeff = 0.5 //They thrive on energy
	payday_modifier = 1
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_NOHUNGER,
		TRAIT_NO_BLOODLOSS_DAMAGE, //we handle that species-side.
		TRAIT_SPLEENLESS_METABOLISM,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/energybar
	species_language_holder = /datum/language_holder/ethereal

	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = 283 KELVIN // about 10c
	hair_color = "fixedmutcolor"
	hair_alpha = 180
	facial_hair_alpha = 180

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

	var/current_color
	var/EMPeffect = FALSE
	var/EMP_timer = null
	var/emageffect = FALSE
	var/emag_timer = null
	var/obj/effect/dummy/lighting_obj/ethereal_light
	var/default_color
	var/powermult = 1
	var/rangemult = 1
	var/flickering = FALSE
	var/currently_flickered

/datum/species/ethereal/Destroy(force)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/on_species_gain(mob/living/carbon/new_ethereal, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(new_ethereal))
		return
	var/mob/living/carbon/human/ethereal = new_ethereal
	var/datum/color_palette/generic_colors/palette = ethereal.dna.color_palettes[/datum/color_palette/generic_colors]
	default_color = palette.ethereal_color
	RegisterSignal(ethereal, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(ethereal, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	RegisterSignal(ethereal, COMSIG_ATOM_SABOTEUR_ACT, PROC_REF(on_saboteur))
	RegisterSignal(ethereal, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(on_after_attackedby))
	ethereal_light = ethereal.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	spec_updatehealth(ethereal)

	var/obj/item/organ/internal/heart/ethereal/ethereal_heart = new_ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	ethereal_heart.ethereal_color = default_color

	for(var/obj/item/bodypart/limb as anything in new_ethereal.bodyparts)
		if(limb.limb_id == SPECIES_ETHEREAL)
			limb.update_limb(is_creating = TRUE)

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/former_ethereal, datum/species/new_species, pref_load)
	UnregisterSignal(former_ethereal, COMSIG_ATOM_EMAG_ACT)
	UnregisterSignal(former_ethereal, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(former_ethereal, COMSIG_LIGHT_EATER_ACT)
	UnregisterSignal(former_ethereal, COMSIG_ATOM_SABOTEUR_ACT)
	UnregisterSignal(former_ethereal, COMSIG_ATOM_AFTER_ATTACKEDBY)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_ethereal_name()

	var/randname = ethereal_name()

	return randname

/datum/species/ethereal/randomize_features(mob/living/carbon/human/human_mob)
	var/datum/color_palette/generic_colors/palette = human_mob.dna.color_palettes[/datum/color_palette/generic_colors]
	palette.ethereal_color = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]

/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/ethereal)
	. = ..()
	var/datum/color_palette/generic_colors/palette = ethereal.dna.color_palettes[/datum/color_palette/generic_colors]
	if(!ethereal_light)
		return
	if(ethereal.stat != DEAD && !EMPeffect)
		var/healthpercent = max(ethereal.health, 0) / 100
		if(!emageffect)
			var/static/list/skin_color = rgb2num("#eda495")
			var/list/colors = rgb2num(palette.ethereal_color)
			var/list/built_color = list()
			for(var/i in 1 to 3)
				built_color += skin_color[i] + ((colors[i] - skin_color[i]) * healthpercent)
			current_color = rgb(built_color[1], built_color[2], built_color[3])
		ethereal_light.set_light_range_power_color((1 + (2 * healthpercent)) * rangemult, (1 + round(0.5 * healthpercent)) * powermult, current_color)
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = current_color
		if(flickering)
			if(currently_flickered)
				ethereal_light.set_light_on(FALSE)
			else
				ethereal_light.set_light_on(TRUE)
		else
			if(currently_flickered)
				currently_flickered = FALSE
			ethereal_light.set_light_on(TRUE)
	else
		ethereal_light.set_light_on(FALSE)
		current_color = rgb(230, 230, 230)
		fixed_mut_color = current_color
	ethereal.set_haircolor(current_color, TRUE, update = FALSE)
	ethereal.set_facial_haircolor(current_color, TRUE, update = FALSE)
	if(ethereal.organs_slot["horns"])
		var/obj/item/organ/external/horms = ethereal.organs_slot["horns"]
		horms.bodypart_overlay.draw_color = current_color
	if(ethereal.organs_slot["tail"])
		var/obj/item/organ/external/tail = ethereal.organs_slot["tail"]
		tail.bodypart_overlay.draw_color = current_color
	ethereal.update_body()

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/H, severity)
	SIGNAL_HANDLER
	EMPeffect = TRUE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel the light of your body leave you."))
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds

/datum/species/ethereal/proc/on_saboteur(datum/source, disrupt_duration)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/our_target = source
	EMPeffect = TRUE
	spec_updatehealth(our_target)
	to_chat(our_target, span_warning("Something inside of you crackles in a bad way."))
	our_target.take_bodypart_damage(burn = 3, wound_bonus = CANT_WOUND)
	addtimer(CALLBACK(src, PROC_REF(stop_emp), our_target), disrupt_duration, TIMER_UNIQUE|TIMER_OVERRIDE)
	return COMSIG_SABOTEUR_SUCCESS

/datum/species/ethereal/proc/on_emag_act(mob/living/carbon/human/H, mob/user)
	SIGNAL_HANDLER
	if(emageffect)
		return FALSE
	emageffect = TRUE
	if(user)
		to_chat(user, span_notice("You tap [H] on the back with your card."))
	H.visible_message(span_danger("[H] starts flickering in an array of colors!"))
	handle_emag(H)
	addtimer(CALLBACK(src, PROC_REF(stop_emag), H), 1 MINUTES) //Disco mode for 2 minutes! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.
	return TRUE

/// Special handling for getting hit with a light eater
/datum/species/ethereal/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	source.emp_act(EMP_LIGHT)
	return COMPONENT_BLOCK_LIGHT_EATER

/datum/species/ethereal/proc/stop_emp(mob/living/carbon/human/H)
	EMPeffect = FALSE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel more energized as your shine comes back."))


/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/H)
	if(!emageffect)
		return
	current_color = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	spec_updatehealth(H)
	addtimer(CALLBACK(src, PROC_REF(handle_emag), H), 5) //Call ourselves every 0.5 seconds to change color

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/H)
	emageffect = FALSE
	spec_updatehealth(H)
	H.visible_message(span_danger("[H] stops flickering and goes back to their normal state!"))

/datum/species/ethereal/proc/start_flicker(mob/living/carbon/human/ethereal, duration = 6 SECONDS, min = 1, max = 4)
	flickering = TRUE
	handle_flicker(ethereal, min, max)
	addtimer(CALLBACK(src, PROC_REF(stop_flicker), ethereal), duration)

/datum/species/ethereal/proc/handle_flicker(mob/living/carbon/human/ethereal, flickmin = 1, flickmax = 4)
	if(!flickering)
		currently_flickered = FALSE
		spec_updatehealth(ethereal)
		return
	if(currently_flickered)
		currently_flickered = FALSE
	else
		currently_flickered = TRUE
	spec_updatehealth(ethereal)
	addtimer(CALLBACK(src, PROC_REF(handle_flicker), ethereal), rand(1, 4))

/datum/species/ethereal/proc/stop_flicker(mob/living/carbon/human/ethereal)
	flickering = FALSE
	currently_flickered = FALSE

/datum/species/ethereal/proc/handle_glow_emote(mob/living/carbon/human/ethereal, power, range, flare = FALSE, duration = 5 SECONDS, flare_time = 0)
	powermult = power
	rangemult = range
	spec_updatehealth(ethereal)
	addtimer(CALLBACK(src, PROC_REF(stop_glow_emote), ethereal, flare, flare_time), duration)

/datum/species/ethereal/proc/stop_glow_emote(mob/living/carbon/human/ethereal, flare, flare_time)
	if(!flare)
		powermult = 1
		rangemult = 1
		spec_updatehealth(ethereal)
		return
	powermult = 0.5
	rangemult = 0.75
	spec_updatehealth(ethereal)
	start_flicker(ethereal, duration = 1.5 SECONDS, min = 1, max = 2)
	sleep(1.5 SECONDS)
	powermult = 1
	rangemult = 1
	EMPeffect = TRUE
	to_chat(ethereal, span_warning("Your shine flickers and fades."))
	addtimer(CALLBACK(src, PROC_REF(stop_emp), ethereal), flare_time, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/species/ethereal/get_features()
	var/list/features = ..()

	features += "feature_ethcolor"

	return features

/datum/species/ethereal/proc/on_after_attackedby(mob/living/lightbulb, obj/item/item, mob/living/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(!proximity_flag || !istype(user))
		return

	if(istype(item, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cig = item
		if(!cig.lit)
			cig.light()
			user.visible_message(span_notice("[user] quickly strikes [item] across [lightbulb]'s skin, [lightbulb.p_their()] warmth lighting it!"))
			return COMPONENT_NO_AFTERATTACK
		return

	if(istype(item, /obj/item/match))
		var/obj/item/match/match = item
		if(!match.lit)
			match.matchignite()
			user.visible_message(span_notice("[user] strikes [item] against [lightbulb], sparking it to life!"))
			return COMPONENT_NO_AFTERATTACK
		return
	return

/datum/species/ethereal/get_species_description()
	return "Coming from the planet of Sprout, the theocratic ethereals are \
		separated socially by caste, and espouse a dogma of aiding the weak and \
		downtrodden."

/datum/species/ethereal/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "Ethereals can feed on electricity from APCs, and do not otherwise need to eat.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Disco Ball",
			SPECIES_PERK_DESC = "Ethereals passively generate their own light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "gem",
			SPECIES_PERK_NAME = "Crystal Core",
			SPECIES_PERK_DESC = "The Ethereal's heart will encase them in crystal should they die, returning them to life after a time - \
				at the cost of a permanent brain trauma.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Elemental Attacker",
			SPECIES_PERK_DESC = "Ethereals deal burn damage with their punches instead of brute.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Starving Artist",
			SPECIES_PERK_DESC = "Ethereals take toxin damage while starving.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shield-halved",
			SPECIES_PERK_NAME = "Power(Only) Armor",
			SPECIES_PERK_DESC = "You take increased brute damage the less power you have.	",
		),
	)

	return to_add
