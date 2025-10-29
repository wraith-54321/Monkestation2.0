/obj/machinery/computer/camera_advanced/ratvar
	name = "Ratvarian Observation Console"
	desc = "Used by the servants of Ratvar to conduct operations on Nanotrasen property."
	icon_screen = "ratvar1"
	icon_keyboard = "ratvar_key1"
	icon_state = "ratvarcomputer"
	resistance_flags = INDESTRUCTIBLE
	clockwork = TRUE
	lock_override = TRUE
	circuit = /obj/item/circuitboard/machine/camera_console_ratvar

/obj/machinery/computer/camera_advanced/ratvar/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	actions += new /datum/action/innate/clockcult/warp(src)
	actions += new /datum/action/innate/clockcult/show_warpable_areas(src)
	actions += new /datum/action/innate/clockcult/add_warp_area(src)

/obj/machinery/computer/camera_advanced/ratvar/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/computer/camera_advanced/ratvar/process(seconds_per_tick)
	if(SPT_PROB(3, seconds_per_tick))
		new /obj/effect/temp_visual/steam_release(get_turf(src))
	if(SPT_PROB(7, seconds_per_tick))
		playsound(get_turf(src), 'sound/machines/beep.ogg', 20, TRUE)

/obj/machinery/computer/camera_advanced/ratvar/can_use(mob/living/user)
	if(!IS_CLOCK(user) || iscogscarab(user))
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/ratvar/CreateEye()
	. = ..()
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'monkestation/icons/mob/silicon/cameramob.dmi'
	eyeobj.icon_state = "ratvar_camera"
	eyeobj.invisibility = INVISIBILITY_OBSERVER

/datum/action/innate/clockcult/warp
	name = "Warp"
	desc = "Warp to a location."
	button_icon_state = "warp_down"
	///are we warping down
	var/warping = FALSE
	///what area types are we blocked from warping to
	var/static/list/blocked_areas = typecacheof(list(/area/station/service/chapel, /area/station/ai_monitored))

/datum/action/innate/clockcult/warp/IsAvailable(feedback)
	if(!IS_CLOCK(owner) || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockcult/warp/Activate()
	if(!isliving(owner))
		return

	if(GLOB.clock_ark && GLOB.clock_ark.current_state >= ARK_STATE_ACTIVE)
		to_chat(owner, span_brass("You cannot warp while the gateway is opening!"))
		return

	if(warping)
		button_icon_state = "warp_down"
		build_all_button_icons(UPDATE_BUTTON_ICON)
		warping = FALSE
		return

	var/mob/living/cam_user = owner
	var/mob/eye/ai_eye/remote/cam = cam_user.remote_control
	var/turf/target_loc = get_turf(cam)
	var/area/target_area = get_area(target_loc)
	if(!(SSthe_ark.marked_areas[target_area]))
		to_chat(owner, span_brass("This area is not marked."))
		return

	if(isclosedturf(target_loc))
		to_chat(owner, span_brass("You cannot warp into dense objects."))
		return

	do_sparks(5, TRUE, get_turf(cam))
	warping = TRUE
	button_icon_state = "warp_cancel"
	build_all_button_icons(UPDATE_BUTTON_ICON)
	if(do_after(cam_user, 5 SECONDS, target = target_loc, extra_checks = CALLBACK(src, PROC_REF(warping_check))))
		try_servant_warp(cam_user, target_loc)
		astype(owner.remote_control, /mob/eye/ai_eye/remote)?.origin.remove_eye_control(owner)

	button_icon_state = "warp_down"
	build_all_button_icons(UPDATE_BUTTON_ICON)
	warping = FALSE

/datum/action/innate/clockcult/warp/proc/warping_check()
	return warping

/obj/item/circuitboard/machine/camera_console_ratvar
	build_path = /obj/machinery/computer/camera_advanced/ratvar
