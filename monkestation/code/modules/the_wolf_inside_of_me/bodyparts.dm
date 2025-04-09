#define IMPL_UPDATE_SPECIES_COLOR(X) \
	/obj/item/bodypart/##X/werewolf/update_limb(dropping_limb, is_creating) { \
		if(ishuman(owner)) { \
			var/mob/living/carbon/human/wolf = owner; \
			species_color = wolf.hair_color; \
			draw_color = wolf.hair_color; \
		}; \
		return ..(); \
	}; \
	/obj/item/bodypart/##X/werewolf/set_owner(new_owner) { \
		. = ..(); \
		if(. != FALSE && ishuman(owner)) { \
			var/mob/living/carbon/human/wolf = owner; \
			species_color = wolf.hair_color; \
			draw_color = wolf.hair_color; \
		}; \
	};

///WEREWOLF
/obj/item/bodypart/head/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'monkestation/code/modules/the_wolf_inside_of_me/icons/werewolf_parts_greyscale.dmi'
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE
	burn_modifier = 0.75
	brute_modifier = 0.25
	unarmed_attack_verb = "bite"
	//grappled_attack_verb = "maul"
	unarmed_attack_effect = ATTACK_EFFECT_BITE
	unarmed_attack_sound = 'sound/weapons/bite.ogg'
	unarmed_miss_sound = 'sound/weapons/bite.ogg'
	unarmed_damage_low = 60
	unarmed_damage_high = 75
	//unarmed_effectiveness = 50
	dmg_overlay_type = null
	biological_state = BIO_FLESH|BIO_BLOODED
	head_flags = HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_HAIR

IMPL_UPDATE_SPECIES_COLOR(head)

/obj/item/bodypart/chest/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'monkestation/code/modules/the_wolf_inside_of_me/icons/werewolf_parts_greyscale.dmi'
	is_dimorphic = TRUE
	should_draw_greyscale = TRUE
	burn_modifier = 0.75
	brute_modifier = 0.25
	dmg_overlay_type = null
	biological_state = BIO_FLESH|BIO_BLOODED
	bodypart_traits = list(TRAIT_NO_JUMPSUIT, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE)
	wing_types = null
	acceptable_bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

IMPL_UPDATE_SPECIES_COLOR(chest)

/obj/item/bodypart/arm/left/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'monkestation/code/modules/the_wolf_inside_of_me/icons/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	unarmed_attack_verb = "slash"
	//grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	unarmed_damage_low = 20
	unarmed_damage_high = 25
	//unarmed_effectiveness = 20
	burn_modifier = 0.75
	brute_modifier = 0.25
	dmg_overlay_type = null
	hand_traits = list(TRAIT_CHUNKYFINGERS)
	biological_state = BIO_FLESH|BIO_BLOODED

IMPL_UPDATE_SPECIES_COLOR(arm/left)

/obj/item/bodypart/arm/right/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'monkestation/code/modules/the_wolf_inside_of_me/icons/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	unarmed_attack_verb = "slash"
	//grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	unarmed_damage_low = 20
	unarmed_damage_high = 25
	//unarmed_effectiveness = 20
	burn_modifier = 0.75
	brute_modifier = 0.25
	dmg_overlay_type = null
	hand_traits = list(TRAIT_CHUNKYFINGERS)
	biological_state = BIO_FLESH|BIO_BLOODED

IMPL_UPDATE_SPECIES_COLOR(arm/right)

/obj/item/bodypart/leg/left/werewolf
	limb_id = SPECIES_WEREWOLF
	digitigrade_id = SPECIES_WEREWOLF
	icon_greyscale = 'monkestation/code/modules/the_wolf_inside_of_me/icons/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	burn_modifier = 0.75
	brute_modifier = 0.25
	speed_modifier = 3
	dmg_overlay_type = null
	//footstep_type = FOOTSTEP_MOB_CLAW
	biological_state = BIO_FLESH|BIO_BLOODED

IMPL_UPDATE_SPECIES_COLOR(leg/left)

/obj/item/bodypart/leg/right/werewolf
	limb_id = SPECIES_WEREWOLF
	digitigrade_id = SPECIES_WEREWOLF
	icon_greyscale = 'monkestation/code/modules/the_wolf_inside_of_me/icons/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	burn_modifier = 0.75
	brute_modifier = 0.25
	speed_modifier = 3
	dmg_overlay_type = null
	//footstep_type = FOOTSTEP_MOB_CLAW
	biological_state = BIO_FLESH|BIO_BLOODED

IMPL_UPDATE_SPECIES_COLOR(leg/right)

#undef IMPL_UPDATE_SPECIES_COLOR
