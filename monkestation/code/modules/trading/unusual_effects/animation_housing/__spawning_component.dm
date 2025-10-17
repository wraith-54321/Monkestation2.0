
/obj/effect/abstract/particle
	name = ""
	plane = GAME_PLANE_FOV_HIDDEN
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'monkestation/code/modules/trading/icons/particles.dmi'
	icon_state = "none"
	underlays = null
	overlays = null

/datum/component/particle_spewer
	var/atom/source_object
	///the unusual_description grabbed into the actual handler itself only needed when used as an unusual
	var/unusual_description = "teehee"
	///the duration we last
	var/duration = 0
	///the spawn intervals in game ticks
	var/spawn_interval = 1
	///particles still in the process of animating
	var/list/living_particles = list()
	///list of particles that finished (added only as a failsafe)
	var/list/dead_particles = list()
	///x offset for source_object
	var/offset_x = 0
	///y offset for source_object
	var/offset_y = 0
	///the dmi location of the particle
	var/icon_file = 'monkestation/code/modules/trading/icons/particles.dmi'
	///the icon_state given to the objects
	var/particle_state = "none"
	///current process count
	var/count = 0
	///equipped offset ie hats go to 32 if set to 32 will also reset to height changes
	var/equipped_offset = 0
	///per burst spawn amount
	var/burst_amount = 1
	///the actual lifetime of this component before we die [ 0 = infinite]
	var/lifetime = 0
	///kept track of for removal sake
	var/added_x = 0
	var/added_y = 0
	/// do we do random amounts of particle bursts?
	var/random_bursts = FALSE
	///should we offset
	var/offsets = TRUE
	/// do we process?
	var/processes = TRUE
	///the blend type we use for particles
	var/particle_blending = BLEND_DEFAULT
	/// our animate_holder
	var/datum/animate_holder/animate_holder
	/// If the effect is currently paused.
	var/paused = FALSE

/datum/component/particle_spewer/Initialize(duration = 0, spawn_interval = 0, offset_x = 0, offset_y = 0, icon_file, particle_state, equipped_offset = 0, burst_amount = 0, lifetime = 0, random_bursts = 0)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(icon_file)
		src.icon_file = icon_file
	if(particle_state)
		src.particle_state = particle_state
	if(offset_x)
		src.offset_x = offset_x + rand(-8, 8)
	if(offset_y)
		src.offset_y = offset_y + rand(-4, 4)
	if(spawn_interval)
		src.spawn_interval = spawn_interval
	if(duration)
		src.duration = duration
	if(equipped_offset)
		src.equipped_offset = equipped_offset
	if(burst_amount)
		src.burst_amount = burst_amount
	if(lifetime)
		src.lifetime = lifetime
	if(random_bursts)
		src.random_bursts = random_bursts
	source_object = parent

	animate_holder = new()
	animate_holder.animates_self = FALSE
	adjust_animate_steps()

	update_processing()
	RegisterSignal(source_object, COMSIG_ITEM_EQUIPPED, PROC_REF(handle_equip_offsets))
	RegisterSignal(source_object, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(reset_offsets))
	RegisterSignal(source_object, COMSIG_MOVABLE_MOVED, PROC_REF(update_processing))

	if(lifetime)
		QDEL_IN(src, lifetime)

/datum/component/particle_spewer/Destroy(force)
	UnregisterSignal(source_object, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_POST_UNEQUIP,
		COMSIG_MOVABLE_MOVED,
	))
	STOP_PROCESSING(SSactualfastprocess, src)
	QDEL_LIST(living_particles)
	QDEL_LIST(dead_particles)
	source_object = null
	QDEL_NULL(animate_holder)
	return ..()

/datum/component/particle_spewer/process(seconds_per_tick)
	if(!get_turf(source_object) || paused)
		return PROCESS_KILL
	if(spawn_interval != 1)
		count++
		if(count < spawn_interval)
			return
	count = 0
	spawn_particles()

/datum/component/particle_spewer/proc/update_processing()
	SIGNAL_HANDLER
	if(paused || QDELETED(src) || QDELETED(source_object) || !processes || !get_turf(source_object) || istype(source_object.loc, /obj/machinery/ore_silo) || istype(source_object.loc, /obj/machinery/rnd/production) || istype(source_object.loc, /obj/machinery/mecha_part_fabricator)) // we do not need the ore silo to sparkle constantly
		STOP_PROCESSING(SSactualfastprocess, src)
	else
		START_PROCESSING(SSactualfastprocess, src)

/datum/component/particle_spewer/proc/spawn_particles(atom/movable/mover, turf/target)
	var/burstees = burst_amount
	if(random_bursts)
		burstees = rand(1, burst_amount)

	var/turf/spawn_loc = get_turf(source_object)
	for(var/i = 0 to burstees)
		//create and assign particle its stuff
		var/obj/effect/abstract/particle/spawned = new(spawn_loc)
		if(offsets)
			spawned.pixel_x = offset_x
			spawned.pixel_y = offset_y
		spawned.icon = icon_file
		spawned.icon_state = particle_state
		spawned.blend_mode = particle_blending

		living_particles |= spawned

		RegisterSignal(spawned, COMSIG_QDELETING, PROC_REF(particle_qdeleting))
		animate_particle(spawned)

///this is the proc that gets overridden when we create new particle spewers that control its movements
//example is animating upwards over duration and deleting
/datum/component/particle_spewer/proc/animate_particle(obj/effect/abstract/particle/spawned)
	animate_holder?.animate_object(spawned)
	QDEL_IN(spawned, duration)

/datum/component/particle_spewer/proc/adjust_animate_steps()
	animate_holder.add_animation_step(list(alpha = 75, time = duration))
	animate_holder.add_animation_step(list(pixel_y = offset_y + 64, time = duration))

/datum/component/particle_spewer/proc/particle_qdeleting(obj/effect/abstract/particle/spawned)
	living_particles -= spawned
	UnregisterSignal(spawned, COMSIG_QDELETING)

/datum/component/particle_spewer/proc/handle_equip_offsets(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	offset_x -= added_x
	offset_y -= added_y
	added_x = 0
	added_y = 0

	switch(slot)
		if(ITEM_SLOT_HEAD)
			added_y = 16
		else
			added_y = 0
			added_x = 0

	offset_y += added_y
	offset_x += added_x

/datum/component/particle_spewer/proc/reset_offsets()
	SIGNAL_HANDLER
	offset_x -= added_x
	offset_y -= added_y
	added_x = 0
	added_y = 0

/obj/item/debug_particle_holder/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/particle_spewer, 2 SECONDS)

/datum/component/particle_spewer/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_ADJUST_ANIMATIONS, "Adjust Animations")

/datum/component/particle_spewer/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ADJUST_ANIMATIONS] && check_rights(R_VAREDIT))
		animate_holder.ui_interact(usr)
