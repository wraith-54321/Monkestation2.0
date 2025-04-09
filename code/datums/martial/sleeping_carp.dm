#define STRONG_PUNCH_COMBO "HH"
#define LAUNCH_KICK_COMBO "HD"
#define DROP_KICK_COMBO "DD"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	allow_temp_override = FALSE
	help_verb = /mob/living/proc/sleeping_carp_help
	display_combos = TRUE
	COOLDOWN_DECLARE(block_cooldown)
	var/list/scarp_traits = list(TRAIT_NOGUNS, TRAIT_HARDLY_WOUNDED, TRAIT_NODISMEMBER, TRAIT_HEAVY_SLEEPER, TRAIT_THROW_GUNS)
	var/deflect_cooldown = 3 SECONDS //monke edit start
	var/deflect_stamcost = 15 //how much stamina it costs per bullet deflected
	var/log_name = "Sleeping Carp"
	var/damage = 20
	var/kick_speed = 0 //how fast you get punted into the stratosphere on launchkick
	var/wounding = 0 //whether or not you get wounded by the attack
	var/zone_message = "" //string for where the attack is targetting
	var/zone = null //where the attack is targetting
	var/stamina_damage = 0
	var/counter = FALSE //monke edit end

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/target, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	target.add_traits(scarp_traits, SLEEPING_CARP_TRAIT)
	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(target, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile))
	target.faction |= FACTION_CARP //:D

/datum/martial_art/the_sleeping_carp/on_remove(mob/living/target)
	REMOVE_TRAITS_IN(target, SLEEPING_CARP_TRAIT)
	UnregisterSignal(target, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_PRE_BULLET_ACT))
	target.faction -= FACTION_CARP //:(
	. = ..()

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, STRONG_PUNCH_COMBO))
		reset_streak()
		strongPunch(attacker, defender)
		return TRUE
	if(findtext(streak, LAUNCH_KICK_COMBO))
		reset_streak()
		launchKick(attacker, defender)
		return TRUE
	if(findtext(streak, DROP_KICK_COMBO))
		reset_streak()
		dropKick(attacker, defender)
		return TRUE
	return FALSE

///Gnashing Teeth: Harm Harm, consistent 20 force punch on every second harm punch
/datum/martial_art/the_sleeping_carp/proc/strongPunch(mob/living/attacker, mob/living/defender, set_damage = TRUE)
	if(set_damage)
		damage = 20
		wounding = 0
	///this var is so that the strong punch is always aiming for the body part the user is targeting and not trying to apply to the chest before deviating
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("precisely kick", "brutally chop", "cleanly hit", "viciously slam")
	defender.visible_message(
		span_danger("[attacker] [atk_verb]s [defender]!"),
		span_userdanger("[attacker] [atk_verb]s you!"),
		ignored_mobs = attacker
	)
	to_chat(attacker, span_danger("You [atk_verb] [defender]!"))
	playsound(defender, 'sound/weapons/punch1.ogg', vol = 25, vary = TRUE, extrarange = -1)
	log_combat(attacker, defender, "strong punched ([log_name])") //monke edit
	defender.apply_damage(damage, attacker.get_attack_type(), affecting, wound_bonus = wounding)

