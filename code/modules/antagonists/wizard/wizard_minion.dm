/datum/antagonist/wizard_minion
	name = "Wizard Minion"
	antagpanel_category = ANTAG_GROUP_WIZARDS
	antag_hud_name = "apprentice"
	show_in_roundend = FALSE
	show_name_in_check_antagonists = TRUE
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_IGNORE // monkestation addition
	/// The wizard team this wizard minion is part of.
	var/datum/team/wizard/wiz_team

/datum/antagonist/wizard_minion/create_team(datum/team/wizard/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	wiz_team = new_team

/datum/antagonist/wizard_minion/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.faction |= ROLE_WIZARD
	add_team_hud(current_mob)

/datum/antagonist/wizard_minion/remove_innate_effects(mob/living/mob_override)
	var/mob/living/last_mob = mob_override || owner.current
	last_mob.faction -= ROLE_WIZARD

/datum/antagonist/wizard_minion/on_gain()
	create_objectives()
	. = ..()
	ADD_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))

/datum/antagonist/wizard_minion/on_removal()
	REMOVE_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))
	return ..()

/datum/antagonist/wizard_minion/proc/create_objectives()
	if(!wiz_team)
		return
	var/datum/objective/custom/custom_objective = new()
	custom_objective.owner = owner
	custom_objective.name = "Serve [wiz_team.master_wizard?.owner]"
	custom_objective.explanation_text = "Serve [wiz_team.master_wizard?.owner]"
	objectives += custom_objective

/datum/antagonist/wizard_minion/get_team()
	return wiz_team
