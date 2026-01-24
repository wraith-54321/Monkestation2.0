/datum/objective/highest_gang_rep
	name = "Highest reputation"
	explanation_text = "Have more reputation then any other gang."

/datum/objective/highest_gang_rep/check_completion()
	var/static/datum/team/gang/highest_rep_gang
	if(!highest_rep_gang)
		var/highest_rep = 0
		for(var/tag in GLOB.all_gangs_by_tag)
			var/datum/team/gang/gang_team = GLOB.all_gangs_by_tag[tag]
			if(gang_team.rep > highest_rep)
				highest_rep = gang_team.rep
				highest_rep_gang = gang_team
	return team == highest_rep_gang
