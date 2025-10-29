/obj/item/gun/energy/recharge/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure."
	icon_state = "kineticgun"
	base_icon_state = "kineticgun"
	inhand_icon_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_LIGHT
	can_bayonet = TRUE
	knife_x_offset = 20
	knife_y_offset = 12
	var/mob/holder
	var/max_mod_capacity = 100
	var/list/modkits = list()
	gun_flags = NOT_A_REAL_GUN
	var/disablemodification = FALSE //monkeedit - stops removal and addition of mods

/obj/item/gun/energy/recharge/kinetic_accelerator/apply_fantasy_bonuses(bonus)
	. = ..()
	max_mod_capacity = modify_fantasy_variable("max_mod_capacity", max_mod_capacity, bonus * 10)

/obj/item/gun/energy/recharge/kinetic_accelerator/remove_fantasy_bonuses(bonus)
	max_mod_capacity = reset_fantasy_variable("max_mod_capacity", max_mod_capacity)
	return ..()

/obj/item/gun/energy/recharge/kinetic_accelerator/Initialize(mapload)
	. = ..()

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		rmb_text = "Detach a modkit", \
	)

	var/static/list/tool_behaviors = list(
		TOOL_CROWBAR = list(
			SCREENTIP_CONTEXT_LMB = "Eject all modkits",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/item/gun/energy/recharge/kinetic_accelerator/shoot_with_empty_chamber(mob/living/user)
	playsound(src, dry_fire_sound, 30, TRUE) //click sound but no to_chat message to cut on spam
	return

/obj/item/gun/energy/recharge/kinetic_accelerator/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 9)

/obj/item/gun/energy/recharge/kinetic_accelerator/examine(mob/user)
	. = ..()
	if(max_mod_capacity)
		. += "<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining."
		. += span_info("You can use a <b>crowbar</b> to remove all modules or <b>right-click</b> with an empty hand to remove a specific one.")
		for(var/A in modkits)
			var/obj/item/borg/upgrade/modkit/M = A
			. += span_notice("There is \a [M] installed, using <b>[M.cost]%</b> capacity.")

/obj/item/gun/energy/recharge/kinetic_accelerator/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(modkits.len && !disablemodification) //monkeedit
		to_chat(user, span_notice("You pry all the modifications out."))
		I.play_tool_sound(src, 100)
		for(var/a in modkits)
			var/obj/item/borg/upgrade/modkit/M = a
			M.forceMove(drop_location()) //uninstallation handled in Exited(), or /mob/living/silicon/robot/remove_from_upgrades() for borgs
	else
		to_chat(user, span_notice("There are no modifications currently installed."))

/obj/item/gun/energy/recharge/kinetic_accelerator/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!LAZYLEN(modkits))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	var/list/display_names = list()
	var/list/items = list()
	for(var/modkits_length in 1 to length(modkits))
		var/obj/item/thing = modkits[modkits_length]
		display_names["[thing.name] ([modkits_length])"] = REF(thing)
		var/image/item_image = image(icon = thing.icon, icon_state = thing.icon_state)
		if(length(thing.overlays))
			item_image.copy_overlays(thing)
		items["[thing.name] ([modkits_length])"] = item_image

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/modkit_reference = display_names[pick]
	var/obj/item/borg/upgrade/modkit/modkit_to_remove = locate(modkit_reference) in modkits
	if(!istype(modkit_to_remove))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!user.put_in_hands(modkit_to_remove))
		modkit_to_remove.forceMove(drop_location())
	update_appearance(UPDATE_ICON)


	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/energy/recharge/kinetic_accelerator/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/item/gun/energy/recharge/kinetic_accelerator/Exited(atom/movable/gone, direction)
	if(gone in modkits)
		var/obj/item/borg/upgrade/modkit/MK = gone
		MK.uninstall(src)
	return ..()

/obj/item/gun/energy/recharge/kinetic_accelerator/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/borg/upgrade/modkit))
		modkits |= arrived

/obj/item/gun/energy/recharge/kinetic_accelerator/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/borg/upgrade/modkit) && !disablemodification) //monkeedit
		var/obj/item/borg/upgrade/modkit/MK = I
		MK.install(src, user)
	else
		return ..()

