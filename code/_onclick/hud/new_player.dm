/datum/hud/new_player

/datum/hud/new_player/New(mob/owner)
	..()

	if(!owner || !owner.client)
		return

	if (owner.client.interviewee)
		return

	var/list/buttons = subtypesof(/atom/movable/screen/lobby)
	for(var/atom/movable/screen/lobby/button_type as anything in buttons)
		if(button_type::abstract_type == button_type)
			continue
		var/atom/movable/screen/lobby/lobbyscreen = new button_type(our_hud = src)
		lobbyscreen.SlowInit()
		static_inventory += lobbyscreen
		if(istype(lobbyscreen, /atom/movable/screen/lobby/button))
			var/atom/movable/screen/lobby/button/lobby_button = lobbyscreen
			lobby_button.owner = REF(owner)

/atom/movable/screen/lobby
	plane = SPLASHSCREEN_PLANE
	layer = LOBBY_BUTTON_LAYER
	screen_loc = "TOP,CENTER"
	/// Do not instantiate if type matches this.
	var/abstract_type = /atom/movable/screen/lobby
	var/here

///Set the HUD in New, as lobby screens are made before Atoms are Initialized.
/atom/movable/screen/lobby/New(loc, datum/hud/our_hud, ...)
	set_new_hud(our_hud)
	return ..()

/// Run sleeping actions after initialize
/atom/movable/screen/lobby/proc/SlowInit()
	return

/atom/movable/screen/lobby/background
	layer = LOBBY_BACKGROUND_LAYER
	icon = 'icons/hud/lobby/background_monke.dmi'
	icon_state = "background"
	screen_loc = "TOP,CENTER:-61"

/atom/movable/screen/lobby/button
	abstract_type = /atom/movable/screen/lobby/button
	mouse_over_pointer = MOUSE_HAND_POINTER
	///Is the button currently enabled?
	VAR_PROTECTED/enabled = TRUE
	///Is the button currently being hovered over with the mouse?
	var/highlighted = FALSE
	/// The ref of the mob that owns this button. Only the owner can click on it.
	var/owner
	var/area/misc/start/lobbyarea

/atom/movable/screen/lobby/button/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	lobbyarea = GLOB.areas_by_type[/area/misc/start]

/atom/movable/screen/lobby/button/Click(location, control, params)
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()

	if(!enabled)
		return
	flick("[base_icon_state]_pressed", src)
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()
	highlighted = TRUE
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/lobby/button/MouseExited()
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()
	highlighted = FALSE
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/lobby/button/update_icon_state(updates)
	if(!enabled)
		icon_state = "[base_icon_state]_disabled"
	else if(highlighted)
		icon_state = "[base_icon_state]_highlighted"
	else
		icon_state = base_icon_state
	return ..()

/atom/movable/screen/lobby/button/proc/set_button_status(status)
	if(status == enabled)
		return FALSE
	enabled = status
	update_appearance(UPDATE_ICON)
	mouse_over_pointer = enabled ? MOUSE_HAND_POINTER : MOUSE_INACTIVE_POINTER
	return TRUE

///Prefs menu
/atom/movable/screen/lobby/button/character_setup
	screen_loc = "TOP:-87,CENTER:+100"
	icon = 'icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup"
	base_icon_state = "character_setup"

/atom/movable/screen/lobby/button/character_setup/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.canon_client.prefs
	preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

///Button that appears before the game has started
/atom/movable/screen/lobby/button/ready
	screen_loc = "TOP:-54,CENTER:-35"
	icon = 'icons/hud/lobby/ready.dmi'
	icon_state = "not_ready"
	base_icon_state = "not_ready"
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(hide_ready_button))
		if(GAME_STATE_SETTING_UP)
			set_button_status(FALSE)
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(show_ready_button))
		else
			set_button_status(FALSE)

/atom/movable/screen/lobby/button/ready/proc/hide_ready_button()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(show_ready_button))

/atom/movable/screen/lobby/button/ready/proc/show_ready_button()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(hide_ready_button))

