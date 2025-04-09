// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed" // Unknown plant seed - these shouldn't exist in-game.
	worn_icon_state = "seed"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	/// Name of plant when planted.
	var/plantname = "Plants"
	/// A type path. The thing that is created when the plant is harvested.
	var/obj/item/product
	///Describes the product on the product path.
	var/productdesc
	/// Used to update icons. Should match the name in the sprites unless all icon_* are overridden.
	var/species = ""
	///the file that stores the sprites of the growing plant from this seed.
	var/growing_icon = 'icons/obj/hydroponics/growing.dmi'
	/// Used to override grow icon (default is `"[species]-grow"`). You can use one grow icon for multiple closely related plants with it.
	var/icon_grow
	/// Used to override dead icon (default is `"[species]-dead"`). You can use one dead icon for multiple closely related plants with it.
	var/icon_dead
	/// Used to override harvest icon (default is `"[species]-harvest"`). If null, plant will use `[icon_grow][growthstages]`.
	var/icon_harvest
	/// Used to offset the plant sprite so that it appears at proper height in the tray
	var/plant_icon_offset = 8
	/// How long before the plant begins to take damage from age.
	var/lifespan = 25
	/// Amount of health the plant has.
	var/endurance = 15
	/// Used to determine which sprite to switch to when growing.
	var/maturation = 25
	/// Changes the amount of time needed for a plant to become harvestable.
	var/production = 25
	/// Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/yield = 30
	/// The 'power' of a plant. Generally effects the amount of reagent in a plant, also used in other ways.
	var/potency = 10
	/// Amount of growth sprites the plant has.
	var/growthstages = 6
	/// How rare the plant is. Used for giving points to cargo when shipping off to CentCom.
	var/rarity = 0
	/// The type of plants that this plant can mutate into.
	var/list/mutatelist
	/// Starts as a list of paths, is converted to a list of types on init. Plant gene datums are stored here, see plant_genes.dm for more info.
	var/list/genes = list()
	/// A list of reagents to add to product.
	var/list/reagents_add
	// Format: "reagent_id" = potency multiplier
	// Stronger reagents must always come first to avoid being displaced by weaker ones.
	// Total amount of any reagent in plant is calculated by formula: max(round(potency * multiplier), 1)
	///If the chance below passes, then this many weeds sprout during growth
	var/weed_rate = 1
	///Percentage chance per tray update to grow weeds
	var/weed_chance = 5
	///Determines if the plant has had a graft removed or not.
	var/grafted = FALSE
	///Type-path of trait to be applied when grafting a plant.
	var/graft_gene

	var/blooming_stage = 0
	///the age at which the plant should be harvested at
	var/harvest_age = 120
	///list of all mutations that are generated via stats
	var/list/possible_mutations = list()
	///list of all traits currently being trained
	var/list/traits_in_progress = list()
	///list of infusion_mutations checked on infusion for requirements and moved to possible_mutations
	var/list/infusion_mutations = list()
	///infusion damage
	var/infusion_damage = 0

