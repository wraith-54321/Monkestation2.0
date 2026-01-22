/datum/uplink_item/dangerous/uzi
	name = "Type U3 Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	item = /obj/item/gun/ballistic/automatic/mini_uzi
	cost = 16
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/uzi_mag
	name = "U3 Uzi Magazine"
	desc = "A single 32 round magazine for the U3 Uzi SMG."
	item = /obj/item/ammo_box/magazine/uzim9mm
	cost = 5
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/bulk_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 120 rounds of 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/bulk
	cost = 10
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/ap_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 30 rounds of AP 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/ap
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/ap_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 30 rounds of hollowpoint 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/hp
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/ap_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 30 rounds of incendiary 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/fire
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/dangerous/gang_turret
	name = "Disposable Sentry Gun"
	desc = "A disposable gang aligned sentry gun deployment system cleverly disguised as a toolbox, apply wrench for functionality."
	item = /obj/item/storage/toolbox/emergency/turret/gang
	cost = 12
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/dangerous/tommygun
	name = "Thomson SMG"
	desc = "A classic design nicknamed the \"Tommy Gun\" carrying an impressive 50 round drum magazine chambered in .45,\
			sure to mow down your enemies. Comes with 2 magazines and a stylish carrying case."
	item = /obj/item/storage/briefcase/tommygun
	cost = 25
	purchasable_from = UPLINK_GANGS

/obj/item/storage/briefcase/tommygun
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/briefcase/tommygun/Initialize(mapload)
	atom_storage.max_slots = 3
	atom_storage.max_total_storage = 8
	atom_storage.set_holdable(list(/obj/item/ammo_box/magazine/tommygunm45), exception_hold_list = list(/obj/item/gun/ballistic/automatic/tommygun/gang))
	return ..()

/obj/item/storage/briefcase/tommygun/PopulateContents()
	new /obj/item/gun/ballistic/automatic/tommygun/gang(src)
	new /obj/item/ammo_box/magazine/tommygunm45(src)
	new /obj/item/ammo_box/magazine/tommygunm45(src)

/datum/uplink_item/device_tools/gang_communicator
	name = "Uplink Communicator Upgrade"
	desc = "An upgrade for your implant that when applied will grant you the ability to communicate to other members of your gang via your implant's inbuilt communication network."
	item = /obj/item/gang_device/communicator_upgrade
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_spraycan
	name = "Gang Spraycan"
	desc = "A modified spraycan that can be used to claim areas for your gang."
	item = /obj/item/toy/crayon/spraycan/gang
	cost = 1
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_spraycan_resistant
	name = "Improved Gang Spraycan"
	desc = "An improved version of the gang spraycan that comes with 5 charges of an extra chemical mix used to give it's painted tags a coating making them resistant to cleaning\
			and being sprayed over. This mix is also able to disolve the coating on other resistant tags."
	item = /obj/item/toy/crayon/spraycan/gang/resistant
	cost = 3
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/credit_converter_beacon
	name = "Credit Converter Beacon"
	desc = "A device used to call down a credit converter in a stylish drop pod."
	item = /obj/item/gang_device/object_beacon/gang_machine/credit_converter
	cost = 20
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_fabricator_beacon
	name = "Gang Fabricator Beacon"
	desc = "A device used to call down a gang fabricator in a stylish drop pod."
	item = /obj/item/gang_device/object_beacon/gang_machine/fabricator
	cost = 15
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_machine_converter
	name = "Machine Hacking Device"
	desc = "A small device that can be used to convert the ownership of a machine owned by another gang to that of your own."
	item = /obj/item/gang_device/machine_converter
	cost = 5
	purchasable_from = UPLINK_GANGS
