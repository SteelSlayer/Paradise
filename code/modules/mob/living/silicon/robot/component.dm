/**
 * # Robot Component
 *
 * These are essentially the cyborg equivalent of humanoid organs.
 */
/obj/item/robot_component
	name = "robot component"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "working"
	// The component will turn into a "broken" part at this threshold.
	integrity_failure = 30
	// The component will be deleted at this threshold.
	max_integrity = 60
	/// Is the component powered?
	var/powered = TRUE
	/// Is the component toggled on or off?
	var/toggled = TRUE
	/// How much brute damage the component has sustained.
	var/brute_damage = NONE
	/// How much burn damage the component has sustained.
	var/burn_damage = NONE
	/// Is the component disabled?
	var/disabled = FALSE
	/// The cyborg this component is installed in.
	var/mob/living/silicon/robot/owner

/obj/item/robot_component/Initialize(mapload)
	. = ..()
	if(!isrobot(loc))
		return
	owner = loc
	install()

/**
 * Installs the component into a cyborg, and adjusts their health taking into account the damage of the component.
 */
/obj/item/robot_component/proc/install()
	go_online()
	owner.updatehealth("component '[src]' installed")

/**
 * Uninstalls the component from a cyborg, and adjusts their health taking into account the damage of the component.
 */
/obj/item/robot_component/proc/uninstall()
	go_offline()
	owner.updatehealth("component '[src]' removed")

/obj/item/robot_component/obj_break(damage_flag)
	uninstall()
	name = "broken + [name]"
	// TODO: change color to dark grey to make it look broken.
	// color = grey
	return ..()

/**
 * Returns true if the component installed into a cyborg.
 */
/obj/item/robot_component/proc/is_installed()
	return isrobot(loc)

/**
 * Returns true if the component is broken.
 */
/obj/item/robot_component/proc/is_broken()
	return obj_integrity <= integrity_failure

/obj/item/robot_component/take_damage(damage_amount, damage_type, damage_flag, sound_effect = FALSE, attack_dir, armour_penetration = 0)
	if(is_broken() && is_installed())
		return

	..()
	if(!QDELETED(src))
		return
	if(damage_type == BRUTE)
		brute_damage += damage_amount
	else if(damage_type == BURN)
		burn_damage += damage_amount
	if(owner)
		owner.updatehealth("component '[src]' take damage")
		SStgui.update_uis(owner.self_diagnosis)

/**
 * Heals the component's brute/burn damage.
 */
/obj/item/robot_component/proc/heal_damage(brute, burn, updating_health = TRUE)
	// If it's not installed, can't repair it.
	if(!is_installed())
		return

	brute_damage = max(0, brute_damage - brute)
	burn_damage = max(0, burn_damage - burn)

	if(owner)
		owner.updatehealth("component '[src]' heal damage")
		SStgui.update_uis(owner.self_diagnosis)

/**
 * Checks if the component is powered.
 */
/obj/item/robot_component/proc/is_powered()
	return !is_broken() && powered

/**
 * Disables the component permenantly until `enable()` is called.
 */
/obj/item/robot_component/proc/disable()
	disabled = TRUE
	go_offline()

/**
 * Enables the component from a disabled state.
 */
/obj/item/robot_component/proc/enable()
	disabled = FALSE
	go_online()

/**
 * Manually toggles the component on or off.
 */
/obj/item/robot_component/proc/toggle()
	toggled = !toggled
	if(toggled)
		go_online()
	else
		go_offline()

	SStgui.update_uis(owner.self_diagnosis)

/**
 * Called when the component is enabled. Base proc.
 */
/obj/item/robot_component/proc/go_online()
	return

/**
 * Called when the component is disabled. Base proc.
 */
/obj/item/robot_component/proc/go_offline()
	return

/obj/item/robot_component/binary_communication_device
	name = "binary communication device"
	icon_state = "binary_translator"

/obj/item/robot_component/actuator
	name = "actuator"
	icon_state = "actuator"
	integrity_failure = 50
	max_integrity = 100

/obj/item/robot_component/armor
	name = "armour plating"
	icon_state = "armor_plating"
	integrity_failure = 100
	max_integrity = 200

/obj/item/robot_component/camera
	name = "camera"
	icon_state = "camera"
	integrity_failure = 40
	max_integrity = 80

/obj/item/robot_component/diagnosis_unit
	name = "diagnosis unit"
	icon_state = "diagnosis_unit"

/obj/item/robot_component/cell
	name = "power cell"
	integrity_failure = 50
	max_integrity = 100

/obj/item/robot_component/cell/is_powered()
	return ..() && owner.cell

/obj/item/robot_component/cell/Destroy()
	owner.cell = null // TODO: possibly needs to be qdel_null
	return ..()

/obj/item/robot_component/radio
	name = "radio"
	integrity_failure = 40
	max_integrity = 80

/obj/item/robot_component/camera/go_online()
	owner.update_blind_effects()
	owner.update_sight()

/obj/item/robot_component/camera/go_offline()
	owner.update_blind_effects()
	owner.update_sight()

/obj/item/broken_device
	name = "broken component"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "broken"

/**
 * Creates and installs all components for a cyborg.
 */
