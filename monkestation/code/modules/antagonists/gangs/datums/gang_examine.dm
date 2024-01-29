/datum/element/extra_examine/gang

/datum/element/extra_examine/gang/check_requirements(atom/source, mob/user, list/examine_texts)
	return isobserver(user) || IS_GANGMEMBER(user)