///Crashing Wave Kick: Harm Disarm combo, throws people seven tiles backwards
/datum/martial_art/the_sleeping_carp/proc/launchKick(mob/living/attacker, mob/living/defender, set_damage = TRUE)
	//monke edit start
	if(set_damage)
		damage = 15
		kick_speed = 4
		wounding = CANT_WOUND
		zone_message = "chest"
		zone = BODY_ZONE_CHEST
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	defender.visible_message(
		span_warning("[attacker] kicks [defender] square in the [zone_message], sending [defender.p_them()] flying!"),
		span_userdanger("You are kicked square in the [zone_message] by [attacker], sending you flying!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = attacker,
	)
	playsound(get_turf(attacker), 'sound/effects/hit_kick.ogg', vol = 50, vary = TRUE, extrarange = -1)
	var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
	defender.throw_at(throw_target, 7, kick_speed, attacker)
	defender.apply_damage(damage, attacker.get_attack_type(), zone, wound_bonus = wounding)
	log_combat(attacker, defender, "launchkicked ([log_name])") //monke edit end
	return

///Keelhaul: Disarm Disarm combo, knocks people down and deals substantial stamina damage, and also discombobulates them. Knocks objects out of their hands if they're already on the ground.
/datum/martial_art/the_sleeping_carp/proc/dropKick(mob/living/attacker, mob/living/defender, set_damage = TRUE)
	//monke edit start
	if(set_damage)
		stamina_damage = -100
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	playsound(get_turf(attacker), 'sound/effects/hit_kick.ogg', vol = 50, vary = TRUE, extrarange = -1)
	if(defender.body_position == STANDING_UP)
		defender.Knockdown(2 SECONDS)
		defender.visible_message(
			span_warning("[attacker] kicks [defender] in the head, sending [defender.p_them()] face first into the floor!"),
			span_userdanger("You are kicked in the head by [attacker], sending you crashing to the floor!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
	else
		defender.drop_all_held_items()
		defender.visible_message(
			span_warning("[attacker] kicks [defender] in the head!"),
			span_userdanger("You are kicked in the head by [attacker]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
	defender.stamina.adjust(stamina_damage)
	defender.adjust_dizzy_up_to(10 SECONDS, 10 SECONDS)
	defender.adjust_temp_blindness_up_to(2 SECONDS, 10 SECONDS)
	log_combat(attacker, defender, "dropkicked ([log_name])") //monke edit end
	return

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/attacker, mob/living/defender)
	if(!can_deflect(attacker)) //allows for deniability
		return ..()

	add_to_streak("G", defender)
	if(check_streak(attacker, defender))
		return TRUE
	var/grab_log_description = "grabbed"
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/weapons/punch1.ogg', vol = 25, vary = TRUE, extrarange = -1)
	if(defender.stat != DEAD && !defender.IsUnconscious() && defender.stamina.current <= 50) //We put our target to sleep.
		defender.visible_message(
			span_danger("[attacker] carefully pinch a nerve in [defender]'s neck, knocking [defender.p_them()] out cold"),
			span_userdanger("[attacker] pinches something in your neck, and you fall unconscious!"),
		)
		grab_log_description = "grabbed and nerve pinched"
		defender.Unconscious(10 SECONDS)
	defender.stamina.adjust(-50)
	log_combat(attacker, defender, "[grab_log_description] (Sleeping Carp)")
	return ..()

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/attacker, mob/living/defender)
	if(attacker.grab_state == GRAB_KILL \
		&& attacker.zone_selected == BODY_ZONE_HEAD \
		&& attacker.pulling == defender \
		&& defender.stat != DEAD \
	)
		var/obj/item/bodypart/head = defender.get_bodypart(BODY_ZONE_HEAD)
		if(!isnull(head))
			playsound(defender, 'sound/effects/wounds/crack1.ogg', vol = 100)
			defender.visible_message(
				span_danger("[attacker] snaps the neck of [defender]!"),
				span_userdanger("Your neck is snapped by [attacker]!"),
				span_hear("You hear a sickening snap!"),
				ignored_mobs = attacker,
			)
			to_chat(attacker, span_danger("In a swift motion, you snap the neck of [defender]!"), type = MESSAGE_TYPE_COMBAT)
			log_combat(attacker, defender, "snapped neck")
			defender.apply_damage(100, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND)
			if(!HAS_TRAIT(defender, TRAIT_NODEATH))
				defender.death()
				defender.investigate_log("has had [defender.p_their()] neck snapped by [attacker].", INVESTIGATE_DEATHS)
			return MARTIAL_ATTACK_SUCCESS

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	defender.visible_message(
		span_danger("[attacker] [atk_verb]s [defender]!"),
		span_userdanger("[attacker] [atk_verb]s you!"), null, null, attacker
		)
	to_chat(attacker, span_danger("You [atk_verb] [defender]!"), type = MESSAGE_TYPE_COMBAT)

	defender.apply_damage(rand(10,15), attacker.get_attack_type(), affecting, wound_bonus = CANT_WOUND)
	playsound(defender, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "punched ([log_name]])") //monke edit
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/attacker, mob/living/defender)
	if(!can_deflect(attacker)) //allows for deniability
		return ..()

	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return TRUE

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/weapons/punch1.ogg', vol = 25, vary = TRUE, extrarange = -1)
	defender.stamina.adjust(-50)
	log_combat(attacker, defender, "disarmed ([log_name])") //monke edit

	return ..()

/datum/martial_art/the_sleeping_carp/proc/can_deflect(mob/living/carp_user, check_intent = TRUE)
	if(!COOLDOWN_FINISHED(src, block_cooldown)) //monke edit
		return FALSE
	if(!can_use(carp_user))
		return FALSE
	if(check_intent && !(carp_user.istate & ISTATE_HARM)) // monke edit: istates/intents
		return FALSE
	if(carp_user.incapacitated(IGNORE_GRAB)) //NO STUN
		return FALSE
	if(!(carp_user.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return FALSE
	var/datum/dna/dna = carp_user.has_dna()
	if(dna?.check_mutation(/datum/mutation/human/hulk)) //NO HULK
		return FALSE
	if(!isturf(carp_user.loc)) //NO MOTHERFLIPPIN MECHS!
		return FALSE
	return TRUE

/datum/martial_art/the_sleeping_carp/proc/hit_by_projectile(mob/living/carp_user, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!can_deflect(carp_user))
		return NONE

	carp_user.visible_message(
		span_danger("[carp_user] effortlessly swats [hitting_projectile] aside! [carp_user.p_They()] can block bullets with [carp_user.p_their()] bare hands!"),
		span_userdanger("You deflect [hitting_projectile]!"),
	)
	COOLDOWN_START(src, block_cooldown, deflect_cooldown)// monke edit start
	playsound(carp_user, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), vol = 75, vary = TRUE)
	carp_user.stamina?.adjust(deflect_stamcost) //monke edit end
	hitting_projectile.firer = carp_user
	hitting_projectile.set_angle(rand(0, 360))//SHING
	return COMPONENT_BULLET_PIERCED

///Signal from getting attacked with an item, for a special interaction with touch spells
/datum/martial_art/the_sleeping_carp/proc/on_attackby(mob/living/carbon/human/carp_user, obj/item/melee/touch_attack/touch_weapon, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(touch_weapon) || !can_deflect(carp_user, check_intent = !touch_weapon.dangerous))
		return
	var/datum/action/cooldown/spell/touch/touch_spell = touch_weapon.spell_which_made_us?.resolve()
	// monkestation edit: flavor tweaks
	if(!counter)
		carp_user.visible_message(
			span_danger("[carp_user] carefully dodges [attacker]'s [touch_weapon]!"),
			span_userdanger("You take great care to remain untouched by [attacker]'s [touch_weapon]!"),
			ignored_mobs = list(attacker),
		)
		to_chat(attacker, span_userdanger("[carp_user] carefully dodges your [touch_weapon], remaining completely untouched!"), type = MESSAGE_TYPE_COMBAT)
		carp_user.balloon_alert(attacker, "miss!")
		playsound(carp_user, 'monkestation/sound/effects/miss.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	else
		carp_user.visible_message(
			span_danger("[carp_user] twists [attacker]'s arm, sending [attacker.p_their()] [touch_weapon] back towards [attacker.p_them()]!"),
			span_userdanger("Making sure to avoid [attacker]'s [touch_weapon], you twist [attacker.p_their()] arm to send it right back at [attacker.p_them()]!"),
			ignored_mobs = list(attacker),
		)
		to_chat(attacker, span_userdanger("[carp_user] swiftly grabs and twists your arm, hitting you with your own [touch_weapon]!"), type = MESSAGE_TYPE_COMBAT)
		INVOKE_ASYNC(carp_user, TYPE_PROC_REF(/atom/movable, say), message = "PATHETIC!", language = /datum/language/common, ignore_spam = TRUE, forced = src)
		if(touch_spell)
			INVOKE_ASYNC(touch_spell, TYPE_PROC_REF(/datum/action/cooldown/spell/touch, do_hand_hit), touch_weapon, attacker, attacker)
	attacker.changeNext_move(CLICK_CD_MELEE)
	// monkestation end
	return COMPONENT_NO_AFTERATTACK

/// Verb added to humans who learn the art of the sleeping carp.
/mob/living/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>\n\
	[span_notice("Gnashing Teeth")]: Punch Punch. Deal additional damage every second (consecutive) punch! Very good chance to wound!\n\
	[span_notice("Crashing Wave Kick")]: Punch Shove. Launch your opponent away from you with incredible force!\n\
	[span_notice("Keelhaul")]: Shove Shove. Nonlethally kick an opponent to the floor, knocking them down, discombobulating them and dealing substantial stamina damage. If they're already prone, disarm them as well.\n\
	[span_notice("Grabs and Shoves")]: While in combat mode, your typical grab and shove do decent stamina damage. If you grab someone who has substantial amounts of stamina damage, you knock them out!\n\
	<span class='notice'>While in combat mode (and not stunned, not a hulk, and not in a mech), you can reflect all projectiles that come your way, sending them back at the people who fired them! \n\
	Also, you are more resilient against suffering wounds in combat, and your limbs cannot be dismembered. This grants you extra staying power during extended combat, especially against slashing and other bleeding weapons. \n\
	You are not invincible, however- while you may not suffer debilitating wounds often, you must still watch your health and should have appropriate medical supplies for use during downtime. \n\
	In addition, your training has imbued you with a loathing of guns, and you can no longer use them.</span>")

/obj/item/staff/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 2
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "bostaff0"
	base_icon_state = "bostaff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50

/obj/item/staff/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 10, \
		force_wielded = 24, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/staff/bostaff/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/staff/bostaff/attack(mob/target, mob/living/user, params)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, span_warning("You club yourself over the head with [src]."))
		user.Paralyze(6 SECONDS)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2 * force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2 * force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, span_warning("It would be dishonorable to attack a foe while they cannot retaliate."))
		return
	if((user.istate & ISTATE_SECONDARY))
		if(!HAS_TRAIT(src, TRAIT_WIELDED))
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("club", "smack", "broadside", "beat", "slam")
		H.visible_message(span_warning("[user] [pick(fluffmessages)]s [H] with [src]!"), \
						span_userdanger("[user] [pick(fluffmessages)]s you with [src]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
		to_chat(user, span_danger("You [pick(fluffmessages)] [H] with [src]!"))
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, TRUE, -1)
		H.stamina.adjust(-rand(13,20))
		if(prob(10))
			H.visible_message(span_warning("[H] collapses!"), \
							span_userdanger("Your legs give out!"))
			H.Paralyze(8 SECONDS)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message(span_warning("[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"), \
								span_userdanger("You're knocked unconscious by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
				to_chat(user, span_danger("You deliver a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"))
				H.SetSleeping(60 SECONDS)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/staff/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return FALSE

#undef STRONG_PUNCH_COMBO
#undef LAUNCH_KICK_COMBO
#undef DROP_KICK_COMBO
