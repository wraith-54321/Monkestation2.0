/client/proc/add_admin_verbs()
	control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS
	SSadmin_verbs.assosciate_admin(src)

/client/proc/remove_admin_verbs()
	control_freak = initial(control_freak)
	SSadmin_verbs.deassosciate_admin(src)

ADMIN_VERB(hide_verbs, R_NONE, FALSE, "Adminverbs - Hide All", "Hide most of your admin verbs.", ADMIN_CATEGORY_MAIN)
	user.remove_admin_verbs()
	add_verb(user, /client/proc/show_verbs)

	to_chat(user, span_interface("Almost all of your adminverbs have been hidden."), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Hide All Adminverbs")

ADMIN_VERB(admin_ghost, R_ADMIN, FALSE, "AGhost", "Become a ghost without DNR.", ADMIN_CATEGORY_GAME)
	. = TRUE
	if(isobserver(user.mob))
		//re-enter
		var/mob/dead/observer/ghost = user.mob
		if(!ghost.mind || !ghost.mind.current) //won't do anything if there is no body
			return FALSE
		if(!ghost.can_reenter_corpse)
			log_admin("[key_name(user)] re-entered corpse")
			message_admins("[key_name_admin(user)] re-entered corpse")
		ghost.can_reenter_corpse = 1 //force re-entering even when otherwise not possible
		ghost.reenter_corpse()
		BLACKBOX_LOG_ADMIN_VERB("Admin Reenter")
	else if(isnewplayer(user.mob))
		to_chat(user, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>", confidential = TRUE)
		return FALSE
	else
		//ghostize
		log_admin("[key_name(user)] admin ghosted.")
		message_admins("[key_name_admin(user)] admin ghosted.")
		var/mob/body = user.mob
		body.ghostize(TRUE)
		user.init_verbs()
		if(body && !body.key)
			body.key = "@[user.key]" //Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		BLACKBOX_LOG_ADMIN_VERB("Admin Ghost")

ADMIN_VERB(invisimin, R_ADMIN, FALSE, "Inisimin", "Toggles ghost-like invisibility. (Don't abuse this)", ADMIN_CATEGORY_GAME)
	if(initial(user.mob.invisibility) == INVISIBILITY_OBSERVER)
		to_chat(user.mob, span_boldannounce("Invisimin toggle failed. You are already an invisible mob like a ghost."), confidential = TRUE)
		return

	if(user.mob.invisibility == INVISIBILITY_OBSERVER)
		user.mob.invisibility = initial(user.mob.invisibility)
		to_chat(user.mob, span_boldannounce("Invisimin off. Invisibility reset."), confidential = TRUE)
		return

	user.mob.invisibility = INVISIBILITY_OBSERVER
	to_chat(user.mob, span_adminnotice("<b>Invisimin on. You are now as invisible as a ghost.</b>"), confidential = TRUE)

ADMIN_VERB(check_antagonists, R_ADMIN, FALSE, "Check Antagonists", "See all antagonists for the round.", ADMIN_CATEGORY_GAME)
	user.holder.check_antagonists()
	log_admin("[key_name(user)] checked antagonists.")
	if(!isobserver(user.mob) && SSticker.HasRoundStarted())
		message_admins("[key_name_admin(user)] checked antagonists.")
	BLACKBOX_LOG_ADMIN_VERB("Check Antagonists")

ADMIN_VERB(list_bombers, R_ADMIN, FALSE, "List Bombers", "Look at all bombs and their likely culprit.", ADMIN_CATEGORY_GAME)
	user.holder.list_bombers()
	BLACKBOX_LOG_ADMIN_VERB("List Bombers")

ADMIN_VERB(list_signalers, R_ADMIN, FALSE, "List Signalers", "View all signalers.", ADMIN_CATEGORY_GAME)
	user.holder.list_signalers()
	BLACKBOX_LOG_ADMIN_VERB("List Signalers")

ADMIN_VERB(list_law_changes, R_ADMIN, FALSE, "List Law Changes", "View all AI law changes.", ADMIN_CATEGORY_DEBUG)
	user.holder.list_law_changes()
	BLACKBOX_LOG_ADMIN_VERB("List Law Changes")

ADMIN_VERB(show_manifest, R_ADMIN, FALSE, "Show Manifest", "View the shift's Manifest.", ADMIN_CATEGORY_DEBUG)
	user.holder.show_manifest()
	BLACKBOX_LOG_ADMIN_VERB("Show Manifest")

ADMIN_VERB(list_dna, R_ADMIN, FALSE, "List DNA", "View DNA.", ADMIN_CATEGORY_DEBUG)
	user.holder.list_dna()
	BLACKBOX_LOG_ADMIN_VERB("List DNA")

ADMIN_VERB(list_fingerprints, R_ADMIN, FALSE, "List Fingerprints", "View fingerprints.", ADMIN_CATEGORY_DEBUG)
	user.holder.list_fingerprints()
	BLACKBOX_LOG_ADMIN_VERB("List Fingerprints")

ADMIN_VERB(ban_panel, R_BAN, FALSE, "Banning Panel", "Ban players here.", ADMIN_CATEGORY_MAIN)
	user.holder.ban_panel()
	BLACKBOX_LOG_ADMIN_VERB("Banning Panel")

ADMIN_VERB(unban_panel, R_BAN, FALSE, "Unbanning Panel", "Unban players here.", ADMIN_CATEGORY_MAIN)
	user.holder.unban_panel()
	BLACKBOX_LOG_ADMIN_VERB("Unbanning Panel")

ADMIN_VERB(game_panel, R_ADMIN, FALSE, "Game Panel", "Look at the state of the game.", ADMIN_CATEGORY_GAME)
	user.holder.Game()
	BLACKBOX_LOG_ADMIN_VERB("Game Panel")

ADMIN_VERB(poll_panel, R_POLL, FALSE, "Server Poll Management", "View and manage polls.", ADMIN_CATEGORY_MAIN)
	user.holder.poll_list_panel()
	BLACKBOX_LOG_ADMIN_VERB("Server Poll Management")

/// Returns this client's stealthed ckey
/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/// Takes a stealthed ckey as input, returns the true key it represents
/proc/findTrueKey(stealth_key)
	if(!stealth_key)
		return
	for(var/potentialKey in GLOB.stealthminID)
		if(GLOB.stealthminID[potentialKey] == stealth_key)
			return potentialKey

/// Hands back a stealth ckey to use, guarenteed to be unique
/proc/generateStealthCkey()
	var/guess = rand(0, 1000)
	var/text_guess
	var/valid_found = FALSE
	while(valid_found == FALSE)
		valid_found = TRUE
		text_guess = "@[num2text(guess)]"
		// We take a guess at some number, and if it's not in the existing stealthmin list we exit
		for(var/key in GLOB.stealthminID)
			// If it is in the list tho, we up one number, and redo the loop
			if(GLOB.stealthminID[key] == text_guess)
				guess += 1
				valid_found = FALSE
				break

	return

/client/proc/createStealthKey()
	GLOB.stealthminID["[ckey]"] = generateStealthCkey()

ADMIN_VERB(stealth, R_STEALTH, FALSE, "Stealth Mode", "Toggle stealth.", ADMIN_CATEGORY_MAIN)
	if(user.holder.fakekey)
		user.disable_stealth_mode()
	else
		user.enable_stealth_mode()
	BLACKBOX_LOG_ADMIN_VERB("Stealth Mode")

#define STEALTH_MODE_TRAIT "stealth_mode"

/client/proc/enable_stealth_mode(new_key, source)
	if (!new_key)
		new_key = ckeyEx(stripped_input(usr, "Enter your desired display name.", "Fake Key", key, 26))
		if(!new_key)
			return
	holder.fakekey = new_key
	createStealthKey()
	if(isobserver(mob))
		mob.invisibility = INVISIBILITY_MAXIMUM //JUST IN CASE
		mob.alpha = 0 //JUUUUST IN CASE
		mob.name = " "
		mob.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		var/image/invisible = image(icon = 'icons/mob/simple/mob.dmi', icon_state = null, loc = mob)
		invisible.override = TRUE
		mob.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/actually_everyone, "stealthmin", invisible)

	ADD_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)
	QDEL_NULL(mob.orbiters)
	source = isnull(source) ? " via [source]." : ""
	log_admin("[key_name(usr)] has turned stealth mode ON (with key '[new_key]')[source]")
	message_admins("[key_name_admin(usr)] has turned stealth mode ON (with key '[new_key]')[source]")

