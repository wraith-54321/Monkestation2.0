GLOBAL_LIST_INIT(loadout_toys, generate_loadout_items(/datum/loadout_item/toys))

/datum/loadout_item/toys
	category = LOADOUT_ITEM_TOYS
	can_be_named = TRUE

/*
*	PLUSHIES
*/

/datum/loadout_item/toys/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)  // these go in the backpack
	return FALSE

/*
*	CARDS
*/

/datum/loadout_item/toys/card_binder
	name = "Card Binder"
	item_path = /obj/item/storage/card_binder
	requires_purchase = FALSE

/datum/loadout_item/toys/card_deck
	name = "Playing Card Deck"
	item_path = /obj/item/toy/cards/deck

/datum/loadout_item/toys/kotahi_deck
	name = "Kotahi Deck"
	item_path = /obj/item/toy/cards/deck/kotahi
	requires_purchase = FALSE

/datum/loadout_item/toys/wizoff_deck
	name = "Wizoff Deck"
	item_path = /obj/item/toy/cards/deck/wizoff

/datum/loadout_item/toys/tarot
	name = "Tarot Card Deck"
	item_path = /obj/item/toy/cards/deck/tarot

/*
*	DICE
*/

/datum/loadout_item/toys/d1
	name = "D1"
	item_path = /obj/item/dice/d1

/datum/loadout_item/toys/d2
	name = "D2"
	item_path = /obj/item/dice/d2

/datum/loadout_item/toys/d4
	name = "D4"
	item_path = /obj/item/dice/d4

/datum/loadout_item/toys/d6
	name = "D6"
	item_path = /obj/item/dice/d6

/datum/loadout_item/toys/d6_ebony
	name = "D6 (Ebony)"
	item_path = /obj/item/dice/d6/ebony

/datum/loadout_item/toys/d6_space
	name = "D6 (Space)"
	item_path = /obj/item/dice/d6/space

/datum/loadout_item/toys/d8
	name = "D8"
	item_path = /obj/item/dice/d8

/datum/loadout_item/toys/d10
	name = "D10"
	item_path = /obj/item/dice/d10

/datum/loadout_item/toys/d12
	name = "D12"
	item_path = /obj/item/dice/d12

/datum/loadout_item/toys/d20
	name = "D20"
	item_path = /obj/item/dice/d20

/datum/loadout_item/toys/d100
	name = "D100"
	item_path = /obj/item/dice/d100

/datum/loadout_item/toys/d00
	name = "D00"
	item_path = /obj/item/dice/d00

/datum/loadout_item/toys/dice
	name = "Dice Bag"
	item_path = /obj/item/storage/dice

/*
*	MISC
*/

/datum/loadout_item/toys/cat_toy
	name = "Cat Toy"
	item_path = /obj/item/toy/cattoy

/datum/loadout_item/toys/crayons
	name = "Box of Crayons"
	item_path = /obj/item/storage/crayons

/datum/loadout_item/toys/eightball
	name = "Magic Eightball"
	item_path = /obj/item/toy/eightball

/datum/loadout_item/toys/toykatana
	name = "Toy Katana"
	item_path = /obj/item/toy/katana


/datum/loadout_item/toys/foam_sword
	name = "Foam Sword"
	item_path = /obj/item/toy/sword

/datum/loadout_item/toys/walkman
	name = "Walkman"
	item_path = /obj/item/device/walkman