/atom/movable/screen/lobby/button/ready/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	var/datum/station_trait/overflow_job_bureaucracy/overflow = locate() in SSstation.station_traits
	if(!ready && overflow?.picked_job && new_player.client?.prefs?.read_preference(/datum/preference/toggle/verify_overflow))
		if(tgui_alert(new_player, "The current overflow role is [overflow.picked_job.title], are you sure you would like to ready up?", "Overflow Notice", list("Yes", "No")) != "Yes")
			return
	ready = !ready
	if(ready)
		new_player.ready = PLAYER_READY_TO_PLAY
		base_icon_state = "ready"
		var/client/new_client = new_player.client
		if(new_client)
			if(!new_client.readied_store)
				new_client.readied_store = new(new_player)
			new_client.readied_store.ui_interact(new_player)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(interview_safety), new_player, "readied up"), 1 SECONDS, TIMER_UNIQUE)
	else
		new_player.ready = PLAYER_NOT_READY
		base_icon_state = "not_ready"
	update_appearance(UPDATE_ICON)

///Shown when the game has started
/atom/movable/screen/lobby/button/join
	screen_loc = "TOP:-54,CENTER:-35"
	icon = 'icons/hud/lobby/join.dmi'
	icon_state = "" //Default to not visible
	base_icon_state = "join_game"

/atom/movable/screen/lobby/button/join/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	set_button_status(FALSE)
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(show_join_button))
		if(GAME_STATE_SETTING_UP)
			set_button_status(TRUE)
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(hide_join_button))
		else
			set_button_status(TRUE)

/atom/movable/screen/lobby/button/join/Click(location, control, params)
	. = ..()
	if(!.)
		return

	if(!SSticker?.IsRoundInProgress())
		to_chat(hud.mymob, span_boldwarning("The round is either not ready, or has already finished..."))
		return

	if(hud.mymob.client?.check_overwatch())
		to_chat(hud.mymob, span_warning("Kindly wait until your connection has been authenticated before joining"))
		message_admins("[hud.mymob.key] tried to use the Join button but failed the overwatch check.")
		return

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hard_popcap = CONFIG_GET(number/hard_popcap)
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(hard_popcap && extreme_popcap)
		relevant_cap = min(hard_popcap, extreme_popcap)
	else
		relevant_cap = max(hard_popcap, extreme_popcap)

	var/mob/dead/new_player/new_player = hud.mymob

	//Allow admins and Patreon supporters to bypass the cap/queue
	if ((relevant_cap && living_player_count() >= relevant_cap) && (get_player_details(new_player)?.patreon?.is_donator() || is_admin(new_player.client) || new_player.client?.is_mentor()))
		to_chat(new_player, span_notice("The server is currently overcap, but you are a(n) patreon/mentor/admin!"))
	else if (SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap))
		to_chat(new_player, span_danger("[CONFIG_GET(string/hard_popcap_message)]"))

		var/queue_position = SSticker.queued_players.Find(new_player)
		if(queue_position == 1)
			to_chat(new_player, span_notice("You are next in line to join the game. You will be notified when a slot opens up."))
		else if(queue_position)
			to_chat(new_player, span_notice("There are [queue_position-1] players in front of you in the queue to join the game."))
		else
			SSticker.queued_players += new_player
			to_chat(new_player, span_notice("You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len]."))
		return

	if(!LAZYACCESS(params2list(params), CTRL_CLICK))
		GLOB.latejoin_menu.ui_interact(new_player)
	else
		to_chat(new_player, span_warning("Opening emergency fallback late join menu! If THIS doesn't show, ahelp immediately!"))
		GLOB.latejoin_menu.fallback_ui(new_player)


/atom/movable/screen/lobby/button/join/proc/show_join_button()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(hide_join_button))

/atom/movable/screen/lobby/button/join/proc/hide_join_button()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(show_join_button))

/atom/movable/screen/lobby/button/observe
	screen_loc = "TOP:-54,CENTER:+82"
	icon = 'icons/hud/lobby/observe.dmi'
	icon_state = "observe_disabled"
	base_icon_state = "observe"
	enabled = FALSE

