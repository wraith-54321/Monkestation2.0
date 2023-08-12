/obj/structure/spacevine/dense
	name = "dense space vines"
	opacity = TRUE
	growth_stage = 2

/obj/structure/spacevine/dense/Initialize(mapload)
	. = ..()
	icon_state = pick("Hvy1", "Hvy2", "Hvy3")
