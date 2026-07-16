#define REACTION_COOLDOWN_DURATION 10 SECONDS
/obj/item/clothing/neck/neckless/wizard_reactive //reactive armor for wizards that casts a spell when it reacts
	name = "reactive talisman"
	desc = "A reactive talisman for the reactive mage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | UNACIDABLE
	///ref to whomever the talisman is bound to
	var/mob/living/binding_owner
	///list of spells that can be cast by the talisman
	var/static/list/spell_list = list(/datum/action/cooldown/spell/rod_form, /datum/action/cooldown/spell/aoe/magic_missile,
									  /datum/action/cooldown/spell/emp/disable_tech, /datum/action/cooldown/spell/aoe/repulse/wizard,
								      /datum/action/cooldown/spell/timestop, /datum/action/cooldown/spell/forcewall, /datum/action/cooldown/spell/conjure/the_traps,
								      /datum/action/cooldown/spell/conjure/bee, /datum/action/cooldown/spell/conjure/simian,
								      /datum/action/cooldown/spell/teleport/radius_turf/blink)

	COOLDOWN_DECLARE(armor_cooldown) //unsure if I should use a world.time instead of this

/obj/item/clothing/neck/neckless/wizard_reactive/examine(mob/user)
	. = ..()
	if(binding_owner)
		. += "It is currently bound to [binding_owner.name]."
	else
		. += "It is currently unbound."

/obj/item/clothing/neck/neckless/wizard_reactive/attack_self(mob/user)
	. = ..()
	if(binding_owner)
		if(binding_owner == user)
			to_chat(user, "You start to unbind the talisman from yourself.")
			if(!do_after(user, 10 SECONDS))
				to_chat(user, "You fail to unbind the talisman from yourself.")
				return
			to_chat(user, "You unbind the talisman from yourself!")
			set_owner(null)
			return
		to_chat(user, "This talisman is already bound to someone else!.")
		return

	to_chat(user, "You start to bind the talisman to yourself.")
	if(!do_after(user, 10 SECONDS))
		to_chat(user, "You fail to bind the talisman to yourself.")
		return
	to_chat(user, "You bind the talisman to yourself!")
	set_owner(user)

//do the casting of the spell
/obj/item/clothing/neck/neckless/wizard_reactive/proc/talisman_activation()
	var/datum/action/cooldown/spell/new_spell = pick(spell_list)

	COOLDOWN_START(src, armor_cooldown, REACTION_COOLDOWN_DURATION)
	new_spell = new new_spell(binding_owner.mind || binding_owner)
	new_spell.owner_has_control = FALSE
	new_spell.spell_requirements = NONE
	new_spell.Grant(binding_owner)
	new_spell.cast(binding_owner)
	binding_owner.visible_message("The [src] glows brightly and casts [new_spell.name]!")
	qdel(new_spell)

/obj/item/clothing/neck/neckless/wizard_reactive/proc/set_owner(mob/living/new_owner)
	if(new_owner == binding_owner)
		return

	if(binding_owner)
		UnregisterSignal(binding_owner, list(COMSIG_LIVING_CHECK_BLOCK, COMSIG_QDELETING))

	binding_owner = new_owner
	if(new_owner)
		RegisterSignal(new_owner, COMSIG_QDELETING, PROC_REF(owner_qdel))
		RegisterSignal(new_owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))

/obj/item/clothing/neck/neckless/wizard_reactive/proc/check_block(mob/living/carbon/human/owner, atom/movable/hitby, damage, attack_text, attack_type, armour_penetration)
	SIGNAL_HANDLER
	if(!prob(50)) //high chanc, so no damage blocking
		return
	if(!COOLDOWN_FINISHED(src, armor_cooldown))
		owner.visible_message("The [src] glows faintly for a second and then fades.")
		return
	INVOKE_ASYNC(src, PROC_REF(talisman_activation))

/obj/item/clothing/neck/neckless/wizard_reactive/proc/owner_qdel()
	SIGNAL_HANDLER
	set_owner(null)

#undef REACTION_COOLDOWN_DURATION