/atom/movable/screen/lobby/button/observe/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(SSticker.current_state > GAME_STATE_STARTUP)
		set_button_status(TRUE)
	else
		set_button_status(FALSE)
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(enable_observing))

/atom/movable/screen/lobby/button/observe/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.make_me_an_observer()

/atom/movable/screen/lobby/button/observe/proc/enable_observing()
	SIGNAL_HANDLER
	flick("[base_icon_state]_enabled", src)
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME)

/atom/movable/screen/lobby/button/patreon_link
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "patreon"
	base_icon_state = "patreon"
	screen_loc = "TOP:-126,CENTER:86"

/atom/movable/screen/lobby/button/patreon_link/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!CONFIG_GET(string/patreon_link_website))
		return
	hud.mymob.client << link("[CONFIG_GET(string/patreon_link_website)]?ckey=[hud.mymob.client.ckey]")

/atom/movable/screen/lobby/button/intents
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "intents"
	base_icon_state = "intents"
	screen_loc = "TOP:-126,CENTER:62"

/atom/movable/screen/lobby/button/intents/Click(location, control, params)
	. = ..()
	var/datum/player_details/details = get_player_details(hud.mymob)
	details.challenge_menu ||= new(details)
	details.challenge_menu.ui_interact(hud.mymob)

/atom/movable/screen/lobby/button/discord
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "discord"
	base_icon_state = "discord"
	screen_loc = "TOP:-126,CENTER:38"

/atom/movable/screen/lobby/button/discord/Click(location, control, params)
	. = ..()
	if(!.)
		return
	hud.mymob.client << link("https://discord.gg/monkestation")

/atom/movable/screen/lobby/button/twitch
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "info"
	base_icon_state = "info"
	screen_loc = "TOP:-126,CENTER:14"

/atom/movable/screen/lobby/button/twitch/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!CONFIG_GET(string/twitch_link_website))
		return
	hud.mymob.client << link("[CONFIG_GET(string/twitch_link_website)]?ckey=[hud.mymob.client.ckey]")

/atom/movable/screen/lobby/button/settings
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "settings"
	base_icon_state = "settings"
	screen_loc = "TOP:-126,CENTER:-10"

/atom/movable/screen/lobby/button/settings/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.canon_client.prefs
	preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

/atom/movable/screen/lobby/button/volume
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "volume"
	base_icon_state = "volume"
	screen_loc = "TOP:-126,CENTER:-34"

/atom/movable/screen/lobby/button/volume/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.client.prefs
	if(!preferences.pref_mixer)
		preferences.pref_mixer = new
	preferences.pref_mixer.open_ui(hud.mymob)

/atom/movable/screen/lobby/button/changelog_button
	icon = 'icons/hud/lobby/changelog.dmi'
	icon_state = "changelog"
	base_icon_state = "changelog"
	screen_loc ="TOP:-98,CENTER:+45"


/atom/movable/screen/lobby/button/crew_manifest
	icon = 'icons/hud/lobby/manifest.dmi'
	icon_state = "manifest"
	base_icon_state = "manifest"
	screen_loc = "TOP:-98,CENTER:-9"

/atom/movable/screen/lobby/button/crew_manifest/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.ViewManifest()

/atom/movable/screen/lobby/button/changelog_button/Click(location, control, params)
	. = ..()
	usr.client?.changelog()

/atom/movable/screen/lobby/button/poll
	icon = 'icons/hud/lobby/poll.dmi'
	icon_state = "poll"
	base_icon_state = "poll"
	screen_loc = "TOP:-98,CENTER:-40"

	var/new_poll = FALSE

