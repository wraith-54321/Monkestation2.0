/datum/round_event_control/antagonist/solo/clockcult
	name = "Clock Cult"
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_MAGICAL)
	antag_flag = ROLE_CLOCK_CULTIST
	antag_datum = /datum/antagonist/clock_cultist
	typepath = /datum/round_event/antagonist/solo/clockcult
	shared_occurence_type = SHARED_HIGH_THREAT
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 5
	base_antags = 4
	maximum_antags = 4
	min_players = 45
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 0
	max_occurrences = 1
	event_icon_state = "clockcult"
	preferred_events = list(/datum/round_event_control/antagonist/solo/bloodcult = 1)

/datum/round_event/antagonist/solo/clockcult
	end_when = 60000

/datum/round_event/antagonist/solo/clockcult/setup()
	. = ..()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_reebe))

/datum/round_event/antagonist/solo/clockcult/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.special_role = ROLE_CLOCK_CULTIST
	antag_mind.add_antag_datum(antag_datum)
