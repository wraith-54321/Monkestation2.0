GLOBAL_LIST_EMPTY(cached_preround_items)

/client
	var/datum/pre_round_store/readied_store

/datum/pre_round_store
	var/datum/store_item/bought_item

/datum/pre_round_store/Destroy(force)
	SStgui.close_uis(src)
	bought_item = null
	return ..()

/datum/pre_round_store/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreRoundStore", "Spend Monkecoins")
		ui.open()

/datum/pre_round_store/ui_state(mob/user)
	return GLOB.always_state

/datum/pre_round_store/ui_data(mob/user)
	. = ..()

	var/list/data = list(
		"notices" = config.lobby_notices
	)
	var/list/buyables = list()

	if(!length(GLOB.cached_preround_items))
		for(var/datum/store_item/listed_item as anything in (subtypesof(/datum/store_item) - /datum/store_item/roundstart))
			if(!initial(listed_item.one_time_buy))
				continue
			GLOB.cached_preround_items += listed_item

	for(var/datum/store_item/listed_item as anything in GLOB.cached_preround_items)
		var/datum/store_item/created_store_item = new listed_item
		var/obj/item/created_item = new created_store_item.item_path
		buyables += list(
			list(
				"path" = created_store_item.type,
				"name" = created_store_item.name,
				"cost" = created_store_item.item_cost,
				"image" = icon2base64(icon(created_item.icon, created_item.icon_state)),
			)
		)
		qdel(created_store_item)
		qdel(created_item)

	if(!user.client.prefs.metacoins)
		user.client.prefs.load_metacoins(user.client.ckey)


	if(bought_item)
		data["balance"] = user.client.prefs.metacoins - initial(bought_item.item_cost)
	else
		data["balance"] = user.client.prefs.metacoins

	data["items"] += buyables
	data["currently_owned"] = initial(bought_item.name)

	return data

/datum/pre_round_store/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("attempt_buy")
			attempt_buy(params)
			return TRUE

/datum/pre_round_store/proc/attempt_buy(list/params)
	var/id = params["path"]
	var/path = text2path(id)
	var/datum/store_item/attempted_item = text2path(id)
	if(!ispath(path, /datum/store_item))
		message_admins("[usr] attempted an href exploit.")
		return
	bought_item = new attempted_item

/datum/pre_round_store/proc/finalize_purchase_spawn(mob/new_player_mob, mob/new_player_mob_living)
	var/datum/preferences/owners_prefs = new_player_mob.client.prefs
	if(!owners_prefs.has_coins(initial(bought_item.item_cost)))
		to_chat(new_player_mob, span_warning("It seems your lacking coins to complete this transaction."))
		return
	var/obj/item/created_item = new bought_item.item_path

	if(istype(created_item, /obj/item/effect_granter))
		var/obj/item/effect_granter/granting_time = created_item
		if(granting_time.human_only && iscarbon(new_player_mob_living))
			spawn(4 SECONDS)
				if(!granting_time.grant_effect(new_player_mob_living))
					return
		else
			QDEL_NULL(new_player_mob.client.readied_store)
			return
	else if(!new_player_mob.put_in_hands(created_item, FALSE))
		var/obj/item/storage/backpack/backpack = new_player_mob_living.get_item_by_slot(ITEM_SLOT_BACK)
		if(!backpack)
			to_chat(new_player_mob, "There was an error spawning in your items, you will not be charged")
			return
		backpack.atom_storage.attempt_insert(created_item, new_player_mob, force = TRUE)

	owners_prefs.adjust_metacoins(new_player_mob.client.ckey, (-initial(bought_item.item_cost)), "Bought a [created_item] for [initial(bought_item.item_cost)] (Pre-round Store)", donator_multiplier = FALSE)
	QDEL_NULL(new_player_mob.client.readied_store)
