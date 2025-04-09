/obj/item/organ/external/goblin_ears
	name = "goblin ears"
	desc = "They don't actually let you hear better."
	icon_state = "goblin_ears"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_goblin_ears"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/goblin_ears

/datum/bodypart_overlay/mutant/goblin_ears
	layers = EXTERNAL_ADJACENT | EXTERNAL_FRONT
	feature_key = "goblin_ears"

/datum/bodypart_overlay/mutant/goblin_ears/get_global_feature_list()
	return GLOB.goblin_ears_list

/datum/bodypart_overlay/mutant/goblin_ears/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/goblin_ears/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

/obj/item/organ/external/goblin_nose
	name = "goblin nose"
	desc = "It doesn't actually let you smell better."
	icon_state = "goblin_nose"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_goblin_nose"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/goblin_nose

/datum/bodypart_overlay/mutant/goblin_nose
	layers = EXTERNAL_ADJACENT | EXTERNAL_FRONT
	feature_key = "goblin_nose"

/datum/bodypart_overlay/mutant/goblin_nose/get_global_feature_list()
	return GLOB.goblin_nose_list

/datum/bodypart_overlay/mutant/goblin_nose/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/goblin_nose/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE
