/// Tests that no new simple_animal subtypes are added.
/datum/unit_test/simple_animal_freeze
	// !!! DO NOT ADD NEW ENTRIES TO THIS LIST !!!
	// NO new simple animals are allowed.
	// Use the new basic mobs system instead.
	// If you are refactoring a simple_animal, REMOVE it from this list
	var/list/allowed_types = list(
		/mob/living/simple_animal/bot,
		/mob/living/simple_animal/bot/firebot,
		/mob/living/simple_animal/bot/floorbot,
		/mob/living/simple_animal/bot/mulebot,
		/mob/living/simple_animal/bot/mulebot/paranormal,
		/mob/living/simple_animal/bot/secbot,
		/mob/living/simple_animal/bot/secbot/beepsky,
		/mob/living/simple_animal/bot/secbot/beepsky/armsky,
		/mob/living/simple_animal/bot/secbot/beepsky/jr,
		/mob/living/simple_animal/bot/secbot/beepsky/officer,
		/mob/living/simple_animal/bot/secbot/beepsky/ofitser,
		/mob/living/simple_animal/bot/secbot/ed209,
		/mob/living/simple_animal/bot/secbot/genesky,
		/mob/living/simple_animal/bot/secbot/grievous,
		/mob/living/simple_animal/bot/secbot/grievous/toy,
		/mob/living/simple_animal/bot/secbot/honkbot,
		/mob/living/simple_animal/bot/secbot/pingsky,
		/mob/living/simple_animal/bot/vibebot,
		/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/hostile/asteroid,
		/mob/living/simple_animal/hostile/asteroid/curseblob,
		/mob/living/simple_animal/hostile/asteroid/elite,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child,
		/mob/living/simple_animal/hostile/asteroid/elite/herald,
		/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror,
		/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
		/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead,
		/mob/living/simple_animal/hostile/asteroid/elite/pandora,
		/mob/living/simple_animal/hostile/asteroid/polarbear,
		/mob/living/simple_animal/hostile/asteroid/polarbear/lesser,
		/mob/living/simple_animal/hostile/dark_wizard,
		/mob/living/simple_animal/hostile/illusion,
		/mob/living/simple_animal/hostile/illusion/escape,
		/mob/living/simple_animal/hostile/illusion/mirage,
		/mob/living/simple_animal/hostile/jungle,
		/mob/living/simple_animal/hostile/jungle/leaper,
		/mob/living/simple_animal/hostile/megafauna,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/doom,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/guidance,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/hunter,
		/mob/living/simple_animal/hostile/megafauna/bubblegum,
		/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination,
		/mob/living/simple_animal/hostile/megafauna/clockwork_defender,
		/mob/living/simple_animal/hostile/megafauna/colossus,
		/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner,
		/mob/living/simple_animal/hostile/megafauna/dragon,
		/mob/living/simple_animal/hostile/megafauna/dragon/lesser,
		/mob/living/simple_animal/hostile/megafauna/hierophant,
		/mob/living/simple_animal/hostile/megafauna/legion,
		/mob/living/simple_animal/hostile/megafauna/legion/medium,
		/mob/living/simple_animal/hostile/megafauna/legion/medium/eye,
		/mob/living/simple_animal/hostile/megafauna/legion/medium/left,
		/mob/living/simple_animal/hostile/megafauna/legion/medium/right,
		/mob/living/simple_animal/hostile/megafauna/legion/small,
		/mob/living/simple_animal/hostile/megafauna/wendigo,
		/mob/living/simple_animal/hostile/ooze,
		/mob/living/simple_animal/hostile/ooze/gelatinous,
		/mob/living/simple_animal/hostile/ooze/grapes,
		/mob/living/simple_animal/hostile/retaliate,
		/mob/living/simple_animal/hostile/retaliate/goose,
		/mob/living/simple_animal/hostile/retaliate/goose/vomit,
		/mob/living/simple_animal/hostile/vatbeast,
		/mob/living/simple_animal/pet,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/cat/_proc,
		/mob/living/simple_animal/pet/cat/breadcat,
		/mob/living/simple_animal/pet/cat/cak,
		/mob/living/simple_animal/pet/cat/jerry,
		/mob/living/simple_animal/pet/cat/kitten,
		/mob/living/simple_animal/pet/cat/original,
		/mob/living/simple_animal/pet/cat/runtime,
		/mob/living/simple_animal/pet/cat/space,
		/mob/living/simple_animal/pet/gondola,
		/mob/living/simple_animal/pet/gondola/gondolapod,
		/mob/living/simple_animal/pet/gondola/virtual_domain,
		/mob/living/simple_animal/soulscythe,

		//MONKESTATION-SPECIFIC ENTRIES START
		/mob/living/simple_animal/bot/buttbot,
		/mob/living/simple_animal/bot/secbot/beepsky/big,
		/mob/living/simple_animal/fish,
		/mob/living/simple_animal/fish/angelfish,
		/mob/living/simple_animal/fish/catfish,
		/mob/living/simple_animal/fish/clownfish,
		/mob/living/simple_animal/fish/dwarf_moonfish,
		/mob/living/simple_animal/fish/goldfish,
		/mob/living/simple_animal/fish/gunner_jellyfish,
		/mob/living/simple_animal/fish/guppy,
		/mob/living/simple_animal/fish/firefish,
		/mob/living/simple_animal/fish/greenchromis,
		/mob/living/simple_animal/fish/plasmatetra,
		/mob/living/simple_animal/hostile/feral,
		/mob/living/simple_animal/hostile/feraltabby,
		/mob/living/simple_animal/hostile/illusion/khan_warrior,
		/mob/living/simple_animal/hostile/megafauna/wendigo/monkestation_override,
		/mob/living/simple_animal/hostile/syndicat,
		/mob/living/simple_animal/hostile/syndicat/super,
		/mob/living/simple_animal/pet/cat/breadcat/super,
		/mob/living/simple_animal/pet/cat/original/super,
		/mob/living/simple_animal/pet/cat/super,
		/mob/living/simple_animal/pet/gondola/funky,
		/mob/living/simple_animal/pet/hamster,
		//MONKESTATION-SPECIFIC ENTRIES END

		// DO NOT ADD NEW ENTRIES TO THIS LIST
		// READ THE COMMENT ABOVE
	)

/datum/unit_test/simple_animal_freeze/Run()
	var/list/seen = list()

	// Sanity check, to prevent people from just doing a mass find and replace
	for (var/allowed_type in allowed_types)
		if (allowed_type in seen)
			TEST_FAIL("[allowed_type] is in the allowlist more than once")
		else
			seen[allowed_type] = TRUE

		TEST_ASSERT(ispath(allowed_type, /mob/living/simple_animal), "[allowed_type] is not a simple_animal. Remove it from the list.")

	for (var/subtype in subtypesof(/mob/living/simple_animal))
		if (!(subtype in allowed_types))
			TEST_FAIL("No new simple_animal subtypes are allowed. Please refactor [subtype] into a basic mob.")