/obj/item/gun/energy/recharge/kinetic_accelerator/proc/get_remaining_mod_capacity()
	var/current_capacity_used = 0
	for(var/A in modkits)
		var/obj/item/borg/upgrade/modkit/M = A
		current_capacity_used += M.cost
	return max_mod_capacity - current_capacity_used

/obj/item/gun/energy/recharge/kinetic_accelerator/proc/modify_projectile(obj/projectile/kinetic/K)
	K.kinetic_gun = src //do something special on-hit, easy!
	for(var/A in modkits)
		var/obj/item/borg/upgrade/modkit/M = A
		M.modify_projectile(K)

/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg
	icon_state = "kineticgun_b"
	holds_charge = TRUE
	unique_frequency = TRUE
	can_bayonet = FALSE
	sharpness = SHARP_EDGED
	force = 15
	wound_bonus = 5
	bare_wound_bonus = 10 // worse than surviavl knife

/obj/item/gun/energy/recharge/kinetic_accelerator/minebot
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	recharge_time = 2 SECONDS
	holds_charge = TRUE
	unique_frequency = TRUE

//Casing
/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/projectile/kinetic
	select_name = "kinetic"
	e_cost = LASER_SHOTS(1, STANDARD_CELL_CHARGE * 0.5)
	fire_sound = 'sound/weapons/kenetic_accel.ogg' // fine spelling there chap

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/gun/energy/recharge/kinetic_accelerator))
		var/obj/item/gun/energy/recharge/kinetic_accelerator/KA = loc
		KA.modify_projectile(loaded_projectile)

/obj/item/gun/energy/recharge/kinetic_accelerator/glock
	name = "proto-kinetic pistol"
	desc = "An innovative take on the Proto-Kinetic Accelerator, this model comes with none of the technology that makes the accelerator actually good. \
	Working a late shift one night, the Mining Research Director used a box of salvaged spare parts from busted accelerators to throw together this design. While it lacks \
	most of what makes the accelerator a good tool, it makes up for it with a unprecidented amount of room for modification, capable of holding nearly triple \
	the amount of mods that a normal accelerator could. 'Assemble it yourself' he said."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticpistol"
	base_icon_state = "kineticpistol"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/glock)
	can_bayonet = FALSE
	max_mod_capacity = 300 //experimental, if people find too many wack ass combos on the pistol im dropping it back to 200


/obj/item/gun/energy/recharge/kinetic_accelerator/railgun
	name = "proto-kinetic railgun"
	desc = "Before the nice streamlined and modern day Proto-Kinetic Accelerator was created, multiple designs were drafted by the Mining Research and Development \
	team. Many were failures, including this one, which came out too bulky and too ineffective. Well recently the MR&D Team got drunk and said 'fuck it we ball' and \
	went back to the bulky design, overclocked it, and made it functional, turning it into what is essentially a literal man portable particle accelerator. \
	The design results in a massive hard to control blast of kinetic energy, with the power to punch right through creatures and cause massive damage. The \
	only problem with the design is that it is so bulky you need to carry it with two hands, and the technology has been outfitted with a special firing pin \
	that denies use near or on the station, due to its destructive nature."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticrailgun"
	base_icon_state = "kineticrailgun"
	w_class = WEIGHT_CLASS_BULKY
	pin = /obj/item/firing_pin/wastes
	recharge_time = 3 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/railgun)
	weapon_weight = WEAPON_HEAVY
	can_bayonet = FALSE
	max_mod_capacity = 0 // Fuck off
	recoil = 1 // Railgun go brrrrr
	disablemodification = TRUE


/obj/item/gun/energy/recharge/kinetic_accelerator/repeater
	name = "proto-kinetic repeater"
	desc = "A Proto-Kinetic Accelerator with multiple smaller capacitors instead of one big one for storing charges. Turns out using less than \
	full power on the kinetic force generation means that you can fit a couple more smaller capacitors in without the entire thing exploding. \
	This results in a multi shot accelerator that doesn't combust on the first shot and allows rapid follow up shots in short succession. \
	The director said 'It came to me in a delusion' when we asked him how the team came up with this."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticrepeater"
	base_icon_state = "kineticrepeater"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/repeater)
	max_mod_capacity = 60


