/*
*	LOADOUT ITEM DATUMS FOR THE HEAD SLOT
*/

/// Head Slot Items (Moves overrided items to backpack)
GLOBAL_LIST_INIT(loadout_helmets, generate_loadout_items(/datum/loadout_item/head))

/datum/loadout_item/head
	category = LOADOUT_ITEM_HEAD

/datum/loadout_item/head/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.head))
		.. ()
		return TRUE

/datum/loadout_item/head/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.head)
			spawn_in_backpack(outfit, outfit.head, equipper)
		outfit.head = item_path
	else
		outfit.head = item_path

/*
*	BEANIES
*/

/datum/loadout_item/head/white_beanie
	name = "Recolorable Beanie"
	item_path = /obj/item/clothing/head/beanie

/datum/loadout_item/head/black_beanie
	name = "Black Beanie"
	item_path = /obj/item/clothing/head/beanie/black

/datum/loadout_item/head/red_beanie
	name = "Red Beanie"
	item_path = /obj/item/clothing/head/beanie/red

/datum/loadout_item/head/dark_blue_beanie
	name = "Dark Blue Beanie"
	item_path = /obj/item/clothing/head/beanie/darkblue

/datum/loadout_item/head/yellow_beanie
	name = "Yellow Beanie"
	item_path = /obj/item/clothing/head/beanie/yellow

/datum/loadout_item/head/orange_beanie
	name = "Orange Beanie"
	item_path = /obj/item/clothing/head/beanie/orange

/datum/loadout_item/head/rastafarian
	name = "Rastafarian Cap"
	item_path = /obj/item/clothing/head/rasta

/datum/loadout_item/head/christmas_beanie
	name = "Christmas Beanie"
	item_path = /obj/item/clothing/head/beanie/christmas

/*
*	BERETS
*/

/datum/loadout_item/head/greyscale_beret
	name = "Greyscale Beret"
	item_path = /obj/item/clothing/head/beret

/*
*	CAPS
*/

/datum/loadout_item/head/black_cap
	name = "Black Cap"
	item_path = /obj/item/clothing/head/soft/black

/datum/loadout_item/head/blue_cap
	name = "Blue Cap"
	item_path = /obj/item/clothing/head/soft/blue

/datum/loadout_item/head/green_cap
	name = "Green Cap"
	item_path = /obj/item/clothing/head/soft/green

/datum/loadout_item/head/grey_cap
	name = "Grey Cap"
	item_path = /obj/item/clothing/head/soft/grey

/datum/loadout_item/head/orange_cap
	name = "Orange Cap"
	item_path = /obj/item/clothing/head/soft/orange

/datum/loadout_item/head/purple_cap
	name = "Purple Cap"
	item_path = /obj/item/clothing/head/soft/purple

/datum/loadout_item/head/red_cap
	name = "Red Cap"
	item_path = /obj/item/clothing/head/soft/red

/datum/loadout_item/head/grey_cap
	name = "Grey Cap"
	item_path = /obj/item/clothing/head/soft/grey

/datum/loadout_item/head/yellow_cap
	name = "Yellow Cap"
	item_path = /obj/item/clothing/head/soft/yellow

/datum/loadout_item/head/rainbow_cap
	name = "Rainbow Cap"
	item_path = /obj/item/clothing/head/soft/rainbow

/datum/loadout_item/head/delinquent_cap
	name = "Delinquent Cap"
	item_path = /obj/item/clothing/head/costume/delinquent

/datum/loadout_item/head/flatcap
	name = "Flat Cap"
	item_path = /obj/item/clothing/head/flatcap


/*
*	FEDORAS
*/

/datum/loadout_item/head/beige_fedora
	name = "Beige Fedora"
	item_path = /obj/item/clothing/head/fedora/beige

/datum/loadout_item/head/white_fedora
	name = "White Fedora"
	item_path = /obj/item/clothing/head/fedora/white


/*
*	HARDHATS
*/

