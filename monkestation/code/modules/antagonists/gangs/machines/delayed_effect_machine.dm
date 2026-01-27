///Does a callback with a tiny bit of flare after a delay, used for objective calldowns
/obj/machinery/gang_machine/delayed_effect
	layer = ABOVE_OBJ_LAYER //these should be hard to hide
	///Should we delete after we activate
	var/del_on_activation = TRUE
	///How long until we activate
	var/timer = 5 MINUTES

/obj/machinery/gang_machine/delayed_effect/Initialize(mapload, gang)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(attempt_activation)), timer)

/obj/machinery/gang_machine/delayed_effect/proc/attempt_activation()
	if(QDELETED(src))
		return

	say("Activated")
	send_gang_message(list(owner), "Activated", src, "<span class='alertsyndie'>")
	SEND_SIGNAL(src, COMSIG_GANG_MACHINE_ACTIVATED)
	activate()
	if(del_on_activation)
		do_sparks(4, FALSE, src)
		qdel(src)

/obj/machinery/gang_machine/delayed_effect/proc/activate()
	return

//gives the controling gang a bunch of TC when it charges
/obj/machinery/gang_machine/delayed_effect/telecrystal_beacon
	///How many TC do we give to our owner
	var/given_tc = 30

/obj/machinery/gang_machine/delayed_effect/telecrystal_beacon/activate()
	owner.unallocated_tc += given_tc
