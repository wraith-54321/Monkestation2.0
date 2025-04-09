/mob/living/basic/pet/dog/bullterrier/walter
	name = "Walter"
	real_name = "Walter"
	desc = "It's Walter, he bites criminals just as well as he bites toddlers."

/mob/living/basic/pet/dog/bullterrier/walter/saulter
	name = "Saulter Goodman"
	real_name = "Saulter Goodman"
	desc = "Seccies and wardens are nothing compared to the might of this consititutional right loving lawyer."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "saulter"
	icon_living = "saulter"
	icon_dead = "saulter_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/saulter/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("barks!", "Hi, i'm Saul Goodman.", "Did you know you have rights?", "Based!"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/negative
	name = "Negative Walter"
	real_name = "Negative Walter"
	desc = "Nar'sie and rat'var are a lot compared to the might of this skcurtretsnom despising god."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "negative"
	icon_living = "negative"
	icon_dead = "negative_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/negative/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("skrab!", "sfoow!", "retlaW", "skcurterif", "skcurtretsnom"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/syndicate
	name = "Syndicate Walter"
	real_name = "Syndicate Walter"
	desc = "Nanotrasen and Centcom are nothing compared to the might of this nuke loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "syndie"
	icon_living = "syndie"
	icon_dead = "syndie_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/syndicate/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("barks!", "woofs!", "Walter", "Down with Nanotrasen!", "For the Syndicate!"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/doom
	name = "Doom Walter"
	real_name = "Doom Walter"
	desc = "Devils and Gods are nothing compared to the might of this gun loving soldier."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "doom"
	icon_living = "doom"
	icon_dead = "doom_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/doom/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("..."))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/space
	name = "Space Walter"
	real_name = "Space Walter"
	desc = "Exploring the galaxies is nothing for this star loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "space"
	icon_living = "space"
	icon_dead = "space_dead"
	unsuitable_atmos_damage = 0
	bodytemp_cold_damage_limit = -1
	bodytemp_heat_damage_limit = 1500
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/space/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("barks!", "woofs!", "spess!", "Walter", "firetrucks", "monstertrucks", "spaceships"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/sus
	name = "Suspicious Walter"
	real_name = "Suspicious Walter"
	desc = "This vent loving dog is a little suspicious..."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "sus"
	icon_living = "sus"
	icon_dead = "sus_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier/walter/sus/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/sus/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("barks!", "woofs!", "sus!", "Walter", "firetrucks", "monstertrucks", "tasks"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/clown
	name = "Clown Walter"
	real_name = "Clown Walter"
	desc = "Seccies and staff members are nothing compared to the might of this banana loving loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/clown/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("barks!", "woofs!", "honks!", "Walter", "firetrucks", "monstertrucks"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/french
	name = "French Walter"
	real_name = "French Walter"
	desc = "Nar'sie et rat'var ne sont rien comparés à la puissance de ce chien qui aime les monstertrucks."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "french"
	icon_living = "french"
	icon_dead = "french_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/french/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("aboiement!", "aboyer!", "Walter", "camions de pompiers", "camions monstres"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/british
	name = "Bri'ish Wal'ah"
	real_name = "Bri'ish Wal'ah"
	desc = "Nar'sie and like ra''var are naw'hin' compared 'o 'he migh' of 'hiz mons'er'ruck lovin' dog."
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/british/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("barks!", "woofs!", "Wal'ah", "fire'rucks", "mons'er'rucks"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/wizard
	name = "Magic Walter"
	real_name = "Magic Walter"
	desc = "Assistants and secoffs are nothing compared to the might of this magic loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/wizard/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("ONI SOMA", "CLANG!", "UN'LTD P'WAH", "AULIE OXIN FIERA", "GIN'YU`CAPAN"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/bullterrier/walter/smallter
	name = "Smallter"
	real_name = "Smallter"
	desc = "Nar'sie and rat'var are nothing compared to the might of this tiny dog."
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier/walter/smallter/Initialize(mapload)
	. = ..()
	update_transform(0.5)

///Updates dog speech and emotes for each walter
/mob/living/basic/pet/dog/bullterrier/walter/smallter/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speech_chance = 5
	speech.speak = string_list(list("barks", "woofs", "walter", "firetrucks", "monstertrucks"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))
