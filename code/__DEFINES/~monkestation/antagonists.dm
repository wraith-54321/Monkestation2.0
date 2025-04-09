// Monster Hunter stuff
#define UPGRADED_VAL(x,y) ( CEILING((x * (1.07 ** y)), 1) )
#define CALIBER_BLOODSILVER "bloodsilver"

///Whether a mob is a Monster Hunter
#define IS_MONSTERHUNTER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/monsterhunter))

/// Checks if the given mob is a slasher.
#define IS_SLASHER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/slasher))

/// List of areas blacklisted from area based traitor objectives
#define TRAITOR_OBJECTIVE_BLACKLISTED_AREAS list(/area/station/engineering/hallway, \
		/area/station/engineering/lobby, \
		/area/station/engineering/storage, \
		/area/station/science/lobby, \
		/area/station/science/ordnance/bomb, \
		/area/station/science/ordnance/freezerchamber, \
		/area/station/science/ordnance/burnchamber, \
		/area/station/security/prison, \
	)

// Clock cultist
#define IS_CLOCK(mob) ((FACTION_CLOCK in mob.faction) || mob?.mind?.has_antag_datum(/datum/antagonist/clock_cultist))
/// maximum amount of cogscarabs the clock cult can have
#define MAXIMUM_COGSCARABS 9
/// is something a cogscarab
#define iscogscarab(checked) (istype(checked, /mob/living/basic/drone/cogscarab))
/// is something an eminence
#define iseminence(checked) (istype(checked, /mob/living/eminence))

/// is something a worm
#define iscorticalborer(A) (istype(A, /mob/living/basic/cortical_borer))

/// Is the mob a blood brother
#define IS_BROTHER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/brother))

/// Whether the mob can convert others through innate flash shielding like IPCs (head revolutionaries and blood brothers)
#define CAN_BYPASS_INNATE_FLASH_RESISTANCE(mob) (IS_BROTHER(mob) || IS_HEAD_REVOLUTIONARY(mob))

// Borer evolution defines
// The three primary paths that eventually diverge
#define BORER_EVOLUTION_SYMBIOTE "Symbiote"
#define BORER_EVOLUTION_HIVELORD "Hivelord"
#define BORER_EVOLUTION_DIVEWORM "Diveworm"
// Just general upgrades that don't take you in a specific direction
#define BORER_EVOLUTION_GENERAL "General"
#define BORER_EVOLUTION_START "Start"

// Borer effect flags

/// If the borer is in stealth mode, giving less feedback to hosts at the cost of no health/resource/point gain
#define BORER_STEALTH_MODE (1<<0)
/// If the borer is sugar-immune, taking no ill effects from sugar
#define BORER_SUGAR_IMMUNE (1<<1)
/// If the borer is able to enter hosts in half the time, if not hiding
#define BORER_FAST_BORING (1<<2)
/// If the borer is currently hiding under tables/couches/stairs or appearing on top of them
#define BORER_HIDING (1<<3)
/// If the borer can produce eggs without a host
#define BORER_ALONE_PRODUCTION (1<<4)

/// How much heretic Mark of Rust mark does to items
#define RUST_MARK_DAMAGE	50
