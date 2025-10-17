/* Gifts and wrapping paper
 * Contains:
 * Gifts
 * Wrapping Paper
 */

/*
 * Gifts
 */

GLOBAL_LIST_EMPTY(possible_gifts)

/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "giftdeliverypackage3"
	inhand_icon_state = "gift"
	resistance_flags = FLAMMABLE

	var/atom/contains_type

/obj/item/a_gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftdeliverypackage[rand(1,5)]"

	contains_type = get_gift_type()

/obj/item/a_gift/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] peeks inside [src] and cries [user.p_them()]self to death! It looks like [user.p_they()] [user.p_were()] on the naughty list..."))
	return BRUTELOSS

/obj/item/a_gift/examine(mob/M)
	. = ..()
	if((M.mind && HAS_TRAIT(M.mind, TRAIT_PRESENT_VISION)) || isobserver(M))
		. += span_notice("It contains \a [initial(contains_type.name)].")

/obj/item/a_gift/attack_self(mob/M)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_CANNOT_OPEN_PRESENTS))
		to_chat(M, span_warning("You're supposed to be spreading gifts, not opening them yourself!"))
		return

	qdel(src)

	if(isitem(contains_type))
		var/atom/I = new contains_type(get_turf(M))
		if (!QDELETED(I)) //might contain something like metal rods that might merge with a stack on the ground
			M.put_in_hands(I)
			I.add_fingerprint(M)
			I.AddComponent(/datum/component/gift_item, M) // monkestation edit: gift item info component
		else
			M.visible_message(span_danger("Oh no! The present that [M] opened had nothing inside it!"))
			return
	else
		new contains_type(M.drop_location(), M)
	M.visible_message(span_notice("[M] unwraps \the [src], finding \a [contains_type::name] inside!"))
	M.investigate_log("has unwrapped a present containing [contains_type].", INVESTIGATE_PRESENTS)

/obj/item/a_gift/proc/get_gift_type()
	var/gift_type_list = list(/obj/item/sord,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/pickaxe/diamond,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/poster/random_official,
		/obj/item/book/manual/wiki/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/basketball,
		/obj/item/banhammer,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/pai_card,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/neck/tie/horrible,
		/obj/item/clothing/suit/jacket/leather,
		/obj/item/clothing/suit/jacket/leather/biker,
		/obj/item/clothing/suit/costume/poncho,
		/obj/item/clothing/suit/costume/poncho/green,
		/obj/item/clothing/suit/costume/poncho/red,
		/obj/item/clothing/suit/costume/snowman,
		/obj/item/clothing/head/costume/snowman,
		/obj/item/stack/sheet/mineral/coal)

	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/toy) - (((typesof(/obj/item/toy/cards) - /obj/item/toy/cards/deck) + /obj/item/toy/figure + /obj/item/toy/ammo)) //All toys, except for abstract types and syndicate cards.

	var/gift_type = pick(gift_type_list)

	return gift_type


/obj/item/a_gift/anything
	name = "christmas gift"
	desc = "It could be anything!"

/obj/item/a_gift/anything/get_gift_type()
	if(!GLOB.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		for(var/V in gift_types_list)
			var/obj/item/I = V
			if((!initial(I.icon_state)) || (!initial(I.inhand_icon_state)) || (initial(I.item_flags) & ABSTRACT))
				gift_types_list -= V
		//MONKESTATION EDIT START
		// List of items we want to block the anything-gift from spawning. Reasons for blocking
		// these vary, but usually come down to keeping the server (and game clients) stable.
		//
		// Subtypes of these items will also be blocked.
		var/list/blocked_items = list(
			// Just leaves the coordinates everywhere
			/obj/item/gps/visible_debug,
			// Can lag the hell out of the server
			/obj/item/gun/energy/recharge/kinetic_accelerator/meme,
			// Per Biddi's suggestion; plus doesn't seem to do much anyways?
			/obj/item/research,
			//only upsets people consistantly
			/obj/item/gun/magic/wand/death,
			/obj/item/gun/magic/wand/resurrection/debug,
			//holy fuck why was this enabled
			/obj/item/debug,
			/obj/item/storage/box/debugbox,
			/obj/item/gun/energy/beam_rifle/debug,
			/obj/item/multitool/field_debug,
			/obj/item/bounty_cube/debug_cube,
			/obj/item/organ/internal/cyberimp/brain/nif/debug,
			/obj/item/spellbook_charge/debug,
			/obj/item/uplink/nuclear/debug,
			//kills only the debug uplink from the gifts.
			/obj/item/mod/control/pre_equipped/chrono,
			)
		for(var/blocked_item in blocked_items)
			// Block the item listed, and any subtypes too.
			gift_types_list -= typesof(blocked_item)
		//MONKESTATION EDIT END
		GLOB.possible_gifts = gift_types_list
	var/gift_type = pick(GLOB.possible_gifts)

	return gift_type

/obj/item/a_gift/spooky
	name = "spooky gift"
	desc = "Could contain tricks or treats!"

/obj/item/a_gift/spooky/Initialize(mapload)
	. = ..()
	icon_state = "spooky_gift"
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)

	contains_type = get_gift_type()

/obj/item/a_gift/spooky/get_gift_type()
	var/gift_type_list = list(/obj/item/food/burger/ghost,
		/obj/item/paper/selfdestruct/job_application,
		/obj/item/stack/sheet/hauntium,
		/obj/item/tome,
		/obj/item/clothing/suit/costume/ghost_sheet,
		/obj/item/food/cookie/sugar/spookycoffin,
		/obj/item/food/cookie/sugar/spookyskull,
		/mob/living/basic/skeleton,
		/obj/effect/mine/sound/bwoink,
		/obj/effect/mine/shrapnel/sting,
		/obj/item/clothing/mask/cigarette/syndicate,
		/obj/item/clothing/mask/cigarette/candy,
		/obj/effect/mine/sound/spooky,
		/obj/item/knife,
		/obj/item/restraints/legcuffs/beartrap/prearmed,
		/obj/item/skeleton_potion,
		/obj/item/bad_luck
		)
	var/gift_type = pick(gift_type_list)
	return gift_type
