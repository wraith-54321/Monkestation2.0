#define BRASS_POWER_COST STANDARD_CELL_CHARGE * 0.005
#define REGULAR_POWER_COST (BRASS_POWER_COST / 2)

/obj/item/clockwork/replica_fabricator
	name = "replica fabricator"
	desc = "A strange, brass device with many twisting cogs and vents."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	lefthand_file = 'monkestation/icons/mob/clock_cult/clockwork_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/clock_cult/clockwork_righthand.dmi'
	icon_state = "replica_fabricator"
	/// List of things that the fabricator can build for the radial menu
	var/static/list/crafting_possibilities = list(
		"floor" = image(icon = 'icons/turf/floors.dmi', icon_state = "clockwork_floor"),
		"wall" = image(icon = 'icons/turf/walls/clockwork_wall.dmi', icon_state = "clockwork_wall-0"),
		"wall gear" = image(icon = 'icons/obj/structures.dmi', icon_state = "wall_gear"),
		"window" = image(icon = 'icons/obj/smooth_structures/clockwork_window.dmi', icon_state = "clockwork_window-0"),
		"airlock" = image(icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi', icon_state = "closed"),
		"glass airlock" = image(icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi', icon_state = "construction"),
	)
	/// List of initialized fabrication datums, created on Initialize
	var/static/list/fabrication_datums = list()
	/// Ref to the datum we have selected currently
	var/datum/replica_fabricator_output/selected_output


/obj/item/clockwork/replica_fabricator/Initialize(mapload)
	. = ..()
	if(!length(fabrication_datums))
		create_fabrication_list()

/obj/item/clockwork/replica_fabricator/Destroy(force)
	selected_output = null
	return ..()

/obj/item/clockwork/replica_fabricator/examine(mob/user)
	. = ..()
	if(IS_CLOCK(user))
		. += span_brass("Current power: [display_power(SSthe_ark.clock_power)]")
		. += span_brass("Use on brass to convert it into power.")
		. += span_brass("Use on other materials to convert them into power, but less efficiently.")
		. += span_brass("<b>Use</b> in-hand to select what to fabricate.")
		. += span_brass("<b>Right Click</b> in-hand to fabricate bronze sheets.")
		. += span_brass("Walls and windows will be built slower while on reebe.")


/obj/item/clockwork/replica_fabricator/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!IS_CLOCK(user))
		return NONE

	if(istype(interacting_with, /obj/item/stack/sheet)) // If it's an item, handle it seperately
		attempt_convert_materials(interacting_with, user)
		return ITEM_INTERACT_SUCCESS

	if(!selected_output) // Now we handle objects
		return ITEM_INTERACT_BLOCKING

	if(SSthe_ark.clock_power < selected_output.cost)
		to_chat(user, span_clockyellow("[src] needs at least [selected_output.cost]W of power to create this."))
		return ITEM_INTERACT_BLOCKING

	var/turf/creation_turf = get_turf(interacting_with)
	var/atom/movable/replaced
	if(locate(selected_output.to_create_path) in creation_turf)
		to_chat(user, span_clockyellow("There is already one of these on this tile!"))
		return ITEM_INTERACT_BLOCKING

	if(selected_output.replace_types_of && istype(selected_output, /datum/replica_fabricator_output/turf_output))
		if(!isopenturf(interacting_with) && !(locate(creation_turf) in selected_output.replace_types_of))
			return ITEM_INTERACT_BLOCKING
	else if(selected_output.replace_types_of)
		for(var/checked_type in selected_output.replace_types_of)
			var/atom/movable/found_replaced = locate(checked_type) in creation_turf
			if(found_replaced)
				replaced = found_replaced
				break
		if(!replaced && !isopenturf(interacting_with))
			return ITEM_INTERACT_BLOCKING
	else if(!isopenturf(interacting_with))
		return ITEM_INTERACT_BLOCKING

	if(!selected_output.extra_checks(interacting_with, creation_turf, user))
		return ITEM_INTERACT_BLOCKING

	var/creation_delay_mult = 1
	if(on_reebe(user))
		creation_delay_mult += selected_output.reebe_mult
		if(GLOB.clock_ark?.current_state >= ARK_STATE_ACTIVE)
			creation_delay_mult += (iscogscarab(user) ? 2.5 : 5)
	if(replaced)
		creation_delay_mult += selected_output.replacement_mult

	var/selected_creation_delay = selected_output.creation_delay * max(creation_delay_mult, 0.1)
	var/obj/effect/temp_visual/ratvar/constructing_effect/effect = new(creation_turf, selected_creation_delay)
	if(!do_after(user, selected_creation_delay, interacting_with))
		qdel(effect)
		return ITEM_INTERACT_BLOCKING

	if(!SSthe_ark.adjust_clock_power(-selected_output.cost))
		return ITEM_INTERACT_BLOCKING

	var/atom/created
	if(!ispath(selected_output.to_create_path, /turf))
		qdel(replaced)
		created = new selected_output.to_create_path(creation_turf)

	selected_output.on_create(created, creation_turf, user)
	return ITEM_INTERACT_SUCCESS


/obj/item/clockwork/replica_fabricator/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!IS_CLOCK(user))
		return

	attempt_convert_materials(attacking_item, user)


