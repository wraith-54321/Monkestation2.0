/*
 *	# Hide a random object somewhere on the station:
 *
 *	var/turf/targetturf = get_random_station_turf()
 *	var/turf/targetturf = get_safe_random_station_turf()
 */

/datum/objective/bloodsucker
	martyr_compatible = TRUE
	/// The bloodsucker antag datum of this objective's owner.
	var/datum/antagonist/bloodsucker/bloodsucker_datum

// GENERATE
/datum/objective/bloodsucker/New(text, datum/mind/owner)
	update_explanation_text()
	if(owner)
		src.owner = owner
		src.bloodsucker_datum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	return ..()

/datum/objective/bloodsucker/Destroy()
	bloodsucker_datum = null
	return ..()

//////////////////////////////////////////////////////////////////////////////
//	//							 PROCS 									//	//

/// Look at all crew members, and for/loop through.
/datum/objective/bloodsucker/proc/return_possible_targets()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		// Check One: Default Valid User
		if(possible_target != owner && ishuman(possible_target.current) && possible_target.current.stat != DEAD)
			// Check Two: Am Bloodsucker?
			if(IS_BLOODSUCKER(possible_target.current))
				continue
			possible_targets += possible_target

	return possible_targets

/// Check Vassals and get their occupations
/datum/objective/bloodsucker/proc/get_vassal_occupations()
	if(!length(bloodsucker_datum?.vassals))
		return FALSE
	var/list/all_vassal_jobs = list()
	var/vassal_job
	for(var/datum/antagonist/vassal/bloodsucker_vassals in bloodsucker_datum.vassals)
		if(!bloodsucker_vassals?.owner)	// Must exist somewhere, and as a vassal.
			continue
		// Mind Assigned
		if(bloodsucker_vassals.owner?.assigned_role)
			vassal_job = bloodsucker_vassals.owner.assigned_role
		// Mob Assigned
		else if(bloodsucker_vassals.owner?.current?.job)
			vassal_job = SSjob.GetJob(bloodsucker_vassals.owner.current.job)
		// PDA Assigned
		else if(bloodsucker_vassals.owner?.current && ishuman(bloodsucker_vassals.owner.current))
			var/mob/living/carbon/human/vassal = bloodsucker_vassals.owner.current
			vassal_job = SSjob.GetJob(vassal.get_assignment())
		if(vassal_job)
			all_vassal_jobs += vassal_job
	return all_vassal_jobs

//////////////////////////////////////////////////////////////////////////////////////
//	//							 OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////
//    DEFAULT OBJECTIVES    //
//////////////////////////////

/datum/objective/bloodsucker/lair
	name = "claimlair"

// EXPLANATION
/datum/objective/bloodsucker/lair/update_explanation_text()
	explanation_text = "Create a lair by claiming a coffin, and protect it until the end of the shift."//  Make sure to keep it safe!"

// WIN CONDITIONS?
/datum/objective/bloodsucker/lair/check_completion()
	if(bloodsucker_datum?.coffin && bloodsucker_datum.bloodsucker_lair_area)
		return TRUE
	return FALSE

/// Space_Station_13_areas.dm  <--- all the areas

//////////////////////////////////////////////////////////////////////////////////////
/*
/datum/objective/bloodsucker/survive
	name = "bloodsuckersurvive"
	explanation_text = "Survive the entire shift without succumbing to Final Death."

/datum/objective/bloodsucker/survive/check_completion()
	return ..() || (!QDELETED(owner.current) && !bloodsucker_datum?.final_death)
*/
// WIN CONDITIONS?
// Handled by parent

//////////////////////////////////////////////////////////////////////////////////////


/// Vassalize a certain person / people
/datum/objective/bloodsucker/conversion
	name = "vassalization"

/datum/objective/bloodsucker/conversion/New(text, datum/mind/owner)
	if(!target_amount)
		target_amount = generate_target_amount()
	return ..()

/datum/objective/bloodsucker/conversion/proc/generate_target_amount()
	return rand(1, 3)

/datum/objective/bloodsucker/conversion/update_explanation_text()
	explanation_text = "Have [target_amount] living Vassal[target_amount == 1 ? "" : "s"] by the end of the shift."

