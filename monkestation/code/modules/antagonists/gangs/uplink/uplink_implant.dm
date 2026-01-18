//the uplink implanted used by gangs
/obj/item/implant/uplink/gang
	uplink_flag = UPLINK_GANGS
	starting_tc = 1 //a free TC, as a treat
	///What type of antag datum do we give the person we implant
	var/datum/antagonist/gang_member/antag_type = /datum/antagonist/gang_member
	///If set to TRUE then we force our implanting
	var/debug = FALSE
	///Do we have a communicator
	var/has_communicator = FALSE
	///Do we let them get their given_gear_type
	var/give_gear = FALSE
	///A ref to the gang that is currently tracking us
	var/datum/team/gang/tracked_by

/obj/item/implant/uplink/gang/Initialize(mapload)
	. = ..()
	has_communicator = !!initial(antag_type.rank) //leaders always get a communicator

/obj/item/implant/uplink/gang/can_be_implanted_in(mob/living/target)
	. = ..()
	if(!.)
		return

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD) || IS_TRAITOR(target) || IS_NUKE_OP(target)) //mindshields work the same way as cultists
		return FALSE

/obj/item/implant/uplink/gang/implant(mob/living/carbon/target, mob/user, silent, force = debug, datum/team/gang/forced_gang)
	if(!target.mind) //implanting a mindless mob wont work and will runtime, so override force
		to_chat(user, span_warning("\The [src] rejects [target]."))
		return FALSE

	var/datum/antagonist/gang_member/gang_user = IS_GANGMEMBER(user)
	if(!force && (!gang_user || !gang_user.gang_team))
		to_chat(user, span_warning("You can't figure out how to use \the [src]."))
		return FALSE

	var/datum/antagonist/gang_member/gang_target = IS_GANGMEMBER(target)
	if(!force && gang_target)
		to_chat(user, span_warning("\The [src] refuses to implant [target]."))
		return FALSE

	if(gang_target) //if the previous check passes then we are valid to promote
		gang_target.change_rank(antag_type)
		moveToNullspace()
		qdel(src)
		return TRUE

	var/datum/team/gang/given_gang = forced_gang || gang_user?.gang_team
	var/datum/uplink_handler/gang/handler = given_gang?.handlers[target.mind]
	var/qdel_handler_on_fail = FALSE //we only want to qdel the handler if its new
	if(!handler) //might be able to simply make this after we call ..()
		handler = new
		qdel_handler_on_fail = TRUE
		handler.owner = target.mind
		handler.telecrystals = starting_tc //if we override handler then starting_tc does not get used
		handler.assigned_role = target.mind.assigned_role?.title //might not want to have these
		handler.assigned_species = target.dna?.species?.id
	uplink_handler = handler

	. = ..()
	if(!.)
		if(qdel_handler_on_fail)
			qdel(handler)
		return

	var/datum/antagonist/gang_member/new_member_datum = new antag_type //might want to create this on Init instead so it can be accessed by things better
	new_member_datum.handler = handler
	if(!give_gear)
		new_member_datum.given_gear_type = null

	target.mind.add_antag_datum(new_member_datum, given_gang)
	handler.owning_gang ||= new_member_datum.gang_team
	new_member_datum.RegisterSignal(src, COMSIG_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_implant_removal))
	if(new_member_datum.gang_team)
		new_member_datum.gang_team.handlers[target.mind] = handler
		new_member_datum.gang_team.track_implant(src)

	if(has_communicator)
		new_member_datum.set_communicate_source()

/obj/item/implant/uplink/gang/proc/add_communicator(datum/antagonist/gang_member/member_datum)
	if(has_communicator)
		return FALSE

	if(!imp_in)
		has_communicator = TRUE
		return TRUE

	member_datum ||= IS_GANGMEMBER(imp_in)
	if(!member_datum)
		CRASH("add_communicator() being called on a gang uplink implant whos owner does not have a gang datum")

	if(member_datum.communicate)
		return FALSE

	has_communicator = TRUE
	member_datum.set_communicate_source()
	return TRUE

/obj/item/implant/uplink/gang/boss
	starting_tc = 25 //bosses get extra TC over traitors
	antag_type = /datum/antagonist/gang_member/boss

/obj/item/implant/uplink/gang/lieutenant
	starting_tc = 10
	antag_type = /datum/antagonist/gang_member/lieutenant

//implanters
/obj/item/implanter/uplink/gang
	name = "implanter (gang uplink)"
	imp_type = /obj/item/implant/uplink/gang
	///What should we set the debug state of our implant to on init
	var/debug_implant = FALSE

/obj/item/implanter/uplink/gang/Initialize(mapload)
	. = ..()
	var/obj/item/implant/uplink/gang/implant = imp
	implant.debug = debug_implant

/obj/item/implanter/uplink/gang/lieutenant
	name = "implanter (gang lieutenant uplink)"
	imp_type = /obj/item/implant/uplink/gang/lieutenant

/obj/item/implanter/uplink/gang/boss
	name = "implanter (gang boss uplink)"
	imp_type = /obj/item/implant/uplink/gang/boss
	debug_implant = TRUE
