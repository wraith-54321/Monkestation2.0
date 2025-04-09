/// The signal sent when an atom/movable should try to toggle their hiding.
/// Gets called on the target, with (hiding, play_feedback = TRUE) as its args.
/// Used for `/datum/element/can_hide`
#define COMSIG_MOVABLE_TOGGLE_HIDING "movable_toggle_hiding"

/// from base of atom/ratvar_act()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"

/// /datum/component/clockwork_trap signals: ()
#define COMSIG_CLOCKWORK_SIGNAL_RECEIVED "clock_received"

/// from base of atom/eminence_act() : (mob/living/eminence/user)
#define COMSIG_ATOM_EMINENCE_ACT "atom_eminence_act"

///Called by either cell/proc/give or cell/proc/use
#define COMSIG_CELL_CHANGE_POWER "cell_change_power"


// This isn't even used at the moment.
// Refactor this to a component if it's ever brought back.
// ~Absolucy
/*
/// Mob is trying to open the hacking menu of a target [/atom], from /datum/hacking/interactable(): (mob/user)
#define COMSIG_TRY_HACKING_INTERACT "try_hacking_interact"
	#define COMPONENT_CANT_INTERACT_HACKING (1<<0)
*/

/// generic turf checker signal
#define COMSIG_CHECK_TURF_GENERIC "check_turf_generic"
