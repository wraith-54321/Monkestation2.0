#define BINGLE_EVOLVE "bingle evolve"
/* to add:
if too much trash on ground bingles roll

*/
/datum/antagonist/bingle
	name = "\improper Bingle"
	show_in_antagpanel = TRUE
	roundend_category =  "bingles"
	antagpanel_category =  ANTAG_GROUP_BINGLES
	job_rank = ROLE_BINGLE
	antag_hud_name = "bingle"
	show_name_in_check_antagonists =  TRUE
	hud_icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/bingle_hud.dmi'
	show_to_ghosts = TRUE
	antag_flags = FLAG_ANTAG_CAP_TEAM
	antag_count_points = 3
	var/static/datum/team/bingles/dont_bungle_the_bingle
	var/obj/structure/bingle_hole/pit_check

/datum/antagonist/bingle/get_preview_icon()
	return finish_preview_icon(icon('monkestation/code/modules/veth_misc_items/bingle/icons/bingles.dmi', "bingle"))

/datum/antagonist/bingle/on_gain()
	if(!dont_bungle_the_bingle)
		dont_bungle_the_bingle = new

	owner.special_role = ROLE_BINGLE
	owner.set_assigned_role(SSjob.GetJobType(/datum/job/bingle))
	dont_bungle_the_bingle.add_member(owner)
	return ..()

/datum/antagonist/bingle/antag_token(datum/mind/hosts_mind, mob/spender)
	var/spender_key = spender.key
	if(!spender_key)
		CRASH("bingle antag token spender([spender]) had no key")
	var/turf/spawn_loc = find_safe_turf_in_maintenance()//Used for the Drop Pod type of spawn for maints only
	if(isnull(spawn_loc))
		message_admins("Failed to find valid spawn location for [ADMIN_LOOKUPFLW(spender)], who spent a bingle antag token")
		CRASH("Failed to find valid spawn location for bingle antag token")
	if(isliving(spender) && hosts_mind)
		hosts_mind.current.unequip_everything()
		new /obj/effect/holy(hosts_mind.current.loc)
		QDEL_IN(hosts_mind.current, 1 SECOND)
	var/mob/living/basic/bingle/lord/bungle = new(spawn_loc)
	bungle.PossessByPlayer(spender_key)
	if(isobserver(spender))
		qdel(spender)
	message_admins("[ADMIN_LOOKUPFLW(bungle)] has been made into a bingle by using an antag token.")

/datum/antagonist/bingle/greet()
	. = ..()
	to_chat(owner.current, span_boldwarning("You are a [name]! You must feed the pit at any cost! You are VALID ON SIGHT, and do not require escalation."))

/datum/antagonist/bingle/get_team()
	return dont_bungle_the_bingle

/datum/action/cooldown/bingle/spawn_hole
	name = "Spawn Bingle Pit"
	desc = "Spawn the pit that you need to fill with items!"
	button_icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit.dmi'
	button_icon_state = "binglepit"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 15 SECONDS

/datum/action/cooldown/bingle/spawn_hole/Activate(atom/target)
	if(!isliving(owner))
		return FALSE
	var/turf/selected_turf = get_turf(owner)
	if(!check_hole_spawn(selected_turf))
		to_chat(owner, span_warning("This area doesn't have enough space to spawn a bingle pit! It needs a total of 3 by 3 meters of space!"))
		return FALSE
	spawn_hole(selected_turf)


/datum/action/cooldown/bingle/spawn_hole/proc/check_hole_spawn(turf/selected_turf)
	for(var/turf/adjacent_turf as anything in RANGE_TURFS(1, selected_turf))
		if(isnull(adjacent_turf) || adjacent_turf.density)
			return FALSE
	return TRUE

/datum/action/cooldown/bingle/spawn_hole/proc/spawn_hole(turf/selected_turf)
	var/datum/antagonist/bingle/bingle_datum = IS_BINGLE(owner)
	if(!selected_turf)
		to_chat(owner, span_notice("No selected turf found!"))
		return
	var/obj/structure/bingle_hole/hole = new(selected_turf)
	bingle_datum.pit_check = hole
	// Register the team in the pit
	hole.bingle_team = bingle_datum.get_team()
	astype(owner, /mob/living/basic/bingle)?.set_linked_pit(hole) // link the bingle to this binghole
	Remove(owner)
