///datum/traitor_objective_category/gang_protect_machine
//	name = "Protect Machine(gang)"

/datum/traitor_objective/gang/protect_machine
	name = "Call down a %MACHINE% in one of %AREAS% and protect it."
	description = "In order to properly assert control you must hold at least %NEEDED% of %AREAS% for %TIMER%."
	progression_reward = list(15, 20)
	telecrystal_reward = list(1, 2) //the TC reward is mostly from the machine
	progression_minimum = 50
	progression_maximum = 300
	///What areas our machine can be called into
	var/list/valid_areas = list()
	///How many valid areas should we have
	var/valid_area_count = 3
	///The type of machine we create
	var/obj/machinery/gang_machine/created_type = /obj/machinery/gang_machine/telecrystal_beacon
	///The thing we currently have signals registered for, either an object beacon or a machine
	var/obj/registered
	///How long does the machine need to be protected
	var/protect_time = 5 MINUTES
	///Is it ok for the machine to change owners before our protect_time is up
	var/can_change_hands = TRUE

/datum/traitor_objective/gang/protect_machine/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!..() || !length(valid_areas))
		return FALSE
	return TRUE

/datum/traitor_objective/gang/protect_machine/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!owner || !get_valid_areas())
		return FALSE

	var/list/names = list()
	for(var/area/picked_area as anything in valid_areas)
		names += initial(picked_area.name)

	replace_in_name("%AREAS%", english_list(names, and_text = " or "))
	replace_in_name("%MACHINE%", "[initial(created_type.name)]")
	replace_in_name("%TIMER%", DisplayTimeText(protect_time))
	return TRUE

///Get our valid areas list
/datum/traitor_objective/gang/protect_machine/proc/get_valid_areas()
	var/list/station_areas = GLOB.the_station_areas.Copy()
	shuffle_inplace(station_areas)
	for(var/area/area as anything in station_areas)
		if(!(initial(area.area_flags) & VALID_TERRITORY))
			continue

		valid_areas += area
		if(length(valid_areas) >= valid_area_count)
			break
	return length(valid_areas) >= valid_area_count

/obj/machinery/gang_machine/telecrystal_beacon
	///How many TC do we give to our owner
	var/given_tc = 30