/atom/movable/screen/lobby/button/poll/SlowInit(mapload)
	. = ..()
	if(!usr)
		return
	var/mob/dead/new_player/new_player = usr
	if(is_guest_key(new_player.key))
		set_button_status(FALSE)
		return
	if(!SSdbcore.Connect())
		set_button_status(FALSE)
		return
	var/isadmin = FALSE
	if(new_player.client?.holder)
		isadmin = TRUE
	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = new_player.ckey))
	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		set_button_status(FALSE)
		return
	if(query_get_new_polls.NextRow())
		new_poll = TRUE
	else
		new_poll = FALSE
	update_appearance(UPDATE_OVERLAYS)
	qdel(query_get_new_polls)
	if(QDELETED(new_player))
		set_button_status(FALSE)
		return

/atom/movable/screen/lobby/button/poll/update_overlays()
	. = ..()
	if(new_poll)
		. += mutable_appearance('icons/hud/lobby/poll_overlay.dmi', "new_poll")

/atom/movable/screen/lobby/button/poll/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.handle_player_polling()

//This is the changing You are here Button
/atom/movable/screen/lobby/youarehere
	var/vanderlin = 0
	screen_loc = "TOP:-81,CENTER:+177"
	icon = 'icons/hud/lobby/location_indicator.dmi'
	icon_state = "you_are_here"
	screen_loc = "TOP,CENTER:-61"

//Explanation: It gets the port then sets the "here" var in /movable/screen/lobby to the port number
// and if the port number matches it makes clicking the button do nothing so you dont spam reconnect to the server your in
/atom/movable/screen/lobby/youarehere/SlowInit(mapload)
	. = ..()
	var/port = world.port
	switch(port)
		if(HRP_PORT) //HRP
			screen_loc = "TOP:-32,CENTER:+215"
		if(MRP_PORT) //MRP
			screen_loc = "TOP:-65,CENTER:+215"
		if(MRP2_PORT) //MRP2
			screen_loc = "TOP:-98,CENTER:+215"
		else     //Sticks it in the middle, "TOP:0,CENTER:+128" will point at the MonkeStation logo itself.
			screen_loc = "TOP:0,CENTER:+128"

/atom/movable/screen/lobby/button/server
	icon = 'icons/hud/lobby/sister_server_buttons.dmi'
	abstract_type = /atom/movable/screen/lobby/button/server
	enabled = FALSE
	/// The name of the server, used for the connecting message.
	var/server_name
	/// The IP of this server.
	var/server_ip = "play.monkestation.com"
	/// The port of this server.
	var/server_port

/atom/movable/screen/lobby/button/server/SlowInit(mapload)
	. = ..()
	set_button_status(is_available())
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/lobby/button/server/proc/is_available()
	var/time_info = time2text(world.realtime, "DDD hh")
	var/day = copytext(time_info, 1, 4)
	var/hour = text2num(copytext(time_info, 5))
	if(!should_be_up(day, hour))
		return FALSE
	return TRUE

/atom/movable/screen/lobby/button/server/proc/should_be_up(day, hour)
	return TRUE

/atom/movable/screen/lobby/button/server/Click(location, control, params)
	. = ..()
	if(. && world.port != server_port && is_available())
		var/server_link = "byond://[server_ip]:[server_port]"
		to_chat_immediate(
			target = hud.mymob,
			html = boxed_message(span_info(span_big("Connecting you to [server_name]\nIf nothing happens, try manually connecting to the server ([server_link]), or the server may be down!"))),
			type = MESSAGE_TYPE_INFO,
		)
		hud.mymob.client << link(server_link)

//HRP MONKE
/atom/movable/screen/lobby/button/server/hrp
	base_icon_state = "hrp"
	screen_loc = "TOP:-44,CENTER:+173"
	server_name = "Well-Done Roleplay (HRP)"
	server_port = HRP_PORT

/atom/movable/screen/lobby/button/server/hrp/should_be_up(day, hour)
	return day == SATURDAY && ISINRANGE(hour, 12, 18)

//MAIN MONKE (MEDIUM RARE)
/atom/movable/screen/lobby/button/server/mrp
	base_icon_state = "mrp"
	screen_loc = "TOP:-77,CENTER:+173"
	enabled = TRUE
	server_name = "Medium-Rare Roleplay (MRP)"
	server_port = MRP_PORT

