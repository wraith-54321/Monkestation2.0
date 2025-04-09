/datum/round_event_control/antagonist/solo/wizard
	name = "Wizard"
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_MAGICAL, TAG_OUTSIDER_ANTAG)
	typepath = /datum/round_event/antagonist/solo/wizard
	antag_flag = ROLE_WIZARD
	antag_datum = /datum/antagonist/wizard
	shared_occurence_type = SHARED_HIGH_THREAT
	restricted_roles = list(
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_HEAD_OF_SECURITY,
	) // Just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	maximum_antags = 1
	enemy_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 5
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 2
	min_players = 35
	max_occurrences = 1
	event_icon_state = "wizard"

/datum/round_event_control/antagonist/solo/wizard/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!.)
		return
	if(!length(GLOB.wizardstart))
		return FALSE

/datum/round_event/antagonist/solo/wizard

/datum/round_event/antagonist/solo/wizard/add_datum_to_mind(datum/mind/antag_mind)
	var/mob/living/current_mob = antag_mind.current
	SSjob.FreeRole(antag_mind.assigned_role.title)
	current_mob.clear_inventory()

	var/mob/living/carbon/human/new_player_mob = new //while funny, it would kind of suck to be a blind criple wizard
	antag_mind.transfer_to(new_player_mob)
	qdel(current_mob)
	antag_mind.make_wizard()
