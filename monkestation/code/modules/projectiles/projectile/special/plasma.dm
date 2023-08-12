/obj/item/projectile/plasma/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()
	if(istype(newloc, /turf/open/floor/plating/dirt/jungleland))
		var/turf/open/floor/plating/dirt/jungleland/dirt_newloc = newloc
		dirt_newloc.spawn_rock()
