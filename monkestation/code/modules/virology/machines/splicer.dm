#define DISEASE_SPLICER_BURNING_TICKS 5
#define DISEASE_SPLICER_SPLICING_TICKS 5
#define DISEASE_SPLICER_SCANNING_TICKS 5

/obj/machinery/computer/diseasesplicer
	name = "disease splicer"
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "splicer"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.6
	light_color = "#00FF00"

	icon_keyboard = null
	icon_screen = null
	circuit = /obj/item/circuitboard/computer/diseasesplicer
	var/datum/symptom/memorybank = null
	var/analysed = FALSE // If the buffered effect came from a dish that had been analyzed this is TRUE
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0 // Time in process ticks until disk burning is over

	var/splicing = 0 // Time in process ticks until splicing is over
	var/scanning = 0 // Time in process ticks until scan is over
	var/spliced = FALSE // If at least one effect has been spliced into the current dish this is TRUE

	///the slot we are set to grab from
	var/target_slot = 1

/obj/machinery/computer/diseasesplicer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isvirusdish(tool) && !istype(tool, /obj/item/disk/disease))
		return NONE

	if(isvirusdish(tool))
		if(dish)
			to_chat(user, span_warning("A virus containment dish is already inside \the [src]."))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("You can't let go of \the [tool]!"))
			return ITEM_INTERACT_BLOCKING
		dish = tool
		playsound(loc, 'sound/machines/click.ogg', vol = 50, vary = TRUE)
		update_icon()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/disk/disease))
		var/obj/item/disk/disease/disk = tool
		visible_message(span_notice("[user] swipes \the [disk] against \the [src]."),
						span_notice("You swipe \the [disk] against \the [src], copying the data into the machine's buffer."))
		memorybank = disk.effect
		analysed = disk.analyzed
		var/image/disk_icon = image(icon, src, "splicer_disk")
		flick_overlay_global(disk_icon, GLOB.clients, 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 2, TIMER_OVERRIDE | TIMER_UNIQUE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/diseasesplicer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DiseaseSplicer")
		ui.open()


/obj/machinery/computer/diseasesplicer/ui_data(mob/user)
	. = ..()
	var/list/data = list(
		"splicing" = splicing,
		"scanning" = scanning,
		"burning" = burning,
		"target_slot" = target_slot,
	)

	if(dish)
		if(dish.contained_virus)
			if(dish.analysed)
				data["dish_name"] = dish.contained_virus.name()
			else
				data["dish_name"] = "Unknown [dish.contained_virus.form]"
		else
			data["dish_name"] = "Empty Dish"

	if(memorybank)
		data["memorybank"] = "[analysed ? memorybank.name : "Unknown DNA strand"] (Stage [memorybank.stage])"

	if(!dish)
		data["dish_error"] = "no dish inserted"
	else if(!dish.contained_virus)
		data["dish_error"] = "no pathogen in dish"
	else if(!dish.analysed)
		data["dish_error"] = "dish not analysed"
	else if(dish.growth < 50)
		data["dish_error"] = "not enough cells"
	return data

/obj/machinery/computer/diseasesplicer/attack_hand(mob/user, list/modifiers)
	. = ..()

	if(machine_stat & (NOPOWER|BROKEN))
		eject_dish()
		return

	if(.)
		return

	ui_interact(user)

/obj/machinery/computer/diseasesplicer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(scanning || splicing || burning)
		use_power = ACTIVE_POWER_USE
	else
		use_power = IDLE_POWER_USE

	if(scanning)
		scanning--
		if(!scanning)
			update_icon()
	if(splicing)
		splicing--
		if(!splicing)
			update_icon()
	if(burning)
		burning--
		if(!burning)
			update_icon()
			var/image/print = image(icon, src, "splicer_print")
			flick_overlay_global(print, GLOB.clients, 2 SECONDS)
			var/obj/item/disk/disease/d = new /obj/item/disk/disease(src)
			if(analysed)
				d.name = "\improper [memorybank.name] GNA disk"
				d.analyzed = TRUE
			else
				d.name = "unknown GNA disk (Stage: [memorybank.stage])"
			d.effect = memorybank
			d.update_desc()
			addtimer(CALLBACK(src, PROC_REF(drop_disease_disk), d), 1 SECONDS)

/obj/machinery/computer/diseasesplicer/proc/drop_disease_disk(obj/item/disk/disease/disk)
	disk.forceMove(drop_location())
	disk.pixel_x = -6
	disk.pixel_y = 3

/obj/machinery/computer/diseasesplicer/update_overlays()
	..()
	. = list() // We don't use any of the overlays from the parent

	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(dish?.contained_virus)
		if(dish.analysed)
			var/mutable_appearance/scan_pattern = mutable_appearance(icon, "pattern-[dish.contained_virus.pattern]-s")
			. +=  emissive_appearance(icon, "pattern-[dish.contained_virus.pattern]-s", src)

			. += scan_pattern
		else
			. += mutable_appearance(icon, "splicer_unknown")

	if(memorybank)
		. += emissive_appearance(icon, "splicer_buffer", src)
		. += mutable_appearance(icon, "splicer_buffer", src)

	. += emissive_appearance(icon, "splicer_screen", src)
	. += emissive_appearance(icon, "splicer_keyboard", src)

/obj/machinery/computer/diseasesplicer/proc/buffer2dish()
	if(!memorybank || !dish?.contained_virus)
		return

	var/list/effects = dish.contained_virus.symptoms
	for(var/x = 1 to length(effects))
		if(x == target_slot)
			var/datum/symptom/e = effects[x]
			effects[x] = memorybank.Copy(dish.contained_virus)
			var/datum/symptom/ough = effects[x]
			ough.OnAdd(dish.contained_virus)
			dish.contained_virus.log += "<br />[ROUND_TIME()] [memorybank.name] spliced in by [key_name(usr)] (replaces [e.name])"
			break

	splicing = DISEASE_SPLICER_SPLICING_TICKS
	spliced = TRUE
	update_icon()

/obj/machinery/computer/diseasesplicer/proc/dish2buffer(target_slot)
	if(!dish?.contained_virus)
		return
	if(dish.growth < 50)
		return
	var/list/effects = dish.contained_virus.symptoms
	for(var/x = 1 to effects.len)
		var/datum/symptom/e = effects[x]
		if(e.stage == target_slot)
			memorybank = e
			break
	scanning = DISEASE_SPLICER_SCANNING_TICKS
	analysed = dish.analysed
	qdel(dish)
	dish = null
	update_icon()
	var/image/scan = image(icon, src, "splicer_scan")
	flick_overlay_global(scan, GLOB.clients, 2 SECONDS)

/obj/machinery/computer/diseasesplicer/proc/eject_dish()
	if(!dish)
		return
	if(spliced)
		//Here we generate a new ID so the spliced pathogen gets it's own entry in the database instead of being shown as the old one.
		dish.contained_virus.subID = rand(0, 9999)
		var/list/randomhexes = list("7","8","9","a","b","c","d","e")
		var/colormix = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		dish.contained_virus.color = BlendRGB(dish.contained_virus.color,colormix,0.25)
		dish.contained_virus.addToDB()
		say("Updated pathogen database with new spliced entry.")
		dish.info = dish.contained_virus.get_info()
		dish.name = "growth dish ([dish.contained_virus.name()])"
		spliced = FALSE
		dish.contained_virus.update_global_log()

	dish.forceMove(loc)
	if(Adjacent(usr))
		dish.forceMove(usr.drop_location())
		usr.put_in_hands(dish)
	dish = null
	update_icon()


/obj/machinery/computer/diseasesplicer/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE

	if(scanning || splicing || burning)
		return FALSE

	add_fingerprint(usr)

	switch(action)
		if("eject_dish")
			eject_dish()
			return TRUE
		if("erase_buffer")
			memorybank = null
			update_appearance()
			return TRUE
		if("dish_effect_to_buffer")
			dish2buffer(target_slot)
			return TRUE
		if("splice_buffer_to_dish")
			buffer2dish()
			return TRUE
		if("burn_buffer_to_disk")
			burning = DISEASE_SPLICER_BURNING_TICKS
			return TRUE
		if("target_slot")
			target_slot = params["stage"]
	return FALSE

#undef DISEASE_SPLICER_BURNING_TICKS
#undef DISEASE_SPLICER_SPLICING_TICKS
#undef DISEASE_SPLICER_SCANNING_TICKS