/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave
	name = "proto-kinetic shockwave"
	desc = "Innovating on the mining blast mod, Mining Research and Development has managed to overclock the performance of the mod to the extreme. \
	The result is a specialized accelerator frame that when equipped with the accompanying modkit grants a fairly punchy, large blast that is excellent \
	for clearing large amounts of rocks and crowded fauna. \
	The only downside is the lowered mod capacity, lack of range, required mod, and longer cooldown... but its pretty good for clearing rocks. \
	A warning label is stuck to the side : Weapon will underperform without accompanying mod (Should be included with purchase)."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticshockwave"
	base_icon_state = "kineticshockwave"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shockwave)
	can_bayonet = FALSE
	max_mod_capacity = 90 //bumped up to 90 to compensate for the 30 you need to spend on the AOE mod that gives it its functionality



//ADMIN ONLY SUPER OP

/obj/item/gun/energy/recharge/kinetic_accelerator/meme
	name = "adminium reaper"
	desc = "Mining RnD broke the fabric of space time, please return to your nearest centralcommand officer. <b> WARNING FROM THE MINING RND DIRECTOR : DO NOT RAPIDLY PULL TRIGGER : FABRIC OF SPACE TIME LIABLE TO BREAK </b>"
	recharge_time = 0.1
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/meme)
	max_mod_capacity = 420

/obj/item/gun/energy/recharge/kinetic_accelerator/meme/nonlethal
	name = "adminium stunner"
	desc = "Mining RnD broke the fabric of space time AGAIN, please return to your nearest centralcommand officer. <b> WARNING FROM THE MINING RND DIRECTOR : DO NOT RAPIDLY PULL TRIGGER : FABRIC OF SPACE TIME LIABLE TO BREAK </b>\
	Im being bullied by the admins"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/meme/nonlethal)
	can_bayonet = FALSE
	max_mod_capacity = 0

//Modkits
/obj/item/borg/upgrade/modkit
	name = "kinetic accelerator modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER
	var/denied_type = null
	var/maximum_of_type = 1
	var/cost = 30
	var/modifier = 1 //For use in any mod kit that has numerical modifiers
	var/minebot_upgrade = TRUE
	var/minebot_exclusive = FALSE

/obj/item/borg/upgrade/modkit/examine(mob/user)
	. = ..()
	. += span_notice("Occupies <b>[cost]%</b> of mod capacity.")

/obj/item/borg/upgrade/modkit/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/gun/energy/recharge/kinetic_accelerator) && !issilicon(user))
		install(A, user)
	else
		return ..()

/obj/item/borg/upgrade/modkit/action(mob/living/silicon/robot/R)
	. = ..()
	if (.)
		for(var/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg/H in R.model.modules)
			return install(H, usr, FALSE)

/obj/item/borg/upgrade/modkit/proc/install(obj/item/gun/energy/recharge/kinetic_accelerator/KA, mob/user, transfer_to_loc = TRUE)
	. = TRUE
	if(minebot_upgrade)
		if(minebot_exclusive && !istype(KA.loc, /mob/living/basic/mining_drone))
			to_chat(user, span_notice("The modkit you're trying to install is only rated for minebot use."))
			return FALSE
	else if(istype(KA.loc, /mob/living/basic/mining_drone))
		to_chat(user, span_notice("The modkit you're trying to install is not rated for minebot use."))
		return FALSE
	if(denied_type)
		var/number_of_denied = 0
		for(var/A in KA.modkits)
			var/obj/item/borg/upgrade/modkit/M = A
			if(istype(M, denied_type))
				number_of_denied++
			if(number_of_denied >= maximum_of_type)
				. = FALSE
				break
	if(KA.get_remaining_mod_capacity() >= cost)
		if(.)
			if(transfer_to_loc && !user.transferItemToLoc(src, KA))
				return
			to_chat(user, span_notice("You install the modkit."))
			playsound(loc, 'sound/items/screwdriver.ogg', 100, TRUE)
			KA.modkits |= src
		else
			to_chat(user, span_notice("The modkit you're trying to install would conflict with an already installed modkit. Remove existing modkits first."))
	else
		to_chat(user, span_notice("You don't have room(<b>[KA.get_remaining_mod_capacity()]%</b> remaining, [cost]% needed) to install this modkit. Use a crowbar or right click with an empty hand to remove existing modkits."))
		. = FALSE

/obj/item/borg/upgrade/modkit/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg/KA in R.model.modules)
			uninstall(KA)

/obj/item/borg/upgrade/modkit/proc/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	KA.modkits -= src

/obj/item/borg/upgrade/modkit/proc/modify_projectile(obj/projectile/kinetic/K)