/datum/loadout_item/head/dark_blue_hardhat
	name = "Dark Blue Hardhat"
	item_path = /obj/item/clothing/head/utility/hardhat/dblue

/datum/loadout_item/head/orange_hardhat
	name = "Orange Hardhat"
	item_path = /obj/item/clothing/head/utility/hardhat/orange

/datum/loadout_item/head/red_hardhat
	name = "Red Hardhat"
	item_path = /obj/item/clothing/head/utility/hardhat/red

/datum/loadout_item/head/white_hardhat
	name = "White Hardhat"
	item_path = /obj/item/clothing/head/utility/hardhat/white

/datum/loadout_item/head/yellow_hardhat
	name = "Yellow Hardhat"
	item_path = /obj/item/clothing/head/utility/hardhat

/*
*	MISC
*/

/datum/loadout_item/head/mail_cap
	name = "Mail Cap"
	item_path = /obj/item/clothing/head/costume/mailman

/datum/loadout_item/head/kitty_ears
	name = "Kitty Ears"
	item_path = /obj/item/clothing/head/costume/kitty

/datum/loadout_item/head/rabbit_ears
	name = "Rabbit Ears"
	item_path = /obj/item/clothing/head/costume/rabbitears

/datum/loadout_item/head/bandana
	name = "Bandana"
	item_path = /obj/item/clothing/head/costume/pirate/bandana

/datum/loadout_item/head/top_hat
	name = "Top Hat"
	item_path = /obj/item/clothing/head/hats/tophat

/datum/loadout_item/head/bowler_hat
	name = "Bowler Hat"
	item_path = /obj/item/clothing/head/hats/bowler

/datum/loadout_item/head/mini_crown
	name = "Mini Crown"
	item_path = /obj/item/clothing/head/costume/minicrown

/datum/loadout_item/head/tragic
	name = "Tragic Mime Headpiece"
	item_path = /obj/item/clothing/head/tragic

/datum/loadout_item/head/pharaoh
	name = "Pharaoh's Hat"
	item_path = /obj/item/clothing/head/costume/pharaoh

/datum/loadout_item/head/nemes
	name = "Headdress of Nemes"
	item_path = /obj/item/clothing/head/costume/nemes

/datum/loadout_item/head/straw_hat
	name = "Straw Hat"
	item_path = /obj/item/clothing/head/costume/straw_hat

/datum/loadout_item/head/flowery
	name = "Perfumed Bow"
	item_path = /obj/item/clothing/head/costume/flowery

/datum/loadout_item/head/starry
	name = "Star Speckled Bow"
	item_path = /obj/item/clothing/head/costume/starry

/datum/loadout_item/head/tiara
	name = "Tiara"
	item_path = /obj/item/clothing/head/costume/tiara

/*
*	CHRISTMAS
*/

/datum/loadout_item/head/santa
	name = "Santa Hat"
	item_path = /obj/item/clothing/head/costume/santa
	required_season = CHRISTMAS

/*
*	HALLOWEEN
*/

/datum/loadout_item/head/xenos
	name = "Xenos Helmet"
	item_path = /obj/item/clothing/head/costume/xenos

/datum/loadout_item/head/wedding_veil
	name = "Wedding Veil"
	item_path = /obj/item/clothing/head/costume/weddingveil

/datum/loadout_item/head/synde
	name = "Red Space Helmet Replica"
	item_path = /obj/item/clothing/head/syndicatefake

/datum/loadout_item/head/glatiator
	name = "Gladiator Helmet"
	item_path = /obj/item/clothing/head/helmet/gladiator

/datum/loadout_item/head/griffin
	name = "Griffon Head"
	item_path = /obj/item/clothing/head/costume/griffin

/datum/loadout_item/head/wizard
	name = "Wizard Hat"
	item_path = /obj/item/clothing/head/wizard/fake

/datum/loadout_item/head/witch
	name = "Witch Hat"
	item_path = /obj/item/clothing/head/wizard/marisa/fake

/*
*	MISC
*/

/datum/loadout_item/head/baseball
	name = "Ballcap"
	item_path = /obj/item/clothing/head/soft/mime

