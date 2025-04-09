/mob/living
	///our immune system
	var/datum/immune_system/immune_system

/atom
	///image
	var/image/pathogen

/mob/living/proc/spread_airborne_diseases()
	//spreading our own airborne viruses
	if (diseases && diseases.len > 0)
		var/list/airborne_viruses = filter_disease_by_spread(diseases, required = DISEASE_SPREAD_AIRBORNE)
		if (airborne_viruses && airborne_viruses.len > 0)
			var/strength = 0
			for (var/datum/disease/acute/V as anything in airborne_viruses)
				strength += V.infectionchance
			strength = round(strength/airborne_viruses.len)
			while (strength > 0)//stronger viruses create more clouds at once
				new /obj/effect/pathogen_cloud/core(get_turf(src), src, airborne_viruses)
				strength -= 40

/mob/living/infect_disease(datum/disease/acute/disease, forced = FALSE, notes = "", decay = TRUE)
	if(!istype(disease))
		return FALSE

	if(!(disease.infectable_biotypes & mob_biotypes))
		return

	if(!disease.spread_flags && !(disease.disease_flags & DISEASE_DORMANT))
		return FALSE

	for(var/datum/disease/acute/old_disease as anything in diseases)
		if(disease.uniqueID == old_disease.uniqueID && disease.subID == old_disease.subID) // child ids are for pathogenic mutations and aren't accounted for as thats fucked.
			return FALSE

	if(immune_system && !immune_system.CanInfect(disease))
		return FALSE

	if(prob(disease.infectionchance) || forced)
		var/datum/disease/acute/D = disease.Copy()
		if (D.infectionchance > 5)
			D.infectionchance = max(5, D.infectionchance - 5)//The virus gets weaker as it jumps from people to people

		D.stage = clamp(disease.stage + D.stage_variance, 1, D.max_stages)
		D.log += "<br />[ROUND_TIME()] Infected [key_name(src)] [notes]. Infection chance now [D.infectionchance]%"

		LAZYADD(diseases, D)
		D.affected_mob = src
		//SSdisease.active_diseases += D
		D.after_add()
		src.med_hud_set_status()

		log_virus("[key_name(src)] was infected by virus: [D.admin_details()] at [loc_name(loc)]")

		D.AddToGoggleView(src)

		if(GLOB.static_plague_team)
			var/datum/team/plague_rat/plague = GLOB.static_plague_team
			if (plague && ("[D.uniqueID]-[D.subID]" == plague.disease_id))
				var/datum/objective/plague/O = locate() in plague.objectives
				if (O && !istype(src, /mob/living/basic/mouse/plague))
					O.total_infections++
				plague.update_hud_icons()

	return TRUE

/mob/dead/new_player/proc/DiseaseCarrierCheck(mob/living/carbon/human/H)
	// 10% of players are joining the station with some minor disease if latejoined
	if(prob(10))
		var/virus_choice = pick(WILD_ACUTE_DISEASES)
		var/datum/disease/acute/D = new virus_choice

		var/list/anti = list(
			ANTIGEN_BLOOD	= 1,
			ANTIGEN_COMMON	= 1,
			ANTIGEN_RARE	= 0,
			ANTIGEN_ALIEN	= 0,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 1,
			EFFECT_DANGER_FLAVOR	= 4,
			EFFECT_DANGER_ANNOYING	= 4,
			EFFECT_DANGER_HINDRANCE	= 0,
			EFFECT_DANGER_HARMFUL	= 0,
			EFFECT_DANGER_DEADLY	= 0,
			)

		D.makerandom(list(30,55),list(0,50),anti,bad,null)

		D.log += "<br />[ROUND_TIME()] Infected [key_name(H)]"
		if(!length(H.diseases))
			H.diseases = list()
		H.diseases += D

		D.AddToGoggleView(H)
