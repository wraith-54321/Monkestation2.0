/datum/asset/spritesheet/plumbing
	name = "plumbing-tgui"

/datum/asset/spritesheet/plumbing/create_spritesheets()
	//load only what we need from the icon files,format is icon_file_name = list of icon_states we need from this file
	var/list/essentials = list(
		'icons/obj/medical/iv_drip.dmi' = list("plumb"),
		'icons/obj/plumbing/fluid_ducts.dmi' = list("nduct"),
		'icons/hud/radial.dmi' = list(
			"plumbing_layer1",
			"plumbing_layer2",
			"plumbing_layer4",
			"plumbing_layer8",
			"plumbing_layer16",
		),
		'icons/obj/plumbing/plumbers.dmi' = list(
			"synthesizer",
			"reaction_chamber",
			"grinder_chemical",
			"fermenter",
			"pump",
			"disposal",
			"buffer",
			"manifold",
			"pipe_input",
			"filter",
			"splitter",
			"beacon",
			"pipe_output",
			"tank",
			"acclimator",
			"bottler",
			"pill_press",
			"synthesizer_soda",
			"synthesizer_booze",
			"tap_output",
		),
		/* monkestation start: xenobiology rework */
		'monkestation/code/modules/slimecore/icons/machinery.dmi' = list(
			"cross_compressor",
			"ooze_sucker",
		),
		'monkestation/code/modules/slimecore/icons/slime_grinder.dmi' = list(
			"slime_grinder_backdrop",
		),
		/* monkestation end */
	)

	for(var/icon_file as anything in essentials)
		for(var/icon_state as anything in essentials[icon_file])
			Insert(sprite_name = icon_state, I = icon_file, icon_state = icon_state)

