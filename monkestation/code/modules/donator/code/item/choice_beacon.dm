
//Donator specific pet beacons
/obj/item/choice_beacon/pet/donator
	var/mob/living/donator_pet = /mob/living/basic/axolotl

/obj/item/choice_beacon/pet/donator/generate_display_names()
	var/static/list/pet_list
	if(!pet_list)
		pet_list = list()
		var/list/selectable_pet = list(donator_pet)

		for(var/mob/living/basic_mob as anything in selectable_pet)
			pet_list[initial(basic_mob.name)] = basic_mob

		return pet_list

/obj/item/choice_beacon/pet/donator/open_options_menu(mob/living/user)
	var/input_name = stripped_input(user, "What would you like your new pet to be named?", "New Pet Name", default_name, MAX_NAME_LEN)
	if (!input_name)
		return
	if(!can_use_beacon(user))
		return
	consume_use(donator_pet, user, input_name)

/obj/item/choice_beacon/pet/donator/spycrab
	name = "Mann Co. Crustacean Deployment Apparatus"
	default_name = "Spy Crab"
	company_source = "Mann Co."
	company_message = "Prepare for infiltrator deployment."
	donator_pet = 	/mob/living/basic/crab/spycrab

/obj/item/choice_beacon/pet/donator/void_mothroach
	name = "Secret Beacon of the Stars"
	default_name = "Moffles"
	company_source = "*UNINTELLIGIBLE BUZZING*"
	company_message = "*LOUD MOFF NOISES*"
	donator_pet = 	/mob/living/basic/mothroach/void

/obj/item/choice_beacon/pet/donator/blahaj
	name = "Blahaj"
	default_name = "Blahaj"
	company_source = "IKEA"
	company_message = "Please enjoy your new pet -- some assembly required."
	donator_pet = 	/mob/living/basic/pet/blahaj

/obj/item/choice_beacon/pet/donator/cirno
	name = "Cirno"
	default_name = "Cirno?"
	company_source = "Touhou"
	company_message = "Please handle with care!"
	donator_pet = 	/mob/living/basic/pet/cirno

/obj/item/choice_beacon/pet/donator/slime
	name = "Slime"
	default_name = "Slime"
	company_source = "*blorbling*"
	donator_pet = 	/mob/living/basic/pet/slime/talkative

/obj/item/choice_beacon/pet/donator/spider
	name = "Spider"
	default_name = "Spider"
	donator_pet = 	/mob/living/basic/pet/spider/dancing

/obj/item/choice_beacon/pet/donator/germanshepherd
	name = "German Shepherd"
	default_name = "German Shepherd"
	donator_pet = 	/mob/living/basic/pet/dog/germanshepherd

/obj/item/choice_beacon/pet/donator/void_butterfly
	name = "Void Butterfly"
	default_name = "Void Butterfly"
	donator_pet = 	/mob/living/basic/butterfly/void/spacial

/obj/item/choice_beacon/pet/donator/plantcrab
	name = "Plant Crab"
	default_name = "Plant Crab"
	donator_pet = 	/mob/living/basic/crab/plant

/obj/item/choice_beacon/pet/donator/gumball_goblin
	name = "Gumball Goblin"
	default_name = "Gumball Goblin"
	donator_pet = 	/mob/living/basic/pet/gumball_goblin

/obj/item/choice_beacon/pet/donator/orangutan
	name = "Orangutan"
	default_name = "Orangutan"
	donator_pet = 	/mob/living/basic/pet/orangutan

/obj/item/choice_beacon/pet/donator/fluffykobold
	name = "fluffy kobold"
	default_name = "fluffy kobold"
	donator_pet = 	/mob/living/basic/pet/fluffykobold

/obj/item/choice_beacon/pet/donator/darkscug
	name = "night slugcat"
	default_name = "night slugcat"
	donator_pet = 	/mob/living/basic/pet/darkscug

/obj/item/choice_beacon/pet/donator/hypnotoad
	name = "hypnotoad"
	default_name = "hypnotoad"
	donator_pet = 	/mob/living/basic/frog/hypnotoad

/obj/item/choice_beacon/pet/donator/ghastly_evil_demon
	name = "ghastly evil demon"
	default_name = "ghastly evil demon"
	donator_pet = 	/mob/living/basic/pet/ghastly_evil_demon

/obj/item/choice_beacon/pet/donator/albino_ghost_ian
	name = "ghost ian"
	default_name = "ghost ian"
	donator_pet = /mob/living/basic/pet/albino_ghost_ian

/obj/item/choice_beacon/pet/donator/fluffydonator
	name = "fluffy"
	default_name = "fluffy"
	donator_pet = /mob/living/basic/pet/fluffydonator

/obj/item/choice_beacon/pet/donator/robottoything
	name = "robot toy"
	default_name = "robot toy"
	donator_pet = /mob/living/basic/pet/robottoything

/obj/item/choice_beacon/pet/donator/babypukeko
	name = "baby pukeko"
	default_name = "baby pukeko"
	donator_pet = /mob/living/basic/pet/babypukeko

/obj/item/choice_beacon/pet/donator/tallbabypukeko
	name = "tall baby pukeko"
	default_name = "tall baby pukeko"
	donator_pet = /mob/living/basic/pet/babypukeko/tall