/mob/living/silicon/robot/proc/initialize_components()
	components["radio"] = new /obj/item/robot_component/radio(src)
	components["diagnosis unit"] = new /obj/item/robot_component/diagnosis_unit(src)
	components["camera"] = new /obj/item/robot_component/camera(src)
	components["comms"] = new /obj/item/robot_component/binary_communication_device(src)
	components["armor"] = new /obj/item/robot_component/armor(src)
	/*
	 * Due to load order issues, keep the actuator and power cell at the bottom of this list.
	 * Otherwise the cyborg can become blind, possibly among other things.
	 */
	components["actuator"] = new /obj/item/robot_component/actuator(src)
	components["power cell"] = new /obj/item/robot_component/cell(src)

/**
 * Checks if the given component is functioning.
 *
 * Arguments:
 * * component_name - A string name of a component ("armor", "actuator", etc.)
 */
/mob/living/silicon/robot/proc/is_component_functioning(component_name)
	var/obj/item/robot_component/C = components[component_name]
	return C && !C.is_broken() && C.is_powered() && C.toggled && !C.disabled

/**
 * Disables the given component.
 *
 * Arguments:
 * * component_name - A string name of a component ("armor", "actuator", etc.)
 * * duration - The amount of time to disable the component for
 */
/mob/living/silicon/robot/proc/disable_component(component_name, duration)
	var/obj/item/robot_component/C = get_component(component_name)
	C.disable()
	addtimer(CALLBACK(C, /obj/item/robot_component/proc/enable), duration)

/**
 * Returns a component, given a string name.
 *
 * Arguments:
 * * component_name
 */
/mob/living/silicon/robot/proc/get_component(component_name)
	var/obj/item/robot_component/C = components[component_name]
	return C

//
//Robotic Component Analyzer, basically a health analyzer for robots
//
/obj/item/robotanalyzer
	name = "cyborg analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1

/obj/item/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		user.visible_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>", "<span class='warning'>You try to analyze the floor's vitals!</span>")
		to_chat(user, "<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Healthy</span>")
		to_chat(user, "<span class='notice'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>")
		to_chat(user, "<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>")
		to_chat(user, "<span class='notice'>Body Temperature: ???</span>")
		return

	user.visible_message("<span class='notice'>[user] has analyzed [M]'s components.</span>","<span class='notice'>You have analyzed [M]'s components.</span>")
	robot_healthscan(user, M)
	add_fingerprint(user)


/proc/robot_healthscan(mob/user, mob/living/M)
	var/scan_type
	if(istype(M, /mob/living/silicon/robot))
		scan_type = "robot"
	else if(istype(M, /mob/living/carbon/human))
		scan_type = "prosthetics"
	else
		to_chat(user, "<span class='warning'>You can't analyze non-robotic things!</span>")
		return


	switch(scan_type)
		if("robot")
			var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
			var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
			to_chat(user, "<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health]% functional"]</span>")
			to_chat(user, "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>")
			to_chat(user, "\t Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
			if(M.timeofdeath && M.stat == DEAD)
				to_chat(user, "<span class='notice'>Time of Disable: [station_time_timestamp("hh:mm:ss", M.timeofdeath)]</span>")
			var/mob/living/silicon/robot/H = M
			var/list/damaged = H.get_damaged_components(TRUE, TRUE, TRUE) // Get all except the missing ones
			var/list/missing = H.get_missing_components()
			to_chat(user, "<span class='notice'>Localized Damage:</span>")
			if(!LAZYLEN(damaged) && !LAZYLEN(missing))
				to_chat(user, "<span class='notice'>\t Components are OK.</span>")
			else
				if(LAZYLEN(damaged))
					for(var/obj/item/robot_component/org in damaged)
						user.show_message(text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
						capitalize(org.name),					\
						(org.is_installed())	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
						(org.burn_damage > 0)	?	"<font color='#FFA500'>[org.burn_damage]</font>"	:0,	\
						(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
						(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
						(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
				if(LAZYLEN(missing))
					for(var/obj/item/robot_component/org in missing)
						user.show_message("<span class='warning'>\t [capitalize(org.name)]: MISSING</span>")

			if(H.emagged && prob(5))
				to_chat(user, "<span class='warning'>\t ERROR: INTERNAL SYSTEMS COMPROMISED</span>")

		if("prosthetics")
			var/mob/living/carbon/human/H = M
			to_chat(user, "<span class='notice'>Analyzing Results for \the [H]:</span>")
			to_chat(user, "Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>")

			to_chat(user, "<span class='notice'>External prosthetics:</span>")
			var/organ_found
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/external/E in H.bodyparts)
					if(!E.is_robotic())
						continue
					organ_found = TRUE
					to_chat(user, "[E.name]: <font color='red'>[E.brute_dam]</font> <font color='#FFA500'>[E.burn_dam]</font>")
			if(!organ_found)
				to_chat(user, "<span class='warning'>No prosthetics located.</span>")
			to_chat(user, "<hr>")
			to_chat(user, "<span class='notice'>Internal prosthetics:</span>")
			organ_found = null
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/internal/O in H.internal_organs)
					if(!O.is_robotic())
						continue
					organ_found = TRUE
					to_chat(user, "[capitalize(O.name)]: <font color='red'>[O.damage]</font>")
			if(!organ_found)
				to_chat(user, "<span class='warning'>No prosthetics located.</span>")
