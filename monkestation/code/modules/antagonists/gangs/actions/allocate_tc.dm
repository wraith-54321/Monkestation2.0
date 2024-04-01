/datum/action/innate/allocate_gang_tc
	name = "Allocate Telecrystals"
	desc = "Allocate the free flowing telecrystals within your gang's network to yourself and your lieutenants."
	button_icon = 'icons/obj/telescience.dmi'
	button_icon_state = "telecrystal_3"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/allocate_gang_tc/Activate()
	if(!IsAvailable())
		return

	var/datum/antagonist/gang_member/antag_owner = IS_GANGMEMBER(owner)
	if(!antag_owner)
		to_chat(owner, "You are not a gangmember and should not have this!")
		CRASH("[src] calling Activate() with an owner\[[owner]\] who lacks a gangmember antag datum.")

	if(!antag_owner.gang_team)
		to_chat(owner, "You are not in a gang and should not have this!")
		CRASH("[src] calling Activate() with an owner\[[owner]\] who is not in a gang.")

	if(!antag_owner.gang_team.unallocated_tc)
		to_chat(owner, "Your gang does not have any unallocated TC.")
		return

	var/list/ranking_member_handlers = list()
	for(var/datum/antagonist/gang_member/antag_datum in antag_owner.gang_team.member_datums_by_rank[GANG_RANK_BOSS] + antag_owner.gang_team.member_datums_by_rank[GANG_RANK_LIEUTENANT])
		if(!antag_datum.owner)
			continue

		ranking_member_handlers[antag_datum.owner] = antag_datum.handler

	if(!length(ranking_member_handlers))
		CRASH("[src] calling Activate() without ranking_member_handlers length")

	var/datum/uplink_handler/gang/chosen_handler = tgui_input_list(owner, "Who would you like to allocate to?", "Allocate TC", ranking_member_handlers)
	if(!chosen_handler)
		return

	chosen_handler = ranking_member_handlers[chosen_handler]
	var/chosen_amount = tgui_input_number(owner, "How much would you like to allocate?", "Allocate TC", max_value = antag_owner.gang_team.unallocated_tc, min_value = 0, round_value = TRUE)
	if(!chosen_amount || antag_owner.gang_team.unallocated_tc < chosen_amount)
		return

	chosen_handler.telecrystals += chosen_amount
	chosen_handler.on_update()
	antag_owner.gang_team.unallocated_tc -= chosen_amount
