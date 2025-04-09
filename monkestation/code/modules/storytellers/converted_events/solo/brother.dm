/datum/round_event_control/antagonist/solo/brother
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother
	typepath = /datum/round_event/antagonist/solo/brother
	tags = list(TAG_COMBAT, TAG_TEAM_ANTAG, TAG_CREW_ANTAG)
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_DETECTIVE,
		JOB_WARDEN,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
	)
	required_enemies = 1
	weight = 10
	maximum_antags = 2
	denominator = 30
	cost = 0.45 // so it doesn't eat up threat for a relatively low-threat antag

/datum/round_event_control/antagonist/solo/brother/roundstart
	name = "Blood Brothers"
	roundstart = TRUE
	earliest_start = 0 SECONDS
	extra_spawned_events = list(
		/datum/round_event_control/antagonist/solo/traitor/roundstart = 12,
		/datum/round_event_control/antagonist/solo/bloodsucker/roundstart = 4,
		/datum/round_event_control/antagonist/solo/heretic/roundstart = 2,
	)

/datum/round_event_control/antagonist/solo/brother/midround
	name = "Sleeper Agents (Blood Brothers)"
	prompted_picking = TRUE
	required_enemies = 2

/datum/round_event/antagonist/solo/brother/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/team/brother_team/team = new
	team.add_member(antag_mind)
	team.forge_brother_objectives()
	antag_mind.add_antag_datum(/datum/antagonist/brother, team)