/obj/item/clockwork/replica_fabricator/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(!IS_CLOCK(user))
		return

	if(SSthe_ark.clock_power < BRASS_POWER_COST)
		to_chat(user, span_clockyellow("You need at least [BRASS_POWER_COST]W of power to fabricate bronze."))
		return

	var/sheets = tgui_input_number(user, "How many sheets do you want to fabricate?", "Sheet Fabrication", 0, round(SSthe_ark.clock_power / BRASS_POWER_COST), 0)
	if(!sheets)
		return

	SSthe_ark.adjust_clock_power(sheets * BRASS_POWER_COST)

	var/obj/item/stack/sheet/bronze/sheet_stack = new(null, sheets)
	user.put_in_hands(sheet_stack)
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, span_clockyellow("You fabricate [sheets] bronze."))


/obj/item/clockwork/replica_fabricator/attack_self(mob/user, modifiers)
	. = ..()
	var/choice = show_radial_menu(user, src, crafting_possibilities, radius = 36, custom_check = PROC_REF(check_menu), require_near = TRUE)
	if(!choice)
		return

	selected_output = fabrication_datums[choice]


/// Standard confirmation for the radial menu proc
/obj/item/clockwork/replica_fabricator/proc/check_menu(mob/user)
	if(!istype(user) || user.incapacitated())
		return FALSE

	return TRUE

/// Attempt to convert the targeted item into power, if it's a sheet item
/obj/item/clockwork/replica_fabricator/proc/attempt_convert_materials(atom/attacking_item, mob/user)
	if(SSthe_ark.clock_power >= SSthe_ark.max_clock_power)
		to_chat(user, span_clockyellow("We are already at maximum power!"))
		return

	if(istype(attacking_item, /obj/item/stack/sheet/bronze))
		var/obj/item/stack/bronze_stack = attacking_item

		if((SSthe_ark.clock_power + bronze_stack.amount * BRASS_POWER_COST) > SSthe_ark.max_clock_power)
			var/amount_to_take = clamp(round((SSthe_ark.max_clock_power - SSthe_ark.clock_power) / BRASS_POWER_COST), 0, bronze_stack.amount)

			if(!amount_to_take)
				to_chat(user, span_clockyellow("[src] can't be powered further using this!"))
				return

			bronze_stack.use(amount_to_take)
			SSthe_ark.clock_power += amount_to_take * BRASS_POWER_COST

		else
			SSthe_ark.clock_power += bronze_stack.amount * BRASS_POWER_COST
			qdel(bronze_stack)

		playsound(src, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_clockyellow("You convert [bronze_stack.amount] bronze into [bronze_stack.amount * BRASS_POWER_COST] watts of power."))

		return TRUE

	else if(istype(attacking_item, /obj/item/stack/sheet))
		var/obj/item/stack/stack = attacking_item

		if((SSthe_ark.clock_power + stack.amount * REGULAR_POWER_COST) > SSthe_ark.max_clock_power)
			var/amount_to_take = clamp(round((SSthe_ark.max_clock_power - SSthe_ark.clock_power) / REGULAR_POWER_COST), 0, stack.amount)

			if(!amount_to_take)
				to_chat(user, span_clockyellow("[src] can't be powered further using this!"))
				return

			stack.use(amount_to_take)
			SSthe_ark.clock_power += amount_to_take * REGULAR_POWER_COST

		else
			SSthe_ark.clock_power += stack.amount * REGULAR_POWER_COST
			qdel(stack)

		playsound(src, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_clockyellow("You convert [stack.amount] [stack.name] into [stack.amount * REGULAR_POWER_COST] watts of power."))

		qdel(attacking_item)
		return TRUE

	return FALSE

/// Creates the list of initialized fabricator datums, done once on init
/obj/item/clockwork/replica_fabricator/proc/create_fabrication_list()
	for(var/type in subtypesof(/datum/replica_fabricator_output))
		var/datum/replica_fabricator_output/output_ref = new type
		fabrication_datums[output_ref.name] = output_ref


