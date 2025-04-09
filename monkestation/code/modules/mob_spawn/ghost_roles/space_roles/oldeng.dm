/datum/outfit/oldeng
	ears = /obj/item/radio/headset/headset_old
	skillchips = /obj/item/skillchip/job/engineer
	id = /obj/item/card/id/advanced/old
	id_trim = /datum/id_trim/job/away/old/eng
	belt = /obj/item/storage/belt/utility/full/engi

/datum/outfit/oldeng/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_UNCOMMON)
	R.freqlock = RADIO_FREQENCY_LOCKED
	R.independent = TRUE
	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
		W.update_icon()
	..()
