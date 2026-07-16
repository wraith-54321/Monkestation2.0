/datum/action/cooldown/spell/pointed/projectile/bouncy_fire_ball
	name = "Fire Ball"
	desc = "This spell fires a ball of fire at a target. Watch out for collateral."
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "fire_ball"

	sound = 'sound/magic/fireball.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 6 SECONDS
	invocation = "ONI SOMA!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	active_msg = "You prepare to cast your fire ball spell!"
	deactive_msg = "You extinguish your fire ball... for now."
	spell_max_level = 3
	cast_range = 8
	projectile_type = /obj/projectile/magic/fire_ball

/datum/action/cooldown/spell/pointed/projectile/bouncy_fire_ball/level_spell(bypass_cap)
	. = ..()
	projectile_amount++ //become the schoolyard bully
	unset_after_click = FALSE
	if(spell_level == spell_max_level)
		projectiles_per_fire++

/datum/action/cooldown/spell/pointed/projectile/bouncy_fire_ball/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	to_fire.ricochets_max += spell_level - 1
	if(iteration > 1)
		to_fire.set_angle(dir2angle(user.dir) + rand(-15, 15))
