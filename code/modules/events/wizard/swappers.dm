/datum/round_event_control/wizard/swappers
	name = "The Swappers"
	weight = 1
	typepath = /datum/round_event/wizard/swappers
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Reveals a horrifying truth to everyone, giving them a trauma."
	admin_setup = list(/datum/event_admin_setup/input_number/swappers)

/datum/round_event/wizard/swappers
	///how many swappers to spawn
	var/amount_to_spawn = 2

/datum/round_event/wizard/swappers/start()


/datum/event_admin_setup/input_number/swappers
	input_text = "How many swappers do you want to spawn?"
	default_value = 2
	max_value = 10

/datum/event_admin_setup/input_number/swappers/apply_to_event(datum/round_event/wizard/swappers/event)
	event.amount_to_spawn = chosen_value
