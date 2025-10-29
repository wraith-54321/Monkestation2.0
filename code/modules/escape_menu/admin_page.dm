/datum/escape_menu/proc/show_admin_page()
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/lobby_button/small(
			null,
			/* hud_owner = */ null,
			"Back",
			/* tooltip_text = */ null,
			/* button_screen_loc = */ "TOP:-30,LEFT:30",
			CALLBACK(src, PROC_REF(open_home_page)),
			/* button_overlay = */ "back",
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/admin_help(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Create Admin Ticket",
			/* offset = */ list(-136, 28),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(create_ticket)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/admin_ticket_notification(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "View Latest Ticket",
			/* offset = */ list(-171, 28),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(view_latest_ticket)),
		)
	)
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "See Admin Notices",
			/* offset = */ list(-206, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(admin_notice)),
		)
	)
	if(CONFIG_GET(flag/see_own_notes))
		page_holder.give_screen_object(
			new /atom/movable/screen/escape_menu/text/clickable(
				null,
				/* hud_owner = */ null,
				/* escape_menu = */ src,
				/* button_text = */ "See Notes",
				/* offset = */ list(-241, 30),
				/* font_size = */ 24,
				/* on_click_callback = */ CALLBACK(src, PROC_REF(see_notes)),
			)
		)

///Opens your latest admin ticket.
/datum/escape_menu/proc/view_latest_ticket()
	client?.view_latest_ticket()

///Checks for any admin notices.
/datum/escape_menu/proc/admin_notice()
	client?.admin_notice()

/datum/escape_menu/proc/create_ticket()
	if(!(/client/verb/adminhelp in client?.verbs))
		return
	client?.adminhelp()
	qdel(src)

/datum/escape_menu/proc/see_notes()
	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(client.mob, span_notice("Seeing notes has been disabled on this server."))
		return
	browse_messages(null, client.ckey, null, TRUE)