//use this one for effects you want to trigger before any damage is done at all and before damage is decreased by pressure
/obj/item/borg/upgrade/modkit/proc/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
//use this one for effects you want to trigger before mods that do damage
/obj/item/borg/upgrade/modkit/proc/projectile_strike_predamage(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
//and this one for things that don't need to trigger before other damage-dealing mods
/obj/item/borg/upgrade/modkit/proc/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)

//Range
/obj/item/borg/upgrade/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	modifier = 1
	cost = 25

/obj/item/borg/upgrade/modkit/range/modify_projectile(obj/projectile/kinetic/K)
	K.range += modifier


//Damage
/obj/item/borg/upgrade/modkit/damage
	name = "damage increase"
	desc = "Increases the damage of kinetic accelerator when installed."
	modifier = 10

/obj/item/borg/upgrade/modkit/damage/modify_projectile(obj/projectile/kinetic/K)
	K.damage += modifier


//Cooldown
/obj/item/borg/upgrade/modkit/cooldown
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Not rated for minebot use."
	modifier = 3.2
	minebot_upgrade = FALSE

// Recalculate recharge time after adding or removing cooldown mods.
/obj/item/borg/upgrade/modkit/cooldown/proc/get_recharge_time(obj/item/gun/energy/recharge/kinetic_accelerator/KA)

	var/new_recharge_time = initial(KA.recharge_time)
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in KA.modkits)
		if(istype(modkit_upgrade, src))
			new_recharge_time -= modifier

	return new_recharge_time

