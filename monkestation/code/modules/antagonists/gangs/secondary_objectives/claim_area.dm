/datum/traitor_objective_category/gang_claim_areas
	name = "Claim Areas(gang)"
	objectives = list(/datum/traitor_objective/gang/claim_areas = 1,
					/datum/traitor_objective/gang/claim_areas/claim_multiple = 1,
					list(/datum/traitor_objective/gang/claim_areas/department = 1, /datum/traitor_objective/gang/claim_areas/department/high_risk = 1) = 1,
					list(/datum/traitor_objective/gang/claim_areas/secure_areas = 1, /datum/traitor_objective/gang/claim_areas/secure_areas/claim_multiple = 1) = 1)

/datum/traitor_objective/gang/claim_areas
	name = "Expand your influence by taking control of at least %NEEDED% of %AREAS%."
	description = "In order to properly assert control you must hold at least %NEEDED% of %AREAS% for %TIMER%."
	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(3, 4)
	progression_maximum = 15 MINUTES

	///What area types can be chosen from to be selected as claim targets to be put in picked_areas
	var/list/valid_areas = list(/area/station/cargo,
								/area/station/medical,
								/area/station/science,
								/area/station/engineering,
								/area/station/service,
								/area/station/commons) //commons is here because they are likely to get taken by other gangs
	///How many areas in picked_areas does our gang need to have claimed in order to start counting down
	var/needed_area_count = 1
	///How many entries do we add to picked_areas before filtering
	var/pre_picked_count = 0
	///How many entries do we pick() after filtering to add to picked_areas, set to a negative to allow all
	var/picked_count = 3
	///How long does our gang need to hold needed_area_count areas in order to be able to turn in the objective
	var/hold_time = 5 MINUTES
	///Does an area need its exact type in valid_areas
	var/root_path_only = FALSE
	///Do we include the root paths in valid_areas
	var/include_roots = FALSE
	///A typecache of the areas that we are targeting with this objective
	var/list/picked_areas = list()
	///How many areas in picked_areas does our gang currently own
	var/owned_count = 0
	///How long has our gang met needed_area_count
	var/time_fulfilled = 0

/datum/traitor_objective/gang/claim_areas

/datum/traitor_objective/gang/claim_areas/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!..() || picked_count == 0 || !length(valid_areas))
		return FALSE

	if(length(valid_areas) < pre_picked_count && root_path_only)
		stack_trace("[type] with root_path_only and a pre_picked_count higher than length(valid_areas) trying to generate.")
		return FALSE
	return TRUE

/datum/traitor_objective/gang/claim_areas/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!get_picked_areas())
		return FALSE

	replace_in_name("%AREAS%", english_list(picked_areas, and_text = " or "))
	replace_in_name("%NEEDED%", "[needed_area_count]")
	replace_in_name("%TIMER%", DisplayTimeText(hold_time))
	return TRUE

/datum/traitor_objective/gang/claim_areas/on_objective_taken(mob/user)
	. = ..()
	RegisterSignal(owner, COMSIG_GANG_TOOK_AREA, PROC_REF(on_area_taken))
	RegisterSignal(owner, COMSIG_GANG_TOOK_AREA, PROC_REF(on_area_lost))
	for(var/area/area as anything in owner.claimed_areas)
		if(is_type_in_typecache(area, picked_areas))
			owned_count++

/datum/traitor_objective/gang/claim_areas/ungenerate_objective()
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(owner, list(COMSIG_GANG_LOST_AREA, COMSIG_GANG_TOOK_AREA))

/datum/traitor_objective/gang/claim_areas/process(seconds_per_tick)
	var/mob/owner = handler.owner?.current
	if(objective_state != OBJECTIVE_STATE_ACTIVE)
		return PROCESS_KILL

	if(!owner)
		fail_objective()
		return PROCESS_KILL

	if(owned_count >= needed_area_count)
		time_fulfilled += seconds_per_tick * (1 SECONDS)

	if(time_fulfilled >= hold_time)
		succeed_objective()
		return PROCESS_KILL
	handler.on_update()

/datum/traitor_objective/gang/claim_areas/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(time_fulfilled || owned_count >= needed_area_count)
		buttons += add_ui_button("[DisplayTimeText(time_fulfilled)]", "This tells you how long you have claimed the needed areas.", "clock", "none")
	return buttons