/datum/objective/bloodsucker/conversion/check_completion()
	var/living_vassals = 0
	for(var/datum/antagonist/vassal/vassal in bloodsucker_datum?.vassals)
		if(considered_alive(vassal.owner, enforce_human = FALSE))
			living_vassals++
		if(living_vassals >= target_amount)
			return TRUE
	return FALSE

/////////////////////////////////

// Vassalize a head of staff
/datum/objective/bloodsucker/conversion/command
	name = "vassalizationcommand"
	target_amount = 1

// EXPLANATION
/datum/objective/bloodsucker/conversion/command/update_explanation_text()
	explanation_text = "Guarantee a Vassal ends up as a Department Head or in a Leadership role."

// WIN CONDITIONS?
/datum/objective/bloodsucker/conversion/command/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	for(var/datum/job/checked_job in vassal_jobs)
		if(checked_job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			return TRUE // We only need one, so we stop as soon as we get a match
	return FALSE

/////////////////////////////////

// Vassalize crewmates in a department
/datum/objective/bloodsucker/conversion/department
	name = "vassalize department"

	///The selected department we have to vassalize.
	var/datum/job_department/target_department
	///List of all departments that can be selected for the objective.
	var/static/list/possible_departments = list(
		/datum/job_department/security,
		/datum/job_department/engineering,
		/datum/job_department/medical,
		/datum/job_department/science,
		/datum/job_department/cargo,
		/datum/job_department/service,
	)


// GENERATE!
/datum/objective/bloodsucker/conversion/department/New(text, datum/mind/owner)
	target_department = SSjob.get_department_type(pick(possible_departments))
	return ..()

/datum/objective/bloodsucker/conversion/department/generate_target_amount()
	return rand(2, 3)

// EXPLANATION
/datum/objective/bloodsucker/conversion/department/update_explanation_text()
	explanation_text = "Have [target_amount] Vassal[target_amount == 1 ? "" : "s"] in the [target_department.department_name] department."

// WIN CONDITIONS?
/datum/objective/bloodsucker/conversion/department/check_completion()
	var/converted_count = 0
	for(var/datum/job/checked_job in get_vassal_occupations())
		if(checked_job.departments_bitflags & target_department.department_bitflags)
			converted_count++
		if(converted_count >= target_amount)
			return TRUE
	return FALSE

	/**
	 * # IMPORTANT NOTE!!
	 *
	 * Look for Job Values on mobs! This is assigned at the start, but COULD be changed via the HoP
	 * ALSO - Search through all jobs (look for prefs earlier that look for all jobs, and search through all jobs to see if their head matches the head listed, or it IS the head)
	 * ALSO - registered_account in _vending.dm for banks, and assigning new ones.
	 */

//////////////////////////////
//     CLAN OBJECTIVES      //
//////////////////////////////

/// Steal the Archive of the Kindred - Nosferatu Clan objective
/datum/objective/bloodsucker/kindred
	name = "steal kindred"

// EXPLANATION
/datum/objective/bloodsucker/kindred/update_explanation_text()
	. = ..()
	explanation_text = "Ensure Nosferatu steals and keeps control over the Archive of the Kindred."

// WIN CONDITIONS?
/datum/objective/bloodsucker/kindred/check_completion()
	for(var/obj/item/book/kindred/archive as anything in GLOB.kindred_archives)
		var/mob/living/holder = get(archive, /mob/living)
		if(holder && HAS_MIND_TRAIT(holder, TRAIT_BLOODSUCKER_ALIGNED))
			return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////////////////

/// Max out a Tremere Power - Tremere Clan objective
/datum/objective/bloodsucker/tremere_power
	name = "tremerepower"

// EXPLANATION
/datum/objective/bloodsucker/tremere_power/update_explanation_text()
	explanation_text = "Upgrade a Blood Magic power to at least level [TREMERE_OBJECTIVE_POWER_LEVEL], remember that Vassalizing gives more Ranks!"

// WIN CONDITIONS?
/datum/objective/bloodsucker/tremere_power/check_completion()
	var/found = FALSE //done like this because we want to check all powers, not just return on the first found
	for(var/datum/action/cooldown/bloodsucker/targeted/tremere/tremere_powers in bloodsucker_datum?.powers)
		if(tremere_powers.level_current >= TREMERE_OBJECTIVE_POWER_LEVEL)
			found = TRUE
	//the next line is JUST for the dominate power, which is an offshoot of a nontremere power
	var/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/domin = locate(/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate) in bloodsucker_datum?.powers
	if(domin)
		if(domin.level_current >= TREMERE_OBJECTIVE_POWER_LEVEL)
			found = TRUE
	return found
//////////////////////////////////////////////////////////////////////////////////////

/// Convert a crewmate - Ventrue Clan objective
/datum/objective/bloodsucker/embrace
	name = "embrace"

// EXPLANATION
/datum/objective/bloodsucker/embrace/update_explanation_text()
	. = ..()
	explanation_text = "Use the persuasion rack to Rank your Favorite Vassal up enough to become a Bloodsucker."

// WIN CONDITIONS?
/datum/objective/bloodsucker/embrace/check_completion()
	for(var/datum/antagonist/vassal/favorite/vassal_datum in bloodsucker_datum?.vassals)
		if(vassal_datum.owner.has_antag_datum(/datum/antagonist/bloodsucker))
			return TRUE
	return FALSE



//////////////////////////////
// MONSTERHUNTER OBJECTIVES //
//////////////////////////////

/datum/objective/bloodsucker/monsterhunter
	name = "destroymonsters"

// EXPLANATION
/datum/objective/bloodsucker/monsterhunter/update_explanation_text()
	. = ..()
	explanation_text = "Destroy all monsters on [station_name()]."

// WIN CONDITIONS?
/datum/objective/bloodsucker/monsterhunter/check_completion()
	var/list/datum/mind/monsters = list()
	for(var/datum/antagonist/monster in GLOB.antagonists)
		var/datum/mind/brain = monster.owner
		if(QDELETED(brain) || brain == owner)
			continue
		if(brain.current.stat == DEAD)
			continue
		if(IS_HERETIC(brain.current) || IS_CULTIST(brain.current) || IS_BLOODSUCKER(brain.current) || IS_WIZARD(brain.current))
			monsters += brain
		if(brain.has_antag_datum(/datum/antagonist/changeling))
			monsters += brain

	return completed || !length(monsters)



//////////////////////////////
//     VASSAL OBJECTIVES    //
//////////////////////////////

/datum/objective/bloodsucker/vassal

// EXPLANATION
/datum/objective/bloodsucker/vassal/update_explanation_text()
	. = ..()
	explanation_text = "Guarantee the success of your Master's mission!"

// WIN CONDITIONS?
/datum/objective/bloodsucker/vassal/check_completion()
	var/datum/antagonist/vassal/antag_datum = owner.has_antag_datum(/datum/antagonist/vassal)
	return antag_datum.master?.owner?.current?.stat != DEAD



//////////////////////////////
//    REMOVED OBJECTIVES    //
// NOT GUARANTEED FUNCTIONAL//
//////////////////////////////

// NOTE: Look up /assassinate in objective.dm for inspiration.
/// Vassalize a target.
/datum/objective/bloodsucker/vassalhim
	name = "vassalhim"
	var/target_department_type = FALSE

/datum/objective/bloodsucker/vassalhim/New(text, datum/mind/owner)
	var/list/possible_targets = return_possible_targets()
	find_target(possible_targets)
	..()

// EXPLANATION
/datum/objective/bloodsucker/vassalhim/update_explanation_text()
	. = ..()
	if(target?.current)
		explanation_text = "Ensure [target.name], the [!target_department_type ? target.assigned_role.title : target.special_role], is Vassalized via the Persuasion Rack."
	else
		explanation_text = "Free Objective"

/datum/objective/bloodsucker/vassalhim/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

// WIN CONDITIONS?
/datum/objective/bloodsucker/vassalhim/check_completion()
	if(!target || target.has_antag_datum(/datum/antagonist/vassal))
		return TRUE
	return FALSE
