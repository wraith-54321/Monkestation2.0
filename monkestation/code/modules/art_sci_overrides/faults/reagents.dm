/datum/artifact_fault/reagent
	name = "Chemical Force Injector Fault"
	trigger_chance = 15
	visible_message = "shoots a syringe out."
	var/list/reagents = list()

	research_value = TECHWEB_DISCOUNT_MINOR / 2

/datum/artifact_fault/reagent/on_trigger()
	. = ..()
	if(!length(reagents))
		return

	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/carbon/living in range(rand(3, 5), center_turf))
		living.reagents.add_reagent(pick(reagents), rand(1, 5))
		to_chat(living, span_warning("You feel a soft prick."))

/datum/artifact_fault/reagent/poison
	name = "Poison"

/datum/artifact_fault/reagent/poison/on_trigger()
	if(!reagents.len) //mostly copied from reagents.dm but oh well
		for(var/datum/reagent/reagent as anything in subtypesof(/datum/reagent/toxin))
			if(initial(reagent.chemical_flags) & REAGENT_CAN_BE_SYNTHESIZED)
				reagents += reagent
	. = ..()