///generate our picked_areas
/datum/traitor_objective/gang/claim_areas/proc/get_picked_areas()
	var/i = 0
	while(i < pre_picked_count)
		i++
		var/list/temp = list()
		var/picked = pick_n_take(valid_areas)
		picked_areas += pick(valid_areas - picked_areas) //might be better to manually take and store the picked areas and just add them back when done

	picked_areas = typecacheof(picked_areas + valid_areas, root_path_only, include_roots) //check that just adding valid_areas here works
	//im somewhat guessing here but it should be overall cheaper to run through the longer list once rather than compare it
	var/picked_is_longer = length(picked_areas) > length(GLOB.the_station_areas)
	for(var/area/area as anything in (picked_is_longer ? picked_areas : GLOB.the_station_areas))
		if(!(initial(area.area_flags) & VALID_TERRITORY) || (area in (owner.claimed_areas + owner.permanently_claimed_areas)) || \
			!(area in (picked_is_longer ? GLOB.the_station_areas : picked_areas)))
			picked_areas -= area

		if(length(picked_areas) < picked_count)
			return FALSE

	while(picked_count >= 0 && length(picked_areas) > picked_count)
		pick_n_take(picked_areas)
	return TRUE

/datum/traitor_objective/gang/claim_areas/proc/on_area_taken(datum/team/gang/owner, area/taken_area)
	SIGNAL_HANDLER
	if(!is_type_in_typecache(taken_area, picked_areas))
		return

	owned_count++
	if(owned_count >= needed_area_count && !time_fulfilled)
		START_PROCESSING(SSprocessing, src)

/datum/traitor_objective/gang/claim_areas/proc/on_area_lost(datum/team/gang/owner, area/lost_area)
	SIGNAL_HANDLER
	if(is_type_in_typecache(lost_area, picked_areas))
		owned_count--

/datum/traitor_objective/gang/claim_areas/claim_multiple
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(4, 5)
	needed_area_count = 3
	picked_count = 6

/datum/traitor_objective/gang/claim_areas/secure_areas
	progression_maximum = 30 MINUTES
	progression_minimum = 10 MINUTES
	progression_reward = list(7 MINUTES, 14 MINUTES)
	telecrystal_reward = list(4, 5)
	valid_areas = list(/area/station/command,
						/area/station/security,
						/area/station/ai_monitored)

/datum/traitor_objective/gang/claim_areas/secure_areas/claim_multiple
	progression_reward = list(8 MINUTES, 16 MINUTES)
	telecrystal_reward = list(5, 6)
	needed_area_count = 3
	picked_count = 6

/datum/traitor_objective/gang/claim_areas/department
	name = "Expand your influence by taking control of %NEEDED% areas in %DEPARTMENT%."
	description = "In order to properly assert control you must hold at least %NEEDED% areas in %DEPARTMENT% for %TIMER%."
	progression_maximum = 30 MINUTES
	progression_minimum = 10 MINUTES
	progression_reward = list(15 MINUTES, 20 MINUTES)
	telecrystal_reward = list(3, 4)
	//yes this is a hacky way to get the names but it works(mostly)
	valid_areas = list(/area/station/cargo = "cargo",
						/area/station/medical = "medical",
						/area/station/science = "science",
						/area/station/engineering = "engineering",
						/area/station/service = "service")
	needed_area_count = 5
	pre_picked_count = 1
	picked_count = -1

/datum/traitor_objective/gang/claim_areas/department/get_picked_areas()
	. = ..()
	var/area_key = valid_areas[1]
	replace_in_name("%DEPARTMENT%", "[valid_areas[area_key]]")

/datum/traitor_objective/gang/claim_areas/department/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	for(var/datum/traitor_objective/gang/claim_areas/objective in possible_duplicates)
		var/area/objective_selected_area = objective.valid_areas[1]
		valid_areas -= objective_selected_area.type

	if(!length(valid_areas)) //somehow still generating even with no length
		return FALSE
	return ..()

/datum/traitor_objective/gang/claim_areas/department/high_risk
	progression_maximum = 45 MINUTES
	progression_minimum = 15 MINUTES
	progression_reward = list(20 MINUTES, 25 MINUTES)
	telecrystal_reward = list(6, 7)
	valid_areas = list(/area/station/command = "command",
						/area/station/security = "security")