//MRP 2 MONKE (MEDIUM WELL)
/atom/movable/screen/lobby/button/server/mrp2
	screen_loc = "TOP:-110,CENTER:+173"
	base_icon_state = "mrp2"
	server_name = "Medium-Well (MRP)"
	server_port = MRP2_PORT

//bottom button is "TOP:-140,CENTER:+177"
//The Vanderlin Project
/atom/movable/screen/lobby/button/server/vanderlin
	icon = 'icons/hud/lobby/vanderlin_button.dmi'
	base_icon_state = "vanderlin"
	screen_loc = "TOP:-140,CENTER:+183"
	server_name = "Vanderlin"
	server_port = VANDERLIN_PORT

/atom/movable/screen/lobby/button/server/vanderlin/should_be_up(day, hour)
	return TRUE
/*
	switch(day)
		if(FRIDAY)
			return (hour >= 15)
		if(SATURDAY, SUNDAY)
			return TRUE
	return FALSE
*/

//Monke button
/atom/movable/screen/lobby/button/ook
	screen_loc = "TOP:-126,CENTER:110"
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "monke"
	base_icon_state = "monke"

/atom/movable/screen/lobby/button/ook/Click(location, control, params)
	. = ..()
	if(.)
		SEND_SOUND(usr, 'monkestation/sound/misc/menumonkey.ogg')

/atom/movable/screen/lobby/overflow_alert
	screen_loc = "TOP:-48,CENTER-2.7"
	icon = 'icons/hud/lobby/overflow.dmi'
	icon_state = ""
	base_icon_state = "overflow"
	var/datum/job/overflow_job
	var/static/disabled = FALSE
	var/static/mutable_appearance/job_overlay

/atom/movable/screen/lobby/overflow_alert/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(SSticker.current_state == GAME_STATE_STARTUP)
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(initial_setup))
	else
		generate_and_set_icon()
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/overflow_alert/Destroy()
	overflow_job = null
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME)
	return ..()

/atom/movable/screen/lobby/overflow_alert/update_icon_state()
	if(!disabled && !isnull(job_overlay))
		icon_state = base_icon_state
	else
		icon_state = ""
	return ..()

/atom/movable/screen/lobby/overflow_alert/update_overlays()
	. = ..()
	if(!disabled && job_overlay)
		. += job_overlay

/atom/movable/screen/lobby/overflow_alert/MouseEntered(location,control,params)
	. = ..()
	if(!disabled && overflow_job && !QDELETED(src))
		openToolTip(usr, src, params, title = "Job Overflow", content = "The overflow role this round is <b>[html_encode(overflow_job.title)]</b>!")

/atom/movable/screen/lobby/overflow_alert/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/lobby/overflow_alert/proc/initial_setup(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSstation, COMSIG_TICKER_ENTER_PREGAME)
	var/datum/station_trait/overflow_job_bureaucracy/overflow = locate() in SSstation.station_traits
	overflow_job = overflow?.picked_job
	if(overflow_job)
		generate_and_set_icon()
	else
		disabled = TRUE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/overflow_alert/proc/generate_and_set_icon()
	if(disabled || SSticker.current_state == GAME_STATE_STARTUP || !isnull(job_overlay))
		return
	var/datum/station_trait/overflow_job_bureaucracy/overflow = locate() in SSstation.station_traits
	overflow_job = overflow?.picked_job
	if(!overflow_job)
		disabled = TRUE
		return
	var/icon/job_icon = get_job_hud_icon(overflow_job, include_unknown = TRUE)
	if(!job_icon)
		return
	var/icon/resized_icon = resize_icon(job_icon, 16, 16)
	if(!resized_icon)
		stack_trace("Failed to upscale icon for [overflow_job], upscaling using BYOND!")
		job_icon.Scale(16, 16)
		resized_icon = job_icon
	job_overlay = mutable_appearance(resized_icon)
	job_overlay.pixel_x = 8
	job_overlay.pixel_y = 18
