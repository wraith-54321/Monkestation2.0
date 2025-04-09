/obj/item/organ/internal/cyberimp/arm/item_set/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contain advanced versions of every tool."
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	icon_state = "toolkit_engineering"
	items_to_create = list(
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
	)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/toolset/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/item_set/toolset/emag_act(mob/user, obj/item/card/emag/emag_card)
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_knife = created_item.resolve()
		if(istype(/obj/item/knife/combat/cyborg, potential_knife))
			return FALSE

	balloon_alert(user, "integrated knife unlocked")
	items_list += WEAKREF(new /obj/item/knife/combat/cyborg(src))
	return TRUE

/obj/item/organ/internal/cyberimp/arm/item_set/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_surgical"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/retractor/augment,
		/obj/item/hemostat/augment,
		/obj/item/cautery/augment,
		/obj/item/surgicaldrill/augment,
		/obj/item/scalpel/augment,
		/obj/item/circular_saw/augment,
		/obj/item/surgical_drapes,
	)
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/surgery/emag_act(mob/user, obj/item/card/emag/emag_card)
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_knife = created_item.resolve()
		if(istype(/obj/item/knife/combat/cyborg, potential_knife))
			return FALSE
	balloon_alert(user, "integrated knife unlocked")
	items_list += WEAKREF(new /obj/item/knife/combat/cyborg(src))
	return TRUE

/obj/item/organ/internal/cyberimp/arm/item_set/surgery/emagged
	name = "hacked surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm. This one seems to have been tampered with."
	encode_info = AUGMENT_SYNDICATE_LEVEL
	items_to_create = list(
		/obj/item/retractor/augment,
		/obj/item/hemostat/augment,
		/obj/item/cautery/augment,
		/obj/item/surgicaldrill/augment,
		/obj/item/scalpel/augment,
		/obj/item/circular_saw/augment,
		/obj/item/surgical_drapes,
		/obj/item/knife/combat/cyborg,
	)

/obj/item/organ/internal/cyberimp/arm/item_set/cook
	name = "kitchenware toolset implant"
	desc = "A set of kitchen tools hidden behind a concealed panel on the user's arm."
	items_to_create = list(
		/obj/item/kitchen/rollingpin,
		/obj/item/knife/kitchen,
		/obj/item/reagent_containers/cup/beaker
	)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/janitor
	name = "janitorial toolset implant"
	desc = "A set of janitorial tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_janitor"
	items_to_create = list(
		/obj/item/lightreplacer,
		/obj/item/holosign_creator,
		/obj/item/soap/nanotrasen,
		/obj/item/reagent_containers/spray/cyborg_drying,
		/obj/item/mop/advanced,
		/obj/item/paint/paint_remover,
		/obj/item/reagent_containers/cup/beaker/large,
		/obj/item/reagent_containers/spray/cleaner
	)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/janitor/emag_act()
	if(obj_flags & EMAGGED)
		return FALSE
	for(var/datum/weakref/created_item in items_list)
	to_chat(usr, span_notice("You unlock [src]'s integrated deluxe cleaning supplies!"))
	items_list += WEAKREF(new /obj/item/soap/syndie(src)) //We add not replace.
	items_list += WEAKREF(new /obj/item/reagent_containers/spray/cyborg_lube(src))
	obj_flags |= EMAGGED
	return TRUE

/obj/item/organ/internal/cyberimp/arm/item_set/detective
	name = "detective's toolset implant"
	desc = "A set of detective tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_detective"
	items_to_create = list(
		/obj/item/evidencebag,
		/obj/item/evidencebag,
		/obj/item/evidencebag,
		/obj/item/detective_scanner,
		/obj/item/lighter
	)
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/detective/Destroy()
	on_destruction()
	return ..()

/obj/item/organ/internal/cyberimp/arm/item_set/detective/proc/on_destruction()
	//We need to drop whatever is in the evidence bags
	for(var/obj/item/evidencebag/baggie in contents)
		var/obj/item/located = locate() in baggie
		if(located)
			located.forceMove(drop_location())

/obj/item/organ/internal/cyberimp/arm/item_set/paramedic
	name = "paramedic toolset implant"
	desc = "A set of rescue tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_paramedic"
	items_to_create = list(
		/obj/item/emergency_bed/silicon,
		/obj/item/sensor_device,
		/obj/item/gun/medbeam
	)
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/atmospherics
	name = "atmospherics toolset implant"
	desc = "A set of atmospheric tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_atmosph"
	items_to_create = list(
		/obj/item/extinguisher,
		/obj/item/analyzer,
		/obj/item/crowbar,
		/obj/item/holosign_creator/atmos
	)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/combat
	name = "officer toolset implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	icon_state = "toolkit_security"
	items_to_create = list(
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/melee/baton,
		/obj/item/assembly/flash/armimplant,
	)
	encode_info = AUGMENT_TG_LEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/combat/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_flash = created_item.resolve()
		if(!istype(potential_flash, /obj/item/assembly/flash/armimplant))
			continue
		var/obj/item/assembly/flash/armimplant/flash = potential_flash
		flash.arm = WEAKREF(src) // Todo: wipe single letter vars out of assembly code

/obj/item/organ/internal/cyberimp/arm/item_set/connector
	name = "universal connection implant"
	desc = "Special inhand implant that allows you to connect your brain directly into the protocl sphere of implants, which allows for you to hack them and make the compatible."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#39992d"
	encode_info = AUGMENT_NO_REQ
	items_to_create = list(/obj/item/cyberlink_connector)

/obj/item/organ/internal/cyberimp/arm/item_set/botany
	name = "botany arm implant"
	desc = "A rather simple arm implant containing tools used in gardening and botanical research."
	icon_state = "toolkit_hydro"
	items_to_create = list(
		/obj/item/cultivator,
		/obj/item/shovel/spade,
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/geneshears,
		/obj/item/secateurs,
		/obj/item/storage/bag/plants,
		/obj/item/storage/bag/plants/portaseeder
	)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/item_set/barber
	name = "barber toolset implant"
	desc = "A set of barber tools hidden behind a concealed panel on the user's arm."
	items_to_create = list(
		/obj/item/razor,
		/obj/item/hairbrush/comb,
		/obj/item/scissors,
		/obj/item/reagent_containers/spray/quantum_hair_dye,
		/obj/item/fur_dyer,
		/obj/item/dyespray,
	)
	encode_info = AUGMENT_NT_LOWLEVEL
