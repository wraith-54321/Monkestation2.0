
//random room spawner. takes random rooms from their appropriate map file and places them.

/obj/effect/spawner/room
	name = "random room spawner"
	icon = 'monkestation/icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	///List of template room_key values that are valid for us to pick from
	var/list/valid_room_keys = list()
	///What is the width of rooms we spawn
	var/room_width = 0
	///What is the height of rooms we spawn
	var/room_height = 0

//CHECK MOVING THIS FROM New() ACTUALLY WORKS
/obj/effect/spawner/room/Initialize(mapload)
	. = ..()
	/*if(!SSmapping.random_room_spawners[src.type])
		SSmapping.random_room_spawners[src.type] = list()

	SSmapping.random_room_spawners[src.type] += src
	return INITIALIZE_HINT_LATELOAD*/

	if(!SSmapping.valid_random_templates_by_spawner_type[src.type])
		SSmapping.valid_random_templates_by_spawner_type[src.type] = list()
		for(var/key in valid_room_keys)
			for(var/datum/map_template/random_room/possible_template in SSmapping.random_room_templates[key])
				if(room_height != possible_template.template_height || room_width != possible_template.template_width)
					continue

				SSmapping.valid_random_templates_by_spawner_type[src.type] += possible_template.weight

	//template weights can change so this has to be generated each time we want to spawn a room
	var/list/weighted_template_list = list()
	for(var/datum/map_template/random_room/template in SSmapping.valid_random_templates_by_spawner_type[src.type])
		if((template.stock != -1 && !template.stock))
			SSmapping.valid_random_templates_by_spawner_type[src.type] -= template
			continue

		weighted_template_list[template] = template.weight

	if(!length(weighted_template_list))
		message_admins("Room spawner created with no templates available. This shouldn't happen.")
		stack_trace("Room spawner([src.type]) created with no templates available.")
		return INITIALIZE_HINT_QDEL

	var/datum/map_template/random_room/picked_template = pick_weight(weighted_template_list)
	picked_template.stock--
	picked_template.weight -= picked_template.scaling_weight
	if(SSticker.state == GAME_STATE_STARTUP)
		picked_template.stationinitload(get_turf(src), picked_template.centerspawner)
	else
		picked_template.load(get_turf(src), picked_template.centerspawner)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/room/fivexfour
	name = "5x4 room spawner"
	room_width = 5
	room_height = 4

/obj/effect/spawner/room/fivexthree
	name = "5x3 room spawner"
	room_width = 5
	room_height = 3

/obj/effect/spawner/room/threexfive
	name = "3x5 room spawner"
	room_width = 3
	room_height = 5

/obj/effect/spawner/room/tenxten
	name = "10x10 room spawner"
	room_width = 10
	room_height = 10

/obj/effect/spawner/room/tenxfive
	name = "10x5 room spawner"
	room_width = 10
	room_height = 5

/obj/effect/spawner/room/threexthree
	name = "3x3 room spawner"
	room_width = 3
	room_height = 3

/obj/effect/spawner/room/fland
	name = "Special Room (5x11)"
	icon_state = "random_room_alternative"
	room_width = 5
	room_height = 11

/obj/effect/spawner/room/random_engines
	name = "random room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH

/// MetaStation Engine Area Spawner
/obj/effect/spawner/room/random_engines/meta
	name = "meta engine spawner"
	room_width = 33
	room_height = 25

/// TramStation Engine Area Spawner
/obj/effect/spawner/room/random_engines/tram
	name = "tram engine spawner"
	room_width = 24
	room_height = 20

/obj/effect/spawner/room/random_engines/kilo
	name = "kilo engine spawner"
	room_width = 20
	room_height = 21

/obj/effect/spawner/room/random_bar
	name = "random bar spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH

/obj/effect/spawner/room/random_bar/icebox
	name = "Icebox bar spawner"
	room_width = 18
	room_height = 12

/obj/effect/spawner/room/random_bar/tramstation
	name = "Tramstation bar spawner"
	room_width = 30
	room_height = 25
