//the uplink implanted used by gangs
/obj/item/implant/uplink/gang
	uplink_flag = UPLINK_GANGS
	starting_tc = 1 //a free TC, as a treat
	///What type of antag datum do we give the person we implant
	var/datum/antagonist/antag_type = /datum/antagonist/gang_member

/obj/item/implant/uplink/gang/can_be_implanted_in(mob/living/target)
	. = ..()
	if(!.)
		return

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD)) //mindshields work the same way as cultists where they will block conversion but wont deconvert if implanted with one
		return FALSE

/obj/item/implant/uplink/gang/implant(mob/living/carbon/target, mob/user, silent, force)
	var/datum/antagonist/gang_member/gang_user
	if(user)
		gang_user = IS_GANGMEMBER(user)
	if(!target.mind || (!force && (!gang_user || !gang_user.gang_team))) //implanting a mindless mob wont work and will runtime, so override force
		return FALSE

	var/datum/uplink_handler/gang/handler = gang_user?.gang_team.handlers[target.mind]
	var/qdel_handler_on_fail = FALSE //we only want to qdel the handler if its new
	if(!handler)
		handler = new
		qdel_handler_on_fail = TRUE
		handler.owner = target.mind
		handler.telecrystals = starting_tc //if we override handler then starting_tc does not get used
	uplink_handler = handler

	. = ..()
	if(!.)
		if(qdel_handler_on_fail)
			qdel(handler)
		return

	var/datum/antagonist/gang_member/new_member_datum = target.mind.add_antag_datum(antag_type, gang_user?.gang_team)
	new_member_datum.handler = handler
	new_member_datum.gang_team?.handlers[target.mind] = handler

/obj/item/implant/uplink/gang/removed(mob/living/source, silent, special, forced)
	. = ..()
	if(!.)
		return

/obj/item/implant/uplink/gang/boss
	starting_tc = 25 //bosses get extra TC over traitors
	antag_type = /datum/antagonist/gang_member/boss

/obj/item/implant/uplink/gang/lieutenant
	starting_tc = 5
	antag_type = /datum/antagonist/gang_member/lieutenant
