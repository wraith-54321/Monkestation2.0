/datum/antagonist/gang_member
	///Ref to our team
	var/datum/team/gang/gang_team
	///What is our rank
	var/rank = GANG_RANK_MEMBER
	///Ref to our uplink handler
	var/datum/uplink_handler/gang/handler

/datum/antagonist/gang_member/create_team(datum/team/team)
	if(!team)
		gang_team = new()
		return
	gang_team = team

/datum/antagonist/gang_member/get_team()
	return gang_team

/datum/antagonist/gang_member/on_gain()
	. = ..()
	var/list/member_list = gang_team.member_datums_by_rank["[rank]"]
	if(!member_list)
		member_list = list()
		gang_team.member_datums_by_rank["[rank]"] = member_list
	member_list += src

	objectives += gang_team.objectives
	handler.can_take_objectives = rank != 0 //return it as a bool
	handler.maximum_active_objectives = 1 * rank //this actually just works, but if you for some reason ever mess with ranks this will break
	handler.maximum_potential_objectives = 3 * rank
	if(handler.maximum_potential_objectives)
		handler.generate_objectives()

/datum/antagonist/gang_member/on_removal()
	. = ..()
	gang_team.member_datums_by_rank["[rank]"] -= src

///Change our datum type to a different one
/datum/antagonist/gang_member/proc/change_rank(datum/antagonist/gang_member/new_datum)
	if(ispath(new_datum))
		new_datum = new new_datum()

	silent = TRUE
	on_removal()
	owner?.add_antag_datum(new_datum, gang_team)

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

/datum/antagonist/gang_member/lieutenant
	name = "Syndicate Gang Lieutenant"
	rank = GANG_RANK_LIEUTENANT
