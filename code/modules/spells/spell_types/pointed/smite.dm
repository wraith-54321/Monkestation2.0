#define HEAVY_SMITE "heavy"
#define LIGHT_SMITE "light"

/datum/action/cooldown/spell/pointed/smite
	name = "Smite"
	desc = "A spell to strike down your foes from the heavens."
	button_icon_state = "gib"
	sound = 'sound/magic/disintegrate.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 8 SECONDS
	cast_range = 3
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY // the gods have mercy upon the holy

	invocation = "EI NATH!!"

	spell_max_level = 3

	active_msg = "You prepare to smite your foe..."
	deactive_msg = "You dispel your power."

	/// the prob of a heavy smite being picked
	var/heavy_smite_chance = 30
	/// list of smites that have a high effect on the target, if a smite is not in one of these lists then it cannot be picked(besides rod which is unique)
	var/list/heavy_smites = list(
		/datum/smite/berforate,
		/datum/smite/bloodless,
		/datum/smite/boneless,
		/datum/smite/brain_damage,
		/datum/smite/bsa,
		/datum/smite/gib,
		/datum/smite/nugget,
		/datum/smite/puzzgrid,
		/datum/smite/puzzle,
	)

	/// list of smites that have a low effect on the target
	var/list/light_smites = list(
		/datum/smite/bad_luck,
		/datum/smite/fake_bwoink,
		/datum/smite/fat,
		/datum/smite/ghost_control,
		/datum/smite/immerse,
		/datum/smite/knot_shoes,
		/datum/smite/ocky_icky,
		/datum/smite/scarify,
		/datum/smite/fireball,
		/datum/smite/lightning,
	)

/datum/action/cooldown/spell/pointed/smite/level_spell(bypass_cap)
	. = ..()
	if(!.)
		return

	heavy_smite_chance += 30

/datum/action/cooldown/spell/pointed/smite/get_spell_title()
	switch(spell_level)
		if(2)
			return "Greater "
		if(3)
			return "Divine "
	return ""

/datum/action/cooldown/spell/pointed/smite/is_valid_target(atom/cast_on)
	if(cast_on == owner)
		return FALSE
	if(!iscarbon(cast_on)) //im just gonna make this only work on carbon mobs
		cast_on.balloon_alert(owner, "can only be cast on advanced life forms!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/smite/cast(mob/living/carbon/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel as if the gods have granted you mercy."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	var/smite_type
	if(prob(heavy_smite_chance))
		smite_type = HEAVY_SMITE
	else
		smite_type = LIGHT_SMITE

	var/datum/smite/picked_smite
	if(smite_type == HEAVY_SMITE)
		if(prob(7))
			picked_smite = /datum/smite/rod //very high impact so it should be rare
		else
			picked_smite = pick(heavy_smites)
	else
		picked_smite = pick(light_smites)

	switch(picked_smite) //subtype vars moment, I really want a better way to do this
		if(/datum/smite/bad_luck)
			var/datum/smite/bad_luck/luck_smite = new picked_smite
			luck_smite.incidents = INFINITY
			picked_smite = luck_smite
		if(/datum/smite/berforate)
			var/datum/smite/berforate/shoot_smite = new picked_smite
			shoot_smite.hatred = "A lot"
			picked_smite = shoot_smite
		if(/datum/smite/puzzgrid)
			var/datum/smite/puzzgrid/puzz_smite = new picked_smite
			puzz_smite.gib_on_loss = TRUE
			picked_smite = puzz_smite
		else
			picked_smite = new picked_smite

	picked_smite.should_log = FALSE
	picked_smite.effect(owner.client, target)
	if(picked_smite.should_del)
		qdel(picked_smite)
	to_chat(owner, span_notice("You call down a strike from the heavens upon [cast_on], resulting in [picked_smite.name]!"))

/datum/action/cooldown/spell/pointed/smite/light //used for clown casting and admemery
	name = "\"Harmless\" Smite"
	desc = "For those who just want to watch the world burn."
	cooldown_time = 3 SECONDS
	heavy_smite_chance = 0
	spell_max_level = 1

/datum/action/cooldown/spell/pointed/smite/light/New(Target)
	. = ..()
	light_smites += /datum/smite/puzzle

#undef HEAVY_SMITE
#undef LIGHT_SMITE