/obj/item/borg/upgrade/modkit/cooldown/install(obj/item/gun/energy/recharge/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.recharge_time = get_recharge_time(KA)

/obj/item/borg/upgrade/modkit/cooldown/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	..()
	KA.recharge_time = get_recharge_time(KA)

/obj/item/borg/upgrade/modkit/cooldown/minebot
	name = "minebot cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Only rated for minebot use."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/minebot
	modifier = 10
	cost = 0
	minebot_upgrade = TRUE
	minebot_exclusive = TRUE


//AoE blasts
/obj/item/borg/upgrade/modkit/aoe
	modifier = 0
	var/turf_aoe = FALSE
	var/stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/install(obj/item/gun/energy/recharge/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits) //make sure only one of the aoe modules has values if somebody has multiple
			if(AOE.stats_stolen || AOE == src)
				continue
			modifier += AOE.modifier //take its modifiers
			AOE.modifier = 0
			turf_aoe += AOE.turf_aoe
			AOE.turf_aoe = FALSE
			AOE.stats_stolen = TRUE

/obj/item/borg/upgrade/modkit/aoe/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	..()
	modifier = initial(modifier) //get our modifiers back
	turf_aoe = initial(turf_aoe)
	stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/modify_projectile(obj/projectile/kinetic/K)
	K.name = "kinetic explosion"

/obj/item/borg/upgrade/modkit/aoe/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/explosion/fast(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
			if(ismineralturf(T))
				var/turf/closed/mineral/M = T
				M.gets_drilled(K.firer, TRUE)
	if(modifier)
		for(var/mob/living/L in range(1, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.armor_flag, "", "", K.armour_penetration)
			L.apply_damage(K.damage*modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, span_userdanger("You're struck by a [K.name]!"))

/obj/item/borg/upgrade/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	denied_type = /obj/item/borg/upgrade/modkit/aoe/turfs
	turf_aoe = TRUE

/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	maximum_of_type = 3
	modifier = 0.25

/obj/item/borg/upgrade/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2


/obj/item/borg/upgrade/modkit/aoe/turfs/shockwave
	name = "Shockwave modkit"
	desc = "A special version of the AOE modkit that gives the PK-Shockwave all of its unique properties. \
	It had to be shipped uninstalled from the actual PK-Shockwave due to technical issues, but installation is simple. \
	It does not fit into any other PK weapon."
	maximum_of_type = 1
	modifier = 0.50


/obj/item/borg/upgrade/modkit/aoe/turfs/shockwave/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/explosion/fast(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(2, target_turf) - target_turf)
			if(ismineralturf(T))
				var/turf/closed/mineral/M = T
				M.gets_drilled(K.firer, TRUE)
	if(modifier)
		for(var/mob/living/L in range(2, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.armor_flag, "", "", K.armour_penetration)
			L.apply_damage(K.damage*modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, span_userdanger("You're struck by a [K.name]!"))

/obj/item/borg/upgrade/modkit/aoe/turfs/shockwave/install(obj/item/gun/energy/recharge/kinetic_accelerator/KA, mob/user)
	if(istype(KA, /obj/item/gun/energy/recharge/kinetic_accelerator/shockwave))
		. = ..()
		if(.)
			for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits) //make sure only one of the aoe modules has values if somebody has multiple
				if(AOE.stats_stolen || AOE == src)
					continue
				modifier += AOE.modifier //take its modifiers
				AOE.modifier = 0
				turf_aoe += AOE.turf_aoe
				AOE.turf_aoe = FALSE
				AOE.stats_stolen = TRUE
	else
		to_chat(user, span_warning("[src] does not fit in [KA]. It will only fit in a Shockwave!"))
		return FALSE


//Minebot passthrough
/obj/item/borg/upgrade/modkit/minebot_passthrough
	name = "minebot passthrough"
	desc = "Causes kinetic accelerator shots to pass through minebots."
	cost = 0

//Tendril-unique modules
/obj/item/borg/upgrade/modkit/cooldown/repeater
	name = "rapid repeater"
	desc = "Quarters the kinetic accelerator's cooldown on striking a living target, but greatly increases the base cooldown."
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/repeater
	modifier = -14 //Makes the cooldown 3 seconds(with no cooldown mods) if you miss. Don't miss.
	cost = 50

/obj/item/borg/upgrade/modkit/cooldown/repeater/projectile_strike_predamage(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	var/valid_repeat = FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			valid_repeat = TRUE
	if(ismineralturf(target_turf))
		valid_repeat = TRUE
	if(valid_repeat)
		KA.cell.use(KA.cell.charge)
		KA.attempt_reload(KA.recharge_time * 0.25) //If you hit, the cooldown drops to 0.75 seconds.

/obj/item/borg/upgrade/modkit/lifesteal
	name = "lifesteal crystal"
	desc = "Causes kinetic accelerator shots to slightly heal the firer on striking a living target."
	icon_state = "modkit_crystal"
	modifier = 2.5 //Not a very effective method of healing.
	cost = 20
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/borg/upgrade/modkit/lifesteal/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(isliving(target) && isliving(K.firer))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		L = K.firer
		L.heal_ordered_damage(modifier, damage_heal_order)

/obj/item/borg/upgrade/modkit/resonator_blasts
	name = "resonator blast"
	desc = "Causes kinetic accelerator shots to leave and detonate resonator blasts."
	denied_type = /obj/item/borg/upgrade/modkit/resonator_blasts
	cost = 30
	modifier = 0.25 //A bonus 15 damage if you burst the field on a target, 60 if you lure them into it.

/obj/item/borg/upgrade/modkit/resonator_blasts/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(target_turf && !ismineralturf(target_turf)) //Don't make fields on mineral turfs.
		var/obj/effect/temp_visual/resonance/R = locate(/obj/effect/temp_visual/resonance) in target_turf
		if(R)
			R.damage_multiplier = modifier
			R.burst()
			return
		new /obj/effect/temp_visual/resonance(target_turf, K.firer, null, RESONATOR_MODE_MANUAL, 100) //manual detonate mode and will NOT spread

/obj/item/borg/upgrade/modkit/bounty
	name = "death syphon"
	desc = "Killing or assisting in killing a creature permanently increases your damage against that type of creature."
	denied_type = /obj/item/borg/upgrade/modkit/bounty
	modifier = 1.25
	cost = 30
	var/maximum_bounty = 25
	var/list/bounties_reaped = list()

/obj/item/borg/upgrade/modkit/bounty/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		var/list/existing_marks = L.has_status_effect_list(/datum/status_effect/syphon_mark)
		for(var/i in existing_marks)
			var/datum/status_effect/syphon_mark/SM = i
			if(SM.reward_target == src) //we want to allow multiple people with bounty modkits to use them, but we need to replace our own marks so we don't multi-reward
				SM.reward_target = null
				qdel(SM)
		L.apply_status_effect(/datum/status_effect/syphon_mark, src)

/obj/item/borg/upgrade/modkit/bounty/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		if(bounties_reaped[L.type])
			var/kill_modifier = 1
			if(K.pressure_decrease_active)
				kill_modifier *= K.pressure_decrease
			var/armor = L.run_armor_check(K.def_zone, K.armor_flag, "", "", K.armour_penetration)
			L.apply_damage(bounties_reaped[L.type]*kill_modifier, K.damage_type, K.def_zone, armor)

/obj/item/borg/upgrade/modkit/bounty/proc/get_kill(mob/living/L)
	var/bonus_mod = 1
	if(ismegafauna(L)) //megafauna reward
		bonus_mod = 4
	if(!bounties_reaped[L.type])
		bounties_reaped[L.type] = min(modifier * bonus_mod, maximum_bounty)
	else
		bounties_reaped[L.type] = min(bounties_reaped[L.type] + (modifier * bonus_mod), maximum_bounty)

//Indoors
/obj/item/borg/upgrade/modkit/indoors
	name = "decrease pressure penalty"
	desc = "A syndicate modification kit that increases the damage a kinetic accelerator does in high pressure environments."
	modifier = 2
	denied_type = /obj/item/borg/upgrade/modkit/indoors
	maximum_of_type = 2
	cost = 35

/obj/item/borg/upgrade/modkit/indoors/modify_projectile(obj/projectile/kinetic/K)
	K.pressure_decrease *= modifier


//Trigger Guard
/obj/item/borg/upgrade/modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed."
	cost = 20
	denied_type = /obj/item/borg/upgrade/modkit/trigger_guard

/obj/item/borg/upgrade/modkit/trigger_guard/install(obj/item/gun/energy/recharge/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/borg/upgrade/modkit/trigger_guard/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_NORMAL
	..()


//Cosmetic

/obj/item/borg/upgrade/modkit/chassis_mod
	name = "super chassis"
	desc = "Makes your KA yellow. All the fun of having a more powerful KA without actually having a more powerful KA."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/chassis_mod
	var/chassis_icon = "kineticgun_u"
	var/chassis_name = "super-kinetic accelerator"

/obj/item/borg/upgrade/modkit/chassis_mod/install(obj/item/gun/energy/recharge/kinetic_accelerator/KA, mob/user)
//monkestation edit start
	if(is_type_in_list(KA, list(/obj/item/gun/energy/recharge/kinetic_accelerator/glock,
								/obj/item/gun/energy/recharge/kinetic_accelerator/meme,
								/obj/item/gun/energy/recharge/kinetic_accelerator/railgun,
								/obj/item/gun/energy/recharge/kinetic_accelerator/repeater,
								/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave,)))
		to_chat(user, span_warning("[src] is not compatible with [KA]."))
		return FALSE
//monkestation edit end
	. = ..()
	if(.)
		KA.icon_state = chassis_icon
		KA.inhand_icon_state = chassis_icon
		KA.name = chassis_name
		if(iscarbon(KA.loc))
			var/mob/living/carbon/holder = KA.loc
			holder.update_held_items()

/obj/item/borg/upgrade/modkit/chassis_mod/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	KA.icon_state = initial(KA.icon_state)
	KA.inhand_icon_state = initial(KA.inhand_icon_state)
	KA.name = initial(KA.name)
	if(iscarbon(KA.loc))
		var/mob/living/carbon/holder = KA.loc
		holder.update_held_items()
	..()

/obj/item/borg/upgrade/modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_icon = "kineticgun_h"
	chassis_name = "hyper-kinetic accelerator"

/obj/item/borg/upgrade/modkit/tracer
	name = "white tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a white tracer trail and explosion."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/tracer
	var/bolt_color = "#FFFFFF"

/obj/item/borg/upgrade/modkit/tracer/modify_projectile(obj/projectile/kinetic/K)
	K.icon_state = "ka_tracer"
	K.color = bolt_color

/obj/item/borg/upgrade/modkit/tracer/adjustable
	name = "adjustable tracer bolts"
	desc = "Causes kinetic accelerator bolts to have an adjustable-colored tracer trail and explosion. Use in-hand to change color."

/obj/item/borg/upgrade/modkit/tracer/adjustable/interact(mob/user)
	..()
	choose_bolt_color(user)

/obj/item/borg/upgrade/modkit/tracer/adjustable/proc/choose_bolt_color(mob/user)
	set waitfor = FALSE

	var/new_color = tgui_color_picker(user, "", "Choose Color", bolt_color)
	bolt_color = new_color || bolt_color
