//the uplink implanted used by gangs
/obj/item/implant/uplink/gang
	uplink_flag = UPLINK_GANGS
	starting_tc = 1 //a free TC, as a treat
	///What type of antag datum do we give the person we implant
	var/datum/antagonist/gang_member/antag_type = /datum/antagonist/gang_member
	///If TRUE then this implant can only be used for promotion and not conversion
	var/promotion_only = FALSE

/obj/item/implant/uplink/gang/can_be_implanted_in(mob/living/target)
	. = ..()
	if(!.)
		return

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD)) //mindshields work the same way as cultists where they will block conversion but wont deconvert if implanted with one
		return FALSE

/obj/item/implant/uplink/gang/implant(mob/living/carbon/target, mob/user, silent, force)
	if(!target.mind) //implanting a mindless mob wont work and will runtime, so override force
		to_chat(user, "\The [src] rejects [target].")
		return FALSE

	var/datum/antagonist/gang_member/gang_user = IS_GANGMEMBER(user)
	if(!force && (!gang_user || !gang_user.gang_team))
		to_chat(user, "You can't figure out how to use \the [src].")
		return FALSE

	var/datum/antagonist/gang_member/gang_target = IS_GANGMEMBER(target)
	if((!gang_target && promotion_only) || (gang_target && !promotion_checks()))
		to_chat(user, "\The [src] refuses to implant [target].")
		return FALSE

	if(gang_target) //if the previous check passes then we are valid to promote
		gang_target.change_rank(antag_type)
		moveToNullspace()
		qdel(src)
		return TRUE

	var/datum/uplink_handler/gang/handler = gang_user.gang_team.handlers[target.mind]
	var/qdel_handler_on_fail = FALSE //we only want to qdel the handler if its new
	if(!handler)
		handler = new
		qdel_handler_on_fail = TRUE
		handler.owner = target.mind
		handler.telecrystals = starting_tc //if we override handler then starting_tc does not get used
		handler.owning_gang = gang_user.gang_team
	uplink_handler = handler

	. = ..()
	if(!.)
		if(qdel_handler_on_fail)
			qdel(handler)
		return

	var/datum/antagonist/gang_member/new_member_datum = target.mind.add_antag_datum(antag_type, gang_user.gang_team)
	new_member_datum.handler = handler
	new_member_datum.gang_team?.handlers[target.mind] = handler

///put any unique checks you want for rank promotion here
/obj/item/implant/uplink/gang/proc/promotion_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	if(target.gang_team != user.gang_team || !MEETS_GANG_RANK(user, GANG_RANK_LIEUTENANT) || !initial(antag_type.rank) > target.rank)
		return FALSE
	return TRUE

/obj/item/implant/uplink/gang/boss
	starting_tc = 25 //bosses get extra TC over traitors
	antag_type = /datum/antagonist/gang_member/boss

/obj/item/implant/uplink/gang/boss/fabricated
	promotion_only = TRUE

/obj/item/implant/uplink/gang/boss/promotion_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	if(!..() || !MEETS_GANG_RANK(target, GANG_RANK_LIEUTENANT))
		return FALSE

	var/list/boss_list = target.gang_team.member_datums_by_rank["[GANG_RANK_BOSS]"]
	if(boss_list?.len) //using .len lets us use ?.
		var/datum/antagonist/gang_member/boss/boss_datum = boss_list[1]
		if(boss_datum.owner?.current?.stat != DEAD)
			return FALSE
		boss_datum.change_rank(target.type) //already accessed so just handle this here as we pass by this point
	return TRUE

/obj/item/implant/uplink/gang/lieutenant
	starting_tc = 5
	antag_type = /datum/antagonist/gang_member/lieutenant

/obj/item/implant/uplink/gang/lieutenant/fabricated
	promotion_only = TRUE

/obj/item/implant/uplink/gang/lieutenant/promotion_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	if(!..())
		return FALSE

	var/list/lieutenant_list = target.gang_team.member_datums_by_rank["[GANG_RANK_LIEUTENANT]"]
	if(lieutenant_list && length(lieutenant_list) > MAX_LIEUTENANTS)
		var/list/dead_lieutenants = list()
		for(var/datum/antagonist/gang_member/lieutenant_datum in lieutenant_list)
			if(lieutenant_datum.owner?.current?.stat == DEAD)
				dead_lieutenants += lieutenant_datum

		if(length(dead_lieutenants))
			var/datum/antagonist/gang_member/lieutenant/picked_lieutenant = pick(dead_lieutenants)
			picked_lieutenant.change_rank(target.type)
		else
			return FALSE
	return TRUE
