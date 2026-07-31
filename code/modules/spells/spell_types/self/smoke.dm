/// Basic smoke spell.
/datum/action/cooldown/spell/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of smoke at your location. \
		People within will begin to choke and drop their items."
	button_icon_state = "smoke"

	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = -7 SECONDS
	spell_requirements = NONE
	spell_max_level = 3

	invocation_type = INVOCATION_NONE
	smoke_amt = 4

/datum/action/cooldown/spell/smoke/get_spell_title()
	switch(spell_level)
		if(2)
			return "Choking "
		if(3)
			return "Suffocating "
	return ""

/datum/action/cooldown/spell/smoke/cast(atom/cast_on)
	. = ..()
	if(!smoke_type) //so we can level it properly
		var/datum/effect_system/fluid_spread/smoke/bad/smoke = new /datum/effect_system/fluid_spread/smoke/bad()
		//smoke code is so bad but I dont have time to fix it
		if(spell_level == 2)
			smoke.effect_type = /obj/effect/particle_effect/fluid/smoke/bad/lv_two
		else if(spell_level == 3)
			smoke.effect_type = /obj/effect/particle_effect/fluid/smoke/bad/lv_three
		smoke.set_up(smoke_amt, holder = owner, location = get_turf(owner))
		smoke.start()

/// Chaplain smoke.
/datum/action/cooldown/spell/smoke/lesser
	name = "Holy Smoke"
	desc = "This spell spawns a small cloud of smoke at your location."

	school = SCHOOL_HOLY
	cooldown_time = 36 SECONDS

	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 2

/// Unused smoke that makes people sleep. Used to be for cult?
/datum/action/cooldown/spell/smoke/disable
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."
	background_icon_state = "bg_cult"
	overlay_icon_state = "bg_cult_border"


	cooldown_time = 20 SECONDS

	smoke_type = /datum/effect_system/fluid_spread/smoke/sleeping
