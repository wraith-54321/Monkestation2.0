/datum/antagonist/gang_member
	///Ref to our team
	var/datum/team/gang/gang_team
	///What is our rank
	var/rank = GANG_RANK_MEMBER

/datum/antagonist/gang_member/proc/handle_pre_implant_removal(mob/living/source, silent, special)
	SIGNAL_HANDLER

	if(rank >= GANG_RANK_LIEUTENANT)
		return COMPONENT_STOP_IMPLANT_REMOVAL


/datum/antagonist/gang_member/proc/handle_implant_removal(mob/living/source, silent, special)
	SIGNAL_HANDLER
