/mob/living/basic/mothroach/void
	name = "void mothroach"
	desc = "A mothroach from the stars!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "void_mothroach"
	icon_living = "void_mothroach"
	icon_dead = "void_mothroach_dead"
	held_state = "void_mothroach"
	held_lh = 'monkestation/code/modules/donator/icons/mob/pets_held_lh.dmi'
	held_rh = 'monkestation/code/modules/donator/icons/mob/pets_held_rh.dmi'
	head_icon = 'monkestation/code/modules/donator/icons/mob/pets_held.dmi'
	gold_core_spawnable = NO_SPAWN

	ckeywhitelist = list("spinnermaster")

/mob/living/basic/crab/spycrab
	name = "spy crab"
	desc = "hon hon hon"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	gold_core_spawnable = NO_SPAWN

	ckeywhitelist = list("TTNT789")

/mob/living/basic/crab/spycrab/Initialize(mapload)
	. = ..()
	var/random_icon = pick("crab_red","crab_blue")
	icon_state = random_icon
	icon_living = random_icon
	icon_dead = "[random_icon]_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/blahaj
	name = "\improper Blåhaj"
	desc = "The blue shark can swim very far, dive really deep and hear noises from almost 250 meters away."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "blahaj"
	icon_living = "blahaj"
	icon_dead = "blahaj_dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/

	ckeywhitelist = list("ruby_flamewing")

/mob/living/basic/pet/cirno  //nobody needs to know she's a lizard
	name = "Cirno"
	desc = "She is the greatest."
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "cirno-happy"
	icon_living = "cirno-happy"
	icon_dead = "cirno-happy"
	icon_gib = null
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	basic_mob_flags = FLIP_ON_DEATH

	ckeywhitelist = list("bidlink2")

/mob/living/basic/lizard/snake
	name = "Three Headed Snake"
	desc = "This little fella looks familiar..."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "triple_snake"
	icon_living = "triple_snake"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/dog/germanshepherd
	name = "German Shepherd"
	desc = "He's so cool, he's got sunglasses!!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "germanshepherd"
	icon_living = "germanshepherd"
	icon_dead = "germanshepherd_dead"
	icon_gib = null
	can_be_held = FALSE // as funny as this would be, a german shepherd is way too big to carry with one hand
	gold_core_spawnable = NO_SPAWN

	ckeywhitelist = list("mjolnir2")

/mob/living/basic/pet/slime/talkative
	name = "Extroverted Slime"
	desc = "He's got a lot to say!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "slime"
	icon_living = "slime"
	icon_dead = "slime_dead"
	gold_core_spawnable = NO_SPAWN
	initial_language_holder = /datum/language_holder/slime
	ai_controller = /datum/ai_controller/basic_controller/
	var/quips = list("Your fingers taste like Donk Pockets, get out more.",
					"I've seen salad that dresses better than you.",
					"I smell smoke, are you thinking too hard again?",
					"This one's gene pool needs more chlorine...",
					"I expected nothing and yet I'm still disappointed.",
					"Why is this walking participation trophy touching me?",
					"If I throw a stick, will you leave?",)
	var/positive_quips = list("Hey there, slime pal!",
								"Aw thanks buddy!",)

	ckeywhitelist = list("Senri08")

/mob/living/basic/pet/slime/talkative/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user == src || src.stat != CONSCIOUS || (user.istate & ISTATE_HARM) || LAZYACCESS(modifiers, RIGHT_CLICK))
		return

	new /obj/effect/temp_visual/heart(src.loc)
	if(prob(33))
		if(isslimeperson(user) || isoozeling(user))
			src.say(pick(positive_quips))
		else
			src.say(pick(quips))


/mob/living/basic/pet/spider/dancing
	name = "Dancin' Spider"
	desc = "Look at him go!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "spider"
	icon_living = "spider"
	icon_dead = "spider_dead"
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/

	ckeywhitelist = list("Random516")

/mob/living/basic/butterfly/void
	name = "Void Butterfly"
	desc = "They say if a void butterfly flaps its wings..."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "void_butterfly"
	icon_living = "void_butterfly"
	icon_dead = "void_butterfly_dead"
	gold_core_spawnable = NO_SPAWN
	health = 20
	maxHealth = 20

	ckeywhitelist = list("tonymcsp")

/mob/living/basic/butterfly/void/spacial
	fixed_color = TRUE

/mob/living/basic/crab/plant
	name = "Plant crab"
	desc = "Is it a crab made of plant or a plant made of crab?"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "crab_plant"
	icon_living = "crab_plant"
	icon_dead = "crab_plant_dead"
	gold_core_spawnable = NO_SPAWN

	ckeywhitelist = list("Rickdude1231")