/datum/loadout_item/head/pirate
	name = "Pirate hat"
	item_path = /obj/item/clothing/head/costume/pirate


/datum/loadout_item/head/rice_hat
	name = "Rice Hat"
	item_path = /obj/item/clothing/head/costume/rice_hat

/datum/loadout_item/head/ushanka
	name = "Ushanka"
	item_path = /obj/item/clothing/head/costume/ushanka

/datum/loadout_item/head/slime
	name = "Slime Hat"
	item_path = /obj/item/clothing/head/collectable/slime

/datum/loadout_item/head/maidhead2
	name = "Frilly Maid Headband"
	item_path = /obj/item/clothing/head/costume/maidheadband
	additional_tooltip_contents = list("Larger headband from the maid rework. Fits around head and ears.")

/datum/loadout_item/head/wig
	name = "Wig"
	item_path = /obj/item/clothing/head/wig

/datum/loadout_item/head/wignatural
	name = "Natural Wig"
	item_path = /obj/item/clothing/head/wig/natural

/datum/loadout_item/head/bunnyears
	name = "Colorable Bunny Ears"
	item_path = /obj/item/clothing/head/playbunnyears

/datum/loadout_item/head/propeller_hat
	name = "Rainbow Propeller Hat"
	item_path = /obj/item/clothing/head/soft/propeller_hat

/*
*	JOB-LOCKED
*/

/datum/loadout_item/head/navyblueofficerberet
	name = "Security Officer's Navy Blue beret"
	item_path = /obj/item/clothing/head/beret/sec/navyofficer
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY, JOB_WARDEN)


/datum/loadout_item/head/navybluewardenberet
	name = "Warden's Navy Blue beret"
	item_path = /obj/item/clothing/head/beret/sec/navywarden
	restricted_roles = list(JOB_WARDEN)

/datum/loadout_item/head/nursehat
	name = "Nurse Hat"
	item_path = /obj/item/clothing/head/costume/nursehat
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_GENETICIST, JOB_CHEMIST, JOB_VIROLOGIST)

/*
*	JOB BERETS
*/


/datum/loadout_item/head/engi_beret
	name = "Engineering Beret"
	item_path = /obj/item/clothing/head/beret/engi
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_CHIEF_ENGINEER)

/datum/loadout_item/head/cargo_beret
	name = "Supply Beret"
	item_path = /obj/item/clothing/head/beret/cargo
	restricted_roles = list(JOB_QUARTERMASTER, JOB_CARGO_TECHNICIAN, JOB_SHAFT_MINER)

/datum/loadout_item/head/beret_med
	name = "Medical Beret"
	item_path = /obj/item/clothing/head/beret/medical
	restricted_roles = list(JOB_MEDICAL_DOCTOR,JOB_VIROLOGIST, JOB_CHEMIST, JOB_CHIEF_MEDICAL_OFFICER)

/datum/loadout_item/head/beret_paramedic
	name = "Paramedic Beret"
	item_path = /obj/item/clothing/head/beret/medical/paramedic
	restricted_roles = list(JOB_PARAMEDIC, JOB_CHIEF_MEDICAL_OFFICER)

/datum/loadout_item/head/beret_sci
	name = "Scientist Beret"
	item_path = /obj/item/clothing/head/beret/science
	restricted_roles = list(JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST, JOB_RESEARCH_DIRECTOR)

/*
*	FAMILIES
*/

/datum/loadout_item/head/tmc
	name = "TMC Hat"
	item_path = /obj/item/clothing/head/costume/tmc

/datum/loadout_item/head/deckers
	name = "Deckers Hat"
	item_path = /obj/item/clothing/head/costume/deckers

/datum/loadout_item/head/saints
	name = "Fancy Hat"
	item_path = /obj/item/clothing/head/costume/fancy

/*
*	DONATOR
*/

/datum/loadout_item/head/donator
	donator_only = TRUE
	requires_purchase = FALSE

/*
*	FLOWERS
*/