/datum/replica_fabricator_output
	/// Name of the output
	var/name = "parent"
	/// Power cost of the output
	var/cost = 0
	/// Typepath to spawn
	var/to_create_path
	/// How long the creation actionbar is
	var/creation_delay = 1 SECONDS
	/// List of objs this output can replace, normal walls for clock walls, windows for clock windows, ETC
	var/list/replace_types_of
	/// Multiplier to add to creation_delay when used on reebe
	var/reebe_mult = 0
	/// Multiplier to add to creation_delay when replacing an object in replace_types_of
	var/replacement_mult = 0

/// Any extra actions that need to be taken when an object is created
/datum/replica_fabricator_output/proc/on_create(atom/created_atom, turf/creation_turf, mob/creator)
	SHOULD_CALL_PARENT(TRUE)
	playsound(creation_turf, 'sound/machines/clockcult/integration_cog_install.ogg', 50, 1) // better sound?
	to_chat(creator, span_clockyellow("You create \an [name] for [cost]W of power."))

/datum/replica_fabricator_output/proc/extra_checks(atom/target, turf/created_at, mob/user)
	return TRUE

/datum/replica_fabricator_output/turf_output/extra_checks(atom/target, turf/creation_turf, mob/user)
	return !(creation_turf.resistance_flags & INDESTRUCTIBLE)

/datum/replica_fabricator_output/turf_output/on_create(atom/created_atom, turf/creation_turf, mob/creator)
	creation_turf.ChangeTurf(to_create_path, flags = CHANGETURF_INHERIT_AIR)
	return ..()

/datum/replica_fabricator_output/turf_output/brass_floor
	name = "floor"
	cost = BRASS_POWER_COST * 0.25 // 1/4th the cost, since one sheet = 4 floor tiles
	creation_delay = 3 SECONDS
	to_create_path = /turf/open/floor/engine/clockwork

/datum/replica_fabricator_output/turf_output/brass_floor/extra_checks(atom/target, turf/creation_turf, mob/user)
	return !isindestructiblefloor(creation_turf) && !istype(creation_turf, /turf/open/floor/cult) && !istype(creation_turf, /turf/open/floor/engine/clockwork) && ..()

/datum/replica_fabricator_output/turf_output/brass_floor/on_create(atom/created_atom, turf/creation_turf, mob/creator, looping = FALSE)
	. = ..()
	new /obj/effect/temp_visual/ratvar/floor(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	if(looping)
		return

	for(var/turf/open/floor/floor_turf in RANGE_TURFS(1, creation_turf)) //NOT WORKING?
		if(extra_checks(created_atom, floor_turf, creator))
			if(!SSthe_ark.adjust_clock_power(-cost))
				break
			on_create(created_atom, floor_turf, creator, TRUE)

/datum/replica_fabricator_output/turf_output/brass_wall
	name = "wall"
	cost = BRASS_POWER_COST * 4
	to_create_path = /turf/closed/wall/clockwork
	creation_delay = 14 SECONDS
	replace_types_of = list(/turf/closed/wall, /turf/closed/wall/r_wall)
	replacement_mult = -0.2

/datum/replica_fabricator_output/turf_output/brass_wall/on_create(obj/created_object, turf/creation_turf, mob/creator)
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)

/datum/replica_fabricator_output/wall_gear
	name = "wall gear"
	cost = BRASS_POWER_COST * 2
	to_create_path = /obj/structure/girder/bronze
	creation_delay = 5 SECONDS
	replace_types_of = list(/obj/structure/girder)

/datum/replica_fabricator_output/wall_gear/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/gear(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/brass_window
	name = "window"
	cost = BRASS_POWER_COST * 2
	to_create_path = /obj/structure/window/reinforced/clockwork/fulltile
	creation_delay = 10 SECONDS
	replace_types_of = list(/obj/structure/window)
	reebe_mult = 0.2

/datum/replica_fabricator_output/brass_window/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/window(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/pinion_airlock
	name = "airlock"
	cost = BRASS_POWER_COST * 5 // Breaking it only gets 2 but this is the exception to the rule of equivalent exchange, due to all the small parts inside
	to_create_path = /obj/machinery/door/airlock/bronze/clock/player_made
	creation_delay = 10 SECONDS
	replace_types_of = list(/obj/machinery/door)
	replacement_mult = 1

/datum/replica_fabricator_output/pinion_airlock/extra_checks(atom/target, turf/created_at, mob/user)
	if(on_reebe(created_at) && SSthe_ark.reebe_clockwork_airlock_count > MAXIMUM_REEBE_AIRLOCKS)
		to_chat(user, span_warning("Reebe cannot support the power drain of any more clockwork airlocks."))
		return FALSE
	return TRUE

/datum/replica_fabricator_output/pinion_airlock/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/door(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/pinion_airlock/glass
	name = "glass airlock"
	to_create_path = /obj/machinery/door/airlock/bronze/clock/player_made/glass

#undef BRASS_POWER_COST
#undef REGULAR_POWER_COST
