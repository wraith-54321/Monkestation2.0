//the uplink implanted used by gangs
/obj/item/implant/uplink/gang
	uplink_flag = UPLINK_GANGS

/obj/item/implant/uplink/gang/implant(mob/living/carbon/target, mob/user, silent, force)
	var/datum/antagonist/gang_member
	if(!IS_GANGMEMBER(user))
		return

	var/datum/uplink_handler/handler = linked_gang.handlers[user]
	uplink_handler = handler
	. = ..()
