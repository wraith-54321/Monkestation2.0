/obj/item/toy/crayon
	///list of additonal drawables that are drawable by this spraycan
	var/list/additional_drawables = list()
	///list of additional_drawables by static_additional_drawables
	var/list/formatted_additional_drawables = list()

/obj/item/toy/crayon/spraycan/gang/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_PICKUP, on_pickup)

/obj/item/toy/crayon/spraycan/gang/Destroy(force)
	UnregisterSignal(src, COMSIG_ITEM_PICKUP)
	return ..()

/obj/item/toy/crayon/spraycan/gang/examine(mob/user)
	. = ..()
	if(IS_GANGMEMBER(user))
		. += "It looks like this one is created for use in gang tag painting."

/obj/item/toy/crayon/spraycan/gang/use_on(atom/target, mob/user, params)
	if(drawtype in additional_drawables)
		var/datum/antagonist/gang_member/gang_datum = IS_GANGMEMBER(user)
		if(gang_datum)
			return snowflake_graffiti_creation(atom/target, mob/user, params, gang_datum)
		else
			to_chat(user, "You dont know how to draw this!")
			stack_trace("")
			return FALSE
	else
		return ..()

///We do a bunch of different stuff for our gang graffiti creation but still want normal function for the spraycan so im just cramming all our stuff into this proc instead of use_on()
/obj/item/toy/crayon/spraycan/gang/proc/snowflake_graffiti_creation(atom/target, mob/user, params, datum/antagonist/gang_member/antag_datum)
	if(target && !isturf(target))
		target = get_turf(target)

	if(!target)
		return FALSE

	if(!isValidSurface(target))
		target.balloon_alert(user, "Can't use there!")
		return FALSE

/obj/item/toy/crayon/spraycan/gang/proc/on_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER

	var/datum/antagonist/gang_member/gang_datum = IS_GANGMEMBER(taker)
	if(gang_datum?.gang_team)
		if(!(gang_datum.gang_team.gang_tag in additional_drawables))
			additional_drawables = list(gang_datum.gang_team.gang_tag)
			formatted_additional_drawables = list(list("name" = "Gang", "items" = list(list("item" = gang_datum.gang_team.gang_tag))))
			drawtype = gang_datum.gang_team.gang_tag
		return

	if(drawtype in additional_drawables)
		drawtype = "Random Anything"
	additional_drawables = list()

/obj/item/toy/crayon/spraycan/gang/improved

/obj/effect/decal/cleanable/crayon/gang

