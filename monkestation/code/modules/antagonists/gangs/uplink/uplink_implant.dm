//the uplink implanted used by gangs
/obj/item/implant/uplink/gang
	uplink_flag = UPLINK_GANGS
	///ref to our gang, likely not needed
	var/datum/team/gang/linked_gang

/obj/item/implant/uplink/gang/implant(mob/living/carbon/target, mob/user, silent, force)
	var/datum/antagonist/gang_user = IS_GANGMEMBER(user)
	if(!gang_user)
		return

	var/datum/uplink_handler/handler = linked_gang.handlers[user]
	uplink_handler = handler
	. = ..()

/obj/item/implant/uplink/gang/removed(mob/living/source, silent, special, forced) //monkestation edit: adds forced
	. = ..()
	if(!.)
		return
