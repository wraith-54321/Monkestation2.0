/obj/item/gang_communicator_upgrade
	name = "communicator ugrade"
	desc = "A strange device with what looks to be a radio transmitter attached."
	icon = 'icons/obj/device.dmi'
	icon_state = "trapdoor_pressed"

/obj/item/gang_communicator_upgrade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/extra_examine/gang, span_syndradio("Apply to something that contains a gang implant to upgrade the implant with a communicator for your gang."))

/obj/item/gang_communicator_upgrade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	var/obj/item/implant/uplink/gang/implant = locate(/obj/item/implant/uplink/gang) in target.contents
	if(!implant)
		return ..()

	if(implant.communicate)
		to_chat(user, span_notice("\The [implant] already has a communicator."))
		return ..()

	implant.add_communicator()
	qdel(src)
	return
