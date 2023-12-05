/datum/team/gang
	name = "Syndicate Gang"
	///What gang data do we use(what syndicate orginization are we aligned with)
	var/datum/gang_data/our_gang_type = /datum/gang_data
	///assoc list of uplink handlers for our gang leaders, keyed to the mind that owns the handler
	var/list/handlers = list()
	///how much TC does the gang boss have left to allocate to lieutenants
	var/unallocated_tc = 0

/datum/team/gang/New(starting_members)
	. = ..()
	set_gang_info()

///set up all our stuff for our gang_data, if there is already another gang then we wont pick from their blacklisted types for our data. forced_type will just set our data to whats passed
/datum/team/gang/proc/set_gang_info(/datum/gang_data/forced_type)
	if(forced_type)
		our_gang_type = forced_type
	else
		var/list/blacklisted_types = list()
//		for(var/datum/team/gang/other_gang in GLOB.antagonist_teams)
//			blacklisted_types += other_gang.our_gang_type.blacklisted_enemy_gangs

//		if(length(blacklisted_types) == length(subtypesof(/datum/gang_data)))
//			blacklisted_types = list() //if we somehow get every type blacklisted then just make blacklist_types empty so we pick randomly

		our_gang_type = pick(typesof(/datum/gang_data) - blacklisted_types) //convert this to subtypes

	for(var/datum/mind/gang_member in members)
		var/datum/antagonist/gang_member/member_datum = IS_GANGMEMBER(gang_member)
		member_datum.set_title(our_gang_type)
