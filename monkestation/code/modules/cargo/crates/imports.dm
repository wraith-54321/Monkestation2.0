/datum/supply_pack/imports/servicepistol
	name = "Service pistol crate"
	desc = "!&@#Some classic pistols for the classic spaceman.!%!$#"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/gun/ballistic/revolver/nagant = 2,
					/obj/item/ammo_box/n762 = 2)
	crate_name = "Emergency Crate"

/datum/supply_pack/imports/pistolmags
	name = "Service pistol ammo"
	desc = "%$!#More ammo for your beloved antique.%!#@"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/ammo_box/n762 = 6)
	crate_name = "Emergency Crate"

/datum/supply_pack/imports/wt550
	name = "WT-550 Autorifle Crate"
	desc = "A proper ballistic option for a proper ballistic officer."
	cost = CARGO_CRATE_VALUE * 21
	contains = list(
		/obj/item/gun/ballistic/automatic/wt550/no_mag = 2,
		/obj/item/ammo_box/magazine/wt550m9/wtrub = 4,
	)
	crate_name = "Autorifle Crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/wt550ammo/nonlethal
	name = "WT-550 Non-Lethal Ammo Crate"
	desc = "A supply of non-lethal ammunition for the WT-550 autorifle."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9/wtrub = 3,
		/obj/item/ammo_box/magazine/wt550m9/wtsalt = 3,
	)
	crate_name = "wt-550 non-lethal ammo crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/wt550ammo
	name = "WT-550 Ammo Crate"
	desc = "A supply of spare and exotic lethal ammunition for the WT-550 autorifle."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9 = 2,
		/obj/item/ammo_box/magazine/wt550m9/wtap = 2,
		/obj/item/ammo_box/magazine/wt550m9/wtic = 2,
	)
	crate_name = "wt-550 ammo crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/Lrevolvercrate
	name = "Long Revolver Crate"
	desc = "We got these old revolvers from a unnamed man, enjoy them"
	cost = CARGO_CRATE_VALUE * 10
	contains = list(
		/obj/item/gun/ballistic/revolver/r45l = 2,
		/obj/item/ammo_box/g45l = 1,
		/obj/item/ammo_box/g45l/rubber = 1,
	)
	crate_name = "Long Revolver crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/Briflecrate
	name = "Bush Rifle Crate"
	desc = "These old rifles were sold to us by a unnamed man, quite the bargin"
	cost = CARGO_CRATE_VALUE * 7
	contains = list(
		/obj/item/gun/ballistic/shotgun/leveraction = 3,
		/obj/item/ammo_box/g45l = 2,
		/obj/item/ammo_box/g45l/rubber = 1,
	)
	crate_name = "Bush Rifle crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/fss
	name = "FSS-550 Design Disk"
	desc = "Do you hate gun control? So do I! This will let any autolathe produce more guns than security can keep track of!"
	cost = CARGO_CRATE_VALUE * 10
	hidden = TRUE
	contains = list(/obj/item/disk/design_disk/fss)
	crate_name = "Emergency Crate"
