/datum/round_event_control/wizard/swappers
	name = "The Swappers"
	weight = 1
	typepath = /datum/round_event/wizard/swappers
	max_occurrences = 0
	earliest_start = 0 MINUTES
	description = "Spawn a group of ghost players with AOE mindswap."
	admin_setup = list(/datum/event_admin_setup/input_number/swappers)

/datum/round_event/wizard/swappers
	///how many swappers to spawn
	var/amount_to_spawn = 2

/datum/round_event/wizard/swappers/start()
	var/list/candidates = SSpolling.poll_ghost_candidates("Would you like to be a [span_notice("magical mind swapper")]?",
														check_jobban = ROLE_WIZARD,
														alert_pic = /obj/item/clothing/head/wizard,
														role_name_text = "swapper")

	for(var/i in 1 to amount_to_spawn)
		var/mob/picked = pick_n_take(candidates)
		var/turf/spawn_at = get_safe_random_station_turf()
		var/mob/living/carbon/human/created = new /mob/living/carbon/human(spawn_at)
		do_smoke(4, holder = created, location = spawn_at)
		created.PossessByPlayer(picked.key)

/datum/event_admin_setup/input_number/swappers
	input_text = "How many swappers do you want to spawn?"
	default_value = 2
	max_value = 10

/datum/event_admin_setup/input_number/swappers/apply_to_event(datum/round_event/wizard/swappers/event)
	event.amount_to_spawn = chosen_value

/datum/action/cooldown/spell/aoe/mind_swap/swapper
	///Does our owner currently have the appearence we give
	var/gave_appearance = FALSE
	///The holder for our maptext
	var/static/atom/movable/maptext_holder/multi_parent/holder

/datum/action/cooldown/spell/aoe/mind_swap/swapper/Grant(mob/grant_to)
	. = ..()

/datum/action/cooldown/spell/aoe/mind_swap/swapper/Remove(mob/living/remove_from)
	. = ..()

/datum/action/cooldown/spell/aoe/mind_swap/swapper/process()
	. = ..()
	if(!gave_appearance && next_use_time <= world.time && iscarbon(owner))
		return
		/*var/mob/living/carbon/carbon_owner = owner
		if(carbon_owner.overlays_standing[layer_used])
			mut_overlay = carbon_owner.overlays_standing[layer_used]
			mut_overlay |= get_visual_indicator()
		carbon_owner.remove_overlay(layer_used)
		carbon_owner.overlays_standing[layer_used] = mut_overlay
		carbon_owner.apply_overlay(layer_used)*/
