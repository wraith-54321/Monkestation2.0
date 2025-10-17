/obj/item/organ/internal/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	visual = FALSE
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Your ears begin to resonate with an internal ring sometimes.</span>"
	now_failing = "<span class='warning'>You are unable to hear at all!</span>"
	now_fixed = "<span class='info'>Noise slowly begins filling your ears once more.</span>"
	low_threshold_cleared = "<span class='info'>The ringing in your ears has died down.</span>"

	// `deaf` measures "ticks" of deafness. While > 0, the person is unable
	// to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	//Resistance against loud noises
	var/bang_protect = 0
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/internal/ears/get_status_appendix(advanced, add_tooltips)
	if(owner.stat == DEAD || !HAS_TRAIT(owner, TRAIT_DEAF))
		return
	if(advanced)
		if(HAS_TRAIT_FROM(owner, TRAIT_DEAF, QUIRK_TRAIT))
			return conditional_tooltip("Subject is permanently deaf.", "Irreparable under normal circumstances.", add_tooltips)
		if(HAS_TRAIT_FROM(owner, TRAIT_DEAF, GENETIC_MUTATION))
			return conditional_tooltip("Subject is genetically deaf.", "Use medication such as [/datum/reagent/medicine/mutadone::name].", add_tooltips)
		if(HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
			return conditional_tooltip("Subject is [(organ_flags & ORGAN_FAILING) ? "permanently": "temporarily"] deaf from ear damage.", "Repair surgically, use medication such as [/datum/reagent/medicine/inacusiate::name], or protect ears with earmuffs.", add_tooltips)
	return "Subject is deaf."

/obj/item/organ/internal/ears/show_on_condensed_scans()
	// Always show if we have an appendix
	return ..() || (owner.stat != DEAD && deaf)

/obj/item/organ/internal/ears/on_life(seconds_per_tick, times_fired)
	. = ..()
	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here. Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		return

	if((organ_flags & ORGAN_FAILING))
		deaf = max(deaf, 1) // if we're failing we always have at least 1 deaf stack (and thus deafness)
	else // only clear deaf stacks if we're not failing
		deaf = max(deaf - (0.5 * seconds_per_tick), 0)
		if((damage > low_threshold) && SPT_PROB(damage / 60, seconds_per_tick))
			adjustEarDamage(0, 4)
			SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))

	update_hearing_loss()

/obj/item/organ/internal/ears/proc/adjustEarDamage(ddmg, ddeaf)
	if(HAS_TRAIT(owner, TRAIT_GODMODE))
		return

	// if we are already hard of hearing, don't accumulate the duration
	// instead adjust the amount of damage (so we might escalate to deafness) and reset the duration if appropriate
	if (ddeaf > 0 && HAS_TRAIT_FROM(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE))
		set_organ_damage(max(damage + (ddmg*damage_multiplier), 0))
		deaf = max(deaf, ddeaf*damage_multiplier*0.75)
		update_hearing_loss()
		return

	set_organ_damage(max(damage + (ddmg*damage_multiplier), 0))
	deaf = max(deaf + ddeaf*damage_multiplier*0.75, 0)
	update_hearing_loss()

/obj/item/organ/internal/ears/get_status_appendix(advanced, add_tooltips)
	if (owner.stat == DEAD)
		return
	if (advanced)
		if (HAS_TRAIT_FROM(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE))
			return "Subject is temporarily hard of hearing from ear damage."
	return ..()

/obj/item/organ/internal/ears/proc/update_hearing_loss()
	var/was_deaf = HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE)
	var/was_hoh = HAS_TRAIT_FROM(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)

	if (!deaf)
		if (was_deaf)
			REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		if (was_hoh)
			REMOVE_TRAIT(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)
		return

	if (damage < 25 && !(organ_flags & ORGAN_FAILING))
		ADD_TRAIT(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		if (!was_hoh)
			if (was_deaf)
				to_chat(owner, span_warning("You're able to hear again, but everything sounds quiet."))
			else
				to_chat(owner, span_warning("Everything goes quiet."))
	else
		ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		REMOVE_TRAIT(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)
		if (!was_deaf)
			to_chat(owner, span_warning("The ringing in your ears grows louder, blocking out any external noises."))

/obj/item/organ/internal/ears/invincible
	damage_multiplier = 0

/obj/item/organ/internal/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2

/obj/item/organ/internal/ears/cat/on_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = ear_owner.dna.species.mutant_bodyparts["ears"] = "Cat"
		ear_owner.dna.update_uf_block(DNA_EARS_BLOCK)
		ear_owner.update_body()

/obj/item/organ/internal/ears/cat/on_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.species.mutant_bodyparts -= "ears"
		ear_owner.update_body()

/obj/item/organ/internal/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."

/obj/item/organ/internal/ears/penguin/on_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
		ear_owner.AddElement(/datum/element/waddling)

/obj/item/organ/internal/ears/penguin/on_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("Your sense of balance comes back to you."))
		ear_owner.RemoveElement(/datum/element/waddling)

/obj/item/organ/internal/ears/bronze
	name = "tin ears"
	desc = "The robust ears of a bronze golem. "
	damage_multiplier = 0.1 //STRONK
	bang_protect = 1 //Fear me weaklings.

/obj/item/organ/internal/ears/cybernetic
	name = "basic cybernetic ears"
	icon_state = "ears-c"
	desc = "A basic cybernetic organ designed to mimic the operation of ears."
	damage_multiplier = 0.9
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/internal/ears/cybernetic/upgraded
	name = "cybernetic ears"
	icon_state = "ears-c-u"
	desc = "An advanced cybernetic ear, surpassing the performance of organic ears."
	damage_multiplier = 0.5

/obj/item/organ/internal/ears/cybernetic/whisper
	name = "whisper-sensitive cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Allows the user to more easily hear whispers. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2
	organ_traits = list(TRAIT_GOOD_HEARING)

// "X-ray ears" that let you hear through walls
/obj/item/organ/internal/ears/cybernetic/xray
	name = "wall-penetrating cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Through the power of modern engineering, allows the user to hear speech through walls. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2
	organ_traits = list(TRAIT_XRAY_HEARING)

/obj/item/organ/internal/ears/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(40/severity)
