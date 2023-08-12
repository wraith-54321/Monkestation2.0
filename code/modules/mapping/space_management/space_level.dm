/datum/space_level
	var/name = "NAME MISSING"
	var/list/neigbours = list()
	var/list/traits
	var/z_value = 1 //actual z placement
	var/linkage = SELFLOOPING
	var/xi
	var/yi   //imaginary placements on the grid
//monkestation edit start
	///list of all possible weather_effects this z can have
	var/list/weather_effects
//monkestation edit end

/datum/space_level/New(new_z, new_name, list/new_traits = list(), new_weather_effects) //monkestation edit: adds new_weather_effects
	z_value = new_z
	name = new_name
	traits = new_traits
	weather_effects = new_weather_effects //monkestation edit

	if (islist(new_traits))
		for (var/trait in new_traits)
			SSmapping.z_trait_levels[trait] += list(new_z)
	else // in case a single trait is passed in
		SSmapping.z_trait_levels[new_traits] += list(new_z)


	set_linkage(new_traits[ZTRAIT_LINKAGE])
