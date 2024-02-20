/datum/antagonist/gang_member
	///Ref to our team
	var/datum/team/gang/gang_team
	///What is our rank
	var/rank = GANG_RANK_MEMBER
	///Ref to our uplink handler
	var/datum/uplink_handler/gang/handler

/datum/antagonist/gang_member/create_team(datum/team/team)
	if(!team)
		gang_team = new
		return
	gang_team = team

/datum/antagonist/gang_member/get_team()
	return gang_team

///Change our datum type to a different one
/datum/antagonist/gang_member/proc/change_rank(datum/antagonist/gang_member/new_datum)
	silent = TRUE
	if(ispath(new_datum))
		new_datum = new new_datum()

	owner?.add_antag_datum(new_datum, gang_team)
	handler.can_take_objectives = new_datum.rank != 0 //return it as a bool
	handler.maximum_active_objectives = 1 * new_datum.rank
	handler.maximum_potential_objectives = 3 * new_datum.rank
	if(handler.maximum_potential_objectives)
		handler.generate_objectives()
	on_removal()

///Block imoplant removal if we are a lieutenant or higher
/datum/antagonist/gang_member/proc/handle_pre_implant_removal(mob/living/source, silent, special)
	SIGNAL_HANDLER
	if(rank >= GANG_RANK_LIEUTENANT)
		return COMPONENT_STOP_IMPLANT_REMOVAL

/datum/antagonist/gang_member/proc/handle_implant_removal(mob/living/source, silent, special)
	SIGNAL_HANDLER
	on_removal()

/datum/antagonist/gang_member/boss
	name = "Syndicate Gang Boss"
	rank = GANG_RANK_BOSS
	///How much TC does this gang boss have left to allocate to lieutenants
	var/unallocated_tc = 0

/datum/antagonist/gang_member/lieutenant
	name = "Syndicate Gang Lieutenant"
	rank = GANG_RANK_LIEUTENANT
