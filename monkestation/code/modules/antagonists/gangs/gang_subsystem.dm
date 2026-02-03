#define DESIRED_AREAS_PER_TC_PER_MINUTE 10
#define DESIRED_AREAS_PER_THREAT_PER_MINUTE 4
PROCESSING_SUBSYSTEM_DEF(gangs)
	name = "Gangs"
	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_HIBERNATE
	wait = 10 SECONDS
	runlevels = RUNLEVEL_GAME
	///assoc list of areas with values of amounts to multiply their rewards by
	var/list/gang_area_multipliers
	///assoc list of gangs keyed to their tag
	var/alist/all_gangs_by_tag
	///assoc list of stored rep for a gang
	var/list/cached_extra_rep
	///assoc list of gang outfit items with key values of how much representation they provide
	var/alist/gang_outfits = alist() //starts as a list so we dont need to init the entire SS for a single peice of clothing getting spawned

/datum/controller/subsystem/processing/gangs/PreInit()
	. = ..()
	hibernate_checks += NAMEOF(src, all_gangs_by_tag)

/datum/controller/subsystem/processing/gangs/Initialize()
	initialized = TRUE
	all_gangs_by_tag = alist()
	cached_extra_rep = list()
	gang_area_multipliers = list(
	/area/station/command = 2,
	/area/station/security = 2,
	/area/station/ai_monitored = 2,
	/area/station/maintenance = 0.5,
	)
	for(var/area in gang_area_multipliers)
		var/mult = gang_area_multipliers[area]
		for(var/type in typesof(area))
			gang_area_multipliers[type] = mult * 0.167

/datum/controller/subsystem/processing/gangs/fire(resumed)
	if(!initialized) //we hibernate so this wont get called until we are needed
		Initialize()

	var/static/log_cooldown
	if(!log_cooldown)
		log_cooldown = world.time + 5 MINUTES

	var/list/given_rewards = list()
	for(var/area in GLOB.gang_controlled_areas) //might want to use this to give gangs a printout of their controlled areas
		var/datum/team/gang/area_owner = GLOB.gang_controlled_areas[area]
		var/list/rewards = given_rewards[area_owner]
		var/area_mult = gang_area_multipliers[area] || 0.167 //one sixth
		if(!rewards)
			rewards = list("tc" = 0, "rep" = 0)
			given_rewards[area_owner] = rewards
		//note these values assume we are running on time, might be able to make these be based on SPT
		rewards["tc"] += area_mult / DESIRED_AREAS_PER_TC_PER_MINUTE
		rewards["rep"] += area_mult / DESIRED_AREAS_PER_THREAT_PER_MINUTE

	for(var/datum/team/gang/gang_team in given_rewards)
		var/rep_value = given_rewards[gang_team]["rep"] + (cached_extra_rep[gang_team] || 0)
		var/rounded_rep_value = round(rep_value, 0.1)
		cached_extra_rep[gang_team] = rep_value - rounded_rep_value

		gang_team.unallocated_tc = round((gang_team.unallocated_tc + given_rewards[gang_team]["tc"]), 0.001)
		gang_team.rep = round(rounded_rep_value + gang_team.rep, 0.1)

	for(var/tag, gang in all_gangs_by_tag)
		var/datum/team/gang/gang_datum = gang
		gang_datum.update_handler_rep()

	//if this ends up being kept the code for this can be improved
	if(world.time >= log_cooldown)
		log_cooldown = world.time + 5 MINUTES
		var/text = "gang_rep_values: "
		for(var/tag, gang in all_gangs_by_tag)
			var/datum/team/gang/g = gang
			text += "[g.name]: [g.rep] "
		text += "at: [DisplayTimeText(world.time)]"
		log_game(text)

///Call to add a piece of clothing to gang_outfits
/datum/controller/subsystem/processing/gangs/proc/register_gang_clothing(obj/item/clothing/registered, value = 1)
	gang_outfits[registered] = value
	RegisterSignal(registered, COMSIG_QDELETING, PROC_REF(gang_clothing_destroyed))

/datum/controller/subsystem/processing/gangs/proc/gang_clothing_destroyed(obj/item/clothing/destroyed)
	SIGNAL_HANDLER
	UnregisterSignal(destroyed, COMSIG_QDELETING)
	gang_outfits -= destroyed

#undef DESIRED_AREAS_PER_TC_PER_MINUTE
#undef DESIRED_AREAS_PER_THREAT_PER_MINUTE