/obj/item/seeds/Initialize(mapload, nogenes = FALSE)
	. = ..()
	pixel_x = base_pixel_x + rand(-8, 8)
	pixel_y = base_pixel_y + rand(-8, 8)

	if(!icon_grow)
		icon_grow = "[species]-grow"

	if(!icon_dead)
		icon_dead = "[species]-dead"

	if(!icon_harvest && !get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism) && yield != -1)
		icon_harvest = "[species]-harvest"

	var/list/generated_mutations = list()
	for(var/datum/hydroponics/plant_mutation/listed_item as anything in possible_mutations)
		var/datum/hydroponics/plant_mutation/created_list_item = new listed_item
		generated_mutations += created_list_item
	possible_mutations = generated_mutations

	var/list/generated_infusions = list()
	for(var/datum/hydroponics/plant_mutation/infusion/listed_item as anything in infusion_mutations)
		var/datum/hydroponics/plant_mutation/infusion/created_list_item = new listed_item
		generated_infusions += created_list_item
	infusion_mutations = generated_infusions

	if(!nogenes) // not used on Copy()
		genes += new /datum/plant_gene/core/lifespan(lifespan)
		genes += new /datum/plant_gene/core/endurance(endurance)
		genes += new /datum/plant_gene/core/weed_rate(weed_rate)
		genes += new /datum/plant_gene/core/weed_chance(weed_chance)
		if(yield != -1)
			genes += new /datum/plant_gene/core/yield(yield)
			genes += new /datum/plant_gene/core/production(production)
			genes += new /datum/plant_gene/core/maturation(maturation)
		if(potency != -1)
			genes += new /datum/plant_gene/core/potency(potency)

		for(var/plant_gene in genes)
			if(ispath(plant_gene))
				genes -= plant_gene
				genes += new plant_gene

		// Go through all traits in their genes and call on_new_seed from them.
		for(var/datum/plant_gene/trait/traits in genes)
			traits.on_new_seed(src)

		for(var/reag_id in reagents_add)
			genes += new /datum/plant_gene/reagent(reag_id, reagents_add[reag_id])
		reagents_from_genes() //quality coding

	var/static/list/hovering_item_typechecks = list(
		/obj/item/plant_analyzer = list(
			SCREENTIP_CONTEXT_LMB = "Scan seed stats",
			SCREENTIP_CONTEXT_RMB = "Scan seed chemicals"
		),
	)

	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)
/obj/item/seeds/Destroy()
	// No AS ANYTHING here, because the list/genes could have typepaths in it.
	for(var/datum/plant_gene/gene in genes)
		gene.on_removed(src)
		qdel(gene)

	genes.Cut()
	return ..()

/obj/item/seeds/examine(mob/user)
	. = ..()
	. += span_notice("Use a pen on it to rename it or change its description.")
	if(reagents_add && user.can_see_reagents())
		. += span_notice("- Plant Reagents -")
		for(var/datum/plant_gene/reagent/reagent_gene in genes)
			. += span_notice("- [reagent_gene.get_name()] -")

/// Copy all the variables from one seed to a new instance of the same seed and return it.
/obj/item/seeds/proc/Copy()
	var/obj/item/seeds/copy_seed = new type(null, TRUE)

	copy_seed.genes = list()
	///copy traits first than we do stats
	for(var/datum/plant_gene/gene in genes)
		var/datum/plant_gene/copied_gene = gene.Copy()
		copy_seed.genes += copied_gene
		copied_gene.on_new_seed(copy_seed)

	// Copy all the stats
	copy_seed.set_lifespan(lifespan)
	copy_seed.set_endurance(endurance)
	copy_seed.set_maturation(maturation)
	copy_seed.set_production(production)
	copy_seed.set_yield(yield)
	copy_seed.set_potency(potency)
	copy_seed.set_weed_rate(weed_rate)
	copy_seed.set_weed_chance(weed_chance)
	copy_seed.name = name
	copy_seed.plantname = plantname
	copy_seed.desc = desc
	copy_seed.productdesc = productdesc

	copy_seed.reagents_add = reagents_add.Copy() // Fastetr than grabbing the list from genes.
	copy_seed.harvest_age = harvest_age

	copy_seed.species = species
	copy_seed.icon_grow = icon_grow
	copy_seed.icon_harvest = icon_harvest
	copy_seed.icon_dead = icon_dead
	copy_seed.growthstages = growthstages
	copy_seed.growing_icon = growing_icon
	copy_seed.plant_icon_offset = plant_icon_offset
	copy_seed.traits_in_progress = traits_in_progress

	if(istype(src, /obj/item/seeds/spliced))
		var/obj/item/seeds/spliced/spliced_seed = src
		var/obj/item/seeds/spliced/new_spliced_seed = copy_seed
		new_spliced_seed.produce_list += spliced_seed.produce_list

	return copy_seed

/obj/item/seeds/proc/get_gene(typepath)
	return (locate(typepath) in genes)

/obj/item/seeds/proc/reagents_from_genes()
	reagents_add = list()
	for(var/datum/plant_gene/reagent/R in genes)
		reagents_add[R.reagent_id] = R.rate

