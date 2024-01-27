/obj/item/toy/crayon
	///list of additonal drawables that are drawable by this spraycan, used by subtypes
	var/list/additional_drawables = list()

/obj/item/toy/crayon/spraycan/gang/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_PICKUP, on_pickup)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, on_dropped)

/obj/item/toy/crayon/spraycan/gang/Destroy(force)
	UnregisterSignal(src, COMSIG_ITEM_PICKUP)
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	return ..()

/obj/item/toy/crayon/spraycan/gang/proc/on_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER

	var/datum/antagonist/gang_member/gang_datum = IS_GANGMEMBER(taker)
	if(gang_datum?.gang_team)
		additional_drawables = list(list("name" = "Gang", "items" = list(list("item" = TRUE)))) //SET ITEM CORRECTLY

/obj/item/toy/crayon/spraycan/gang/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	additional_drawables = list()

/obj/item/toy/crayon/spraycan/gang/improved

/obj/effect/decal/cleanable/crayon/gang