/datum/loadout_item/head/donator/poppy
	name = "Poppy Flower"
	item_path = /obj/item/food/grown/poppy

/datum/loadout_item/head/donator/lily
	name = "Lily Flower"
	item_path = /obj/item/food/grown/poppy/lily

/datum/loadout_item/head/donator/geranium
	name = "Geranium Flower"
	item_path = /obj/item/food/grown/poppy/geranium

/datum/loadout_item/head/donator/fraxinella
	name = "Fraxinella Flower"
	item_path = /obj/item/food/grown/poppy/geranium/fraxinella

/datum/loadout_item/head/donator/harebell
	name = "Harebell Flower"
	item_path = /obj/item/food/grown/harebell

/datum/loadout_item/head/donator/rose
	name = "Rose Flower"
	item_path = /obj/item/food/grown/rose

/datum/loadout_item/head/donator/carbon_rose
	name = "Carbon Rose Flower"
	item_path = /obj/item/food/grown/carbon_rose

/datum/loadout_item/head/donator/sunflower
	name = "Sunflower"
	item_path = /obj/item/food/grown/sunflower

/datum/loadout_item/head/donator/rainbow_bunch
	name = "Rainbow Bunch"
	item_path = /obj/item/food/grown/rainbow_flower
	additional_tooltip_contents = list(TOOLTIP_RANDOM_COLOR)

