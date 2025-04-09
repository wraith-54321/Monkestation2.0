/obj/item/disk
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_TINY
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'

// DAT FUKKEN DISK.
/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor_type = /datum/armor/disk_nuclear
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Whether we're a real nuke disk or not.
	var/fake = FALSE
	//MONKESTATION EDIT START
	/// Time unsecured (seconds).
	var/unsecured_time = 0
	/// Can junior OPs trigger from the disk being unsecure?
	var/can_trigger_junior_operative = FALSE
	/// Unsecured time for ghosts
	var/obj/effect/countdown/nukedisk/unsecured_timer
	/// Junior Operative Trigger Time
	var/junior_lone_operative_trigger_time
	//MONKESTATION EDIT STOP

/datum/armor/disk_nuclear
	bomb = 30
	fire = 100
	acid = 100

/obj/item/disk/nuclear/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bed_tuckable, 6, -6, 0)
	AddComponent(/datum/component/stationloving, !fake)

	if(!fake)
		AddComponent(/datum/component/keep_me_secure, CALLBACK(src, PROC_REF(secured_process)), CALLBACK(src, PROC_REF(unsecured_process)))
		SSpoints_of_interest.make_point_of_interest(src)
		//MONKESTATION EDIT START
		unsecured_timer = new(src)
		unsecured_timer.start()
		junior_lone_operative_trigger_time = (15 + rand(-5, 5)) * 60 //15 minutes + -5 to 5 minutes
		can_trigger_junior_operative = TRUE
		GLOB.nuke_disk_list += src
		//MONKESTATION EDIT STOP
	else
		AddComponent(/datum/component/keep_me_secure)

/obj/item/disk/nuclear/proc/secured_process(last_move)
	var/turf/new_turf = get_turf(src)
	var/datum/round_event_control/operative/loneopmode = locate(/datum/round_event_control/operative) in SSgamemode.control
	if(istype(loneopmode) && loneopmode.occurrences < loneopmode.max_occurrences && prob(loneopmode.weight))
		loneopmode.weight = max(loneopmode.weight - 1, 1) //monkestation edit: increased minimum to 1
		loneopmode.checks_antag_cap = (loneopmode.weight < 3)
		if(loneopmode.weight % 5 == 0 && SSticker.totalPlayers > 1)
			message_admins("[src] is secured (currently in [ADMIN_VERBOSEJMP(new_turf)]). The weight of Lone Operative is now [loneopmode.weight].")
		log_game("[src] being secured has reduced the weight of the Lone Operative event to [loneopmode.weight].")
	//MONKESTATION EDIT START
	unsecured_time = 0
	//MONKESTATION EDIT STOP

/obj/item/disk/nuclear/proc/unsecured_process(last_move)
	var/turf/new_turf = get_turf(src)
	/// How comfy is our disk?
	var/disk_comfort_level = 0
	//MONKESTATION EDIT START
	unsecured_time += 1
	if(unsecured_time == junior_lone_operative_trigger_time && can_trigger_junior_operative)
		spawn_op()
	//MONKESTATION EDIT STOP
	//Go through and check for items that make disk comfy
	for(var/obj/comfort_item in loc)
		if(istype(comfort_item, /obj/item/bedsheet) || istype(comfort_item, /obj/structure/bed))
			disk_comfort_level++

	if(last_move < world.time - 300 SECONDS && prob((world.time - 300 SECONDS - last_move)*0.0001)) //monkestation edit: weight will start increasing at 5 minutes unsecure, rather than 8.3
		var/datum/round_event_control/operative/loneopmode = locate(/datum/round_event_control/operative) in SSgamemode.control
		if(istype(loneopmode) && loneopmode.occurrences < loneopmode.max_occurrences)
			loneopmode.checks_antag_cap = (loneopmode.weight < 3)
			loneopmode.weight += 1
			if(loneopmode.weight % 5 == 0 && SSticker.totalPlayers > 1)
				if(disk_comfort_level >= 2)
					visible_message(span_notice("[src] sleeps soundly. Sleep tight, disky."))
				message_admins("[src] is unsecured in [ADMIN_VERBOSEJMP(new_turf)]. The weight of Lone Operative is now [loneopmode.weight].")
			log_game("[src] was left unsecured in [loc_name(new_turf)]. Weight of the Lone Operative event increased to [loneopmode.weight].")


/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	if(!fake)
		return

	if(isobserver(user) || HAS_TRAIT(user, TRAIT_DISK_VERIFIER) || (user.mind && HAS_TRAIT(user.mind, TRAIT_DISK_VERIFIER)))
		. += span_warning("The serial numbers on [src] are incorrect.")

/*
 * You can't accidentally eat the nuke disk, bro
 */
/obj/item/disk/nuclear/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	M.visible_message(span_warning("[M] looks like [M.p_theyve()] just bitten into something important."), \
						span_warning("Wait, is this the nuke disk?"))

	return discover_after

/obj/item/disk/nuclear/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/claymore/highlander) && !fake)
		var/obj/item/claymore/highlander/claymore = weapon
		if(claymore.nuke_disk)
			to_chat(user, span_notice("Wait... what?"))
			qdel(claymore.nuke_disk)
			claymore.nuke_disk = null
			return

		user.visible_message(
			span_warning("[user] captures [src]!"),
			span_userdanger("You've got the disk! Defend it with your life!"),
		)
		forceMove(claymore)
		claymore.nuke_disk = src
		return TRUE

	return ..()

/obj/item/disk/nuclear/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is going delta! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/machines/alarm.ogg', 50, -1, TRUE)
	for(var/i in 1 to 100)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, add_atom_colour), (i % 2)? "#00FF00" : "#FF0000", ADMIN_COLOUR_PRIORITY), i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 101)
	return MANUAL_SUICIDE

/obj/item/disk/nuclear/proc/manual_suicide(mob/living/user)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
	user.visible_message(span_suicide("[user] is destroyed by the nuclear blast!"))
	user.adjustOxyLoss(200)
	user.death(FALSE)

//MONKESTATION EDIT START
/obj/item/disk/nuclear/Destroy()
	QDEL_NULL(unsecured_timer)
	if(src in GLOB.nuke_disk_list)
		GLOB.nuke_disk_list -= src
	return ..()
/obj/item/disk/nuclear/proc/spawn_op()
	force_event(/datum/round_event_control/junior_lone_operative, "the nuke disk being unsecured for [round(unsecured_time/60, 1)] minutes")
//MONKESTATION EDIT STOP

/obj/item/disk/nuclear/fake
	fake = TRUE

/obj/item/disk/nuclear/fake/obvious
	name = "cheap plastic imitation of the nuclear authentication disk"
	desc = "How anyone could mistake this for the real thing is beyond you."