///This proc adds a mutability_flag to a gene
/obj/item/seeds/proc/set_mutability(typepath, mutability)
	var/datum/plant_gene/g = get_gene(typepath)
	if(g)
		g.mutability_flags |=  mutability

///This proc removes a mutability_flag from a gene
/obj/item/seeds/proc/unset_mutability(typepath, mutability)
	var/datum/plant_gene/g = get_gene(typepath)
	if(g)
		g.mutability_flags &=  ~mutability

/obj/item/seeds/proc/mutate(lifemut = 2, endmut = 5, productmut = 1, yieldmut = 2, potmut = 25, wrmut = 2, wcmut = 5, traitmut = 0)
	adjust_lifespan(rand(-lifemut,lifemut))
	adjust_endurance(rand(-endmut,endmut))
	adjust_production(rand(-productmut,productmut))
	adjust_yield(rand(-yieldmut,yieldmut))
	adjust_potency(rand(-potmut,potmut))
	adjust_weed_rate(rand(-wrmut, wrmut))
	adjust_weed_chance(rand(-wcmut, wcmut))
	if(prob(traitmut))
		if(prob(50))
			add_random_traits(1, 1)
		else
			add_random_reagents(1, 1)



/obj/item/seeds/bullet_act(obj/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(istype(Proj, /obj/projectile/energy/flora/yield))
		var/rating = 1
		if(yield == 0)//Oh god don't divide by zero you'll doom us all.
			adjust_yield(1 * rating)
		else if(prob(1/(yield * yield) * 100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			adjust_yield(1 * rating)
	else
		return ..()


// Harvest procs
/obj/item/seeds/proc/getYield()
	return yield


/obj/item/seeds/proc/harvest(mob/user)
	///Reference to the tray/soil the seeds are planted in.
	var/atom/movable/parent = loc //for ease of access
	///List of plants all harvested from the same batch.
	var/list/result = list()
	///Tile of the harvester to deposit the growables.
	var/output_loc = parent.Adjacent(user) ? user.drop_location() : parent.drop_location() //needed for TK
	///Name of the grown products.
	var/product_name
	var/seed_harvest_ratio = 0.2
	var/seedless = get_gene(/datum/plant_gene/trait/seedless)
	///the value of yield that the harvest amount stops being linear and slows down
	var/yield_linearity_breakpoint = 100
	///linear region growth coeff
	var/harvest_linear_coeff = 0.1
	///harvest amount gets close to 20 as yield gets close to +infinity
	var/maximum_harvest_amount = 20
	///to be calculated later based on yield
	var/harvest_amount = 0
	var/harvest_counter = 0
	var/maximum_seed_production = 0
	var/seed_counter = 0
	var/plant_yield = getYield()

	if(user.client)
		add_jobxp_chance(user.client, 1, JOB_BOTANIST, 20)

	if(plant_yield >= yield_linearity_breakpoint)
		harvest_amount = qp_sigmoid(yield_linearity_breakpoint, maximum_harvest_amount, plant_yield)
		if(!seedless)
			maximum_seed_production = floor(harvest_amount * seed_harvest_ratio)

	else
		harvest_amount = floor(plant_yield * harvest_linear_coeff)
		if(!seedless)
			maximum_seed_production = floor(harvest_amount * seed_harvest_ratio)
			if ((plant_yield > 0 && maximum_seed_production == 0) && prob(50))
				maximum_seed_production = 1

	while(harvest_counter < harvest_amount)
		while(seed_counter < maximum_seed_production)
			var/obj/item/seeds/seed_prod
			if(prob(65) && has_viable_mutations())
				seed_prod = create_valid_mutation(output_loc, TRUE)
				ADD_TRAIT(seed_prod, TRAIT_PLANT_WILDMUTATE, "mutated")
			else
				seed_prod = src.Copy_drop(output_loc)
			result.Add(seed_prod)
			harvest_counter++
			seed_counter++
		var/obj/item/food/grown/item_grown
		if(prob(10) && has_viable_mutations())
			item_grown = create_valid_mutation(output_loc)
		else
			if(!product)
				harvest_counter++
				continue
			item_grown = new product(output_loc, src)
			if(plantname != initial(plantname))
				item_grown.name = plantname
			if(istype(item_grown))
				item_grown.seed.name = name
				item_grown.seed.desc = desc
				item_grown.seed.plantname = plantname
		result.Add(item_grown) // User gets a consumable
		if(!item_grown)
			return
		harvest_counter++
		if(istype(item_grown))
			product_name = item_grown.seed.plantname
	if(harvest_amount >= 1)
		SSblackbox.record_feedback("tally", "food_harvested", harvest_amount, product_name)
	return result


/**
 * This is where plant chemical products are handled.
 *
 * Individually, the formula for individual amounts of chemicals is Potency * the chemical production %, rounded to the fullest 1.
 * Specific chem handling is also handled here, like bloodtype, food taste within nutriment, and the auto-distilling/autojuicing traits.
 * This is where chemical reactions can occur, and the heating / cooling traits effect the reagent container.
 */
/obj/item/seeds/proc/prepare_result(obj/item/T)
	if(!T.reagents)
		CRASH("[T] has no reagents.")
	var/total_reagents = 0
	var/potency_rate = potency/100
	for(var/rid in reagents_add)
		total_reagents += reagents_add[rid] * potency_rate
	if(IS_EDIBLE(T) || istype(T, /obj/item/grown))
		var/obj/item/food/grown/grown_edible = T
		if(total_reagents > 0)
			var/grown_edible_volume = grown_edible.reagents ? grown_edible.reagents.maximum_volume : 0
			var/fitting_proportion = min(1/total_reagents, 1)
			for(var/rid in reagents_add)
				var/amount = max(1, round(grown_edible_volume * potency_rate * reagents_add[rid] * fitting_proportion, 1)) //the plant will always have at least 1u of each of the reagents in its reagent production traits
				var/list/data
				if(rid == /datum/reagent/blood) // Hack to make blood in plants always O-
					data = list("blood_type" = /datum/blood_type/crew/human/o_minus)
				if(istype(grown_edible) && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
					data = grown_edible.tastes // apple tastes of apple.
				T.reagents.add_reagent(rid, amount, data)

			//Handles the juicing trait, swaps nutriment and vitamins for that species various juices if they exist. Mutually exclusive with distilling.
			if(get_gene(/datum/plant_gene/trait/juicing) && grown_edible.juice_results)
				grown_edible.on_juice()
				grown_edible.reagents.add_reagent_list(grown_edible.juice_results)

			/// The number of nutriments we have inside of our plant, for use in our heating / cooling genes
			var/num_nutriment = T.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)

			// Heats up the plant's contents by 25 kelvin per 1 unit of nutriment. Mutually exclusive with cooling.
			if(get_gene(/datum/plant_gene/trait/chem_heating))
				T.visible_message(span_notice("[T] releases freezing air, consuming its nutriments to heat its contents."))
				T.reagents.remove_all_type(/datum/reagent/consumable/nutriment, num_nutriment, strict = TRUE)
				T.reagents.chem_temp = min(1000, (T.reagents.chem_temp + num_nutriment * 25))
				T.reagents.handle_reactions()
				playsound(T.loc, 'sound/effects/wounds/sizzle2.ogg', 5)
			// Cools down the plant's contents by 5 kelvin per 1 unit of nutriment. Mutually exclusive with heating.
			else if(get_gene(/datum/plant_gene/trait/chem_cooling))
				T.visible_message(span_notice("[T] releases a blast of hot air, consuming its nutriments to cool its contents."))
				T.reagents.remove_all_type(/datum/reagent/consumable/nutriment, num_nutriment, strict = TRUE)
				T.reagents.chem_temp = max(3, (T.reagents.chem_temp + num_nutriment * -5))
				T.reagents.handle_reactions()
				playsound(T.loc, 'sound/effects/space_wind.ogg', 50)

/// Setters procs ///

/**
 * Adjusts seed yield up or down according to adjustamt. (Max 10)
 */
/obj/item/seeds/proc/adjust_yield(adjustamt)
	if(yield == -1) // Unharvestable shouldn't suddenly turn harvestable
		return

	var/max_yield = MAX_PLANT_YIELD
	var/min_yield = 0
	for(var/datum/plant_gene/trait/trait in genes)
		if(trait.trait_flags & TRAIT_HALVES_YIELD)
			max_yield = round(max_yield/2)
			break
	if(get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		min_yield = FUNGAL_METAB_YIELD_MIN

	yield = clamp(yield + adjustamt, min_yield, max_yield)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
	if(C)
		C.value = yield

/**
 * Adjusts seed lifespan up or down according to adjustamt. (Max 100)
 */
/obj/item/seeds/proc/adjust_lifespan(adjustamt)
	lifespan = clamp(lifespan + adjustamt, 10, MAX_PLANT_LIFESPAN)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/**
 * Adjusts seed endurance up or down according to adjustamt. (Max 100)
 */
/obj/item/seeds/proc/adjust_endurance(adjustamt)
	endurance = clamp(endurance + adjustamt, MIN_PLANT_ENDURANCE, MAX_PLANT_ENDURANCE)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/**
 * Adjusts seed production seed up or down according to adjustamt. (Max 10)
 */
/obj/item/seeds/proc/adjust_production(adjustamt)
	if(yield == -1)
		return
	production = clamp(production + adjustamt, 1, MAX_PLANT_PRODUCTION)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
	if(C)
		C.value = production
/**
 * Adjusts seed potency up or down according to adjustamt. (Max 100)
 */
/obj/item/seeds/proc/adjust_potency(adjustamt)
	if(potency == -1)
		return

	var/max_potency = MAX_PLANT_YIELD
	potency = clamp(potency + adjustamt, 0, max_potency)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
	if(C)
		C.value = potency

/obj/item/seeds/proc/adjust_maturation(adjustamt)
	if(maturation == -1)
		return
	maturation = maturation + adjustamt
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/maturation)
	if(C)
		C.value = maturation
/**
 * Adjusts seed weed grwoth speed up or down according to adjustamt. (Max 10)
 */
/obj/item/seeds/proc/adjust_weed_rate(adjustamt)
	weed_rate = clamp(weed_rate + adjustamt, 0, MAX_PLANT_WEEDRATE)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/**
 * Adjusts seed weed chance up or down according to adjustamt. (Max 67%)
 */
/obj/item/seeds/proc/adjust_weed_chance(adjustamt)
	weed_chance = clamp(weed_chance + adjustamt, 0, MAX_PLANT_WEEDCHANCE)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance


//Directly setting stats

/**
 * Sets the plant's yield stat to the value of adjustamt. (Max 10, or 5 with some traits)
 */
/obj/item/seeds/proc/set_yield(adjustamt)
	if(yield == -1) // Unharvestable shouldn't suddenly turn harvestable
		return

	var/max_yield = MAX_PLANT_YIELD
	var/min_yield = 0
	for(var/datum/plant_gene/trait/trait in genes)
		if(trait.trait_flags & TRAIT_HALVES_YIELD)
			max_yield = round(max_yield/2)
			break
	if(get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		min_yield = FUNGAL_METAB_YIELD_MIN

	yield = clamp(adjustamt, min_yield, max_yield)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
	if(C)
		C.value = yield


/**
 * Sets the plant's lifespan stat to the value of adjustamt. (Max 100)
 */
/obj/item/seeds/proc/set_lifespan(adjustamt)
	lifespan = clamp(adjustamt, 10, MAX_PLANT_LIFESPAN)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan
/**
 * Sets the plant's endurance stat to the value of adjustamt. (Max 100)
 */
/obj/item/seeds/proc/set_endurance(adjustamt)
	endurance = clamp(adjustamt, MIN_PLANT_ENDURANCE, MAX_PLANT_ENDURANCE)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/**
 * Sets the plant's production stat to the value of adjustamt. (Max 10)
 */
/obj/item/seeds/proc/set_production(adjustamt)
	if(yield == -1)
		return
	production = clamp(adjustamt, 1, MAX_PLANT_PRODUCTION)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
	if(C)
		C.value = production

/obj/item/seeds/proc/set_maturation(adjustamt)
	if(yield == -1)
		return
	maturation = adjustamt
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/maturation)
	if(C)
		C.value = maturation
/**
 * Sets the plant's potency stat to the value of adjustamt. (Max 100)
 */
/obj/item/seeds/proc/set_potency(adjustamt)
	if(potency == -1)
		return
	potency = clamp(adjustamt, 0, MAX_PLANT_POTENCY)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
	if(C)
		C.value = potency

/**
 * Sets the plant's weed production rate to the value of adjustamt. (Max 10)
 */
/obj/item/seeds/proc/set_weed_rate(adjustamt)
	weed_rate = clamp(adjustamt, 0, MAX_PLANT_WEEDRATE)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/**
 * Sets the plant's weed growth percentage to the value of adjustamt. (Max 67%)
 */
/obj/item/seeds/proc/set_weed_chance(adjustamt)
	weed_chance = clamp(adjustamt, 0, MAX_PLANT_WEEDCHANCE)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance

/**
 * Override for seeds with unique text for their analyzer. (No newlines at the start or end of unique text!)
 * Returns null if no unique text, or a string of text if there is.
 */
/obj/item/seeds/proc/get_unique_analyzer_text()
	return null

/**
 * Override for seeds with special chem reactions.
 */
/obj/item/seeds/proc/on_chem_reaction(datum/reagents/reagents)
	return

/obj/item/seeds/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/pen))
		var/choice = tgui_input_list(usr, "What would you like to change?", "Seed Alteration", list("Plant Name", "Seed Description", "Product Description"))
		if(isnull(choice))
			return
		if(!user.can_perform_action(src))
			return
		switch(choice)
			if("Plant Name")
				var/newplantname = reject_bad_text(tgui_input_text(user, "Write a new plant name", "Plant Name", plantname, 20))
				if(isnull(newplantname))
					return
				if(!user.can_perform_action(src))
					return
				name = "[lowertext(newplantname)]"
				plantname = newplantname
			if("Seed Description")
				var/newdesc = tgui_input_text(user, "Write a new seed description", "Seed Description", desc, 180)
				if(isnull(newdesc))
					return
				if(!user.can_perform_action(src))
					return
				desc = newdesc
			if("Product Description")
				if(product && !productdesc)
					productdesc = initial(product.desc)
				var/newproductdesc = tgui_input_text(user, "Write a new product description", "Product Description", productdesc, 180)
				if(isnull(newproductdesc))
					return
				if(!user.can_perform_action(src))
					return
				productdesc = newproductdesc

	..() // Fallthrough to item/attackby() so that bags can pick seeds up

/obj/item/seeds/proc/randomize_stats()
	set_lifespan(rand(25, 60))
	set_endurance(rand(15, 35))
	set_production(rand(2, 10))
	set_yield(rand(1, 10))
	set_potency(rand(10, 35))
	set_weed_rate(rand(1, 10))
	set_weed_chance(rand(5, 100))
	maturation = rand(6, 12)

/obj/item/seeds/proc/add_random_reagents(lower = 0, upper = 2)
	var/amount_random_reagents = rand(lower, upper)
	for(var/i in 1 to amount_random_reagents)
		var/random_amount = rand(4, 15) * 0.01 // this must be multiplied by 0.01, otherwise, it will not properly associate
		var/datum/plant_gene/reagent/R = new(pick_reagent(), random_amount) // monkestation edit: pick_reagent proc
		if(R.can_add(src))
			if(!R.try_upgrade_gene(src))
				genes += R
		else
			qdel(R)
	reagents_from_genes()

// monkestation start: pick_reagent proc
/// Returns a random reagent ID.
/// Just a wrapper around [get_random_reagent_id] by default, this exists so subtypes can override it.
/obj/item/seeds/proc/pick_reagent()
	return get_random_reagent_id()
// monkestation end

/obj/item/seeds/proc/add_random_traits(lower = 0, upper = 2)
	var/amount_random_traits = rand(lower, upper)
	for(var/i in 1 to amount_random_traits)
		var/random_trait = pick(subtypesof(/datum/plant_gene/trait))
		var/datum/plant_gene/trait/picked_random_trait = new random_trait
		if((picked_random_trait.mutability_flags & PLANT_GENE_MUTATABLE) && picked_random_trait.can_add(src))
			genes += picked_random_trait
		else
			qdel(picked_random_trait)

/obj/item/seeds/proc/add_random_plant_type(normal_plant_chance = 75)
	if(prob(normal_plant_chance))
		var/random_plant_type = pick(subtypesof(/datum/plant_gene/trait/plant_type))
		var/datum/plant_gene/trait/plant_type/P = new random_plant_type
		if(P.can_add(src))
			genes += P
		else
			qdel(P)

/obj/item/seeds/proc/remove_random_reagents(lower = 0, upper = 2)
	var/amount_random_reagents = rand(lower, upper)
	for(var/i in 1 to amount_random_reagents)
		var/datum/reagent/chemical = pick(reagents_add)
		qdel(chemical)

/**
 * Creates a graft from this plant.
 *
 * Creates a new graft from this plant.
 * Sets the grafts trait to this plants graftable trait.
 * Gives the graft a reference to this plant.
 * Copies all the relevant stats from this plant to the graft.
 * Returns the created graft.
 */
/obj/item/seeds/proc/create_graft()
	var/obj/item/graft/snip = new(loc, graft_gene)
	snip.parent_name = plantname
	snip.name += " ([plantname])"

	// Copy over stats so the graft can outlive its parent.
	snip.lifespan = lifespan
	snip.endurance = endurance
	snip.production = production
	snip.weed_rate = weed_rate
	snip.weed_chance = weed_chance
	snip.yield = yield

	return snip

/**
 * Applies a graft to this plant.
 *
 * Adds the graft trait to this plant if possible.
 * Increases plant stats by 2/3 of the grafts stats to a maximum of 100 (10 for yield).
 * Returns TRUE if the graft could apply its trait successfully, FALSE if it fails to apply the trait.
 * NOTE even if the graft fails to apply the trait it still adjusts the plant's stats and reagents.
 *
 * Arguments:
 * - [snip][/obj/item/graft]: The graft being used applied to this plant.
 */
/obj/item/seeds/proc/apply_graft(obj/item/graft/snip)
	. = TRUE
	var/datum/plant_gene/new_trait = snip.stored_trait
	if(new_trait?.can_add(src))
		genes += new_trait.Copy()
	else
		. = FALSE

	// Adjust stats based on graft stats
	set_lifespan(round(max(lifespan, (lifespan + (2/3)*(snip.lifespan - lifespan)))))
	set_endurance(round(max(endurance, (endurance + (2/3)*(snip.endurance - endurance)))))
	set_production(round(max(production, (production + (2/3)*(snip.production - production)))))
	set_weed_rate(round(max(weed_rate, (weed_rate + (2/3)*(snip.weed_rate - weed_rate)))))
	set_weed_chance(round(max(weed_chance, (weed_chance+ (2/3)*(snip.weed_chance - weed_chance)))))
	set_yield(round(max(yield, (yield + (2/3)*(snip.yield - yield)))))

	// Add in any reagents, too.
	reagents_from_genes()

	return

/*
 * Both `/item/food/grown` and `/item/grown` implement a seed variable which tracks
 * plant statistics, genes, traits, etc. This proc gets the seed for either grown food or
 * grown inedibles and returns it, or returns null if it's not a plant.
 *
 * Returns an `/obj/item/seeds` ref for grown foods or grown inedibles.
 *  - returned seed CAN be null in weird cases but in all applications it SHOULD NOT be.
 * Returns null if it is not a plant.
 */
/obj/item/proc/get_plant_seed()
	return null

/obj/item/food/grown/get_plant_seed()
	return seed

/obj/item/grown/get_plant_seed()
	return seed
