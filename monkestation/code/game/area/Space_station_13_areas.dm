// MonkeDome Areas for the crew's sanity

/// LS = Life Support, or where all the power, atmos, and pipe connections are
/area/maintenance/monkedome/ls/civ/englifesupport
	name = "Civilian Hub LS Engineering Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/civ/seclifesupport
	name = "Civilian Hub LS ComSec Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/civ/reslifesupport
	name = "Civilian Hub LS Research Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/civ/medlifesupport
	name = "Civilian Hub LS Medical Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/eng/lifesupport
	name = "Engineering Hub LS Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/med/lifesupport
	name = "Medical Hub LS Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/med/virolifesupport
	name = "Medical Hub Virology LS Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/res/lifesupport
	name = "Research Hub LS Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/res/xenooutlifesupport
	name = "Research Hub Xenobio LS Connection"
	icon_state = "engine"

/area/maintenance/monkedome/ls/comsec/lifesupport
	name = "ComSec Hub LS Connection"
	icon_state = "engine"

/area/hallway/monkedome/security
	name = "Security Hub Primary Hallway"
	icon_state = "hallA"

/area/hallway/monkedome/comsec
	name = "ComSec Hub Entry Hallway"
	icon_state = "entry"

/area/maintenance/monkedome/comsec/fore
	name = "ComSec Hub Fore Maintenance"
	icon_state = "foremaint"

/area/maintenance/monkedome/comsec/central
	name = "ComSec Hub Central Maintenance"
	icon_state = "centralmaint"

/area/maintenance/monkedome/comsec/aft
	name = "ComSec Hub Aft Maintenance"
	icon_state = "aftmaint"

/area/medical/monkedome/constructionarea
	name = "Medical Hub Construction Area"

/area/medical/monkedome/storageroom
	name = "Medical Hub Storage Room"

/area/hallway/monkedome/medical
	name = "Medical Hub Primary Hallway"
	icon_state = "hallA"

/area/maintenance/monkedome/medical/port
	name = "Medical Hub Port Maintenance"
	icon_state = "portmaint"

/area/maintenance/monkedome/medical/starboard
	name = "Medical Hub Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/monkedome/medical/fore
	name = "Medical Hub Fore Maintenance"
	icon_state = "foremaint"

/area/hallway/monkedome/civilian/central
	name = "Civilian Hub Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/monkedome/civilian/fore
	name = "Civilian Hub Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/monkedome/civilian/aft
	name = "Civilian Hub Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/monkedome/civilian/port
	name = "Civilian Hub Port Primary Hallway"
	icon_state = "hallP"

/area/maintenance/monkedome/civilian/upperfore
	name = "Civilian Hub Upper Fore Maintenance"
	icon_state = "upperforemaint"

/area/maintenance/monkedome/civilian/upperstarboard
	name = "Civilian Hub Upper Starboard Maintenance"
	icon_state = "upperstarboardmaint"

/area/maintenance/monkedome/civilian/upperport
	name = "Civilian Hub Upper Port Maintenance"
	icon_state = "upperportmaint"

/area/maintenance/monkedome/civilian/port
	name = "Civilian Hub Port Maintenance"
	icon_state = "portmaint"

/area/maintenance/monkedome/civilian/starboard
	name = "Civilian Hub Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/monkedome/civilian/central
	name = "Civilian Hub Central Maint"
	icon_state = "centralmaint"

/area/hallway/monkedome/science
	name = "Science Hub Primary Hallway"
	icon_state = "hallP"

/area/maintenance/monkedome/science/port
	name = "Science Hub Port Maintenance"
	icon_state = "portmaint"

/area/maintenance/monkedome/science/starboard
	name = "Science Hub Starboard Maintenance"
	icon_state = "starboardmaint"

/area/maintenance/monkedome/science/aft
	name = "Science Hub Aft Maintenance"
	icon_state = "aftmaint"

/area/science/monkedome/xenobiohall
	name = "Xenobio Outpost Primary Hallway"
	icon_state = "hallP"

/area/science/monkedome/xenobiostorage
	name = "Xenobio Outpost Storage"
	icon_state = "science"

/area/science/monkedome/xenobioconstructionarea
	name = "Xenobio Outpost Construction Area"
	icon_state = "construction"

/area/science/monkedome/xenobiooutdoor //make work with outdoor lighting
	name = "Xenobio Outdoor Testing"
	icon_state = "science"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE

/area/science/monkedome/constructionarea
	name = "Research Hub Construction Area"
	icon_state = "construction"

/area/hallway/monkedome/engineering
	name = "Engineering Hub Primary Hallway"
	icon_state = "hallC"

/area/hallway/monkedome/engineering/fore
	name = "Engineering Hub Fore Primary Hallway"
	icon_state = "hallF"

/area/engine/monkedome/constructionarea
	name = "Engineering Hub Construction Area"
	icon_state = "construction"

/area/engine/monkedome/peepeeroom //yes
	name = "Engineering Hub Restrooms"
	icon_state = "toilet"

/area/engine/monkedome/storageroom
	name = "Engineering Hub Storage"
	icon_state = "engine"

/area/engine/monkedome/freezer
	name = "Engineering Freezer Room"
	icon_state = "engine"

/area/maintenance/monkedome/engine/port
	name = "Engineering Hub Port Maintenance"
	icon_state = "portmaint"

/area/maintenance/monkedome/engine/upperport
	name = "Engineering Hub Upper Port Maintenance"
	icon_state = "upperportmaint"

/area/maintenance/monkedome/engine/central
	name = "Engineering Hub Central Maintenance"
	icon_state = "centralmaint"

/area/maintenance/monkedome/engine/upperstarboard
	name = "Engineering Hub Upper Starboard Maintenance"
	icon_state = "upperstarboardmaint"

/area/engine/monkedome/upperairlock
	name = "Engineering Hub TComm Access Airlock"
	icon_state = "tcom_sat_entrance"

/area/maintenance/solars/monkedome/southprimary
	name = "South Primary Solar Maintenance"
	icon_state = "yellow"

/area/solarsouthprimary
	name = "South Primary Solar Array"
	icon_state = "yellow"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_VERY_SOFT_YELLOW
