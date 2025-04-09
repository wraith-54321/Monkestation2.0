
/obj/item/device/cassette_tape
	name = "Debug Cassette Tape"
	desc = "You shouldn't be seeing this! If you are, ask an admin to spawn you a new cassette tape."
	icon = 'monkestation/code/modules/cassettes/icons/walkman.dmi'
	icon_state = "cassette_flip"
	w_class = WEIGHT_CLASS_SMALL
	///icon of the cassettes front side
	var/side1_icon = "cassette_worstmap"
	var/side2_icon = "cassette_worstmap"
	///if the cassette is flipped, for playing second list of songs
	var/flipped = FALSE
	///list of songs each side has to play
	var/list/songs = list("side1" = list(),
						  "side2" = list())
	///list of each songs name in the order they appear
	var/list/song_names = list("side1" = list(),
						 	   "side2" = list())
	///the id of the cassette
	var/id
	///the ckey of the cassette author
	var/ckey_author
	///the authors name displayed in examine text
	var/author_name
	///are we an approved tape?
	var/approved_tape = FALSE
	///are we random?
	var/random = FALSE
	var/cassette_desc_string = "Generic Desc"

/obj/item/device/cassette_tape/Initialize(mapload, spawned_id)
	. = ..()
	if(!length(GLOB.approved_ids))
		GLOB.approved_ids = initialize_approved_ids()

	if(length(GLOB.approved_ids))
		if(spawned_id && (spawned_id in GLOB.approved_ids))
			id = spawned_id
		else if(random)
			id = pick(GLOB.approved_ids)

	var/loaded_successfully = load_current_id()
	if(random && !loaded_successfully)
		var/list/approved_ids = GLOB.approved_ids.Copy()
		var/attempts_left = 2
		while(!loaded_successfully && length(approved_ids) && attempts_left > 0)
			id = pick_n_take(approved_ids)
			loaded_successfully = load_current_id()
			attempts_left--

	if(!loaded_successfully)
		// this isn't working
		// notify the admins so they know in case of an ahelp
		message_admins("A cassette tape at [ADMIN_VERBOSEJMP(src)] has [random ? "repeatedly " : ""]failed to load data from the cassette storage. Please check the runtime logs for more information (search for \"cassette tape data\").")
		// we probably don't want to try to spawn a new cassette, as that might cause an infinite
		// loop in extreme circumstances (i.e. if no cassettes exist)

/// Attempts to load the JSON associated with the current ID. Returns a boolean - TRUE if the load
/// was successful, and FALSE if it wasn't.
/obj/item/device/cassette_tape/proc/load_current_id()
	var/file = file("data/cassette_storage/[id].json")
	if(!fexists(file))
		stack_trace("Failed to load cassette tape data for ID '[id]': Cassette storage does not have a matching JSON file.")
		return FALSE

	var/file_text = file2text(file)
	if(!rustg_json_is_valid(file_text))
		stack_trace("Failed to load cassette tape data for ID '[id]': The loaded file contains invalid JSON.")
		return FALSE

	var/list/data = json_decode(file_text)
	name = data["name"]
	cassette_desc_string = data["desc"]
	icon_state = data["side1_icon"]
	side1_icon = data["side1_icon"]
	side2_icon = data["side2_icon"]
	songs = data["songs"]
	song_names = data["song_names"]
	author_name = data["author_name"]
	ckey_author = data["author_ckey"]
	approved_tape = data["approved"]

	update_appearance()

	return TRUE

/obj/item/device/cassette_tape/attack_self(mob/user)
	..()
	icon_state = flipped ? side1_icon : side2_icon
	flipped = !flipped
	to_chat(user, span_notice("You flip [src]."))

/obj/item/device/cassette_tape/update_desc(updates)
	. = ..()
	desc = cassette_desc_string
	desc += "\n"
	if(!approved_tape)
		desc += span_warning("It appears to be a bootleg tape, quality is not a guarantee!\n")
	if(author_name)
		desc += span_notice("Mixed by [author_name]\n")

/obj/item/device/cassette_tape/attackby(obj/item/item, mob/living/user)
	if(!istype(item, /obj/item/pen))
		return ..()
	var/choice = tgui_input_list(usr, "What would you like to change?", items = list("Cassette Name", "Cassette Description", "Cancel"))
	switch(choice)
		if("Cassette Name")
			///the name we are giving the cassette
			var/newcassettename = reject_bad_text(tgui_input_text(user, "Write a new Cassette name:", name, name, max_length = MAX_NAME_LEN))
			if(!user.can_perform_action (src, TRUE))
				return
			if(length(newcassettename) > MAX_NAME_LEN)
				to_chat(user, span_warning("That name is too long!"))
				return
			if(!newcassettename)
				to_chat(user, span_warning("That name is invalid."))
				return
			else
				name = "[lowertext(newcassettename)]"
		if("Cassette Description")
			///the description we are giving the cassette
			var/newdesc = tgui_input_text(user, "Write a new description:", name, desc, max_length = 180)
			if(!user.can_perform_action(src, TRUE))
				return
			if (length(newdesc) > 180)
				to_chat(user, span_warning("That description is too long!"))
				return
			if(!newdesc)
				to_chat(user, span_warning("That description is invalid."))
				return
			cassette_desc_string = newdesc
			update_appearance()
		else
			return

/datum/cassette/cassette_tape
	var/name = "Broken Cassette"
	var/desc = "You shouldn't be seeing this! Make an issue about it"
	var/icon_state = "cassette_flip"
	var/side1_icon = "cassette_flip"
	var/side2_icon = "cassette_flip"
	var/id = "blank"
	var/creator_ckey = "Dwasint"
	var/creator_name = "Collects-The-Candy"
	var/approved = TRUE
	var/list/song_names = list("side1" = list(),
							   "side2" = list())

	var/list/songs = list("side1" = list(),
						  "side2" = list())

/obj/item/device/cassette_tape/blank
	id = "blank"

/obj/item/device/cassette_tape/friday
	id = "friday"
