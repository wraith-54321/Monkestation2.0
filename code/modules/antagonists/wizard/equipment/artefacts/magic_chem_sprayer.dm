/obj/item/reagent_containers/spray/chemsprayer/magical
	name = "Magical Chem Sprayer"
	desc = "Simply hit the button on the side and this will instantly be filled with a new reagent! Warning: User not immune to effects."
	icon_state = "chemsprayer_janitor"
	inhand_icon_state = "chemsprayer_janitor"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	reagent_flags = NONE
	volume = 2000
	possible_transfer_amounts = list() //we dont want this to change transfer amounts
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/spray/chemsprayer/magical/attack_self(mob/user)
	reagents.clear_reagents()
	var/selected_reagent = get_random_reagent_id_unrestricted()
	while(ispath(selected_reagent, /datum/reagent/consumable) && prob(70)) //makes food reagents clog up the list less
		selected_reagent = get_random_reagent_id_unrestricted()

	list_reagents = list(selected_reagent = volume)
	reagents.add_reagent_list(list_reagents)
	. = ..()
	balloon_alert(user, "you change the reagent to [english_list(reagents.reagent_list)].")

/obj/item/reagent_containers/spray/chemsprayer/magical/examine()
	. = ..()
	. += "It currently holds [english_list(reagents.reagent_list)]."

//wizard bio/bomb suit
/obj/item/clothing/head/wizard/bio_suit
	name = "gem encrusted bio hood"
	desc = "A hood that protects the head and face from biological contaminants. It's covered in small gemstones."
	icon = 'icons/obj/clothing/head/bio.dmi'
	icon_state = "bio_wizard"
	worn_icon = 'icons/mob/clothing/head/bio.dmi'
	worn_icon_state = "bio_wizard"
	inhand_icon_state = "bio_hood"
	clothing_flags = THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | HEADINTERNALS | CASTING_CLOTHES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	strip_delay = 10 SECONDS
	equip_delay_other = 10 SECONDS
	armor_type = /datum/armor/head_wizard_biosuit

/datum/armor/head_wizard_biosuit
	melee = 35
	bullet = 25
	laser = 25
	energy = 35
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	wound = 25

/obj/item/clothing/suit/wizrobe/bio_suit
	name = "gem encrusted bio suit"
	desc = "A suit that protects against biological contamination. It's covered in small gemstones."
	icon = 'icons/obj/clothing/suits/bio.dmi'
	icon_state = "bio_wizard"
	worn_icon = 'icons/mob/clothing/suits/bio.dmi'
	worn_icon_state = "bio_wizard"
	inhand_icon_state = "bio_suit"
	clothing_flags = THICKMATERIAL | CASTING_CLOTHES
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDEJUMPSUIT
	strip_delay = 10 SECONDS
	equip_delay_other = 10 SECONDS
	armor_type = /datum/armor/suit_wizrobe

/datum/armor/suit_wizrobe
	melee = 35
	bullet = 25
	laser = 25
	energy = 35
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	wound = 25
