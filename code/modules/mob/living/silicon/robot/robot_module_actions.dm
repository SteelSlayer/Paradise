/datum/action/innate/robot_sight
	var/sight_flags = null
	icon_icon = 'icons/obj/decals.dmi'
	button_icon_state = "securearea"

/datum/action/innate/robot_sight/Activate()
	var/mob/living/silicon/robot/R = owner
	R.sight_flags |= sight_flags
	R.update_sight()
	active = 1

/datum/action/innate/robot_sight/Deactivate()
	var/mob/living/silicon/robot/R = owner
	R.sight_flags &= ~sight_flags
	R.update_sight()
	active = 0

/datum/action/innate/robot_sight/xray
	name = "X-ray Vision"
	sight_flags = BORGXRAY

/datum/action/innate/robot_sight/thermal
	name = "Thermal Vision"
	sight_flags = BORGTHERM
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "thermal"

// ayylmao
/datum/action/innate/robot_sight/thermal/alien
	icon_icon = 'icons/mob/alien.dmi'
	button_icon_state = "borg-extra-vision"

/datum/action/innate/robot_sight/meson
	name = "Meson Vision"
	sight_flags = BORGMESON
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "meson"