/client/proc/disable_stealth_mode()
	var/previous_fakekey = holder.fakekey
	holder.fakekey = null
	if(isobserver(mob))
		mob.remove_alt_appearance("stealthmin")
		mob.invisibility = initial(mob.invisibility)
		mob.alpha = initial(mob.alpha)
		if(mob.mind)
			if(mob.mind.ghostname)
				mob.name = mob.mind.ghostname
			else
				mob.name = mob.mind.name
		else
			mob.name = mob.real_name
		mob.mouse_opacity = initial(mob.mouse_opacity)

	REMOVE_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)

	log_admin("[key_name(usr)] has turned stealth mode OFF (with previous key '[previous_fakekey]')")
	message_admins("[key_name_admin(usr)] has turned stealth mode OFF (with previous key '[previous_fakekey]')")

#undef STEALTH_MODE_TRAIT

ADMIN_VERB(drop_bomb, R_FUN, FALSE, "Drop Bomb", "Cause an explosion of varying strength at your location.", ADMIN_CATEGORY_FUN) //MONKE EDIT
	var/list/choices = list("Small Bomb (1, 2, 3, 3)", "Medium Bomb (2, 3, 4, 4)", "Big Bomb (3, 5, 7, 5)", "Maxcap", "Custom Bomb")
	var/choice = tgui_input_list(user, "What size explosion would you like to produce? NOTE: You can do all this rapidly and in an IC manner (using cruise missiles!) with the Config/Launch Supplypod verb. WARNING: These ignore the maxcap", "Drop Bomb", choices)
	if(isnull(choice))
		return
	var/turf/epicenter = get_turf(user.mob) //MONKE EDIT

	switch(choice)
		if("Small Bomb (1, 2, 3, 3)")
			explosion(epicenter, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 3, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Medium Bomb (2, 3, 4, 4)")
			explosion(epicenter, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, flash_range = 4, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Big Bomb (3, 5, 7, 5)")
			explosion(epicenter, devastation_range = 3, heavy_impact_range = 5, light_impact_range = 7, flash_range = 5, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Maxcap")
			explosion(epicenter, devastation_range = GLOB.MAX_EX_DEVESTATION_RANGE, heavy_impact_range = GLOB.MAX_EX_HEAVY_RANGE, light_impact_range = GLOB.MAX_EX_LIGHT_RANGE, flash_range = GLOB.MAX_EX_FLASH_RANGE, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Custom Bomb")
			var/range_devastation = input(user, "Devastation range (in tiles):") as null | num
			if(range_devastation == null)
				return
			var/range_heavy = input(user, "Heavy impact range (in tiles):") as null | num
			if(range_heavy == null)
				return
			var/range_light = input(user, "Light impact range (in tiles):") as null | num
			if(range_light == null)
				return
			var/range_flash = input(user, "Flash range (in tiles):") as null | num
			if(range_flash == null)
				return
			if(range_devastation > GLOB.MAX_EX_DEVESTATION_RANGE || range_heavy > GLOB.MAX_EX_HEAVY_RANGE || range_light > GLOB.MAX_EX_LIGHT_RANGE || range_flash > GLOB.MAX_EX_FLASH_RANGE)
				if(tgui_alert(user, "Bomb is bigger than the maxcap. Continue?",,list("Yes","No")) != "Yes")
					return
			epicenter = get_turf(user.mob) //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
	message_admins("[ADMIN_LOOKUPFLW(user.mob)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(user)] created an admin explosion at [epicenter.loc].")
	BLACKBOX_LOG_ADMIN_VERB("Drop Bomb")

ADMIN_VERB(drop_bomb_dynex, R_FUN, FALSE, "Drop DynEx Bomb", "Cause an explosion of varying strength at your location.", ADMIN_CATEGORY_FUN)
	var/ex_power = input("Explosive Power:") as null | num
	var/turf/epicenter = get_turf(user.mob)
	if(!ex_power || !epicenter)
		return
	dyn_explosion(epicenter, ex_power)
	message_admins("[ADMIN_LOOKUPFLW(user.mob)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(user)] created an admin explosion at [epicenter.loc].")
	BLACKBOX_LOG_ADMIN_VERB("Drop Dynamic Bomb")

ADMIN_VERB(get_dynex_range, R_FUN, FALSE, "Get DynEx Range", "Get the estimated range of a bomb using explosive power.", ADMIN_CATEGORY_DEBUG)
	var/ex_power = input(user, "Explosive Power:") as null | num
	if (isnull(ex_power))
		return
	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(user, "Estimated Explosive Range: (Devastation: [round(range*0.25)], Heavy: [round(range*0.5)], Light: [round(range)])", confidential = TRUE)

ADMIN_VERB(get_dynex_power, R_FUN, FALSE, "Get DynEx Power", "Get the estimated required power of a bomb to reach the given range.", ADMIN_CATEGORY_DEBUG)
	var/ex_range = input(user, "Light Explosion Range:") as null | num
	if (isnull(ex_range))
		return
	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(user, "Estimated Explosive Power: [power]", confidential = TRUE)

ADMIN_VERB(set_dynex_scale, R_FUN, FALSE, "Set DynEx Scale", "Set the scale multiplier on dynex explosions. Default 0.5.", ADMIN_CATEGORY_DEBUG)
	var/ex_scale = input(user, "New DynEx Scale:") as null | num
	if(!ex_scale)
		return
	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(usr)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(usr)] has  modified Dynamic Explosion Scale: [ex_scale]")

ADMIN_VERB(atmos_control, R_DEBUG | R_SERVER, FALSE, "Atmos Control Panel", "Open the atmospherics control panel.", ADMIN_CATEGORY_DEBUG)
	SSair.ui_interact(user.mob)

ADMIN_VERB(reload_cards, R_DEBUG, FALSE, "Reload Cards", "Reload all TCG cards.", ADMIN_CATEGORY_DEBUG)
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded.") //MONKE EDIT
		return
	SStrading_card_game.reloadAllCardFiles()

ADMIN_VERB(validate_cards, R_DEBUG, FALSE, "Validate Cards", "Validate the card settings.", ADMIN_CATEGORY_DEBUG)
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded.") //MONKE EDIT
		return
	var/message = SStrading_card_game.check_cardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.check_card_datums()
	if(message)
		message_admins(message)
	else
		message_admins("No errors found in card rarities or overrides.")

ADMIN_VERB(test_cardpack_distribution, R_DEBUG, FALSE, "Test Cardpack Distribution", "Test the distribution of a card pack.", ADMIN_CATEGORY_DEBUG)
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded.") //MONKE EDIT
		return
	var/pack = tgui_input_list(user, "Which pack should we test?", "You fucked it didn't you?", sort_list(SStrading_card_game.card_packs)) //MONKE EDIT
	if(!pack)
		return
	var/batch_count = tgui_input_number(user, "How many times should we open it?", "Don't worry, I understand.") //MONKE EDIT
	var/batch_size = tgui_input_number(user, "How many cards per batch?", "I hope you remember to check the validation.") //MONKE EDIT
	var/guar = tgui_input_number(user, "Should we use the pack's guaranteed rarity? If so, how many?", "We've all been there. Man you should have seen the old system.") //MONKE EDIT

	SStrading_card_game.check_card_distribution(pack, batch_size, batch_count, guar)

ADMIN_VERB(print_cards, R_DEBUG, FALSE, "Print Cards", "Print all cards to chat.", ADMIN_CATEGORY_DEBUG)
	SStrading_card_game.printAllCards()

///TG GIVE MOB ACTION WOULD GO HERE

ADMIN_VERB(give_spell, R_FUN, FALSE, "Give Spell", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/spell_recipient)
	var/which = tgui_alert(user, "Chose by name or by type path?", "Chose option", list("Name", "Typepath"))
	if(!which)
		return
	if(QDELETED(spell_recipient))
		to_chat(user, span_warning("The intended spell recipient no longer exists."))
		return

	var/list/spell_list = list()
	for(var/datum/action/cooldown/spell/to_add as anything in subtypesof(/datum/action/cooldown/spell))
		var/spell_name = initial(to_add.name)
		if(spell_name == "Spell") // abstract or un-named spells should be skipped.
			continue

		if(which == "Name")
			spell_list[spell_name] = to_add
		else
			spell_list += to_add

	var/chosen_spell = tgui_input_list(user, "Choose the spell to give to [spell_recipient]", "ABRAKADABRA", sort_list(spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/spell_path = which == "Typepath" ? chosen_spell : spell_list[chosen_spell]
	if(!ispath(spell_path))
		return

	var/robeless = (tgui_alert(user, "Would you like to force this spell to be robeless?", "Robeless Casting?", list("Force Robeless", "Use Spell Setting")) == "Force Robeless")

	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	BLACKBOX_LOG_ADMIN_VERB("Give Spell")
	log_admin("[key_name(user)] gave [key_name(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")
	message_admins("[key_name_admin(user)] gave [key_name_admin(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")

	var/datum/action/cooldown/spell/new_spell = new spell_path(spell_recipient.mind || spell_recipient)

	if(robeless)
		new_spell.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB
		new_spell.bypass_cost = TRUE //breaks balance, but allows non darkspawns to use darkspawn abilities

	new_spell.Grant(spell_recipient)

	if(!spell_recipient.mind)
		to_chat(user, span_userdanger("Spells given to mindless mobs will belong to the mob and not their mind, \
			and as such will not be transferred if their mind changes body (Such as from Mindswap)."))


ADMIN_VERB(remove_spell, R_FUN, FALSE, "Remove Spell", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/removal_target)
	var/list/target_spell_list = list()
	for(var/datum/action/cooldown/spell/spell in removal_target.actions)
		target_spell_list[spell.name] = spell

	if(!length(target_spell_list))
		return

	var/chosen_spell = tgui_input_list(user, "Choose the spell to remove from [removal_target]", "ABRAKADABRA", sort_list(target_spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/to_remove = target_spell_list[chosen_spell]
	if(!istype(to_remove))
		return

	qdel(to_remove)
	log_admin("[key_name(user)] removed the spell [chosen_spell] from [key_name(removal_target)].")
	message_admins("[key_name_admin(user)] removed the spell [chosen_spell] from [key_name_admin(removal_target)].")
	BLACKBOX_LOG_ADMIN_VERB("Remove Spell")

ADMIN_VERB(give_disease, R_FUN, FALSE, "Give Disease", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/living/victim)
	//MONKE EDIT START
	make_custom_virus(user, victim)
	//TODO Figure out how to return the new infection to report it in the logs
	log_admin("[key_name(user)] gave [key_name(victim)] a disease.")
	message_admins(span_adminnotice("[key_name_admin(user)] gave [key_name_admin(victim)] a disease."))
	//victim.ForceContractDisease(new D, FALSE, TRUE)
	//MONKE EDIT END
	BLACKBOX_LOG_ADMIN_VERB("Give Disease")

ADMIN_VERB_AND_CONTEXT_MENU(object_say, R_FUN, FALSE, "OSay", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, obj/speaker in world)
	var/message = tgui_input_text(user, "What do you want the message to be?", "Make Sound", encode = FALSE)
	if(!message)
		return
	speaker.say(message, sanitize = FALSE)
	log_admin("[key_name(user)] made [speaker] at [AREACOORD(speaker)] say \"[message]\"")
	message_admins(span_adminnotice("[key_name_admin(user)] made [speaker] at [AREACOORD(speaker)]. say \"[message]\""))
	BLACKBOX_LOG_ADMIN_VERB("Object Say")

ADMIN_VERB(build_mode_self, R_BUILD, FALSE, "Toggle Build Mode Self", "Toggle build mode for yourself.", ADMIN_CATEGORY_EVENTS)
	togglebuildmode(user.mob) // why is this a global proc???
	BLACKBOX_LOG_ADMIN_VERB("Toggle Build Mode")


ADMIN_VERB(check_ai_laws, R_ADMIN, FALSE, "Check AI Laws", "View the current AI laws.", ADMIN_CATEGORY_GAME)
	user.holder.output_ai_laws()

// TG MANAGE Religious Sect WOULD GO HERE

ADMIN_VERB(deadmin, R_NONE, FALSE, "DeAdmin", "Shed your admin powers.", ADMIN_CATEGORY_MAIN)
	user.holder.deactivate()
	to_chat(user, span_interface("You are now a normal player."))
	log_admin("[key_name(user)] deadminned themselves.")
	message_admins("[key_name_admin(user)] deadminned themselves.")
	BLACKBOX_LOG_ADMIN_VERB("Deadmin")

ADMIN_VERB(populate_world, R_DEBUG, FALSE, "Populate World", "Populate the world with test mobs.", ADMIN_CATEGORY_DEBUG, amount = 50 as num)
	for (var/i in 1 to amount)
		var/turf/tile = get_safe_random_station_turf_equal_weight()
		var/mob/living/carbon/human/hooman = new(tile)
		hooman.equipOutfit(pick(subtypesof(/datum/outfit)))
		testing("Spawned test mob at [get_area_name(tile, TRUE)] ([tile.x],[tile.y],[tile.z])")

ADMIN_VERB(toggle_ai_interact, R_ADMIN, FALSE, "Toggle Admin AI Interact", "Allows you to interact with most machines as an AI would as a ghost.", ADMIN_CATEGORY_GAME)
	var/doesnt_have_silicon_access = !HAS_TRAIT_FROM(user, TRAIT_AI_ACCESS, ADMIN_TRAIT)
	if(doesnt_have_silicon_access)
		ADD_TRAIT(user, TRAIT_AI_ACCESS, ADMIN_TRAIT)
	else
		REMOVE_TRAIT(user, TRAIT_AI_ACCESS, ADMIN_TRAIT)

	log_admin("[key_name(user)] has [doesnt_have_silicon_access ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(user)] has [doesnt_have_silicon_access ? "activated" : "deactivated"] their AI interaction")

ADMIN_VERB(debug_statpanel, R_DEBUG, FALSE, "Debug Stat Panel", "Toggles local debug of the stat panel", ADMIN_CATEGORY_DEBUG)
	user.stat_panel.send_message("create_debug")

ADMIN_VERB(display_sendmaps, R_DEBUG, FALSE, "Send Maps Profile", "View the profile.", ADMIN_CATEGORY_DEBUG)
	user << link("?debug=profile&type=sendmaps&window=test")

ADMIN_VERB(spawn_debug_full_crew, R_DEBUG, FALSE, "Spawn Debug Full Crew", "Creates a full crew for the station, flling datacore and assigning minds and jobs.", ADMIN_CATEGORY_DEBUG)
	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(user, "You should only be using this after a round has setup and started.")
		return

	// Two input checks here to make sure people are certain when they're using this.
	if(tgui_alert(user, "This command will create a bunch of dummy crewmembers with minds, job, and datacore entries, which will take a while and fill the manifest.", "Spawn Crew", list("Yes", "Cancel")) != "Yes")
		return

	if(tgui_alert(user, "I sure hope you aren't doing this on live. Are you sure?", "Spawn Crew (Be certain)", list("Yes", "Cancel")) != "Yes")
		return

	// Find the observer spawn, so we have a place to dump the dummies.
	var/obj/effect/landmark/observer_start/observer_point = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	var/turf/destination = get_turf(observer_point)
	if(!destination)
		to_chat(user, "Failed to find the observer spawn to send the dummies.")
		return

	// Okay, now go through all nameable occupations.
	// Pick out all jobs that have JOB_CREW_MEMBER set.
	// Then, spawn a human and slap a person into it.
	var/number_made = 0
	for(var/rank in SSjob.name_occupations)
		var/datum/job/job = SSjob.GetJob(rank)

		// JOB_CREW_MEMBER is all jobs that pretty much aren't silicon
		if(!(job.job_flags & JOB_CREW_MEMBER))
			continue

		// Create our new_player for this job and set up its mind.
		var/mob/dead/new_player/new_guy = new()
		new_guy.mind_initialize()
		new_guy.mind.name = "[rank] Dummy"

		// Assign the rank to the new player dummy.
		if(!SSjob.AssignRole(new_guy, job))
			qdel(new_guy)
			to_chat(user, "[rank] wasn't able to be spawned.")
			continue

		// It's got a job, spawn in a human and shove it in the human.
		var/mob/living/carbon/human/character = new(destination)
		character.name = new_guy.mind.name
		new_guy.mind.transfer_to(character)
		qdel(new_guy)

		// Then equip up the human with job gear.
		SSjob.EquipRank(character, job)
		job.after_latejoin_spawn(character)

		// Finally, ensure the minds are tracked and in the manifest.
		SSticker.minds += character.mind
		if(ishuman(character))
			GLOB.manifest.inject(character)

		number_made++
		CHECK_TICK

	to_chat(user, "[number_made] crewmembers have been created.")

ADMIN_VERB(debug_spell_requirements, R_DEBUG, FALSE, "Debug Spell Requirements", "View all spells and their requirements.", ADMIN_CATEGORY_DEBUG)
	var/header = "<tr><th>Name</th> <th>Requirements</th>"
	var/all_requirements = list()
	for(var/datum/action/cooldown/spell/spell as anything in typesof(/datum/action/cooldown/spell))
		if(initial(spell.name) == "Spell")
			continue

		var/list/real_reqs = list()
		var/reqs = initial(spell.spell_requirements)
		if(reqs & SPELL_CASTABLE_AS_BRAIN)
			real_reqs += "Castable as brain"
		if(reqs & SPELL_REQUIRES_HUMAN)
			real_reqs += "Must be human"
		if(reqs & SPELL_REQUIRES_MIME_VOW)
			real_reqs += "Must be miming"
		if(reqs & SPELL_REQUIRES_MIND)
			real_reqs += "Must have a mind"
		if(reqs & SPELL_REQUIRES_NO_ANTIMAGIC)
			real_reqs += "Must have no antimagic"
		if(reqs & SPELL_REQUIRES_STATION)
			real_reqs += "Must be on the station z-level"
		if(reqs & SPELL_REQUIRES_WIZARD_GARB)
			real_reqs += "Must have wizard clothes"

		all_requirements += "<tr><td>[initial(spell.name)]</td> <td>[english_list(real_reqs, "No requirements")]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[header][jointext(all_requirements, "")]</table>"
	var/datum/browser/popup = new(user.mob, "spellreqs", "Spell Requirements", 600, 400)
	popup.set_content(page_contents)
	popup.open()

ADMIN_VERB(load_lazy_template, R_ADMIN, FALSE, "Load/Jump Lazy Template", "Loads a lazy template and/or jumps to it.", ADMIN_CATEGORY_EVENTS)
	var/list/choices = LAZY_TEMPLATE_KEY_LIST_ALL()
	var/choice = tgui_input_list(user, "Key?", "Lazy Loader", choices)
	if(!choice)
		return
	choice = choices[choice]
	if(!choice)
		to_chat(user, span_warning("No template with that key found, report this!"))
		return

	var/already_loaded = LAZYACCESS(SSmapping.loaded_lazy_templates, choice)
	var/force_load = FALSE
	if(already_loaded && (tgui_alert(user, "Template already loaded.", "", list("Jump", "Load Again")) == "Load Again"))
		force_load = TRUE

	var/datum/turf_reservation/reservation = SSmapping.lazy_load_template(choice, force = force_load)
	if(!reservation)
		to_chat(user, span_boldwarning("Failed to load template!"))
		return

	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)
	user.mob.forceMove(reservation.bottom_left_turfs[1])

	message_admins("[key_name_admin(user)] has loaded lazy template '[choice]'")
	to_chat(user, span_boldnicegreen("Template loaded, you have been moved to the bottom left of the reservation."))

ADMIN_VERB(library_control, R_BAN, FALSE, "Library Management", "List and manage the Library.", ADMIN_CATEGORY_MAIN)
	if(!user.holder.library_manager)
		user.holder.library_manager = new
	user.holder.library_manager.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Library Management")

ADMIN_VERB(create_mob_worm, R_FUN, FALSE, "Create Mob Worm", "Attach a linked list of mobs to your marked mob.", ADMIN_CATEGORY_FUN)
	if(!isliving(user.holder.marked_datum))
		to_chat(user, span_warning("Error: Please mark a mob to attach mobs to."))
		return
	var/mob/living/head = user.holder.marked_datum

	var/attempted_target_path = tgui_input_text(
		user,
		"Enter typepath of a mob you'd like to make your chain from.",
		"Typepath",
		"[/mob/living/basic/pet/dog/corgi/ian]",
	)

	if (isnull(attempted_target_path))
		return //The user pressed "Cancel"

	var/desired_mob = text2path(attempted_target_path)
	if(!ispath(desired_mob))
		var/static/list/mob_paths = make_types_fancy(subtypesof(/mob/living))
		desired_mob = pick_closest_path(attempted_target_path, mob_paths)
	if(isnull(desired_mob) || !ispath(desired_mob) || QDELETED(head))
		return //The user pressed "Cancel"

	var/amount = tgui_input_number(user, "How long should our tail be?", "Worm Configurator", default = 3, min_value = 1)
	if (isnull(amount) || amount < 1 || QDELETED(head))
		return
	head.AddComponent(/datum/component/mob_chain)
	var/mob/living/previous = head
	for (var/i in 1 to amount)
		var/mob/living/segment = new desired_mob(head.drop_location())
		if (QDELETED(segment)) // ffs mobs which replace themselves with other mobs
			i--
			continue
		ADD_TRAIT(segment, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT)
		QDEL_NULL(segment.ai_controller)
		segment.AddComponent(/datum/component/mob_chain, front = previous)
		previous = segment

ADMIN_VERB(clear_legacy_asset_cache, R_DEBUG, FALSE, "Clear Legacy Asset Cache", "Clears the legacy asset cache, regenerating it immediately (may cause lag).", ADMIN_CATEGORY_DEBUG)
	if(!CONFIG_GET(flag/cache_assets))
		to_chat(user, span_warning("Asset caching is disabled in the config!"))
		return
	var/regenerated = 0
	for(var/datum/asset/target_spritesheet as anything in subtypesof(/datum/asset))
		if(!initial(target_spritesheet.cross_round_cachable))
			continue
		if(target_spritesheet == initial(target_spritesheet._abstract))
			continue
		var/datum/asset/asset_datum = GLOB.asset_datums[target_spritesheet]
		asset_datum.regenerate()
		regenerated++
	to_chat(user, span_notice("Regenerated [regenerated] asset\s."))

ADMIN_VERB(clear_smart_asset_cache, R_DEBUG, FALSE, "Clear Smart Asset Cache", "Clear the smart asset cache, causing it to regenerate next round.", ADMIN_CATEGORY_DEBUG)
	if(!CONFIG_GET(flag/smart_cache_assets))
		to_chat(user, span_warning("Smart asset caching is disabled in the config!"))
		return
	var/cleared = 0
	for(var/datum/asset/spritesheet_batched/target_spritesheet as anything in subtypesof(/datum/asset/spritesheet_batched))
		if(target_spritesheet == initial(target_spritesheet._abstract))
			continue
		fdel("[ASSET_CROSS_ROUND_SMART_CACHE_DIRECTORY]/spritesheet_cache.[initial(target_spritesheet.name)].json")
		cleared++
	to_chat(user, span_notice("Cleared [cleared] asset\s."))
