/datum/objective/highest_gang_rep
	name = "Highest reputation"
	explanation_text = "Have more reputation then any other gang."

/datum/objective/highest_gang_rep/check_completion()
	var/static/highest_rep
	if(!highest_rep)
		highest_rep = 0
		for(var/tag, gang in GLOB.all_gangs_by_tag)
			var/datum/team/gang/gang_team = gang
			if(gang_team.rep > highest_rep)
				highest_rep = gang_team.rep
	return astype(team, /datum/team/gang).rep >= highest_rep