/mob/living/basic/pet/gumball_goblin
	name = "Gumball Goblin"
	desc = "AAAAAAAAAAAAAAAA"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "gumball_goblin"
	icon_living = "gumball_goblin"
	icon_dead = "gumball_goblin_dead"
	gold_core_spawnable = NO_SPAWN

	ckeywhitelist = list("elliethedarksun")

	///Ability
	var/datum/action/cooldown/lay_gumball/gumball_ability


/mob/living/basic/pet/gumball_goblin/Initialize(mapload)
	. = ..()
	gumball_ability = new()
	gumball_ability.Grant(src)



///drops peels around the mob when activated
/datum/action/cooldown/lay_gumball
	name = "Lay gumball"
	desc = "Produce a gumball"
	cooldown_time = 15 SECONDS
	button_icon_state = "gumball"
	button_icon = 'icons/obj/food/lollipop.dmi'
	background_icon_state = "bg_nature"
	overlay_icon_state = "bg_nature_border"
	///which type of gumballs to spawn
	var/gumball_type = /obj/item/food/gumball
	///How many gumballs to spawn
	var/gumball_amount = 1

/datum/action/cooldown/lay_gumball/Activate(atom/target)
	. = ..()
	var/list/reachable_turfs = list()
	for(var/turf/adjacent_turf in RANGE_TURFS(1, owner.loc))
		if(adjacent_turf == owner.loc || !owner.CanReach(adjacent_turf) || !isopenturf(adjacent_turf))
			continue
		reachable_turfs += adjacent_turf

	var/gumballs_to_spawn = min(gumball_amount, reachable_turfs.len)
	for(var/i in 1 to gumballs_to_spawn)
		new gumball_type(pick_n_take(reachable_turfs))
	StartCooldown()

/mob/living/basic/pet/orangutan
	name = "\improper Orangutan"
	desc = "A vibrant colored primate once native to Indonesia"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "orangutan"
	icon_living = "orangutan"
	icon_dead = "orangutan"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/

	ckeywhitelist = list("Raziaar")

/mob/living/basic/pet/fluffykobold
	name = "fluffy kobold"
	desc = "A cute and fluffy horned creature with the attitude of a cat and the dexterity of a monkey. Whether it's a stow-away that snuck in from some foreign zoo, a geneticist's mad experiment or a supposedly terrifying predator from the ashlands, it's here now and it wants your pizza."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "Bluedragon66"
	icon_living = "Bluedragon66"
	icon_dead = "Bluedragon66-dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("Bluedragon66")


/mob/living/basic/pet/darkscug
	name = "night slugcat"
	desc = "ITS A FUGGIN SCRUG"
	icon = 'icons/mob/simple/slugcats.dmi'
	icon_state = "scug_nightcat"
	icon_living = "scug_nightcat"
	icon_dead = "scug_dead_nightcat"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("CaptainShiba")

/mob/living/basic/frog/hypnotoad
	name = "hypnotoad"
	desc = "All glory to the hypnotoad."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "hypnotoad"
	icon_living = "hypnotoad"
	icon_dead = "hypnotoad-dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("Ophaq")

/mob/living/basic/pet/ghastly_evil_demon
	name = "ghastly evil demon"
	desc = "It's so scary!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets_32x48.dmi'
	icon_state = "ghastly_evil_demon"
	icon_living = "ghastly_evil_demon"
	icon_dead = "ghastly_evil_demon-dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("ThePooba")
	movement_type = FLYING

/mob/living/basic/pet/albino_ghost_ian
	name = "ghost ian"
	desc = "It's an albino corgi!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "albino_ghost_ian"
	icon_living = "albino_ghost_ian"
	icon_dead = "albino_ghost_ian-dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("Eacles13")

/mob/living/basic/pet/fluffydonator
	name = "fluffy"
	desc = "A big black spider wearing pajama's from Central Command!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "fluffy"
	icon_living = "fluffy"
	icon_dead = "fluffy-dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("Jason Farqiour")

/mob/living/basic/pet/robottoything
	name = "robot toy"
	desc = "It's a small robot toy. It's made of metal"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "robottoything"
	icon_living = "robottoything"
	icon_dead = "robottoything-dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("TheSpecialSnowflake")

/mob/living/basic/pet/babypukeko
	name = "baby pukeko"
	desc = "DAMN!!!!!!!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "babypukeko"
	icon_living = "babypukeko"
	icon_dead = "babypukeko-dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	ckeywhitelist = list("Cobalt Velvet 235")

/mob/living/basic/pet/babypukeko/tall
	icon = 'monkestation/code/modules/donator/icons/mob/pets_160x160.dmi'
	icon_state = "tallbabypukeko"
	icon_living = "tallbabypukeko"
	icon_dead = "tallbabypukeko-dead"
	pixel_x = -96
