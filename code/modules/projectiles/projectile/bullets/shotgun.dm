/obj/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	icon_state = "pellet"
	damage = 50
	sharpness = SHARP_POINTY
	wound_bonus = -5

/obj/projectile/bullet/shotgun_slug/executioner
	name = "executioner slug" // admin only, can dismember limbs
	sharpness = SHARP_EDGED
	wound_bonus = 80

/obj/projectile/bullet/shotgun_slug/pulverizer
	name = "pulverizer slug" // admin only, can crush bones
	sharpness = NONE
	wound_bonus = 80
//MONKE EDIT START
/obj/projectile/bullet/shotgun_slug/apds
	name = "tungsten sabot-slug"
	icon_state = "gauss"
	damage = 32 //18 less than slugs. Only better when bullet armor is 50+, primarily counters bulletproof armor.
	speed = 0.25 //sub-caliber + lighter = speed. (Smaller number = faster)
	armour_penetration = 50 //Tis a solid-tungsten penetrator, what do you expect?
	wound_bonus = -25
	ricochets_max = 2 //Unlike slugs which tend to squish on impact, these are hard enough to bounce rarely.
	ricochet_chance = 50
	ricochet_auto_aim_range = 0
	ricochet_incidence_leeway = 50
	embedding = null
	demolition_mod = 3 //High-velocity tungsten > steel doors
	projectile_piercing = PASSMOB


/obj/projectile/bullet/shotgun_slug/apds/pierce/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		// If the bullet has already gone through 2 people, stop it on this hit
		if(pierces > 2)
			projectile_piercing = NONE

			if(damage > 10) // Lets just be safe with this one
				damage -= 7
			armour_penetration -= 10

	return ..()
//MONKE EDIT END
/obj/projectile/bullet/shotgun_beanbag
	name = "beanbag slug"
	icon_state = "pellet"
	damage = 5 //10 to 5 monkestation edit
	stamina = 75 //monkestation edit
	wound_bonus = 20
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	icon_state = "pellet"
	damage = 20

/obj/projectile/bullet/incendiary/shotgun/no_trail
	name = "precision incendiary slug"
	damage = 35
	leaves_fire_trail = FALSE

/obj/projectile/bullet/incendiary/shotgun/dragonsbreath
	name = "dragonsbreath pellet"
	damage = 5

/obj/projectile/bullet/shotgun_stunslug
	name = "stunslug"
	damage = 5
	paralyze = 100
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	range = 7
	icon_state = "spark"
	color = "#FFFF00"
	embedding = null

/obj/projectile/bullet/shotgun_frag12
	name ="frag12 slug"
	icon_state = "pellet"
	damage = 15
	paralyze = 10

/obj/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 1, explosion_cause = src)
	return BULLET_ACT_HIT

/obj/projectile/bullet/pellet
	icon_state = "pellet"
	var/tile_dropoff = 0.45
	var/tile_dropoff_s = 0.25

/obj/projectile/bullet/pellet/Range()
	..()
	if(damage > 0)
		damage -= tile_dropoff
	if(stamina > 0)
		stamina -= tile_dropoff_s
	if(damage < 0 && stamina < 0)
		qdel(src)

/obj/projectile/bullet/pellet/shotgun_buckshot
	name = "buckshot pellet"
	damage = 7.5
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -2.5 // low damage + additional dropoff will already curb wounding potential anything past point blank

/obj/projectile/bullet/pellet/shotgun_rubbershot
	name = "rubber shot pellet"
	damage = 2 //monkestation edit 3 to 2
	stamina = 15 //monkestation edit
	sharpness = NONE
	embedding = null
	tile_dropoff_s = 0 //monkestation edit
	speed = 1.2
	ricochets_max = 4
	ricochet_chance = 120
	ricochet_decay_chance = 0.9
	ricochet_decay_damage = 0.8
	ricochet_auto_aim_range = 2
	ricochet_auto_aim_angle = 30
	ricochet_incidence_leeway = 75
	/// Subtracted from the ricochet chance for each tile traveled
	var/tile_dropoff_ricochet = 4
	debilitating = TRUE
	debilitate_mult = 1

/obj/projectile/bullet/pellet/shotgun_rubbershot/Range()
	if(ricochet_chance > 0)
		ricochet_chance -= tile_dropoff_ricochet
	. = ..()

/obj/projectile/bullet/pellet/shotgun_incapacitate
	name = "incapacitating pellet"
	damage = 1
	stamina = 12 //monkestation edit
	tile_dropoff_s = 3 //monkestation edit spitting distance
	embedding = null

/obj/projectile/bullet/pellet/shotgun_improvised
	tile_dropoff = 0.35 //Come on it does 6 damage don't be like that.
	damage = 6
	wound_bonus = 0
	bare_wound_bonus = 7.5

/obj/projectile/bullet/pellet/shotgun_improvised/Initialize(mapload)
	. = ..()
	range = rand(1, 8)

/obj/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()

// Mech Scattershot

/obj/projectile/bullet/scattershot
	icon_state = "pellet"
	damage = 24

//Breaching Ammo

/obj/projectile/bullet/shotgun_breaching
	name = "12g breaching round"
	desc = "A breaching round designed to destroy airlocks and windows with only a few shots. Ineffective against other targets."
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	damage = 5 //does shit damage to everything except doors and windows
	demolition_mod = 200 //one shot to break a window or grille, or two shots to breach an airlock door