/datum/loadout_item/head/constable
	name = "Constable Helmet"
	item_path = /obj/item/clothing/head/costume/constable
	restricted_roles = list(JOB_SECURITY_ASSISTANT, JOB_BRIG_PHYSICIAN, JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/// EVERYTHING NOVA RELATED


/*
*	BERETS
*/

/datum/loadout_item/head/greyscale_beret/badge //BUYABLE
	name = "Greyscale Beret with Badge"
	item_path = /obj/item/clothing/head/beret/badge

/*
*	CAPS
*/

/datum/loadout_item/head/pflatcap //BUYABLE
	name = "Poly Flat Cap"
	item_path = /obj/item/clothing/head/colourable_flatcap

/datum/loadout_item/head/mothcap //BUYABLE
	name = "Mothic Softcap"
	item_path = /obj/item/clothing/head/mothcap

/datum/loadout_item/head/frontiercap //BUYABLE
	name = "Frontier Cap"
	item_path = /obj/item/clothing/head/soft/frontier_colonist

/datum/loadout_item/head/frontiercap/medic //BUYABLE
	name = "Frontier Medical Cap"
	item_path = /obj/item/clothing/head/soft/frontier_colonist/medic

/*
*	FEDORAS
*/

/datum/loadout_item/head/black_fedora //BUYABLE
	name = "Black Fedora"
	item_path = /obj/item/clothing/head/fedora


/datum/loadout_item/head/brown_fedora //BUYABLE
	name = "Brown Fedora"
	item_path = /obj/item/clothing/head/fedora/brown

/*
*	MISC
*/

/datum/loadout_item/head/hair_tie //BUYABLE
	name = "Hair Tie"
	item_path = /obj/item/clothing/head/hair_tie

/datum/loadout_item/head/hair_tie_scrunchie //BUYABLE
	name = "Scrunchie"
	item_path = /obj/item/clothing/head/hair_tie/scrunchie

/datum/loadout_item/head/hair_tie_plastic_beads //BUYABLE
	name = "Colorful Hair tie"
	item_path = /obj/item/clothing/head/hair_tie/plastic_beads

/datum/loadout_item/head/standalone_hood //BUYABLE
	name = "Recolorable Standalone Hood"
	item_path = /obj/item/clothing/head/standalone_hood

/datum/loadout_item/head/top_hat //BUYABLE
	name = "Top Hat"
	item_path = /obj/item/clothing/head/hats/tophat

/datum/loadout_item/head/large_bow //BUYABLE
	name = "Colourable Large Bow"
	item_path = /obj/item/clothing/head/large_bow

/datum/loadout_item/head/back_bow //BUYABLE
	name = "Colourable Back Bow"
	item_path = /obj/item/clothing/head/back_bow

/datum/loadout_item/head/small_bow //BUYABLE
	name = "Colourable Small Bow"
	item_path = /obj/item/clothing/head/small_bow

/datum/loadout_item/head/sweet_bow //BUYABLE
	name = "Colourable Sweet bow"
	item_path = /obj/item/clothing/head/sweet_bow

/*
*	MISC
*/

/datum/loadout_item/head/floral_garland //BUYABLE
	name = "Floral Garland"
	item_path = /obj/item/clothing/head/costume/garland

/datum/loadout_item/head/rainbowbunch //BUYABLE
	name = "Rainbow Flower Crown"
	item_path = /obj/item/clothing/head/costume/garland/rainbowbunch

/datum/loadout_item/head/sunflower_crown //BUYABLE
	name = "Sunflower Crown"
	item_path = /obj/item/clothing/head/costume/garland/sunflower

/datum/loadout_item/head/poppy_crown //BUYABLE
	name = "Poppy Crown"
	item_path = /obj/item/clothing/head/costume/garland/poppy

/datum/loadout_item/head/lily_crown //BUYABLE
	name = "Lily Crown"
	item_path = /obj/item/clothing/head/costume/garland/lily

/datum/loadout_item/head/sombrero //BUYABLE
	name = "Sombrero"
	item_path = /obj/item/clothing/head/costume/sombrero

/datum/loadout_item/head/flakhelm //BUYABLE
	name = "Flak Helmet"
	item_path = /obj/item/clothing/head/hats/flakhelm

/datum/loadout_item/head/fashionable_cap //BUYABLE
	name = "Fashionable Baseball Cap"
	item_path = /obj/item/clothing/head/soft/yankee

/datum/loadout_item/head/plague_hat //BUYABLE
	name = "Plague Doctor's Hat"
	item_path = /obj/item/clothing/head/bio_hood/plague

/datum/loadout_item/head/chap_nunh //BUYABLE
	name = "Nun's Hood"
	item_path = /obj/item/clothing/head/chaplain/nun_hood

/datum/loadout_item/head/chap_kippah //BUYABLE
	name = "Jewish Kippah"
	item_path = /obj/item/clothing/head/chaplain/kippah

/*
*	COWBOY
*/

/datum/loadout_item/head/cowboyhat //BUYABLE
	name = "Recolorable Cattleman Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/cattleman

/datum/loadout_item/head/cowboyhat_black //BUYABLE
	name = "Recolorable Wide-Brimmed Cattleman Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/cattleman/wide

/datum/loadout_item/head/cowboyhat_wide //BUYABLE
	name = "Wide-Brimmed Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/wide

/datum/loadout_item/head/cowboyhat_wide_feather //BUYABLE
	name = "Wide-Brimmed Feathered Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/wide/feathered

/datum/loadout_item/head/cowboyhat_flat //BUYABLE
	name = "Flat-Brimmed Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/flat

/datum/loadout_item/head/cowboyhat_flat_cowl //BUYABLE
	name = "Flat-Brimmed Hat with Cowl"
	item_path = /obj/item/clothing/head/cowboy/nova/flat/cowl

/datum/loadout_item/head/cowboyhat_sheriff //BUYABLE
	name = "Sheriff Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/flat/sheriff

/datum/loadout_item/head/cowboyhat_deputy //BUYABLE
	name = "Deputy Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/flat/deputy

/datum/loadout_item/head/cowboyhat_winter //BUYABLE
	name = "Winter Cowboy Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/flat/cowl/sheriff

/*
*	JOB-LOCKED
*/

/datum/loadout_item/head/imperial_cap
	name = "Captain's Naval Cap"
	item_path = /obj/item/clothing/head/hats/imperial/cap
	restricted_roles = list(JOB_CAPTAIN)
	requires_purchase = FALSE

/datum/loadout_item/head/imperial_hop
	name = "Head of Personnel's Naval Cap"
	item_path = /obj/item/clothing/head/hats/imperial/hop
	restricted_roles = list(JOB_HEAD_OF_PERSONNEL)
	requires_purchase = FALSE


/datum/loadout_item/head/imperial_cmo
	name = "Chief Medical Officer's Naval Cap"
	item_path = /obj/item/clothing/head/hats/imperial/cmo
	restricted_roles = list(JOB_CHIEF_MEDICAL_OFFICER)
	requires_purchase = FALSE

/datum/loadout_item/head/imperial_ce
	name = "Chief Engineer's blast helmet."
	item_path = /obj/item/clothing/head/hats/imperial/ce
	restricted_roles = list(JOB_CHIEF_ENGINEER)
	requires_purchase = FALSE

/datum/loadout_item/head/cowboyhat_sec
	name = "Cattleman Hat, Security"
	item_path = /obj/item/clothing/head/cowboy/nova/cattleman/sec
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT ,JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/head/cowboyhat_secwide
	name = "Wide-Brimmed Cattleman Hat, Security"
	item_path = /obj/item/clothing/head/cowboy/nova/cattleman/wide/sec
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT ,JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/head/blasthelmet //BUYABLE
	name = "Blast Helmet"
	item_path = /obj/item/clothing/head/hats/imperial/helmet

/datum/loadout_item/head/navybluehoscap
	name = "Head of Security's Naval Cap"
	item_path = /obj/item/clothing/head/hats/imperial/hos
	restricted_roles = list(JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/head/cybergoggles_civ //BUYABLE
	name = "Type-34C Forensics Headwear"
	item_path = /obj/item/clothing/head/fedora/det_hat/cybergoggles/civilian

/datum/loadout_item/head/cybergoggles	//Cyberpunk-P.I. Outfit
	name = "Type-34P Forensics Headwear"
	item_path = /obj/item/clothing/head/fedora/det_hat/cybergoggles
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT ,JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/head/imperial_generic //BUYABLE
	name = "Grey Naval Officer Cap"
	item_path = /obj/item/clothing/head/hats/imperial

/datum/loadout_item/head/imperial_grey //BUYABLE
	name = "Dark Grey Naval Officer Cap"
	item_path = /obj/item/clothing/head/hats/imperial/grey

/datum/loadout_item/head/imperial_red //BUYABLE
	name = "Red Naval Officer Cap"
	item_path = /obj/item/clothing/head/hats/imperial/red

/datum/loadout_item/head/imperial_white //BUYABLE
	name = "White Naval Officer Cap"
	item_path = /obj/item/clothing/head/hats/imperial/white

/datum/loadout_item/head/jester
	name = "Jester hat"
	item_path = /obj/item/clothing/head/costume/jester
	restricted_roles = list(JOB_CLOWN)
	requires_purchase = FALSE

/*
*	JOB BERETS
*/

/datum/loadout_item/head/atmos_beret
	name = "Atmospherics Beret"
	item_path = /obj/item/clothing/head/beret/atmos
	restricted_roles = list(JOB_ATMOSPHERIC_TECHNICIAN)
	requires_purchase = FALSE

/datum/loadout_item/head/beret_viro
	name = "Virologist Beret"
	item_path = /obj/item/clothing/head/beret/medical/virologist
	restricted_roles = list(JOB_VIROLOGIST)
	requires_purchase = FALSE

/datum/loadout_item/head/beret_chem
	name = "Chemist Beret"
	item_path = /obj/item/clothing/head/beret/medical/chemist
	restricted_roles = list(JOB_CHEMIST)
	requires_purchase = FALSE

/datum/loadout_item/head/beret_robo
	name = "Roboticist Beret"
	item_path = /obj/item/clothing/head/beret/science/fancy/robo
	restricted_roles = list(JOB_ROBOTICIST)
	requires_purchase = FALSE


// Legacy unpaintable cowboy hat because it fits a character better
/datum/loadout_item/head/cowboyhat_legacy  //BUYABLE
	name = "Cowboy Hat (Legacy)"
	item_path = /obj/item/clothing/head/costume/cowboyhat_old
