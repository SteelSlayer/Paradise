GLOBAL_LIST_INIT(robot_verbs_default, list(
	/mob/living/silicon/robot/proc/sensor_mode,
))

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 100
	health = 100
	bubble_icon = "robot"
	universal_understand = 1
	deathgasp_on_death = TRUE
	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)
	additional_law_channels = list("Binary" = ":b ")

	// Hud stuff
	/// The cyborg's first "hand" UI slot.
	var/obj/screen/inv1
	/// The cyborg's second "hand" UI slot.
	var/obj/screen/inv2
	/// The cyborg's third "hand" UI slot.
	var/obj/screen/inv3
	/// The cyborg's lamp UI button.
	var/obj/screen/lamp_button
	/// The cyborg's ion thruster UI button.
	var/obj/screen/thruster_button
	/// Background images for every 'square' of the cyborg's inventory.
	var/obj/screen/robot/module_background/module_backgrounds
	/// Is the cyborg's inventory open?
	var/shown_robot_modules = FALSE

	/// Which module the cyborg currently has equipped (Engineering, Medical, Security, etc.).
	var/obj/item/robot_module/module
	/// Which module type to assign the cyborg. If you want your cyborg to be able to choose their module, do not set this.
	var/module_type
	/// The currently active item the cyborg is wielding.
	var/obj/item/module_active
	/// The item sitting in the cyborg's first module.
	var/obj/item/module_state_1
	/// The item sitting in the cyborg's second module.
	var/obj/item/module_state_2
	/// The item sitting in the cyborg's third module.
	var/obj/item/module_state_3
	/// The cyborg's internal radio.
	var/obj/item/radio/borg/radio
	/// The type of radio to give the cyborg.
	var/radio_type = /obj/item/radio/borg
	/// The cyborg's internal camera.
	var/obj/machinery/camera/cyborg/camera
	/// The cyborg's power cell.
	var/obj/item/stock_parts/cell/cell
	/// The default power cell the cyborg receives upon creation.
	var/default_cell_type = /obj/item/stock_parts/cell/high
	/// The AI the cyborg is connected to.
	var/mob/living/silicon/ai/connected_ai
	/// A list of [robot components][/datum/robot_component] the cyborg has. Components are essentially robot organs.
	var/list/components
	/// An associative list of upgrade type paths as keys, and references to the [upgrade][/obj/item/borg/upgrade] as values.
	var/list/upgrades
	/// Used to remember what the borg was constructed out of when deconstructed.
	var/obj/item/robot_parts/robot_suit/robot_suit
	/// The cyborg's MMI/Positronic brain/Robot brain.
	var/obj/item/mmi/mmi
	/// The robot's internal PDA.
	var/obj/item/pda/silicon/robot/rbPDA
	/// The robot's wires datum.
	var/datum/wires/robot/wires
	/// TODO: I hate this shit
	var/custom_panel
	/// TODO: I hate this shit
	var/list/custom_panel_names = list("Cricket")
	/// TODO: I hate this shit
	var/list/custom_eye_names = list("Cricket", "Standard")
	/// TODO: I hate this shit
	var/list/req_one_access = list(ACCESS_ROBOTICS)
	/// TODO: I hate this shit
	var/list/req_access
	/// TODO: I don't fucking know.
	var/custom_name
	/// TODO: I don't fucking know
	var/static_radio_channels = FALSE
	/// Fluff text for which type of robot they are. There are currently three selections: Cyborg, Android or Robot.
	var/braintype = "Cyborg"
	/// Has the robot been emagged?
	var/emagged = FALSE
	/// Flags for protections such as being emag proof. See code\__DEFINES\robot.dm for valid defines that should go here.
	var/protection_flags = NONE
	/// Flags for the robot's cover such as being open, or locked. See code\__DEFINES\robot.dm for valid defines that should go here.
	var/cover_flags = LOCKED
	/// Flags for various vision modes such as x-ray, thermal, or meson.
	var/sight_flags = NONE
	/// A flat damage reduction that applies to all brute and burn damage the robot receives.
	var/damage_protection = NONE
 	/// Value that all incoming brute damage will be multiplied by.
	var/brute_mod = 1
	/// Value that all incoming burn damage will be multiplied by.
	var/burn_mod = 1
	/// Fluff text used to determind the name of a default cyborg. Example: "Default Android-167"
	var/modtype = "Default"
	/**
	 * Fluff name for the module type the cyborg is. For most station cyborgs, this will be set to the module type such as "Engineering" etc.
	 * However, this can also be something like "Syndicate Assault", or "SpecOps".
	 */
	var/designation = ""
	/// A list of of all modules the cyborg can choose from.
	var/list/available_modules = list("Generalist", "Engineering", "Medical", "Miner", "Janitor", "Service", "Security")
	/// Is the robot allowed to rename itself?
	var/allow_rename = TRUE
	/// So they can initialize sparks whenever.
	var/datum/effect_system/spark_spread/spark_system
	/// Determines whether the robot has no charge left.
	var/low_power_mode = FALSE
	/// Determines if Cyborgs will sync their laws with their AI by default.
	var/lawupdate = TRUE
	/// Determines if Cyborgs will automatically sync to an AI when they're created.
	var/auto_snyc_to_AI = TRUE
	/// If the cyborg been locked down by a robotics console, or other means.
	var/locked_down = FALSE
	/// Speed of the cyborg. A lower number means movement speed is faster (less of a delay between moving).
	var/speed = 0
	/// Determines if a borg shows up on the robotics console.
	var/visible_on_console = FALSE
	/// Does the cyborg have an internal camera?
	var/has_camera = TRUE
	/// Determins if a cyborg's PDA is hidden on the messenger list.
	var/pdahide = FALSE
	/// Maximum brightness of a borg lamp. Set as a var for easy adjusting.
	var/lamp_max = 10
	/// Luminosity of the headlamp. 0 is off. Higher settings than the minimum require power.
	var/lamp_intensity = 0
	/// Flag for if the lamp is on cooldown after being forcibly disabled.
	var/lamp_recharging = FALSE
	/// Portable camera camerachunk update
	var/camera_updating = FALSE
	/// Sound to play upon creation of the cyborg.
	var/creation_sound = 'sound/voice/liveagain.ogg'
	/// If this cyborg has "magboots" enabled.
	var/magpulse = FALSE
	/// Determines if the cyborg can see reagents.
	var/see_reagents = FALSE

// If the AI_to_sync_to argument is supplied. The cyborg will attempt to sync with that AI.
/mob/living/silicon/robot/Initialize(mapload, mob/living/silicon/ai/AI_to_sync_to = null)
	. = ..()
	// Give the borg an MMI if he spawns without for some reason. (probably not the correct way to spawn a robotic brain, but it works)
	if(!mmi)
		mmi = new /obj/item/mmi/robotic_brain(src)

	if(!cell) // Make sure a new cell gets created *before* executing initialize_components(). The cell component needs an existing cell for it to get set up properly
		cell = new default_cell_type(src)

	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	wires = new(src)
	camera = new(src, src)
	module_backgrounds = new()
	radio = new radio_type(src)
	common_radio = radio
	radio.recalculateChannels()
	var/datum/action/item_action/toggle_research_scanner/scanner = new(src)
	scanner.Grant(src)

	LAZYINITLIST(upgrades)
	LAZYINITLIST(components)
	add_language("Robot Talk", TRUE)
	rename_character(null, get_default_name())
	update_icons()
	update_headlamp()
	initialize_components()
	add_robot_verbs()
	diag_hud_set_borgcell()
	make_laws()

	if(auto_snyc_to_AI)
		connect_to_ai(AI_to_sync_to)
	if(module_type)
		module = new module_type(src)
		update_module_icon()

	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	var/datum/robot_component/cell_component = components["power cell"]
	cell_component.wrapped = cell
	cell_component.installed = 1
	cell_component.install()

	playsound(get_turf(src), creation_sound, 75, FALSE)

/mob/living/silicon/robot/Destroy()
	SStgui.close_uis(wires)
	if(mmi && mind) // Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc) // To hopefully prevent run time errors.
		if(T)
			mmi.loc = T
		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			to_chat(src, "<span class='boldannounce'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>")
			ghostize()
			error("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	QDEL_NULL(wires)
	QDEL_NULL(module)
	QDEL_NULL(camera)
	QDEL_NULL(cell)
	QDEL_NULL(robot_suit)
	QDEL_NULL(spark_system)
	QDEL_NULL(self_diagnosis)
	QDEL_LIST_ASSOC_VAL(upgrades)
	return ..()

/mob/living/silicon/robot/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return FALSE

	if(oldname != real_name)
		notify_ai(NOTIFY_NEW_NAME, oldname, newname)
		custom_name = (newname != get_default_name()) ? newname : null
		setup_PDA()

		//We also need to update name of internal camera.
		if(camera)
			camera.c_tag = newname

		//Check for custom sprite
		if(!custom_sprite)
			if(ckey in GLOB.configuration.custom_sprites.cyborg_ckeys)
				custom_sprite = TRUE

	if(mmi && mmi.brainmob)
		mmi.brainmob.name = newname

	return TRUE

/**
 * Returns a default name for the cyborg based on their `modtype` and which MMI type they have. If they have a `custom_name` set, return that instead.
 *
 * Arguments:
 * * prefix - An override for the `modtype` variable.
 */
/mob/living/silicon/robot/proc/get_default_name(prefix)
	if(prefix)
		modtype = prefix
	if(mmi)
		if(istype(mmi, /obj/item/mmi/robotic_brain))
			braintype = "Android"
		else
			braintype = "Cyborg"
	else
		braintype = "Robot"

	if(custom_name)
		return custom_name
	else
		return "[modtype] [braintype]-[rand(1, 999)]"

/**
 * Verb which allows the cyborg to rename itself.
 */
/mob/living/silicon/robot/verb/Namepick()
	set category = "Robot Commands"
	if(custom_name)
		return FALSE
	if(!allow_rename)
		to_chat(src, "<span class='warning'>Rename functionality is not enabled on this unit.</span>")
		return FALSE
	rename_self(braintype, TRUE)

/**
 * Attempts to sync the cyborg's laws and photos with an AI.
 */
/mob/living/silicon/robot/proc/sync()
	if(lawupdate && connected_ai)
		lawsync()
		photosync()

/**
 * Sets up the cyborg's internal PDA.
 */
/mob/living/silicon/robot/proc/setup_PDA()
	if(!rbPDA)
		rbPDA = new(src)
	rbPDA.set_name_and_job(real_name, braintype)
	var/datum/data/pda/app/messenger/M = rbPDA.find_program(/datum/data/pda/app/messenger)
	if(M)
		if(visible_on_console)
			M.hidden = TRUE
		if(pdahide)
			M.toff = TRUE

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		return TRUE
	return FALSE

/**
 * Allows the cyborg to choose their own module.
 */
/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	if(mmi && mmi.alien)
		available_modules = list("Hunter")
	modtype = input("Please, select a module!", "Robot", null, null) as null|anything in available_modules
	if(!modtype)
		return
	designation = modtype

	switch(modtype)
		if("Generalist")
			module = new /obj/item/robot_module/generalist(src)

		if("Service")
			module = new /obj/item/robot_module/butler(src)
			see_reagents = TRUE

		if("Miner")
			module = new /obj/item/robot_module/miner(src)

		if("Medical")
			module = new /obj/item/robot_module/medical(src)
			status_flags &= ~CANPUSH
			see_reagents = TRUE

		if("Security")
			if(!upgrades[/obj/item/borg/upgrade/syndicate])
				var/count_secborgs = 0
				for(var/mob/living/silicon/robot/R in GLOB.alive_mob_list)
					if(R && R.stat != DEAD && R.module && istype(R.module, /obj/item/robot_module/security))
						count_secborgs++
				var/max_secborgs = 2
				if(GLOB.security_level == SEC_LEVEL_GREEN)
					max_secborgs = 1
				if(count_secborgs >= max_secborgs)
					to_chat(src, "<span class='warning'>There are too many Security cyborgs active. Please choose another module.</span>")
					return
			module = new /obj/item/robot_module/security(src)
			status_flags &= ~CANPUSH

		if("Engineering")
			module = new /obj/item/robot_module/engineering(src)
			magpulse = TRUE

		if("Janitor")
			module = new /obj/item/robot_module/janitor(src)

		if("Destroyer") // Rolling Borg
			module = new /obj/item/robot_module/destroyer(src)
			icon_state = "droidcombat"
			status_flags &= ~CANPUSH

		if("Combat") // Gamma ERT
			module = new /obj/item/robot_module/combat(src)
			icon_state = "ertgamma"
			status_flags &= ~CANPUSH

		if("Hunter")
			module = new /obj/item/robot_module/alien/hunter(src)
			icon_state = "xenoborg-state-a"
			modtype = "Xeno-Hu"

	// Custom_sprite check and entry
	if(custom_sprite && check_sprite("[ckey]-[modtype]"))
		module.module_sprites["Custom"] = "[ckey]-[modtype]"

	hands.icon_state = lowertext(module.module_type)
	SSblackbox.record_feedback("tally", "cyborg_modtype", 1, "[lowertext(modtype)]")

	if(!static_radio_channels)
		radio.config(module.channels)

	rename_character(real_name, get_default_name())
	choose_icon(6, module.module_sprites)
	notify_ai(NOTIFY_MODULE_CHOSEN)

/**
 * Deletes the cyborg's module, module-related abilities, and all of their upgrades. Resets them back to when they were first created.
 */
/mob/living/silicon/robot/proc/reset_module()
	magpulse = FALSE
	status_flags |= CANPUSH
	hands.icon_state = "nomod"
	icon_state = "robot"
	languages = list()
	speech_synthesizer_langs = list()
	sight_flags = null

	add_language("Robot Talk", TRUE)
	rename_character(real_name, get_default_name("Default"))
	notify_ai(NOTIFY_MODULE_CHOSEN)
	uneq_all()
	update_sight()
	QDEL_NULL(module)
	QDEL_LIST_ASSOC_VAL(upgrades)
	update_icons()
	update_headlamp()
	radio.recalculateChannels()
	SStgui.close_user_uis(src)

/**
 * Gives cyborgs their default robot verbs and any verbs from their `silicon_subsystems` list.
 */
/mob/living/silicon/robot/proc/add_robot_verbs()
	verbs |= GLOB.robot_verbs_default
	verbs |= silicon_subsystems

/**
 * Removes the cyborg's default robot verbs and any verbs from their `silicon_subsystems` list.
 */
/mob/living/silicon/robot/proc/remove_robot_verbs()
	verbs -= GLOB.robot_verbs_default
	verbs -= silicon_subsystems

/**
 * Verb which lets cyborgs see the station's manifest.
 */
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Robot Commands"
	set name = "Show Station Manifest"
	show_station_manifest()

/**
 * Verb which lets cyborgs toggle their own components on or off. Excludes their power cell component.
 */
/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	C.toggle()
	to_chat(src, "<span class='warning'>You [C.toggled ? "enable" : "disable"] [C.name].</span>")

/**
 * Verb which allows the cyborg to switch between, medical, security or diagnostic huds.
 */
/mob/living/silicon/robot/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = "Robot Commands"
	toggle_sensor_mode()

/**
 * Verb which shows a station alert UI to the cyborg.
 */
/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	if(usr.stat == DEAD)
		to_chat(src, "<span class='userdanger'>Alert: You are dead.</span>")
		return //won't work if dead
	robot_alerts()

/**
 * Compiles a list of station alerts (fire alarms, power alarms, etc.) and opens a browser UI displaying the list of alerts.
 */
/mob/living/silicon/robot/proc/robot_alerts()
	var/list/dat = list()
	var/list/list/temp_alarm_list = SSalarm.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listend_for))
			continue
		dat += text("<B>[cat]</B><BR>\n")
		var/list/list/L = temp_alarm_list[cat].Copy()
		for(var/alarm in L)
			var/list/list/alm = L[alarm].Copy()
			var/list/list/sources = alm[3].Copy()
			var/area_name = alm[1]
			for(var/thing in sources)
				var/atom/A = locateUID(thing)
				if(A && A.z != z)
					L -= alarm
					continue
				dat += "<NOBR>"
				dat += text("-- [area_name]")
				dat += "</NOBR><BR>\n"
		if(!L.len)
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/alerts = new(usr, "robotalerts", "Current Station Alerts", 400, 410)
	var/dat_text = dat.Join("")
	alerts.set_content(dat_text)
	alerts.open()

/**
 * Leaves an ion trail effect when a cyborg moves using their ion thrusters in an area without gravity.
 *
 * Arguments:
 * * datum/source - The src cyborg.
 * * atom/oldloc - The old location they moved from.
 * * _dir - the direction they moved in.
 */
/mob/living/silicon/robot/proc/create_trail(datum/source, atom/oldloc, _dir)
	var/turf/T = get_turf(oldloc)
	if(!has_gravity(null, T))
		new /obj/effect/particle_effect/ion_trails(T, _dir)

/**
 * Proc while is called every time a cyborg moves while in space.
 *
 * Subtracts cell charge if thrusters are present and active. Disables the thrusters if the borg cell doesn't have enough power.
 */
/mob/living/silicon/robot/proc/ionpulse()
	var/obj/item/borg/upgrade/thrusters/thrusters = upgrades[/obj/item/borg/upgrade/thrusters]
	if(!thrusters || !thrusters.active)
		return

	if(cell.charge <= 50)
		toggle_ionpulse()
		return

	cell.charge -= 25 // 500 steps on a default cell.
	return TRUE

/**
 * Toggles the cyborg's ion thruster upgrade on or off.
 */
/mob/living/silicon/robot/proc/toggle_ionpulse()
	var/obj/item/borg/upgrade/thrusters/thrusters = upgrades[/obj/item/borg/upgrade/thrusters]
	if(!thrusters)
		to_chat(src, "<span class='notice'>No thrusters are installed!</span>")
		return

	if(thrusters.active)
		thrusters.active = FALSE
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	else
		thrusters.active = TRUE
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/create_trail)

	thruster_button.icon_state = "ionpulse[thrusters.active]"
	to_chat(src, "<span class='notice'>You [thrusters.active ? null :"de"]activate your ion thrusters.</span>")

/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

/**
 * Shows the borg their power cell charge in the "Status" window.
 */
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
	else
		stat(null, text("No Cell Inserted!"))

/**
 * Shows the borg their GPS location in the "Status" window.
 *
 * Only appears on certain borg which have a GPS such as the mining cyborg.
 */
/mob/living/silicon/robot/proc/show_gps_coords()
	if(locate(/obj/item/gps/cyborg) in module.modules)
		var/turf/T = get_turf(src)
		stat(null, "GPS: [COORD(T)]")

/**
 * Shows the borg their current "stack" count for things like metal sheets, metal rods, glass, etc.
 */
/mob/living/silicon/robot/proc/show_stack_energy()
	for(var/storage in module.storages) // Storages should only contain `/datum/robot_energy_storage`
		var/datum/robot_energy_storage/R = storage
		stat(null, "[R.statpanel_name]: [R.energy] / [R.max_energy]")

// update the status screen display
/mob/living/silicon/robot/Stat()
	..()
	if(!statpanel("Status"))
		return // They aren't looking at the status panel.

	show_cell_power()

	if(module)
		show_gps_coords()
		show_stack_energy()

/mob/living/silicon/robot/restrained()
	return FALSE

/mob/living/silicon/robot/InCritical()
	return low_power_mode

/mob/living/silicon/robot/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)

/mob/living/silicon/robot/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listend_for))
			return
		if(origin.z != z)
			return
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)

/mob/living/silicon/robot/ex_act(severity)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if(stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if(stat != DEAD)
				adjustBruteLoss(30)
	return


/mob/living/silicon/robot/bullet_act(obj/item/projectile/proj)
	..(proj)
	if(prob(75) && proj.damage > 0)
		spark_system.start()
	return 2


/mob/living/silicon/robot/attackby(obj/item/W, mob/user, params)
	// Check if the user is trying to insert another component like a radio, actuator, armor etc.
	if(istype(W, /obj/item/robot_parts/robot_component) && (cover_flags & OPENED))
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type))
				C.installed = 1
				C.wrapped = W
				C.install()
				user.drop_item()
				W.loc = null

				var/obj/item/robot_parts/robot_component/WC = W
				if(istype(WC))
					C.brute_damage = WC.brute
					C.electronics_damage = WC.burn

				to_chat(usr, "<span class='notice'>You install [W].</span>")

				return

	if(istype(W, /obj/item/stack/cable_coil) && user.a_intent == INTENT_HELP && ((cover_flags & WIRES_EXPOSED) || istype(src, /mob/living/silicon/robot/drone)))
		user.changeNext_move(CLICK_CD_MELEE)
		if(!getFireLoss())
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return
		else if(!getFireLoss(TRUE))
			to_chat(user, "<span class='warning'>The damaged components are beyond saving!</span>")
			return
		var/obj/item/stack/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		add_fingerprint(user)
		coil.use(1)
		user.visible_message("<span class='alert'>\The [user] fixes some of the burnt wires on \the [src] with \the [coil].</span>")

	else if(istype(W, /obj/item/stock_parts/cell) && (cover_flags & OPENED))	// trying to put a cell inside
		var/datum/robot_component/cell/C = components["power cell"]
		if((cover_flags & WIRES_EXPOSED))
			to_chat(user, "Close the panel first.")
		else if(cell)
			to_chat(user, "There is a power cell already installed.")
		else
			user.drop_item()
			W.loc = src
			cell = W
			to_chat(user, "You insert the power cell.")

			C.installed = 1
			C.wrapped = W
			C.install()
			C.external_type = W.type // Update the cell component's `external_type` to the path of new cell
			//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
			C.brute_damage = 0
			C.electronics_damage = 0
			module?.update_cells()
			diag_hud_set_borgcell()

	else if(istype(W, /obj/item/encryptionkey) && (cover_flags & OPENED))
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")

	else if(istype(W, /obj/item/card/id) || istype(W, /obj/item/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			to_chat(user, "The interface seems slightly damaged.")
		if((cover_flags & OPENED))
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			if(allowed(W))
				var/locked = (cover_flags & LOCKED)
				if(locked)
					cover_flags &= ~LOCKED
				else
					cover_flags |= LOCKED
				to_chat(user, "You [locked ? "lock" : "unlock"] [src]'s interface.")
				to_chat(src, "<span class='notice'>[user] [locked ? "locked" : "unlocked"] your interface.</span>")
				update_icons()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(istype(W, /obj/item/borg/upgrade))
		var/obj/item/borg/upgrade/U = W
		if(!(cover_flags & OPENED))
			to_chat(user, "<span class='warning'>You must access the borg's internals!</span>")
		else if(!module && U.module_type)
			to_chat(user, "<span class='warning'>The borg must choose a module before it can be upgraded!</span>")
		else
			if(!user.drop_item())
				return
			if(U.action(src))
				user.visible_message("<span class='notice'>[user] applied [U] to [src].</span>", "<span class='notice'>You apply [U] to [src].</span>")
				U.forceMove(src)

	else if(istype(W, /obj/item/mmi_radio_upgrade))
		if(!(cover_flags & OPENED))
			to_chat(user, "<span class='warning'>You must access the borg's internals!</span>")
			return
		else if(!mmi)
			to_chat(user, "<span class='warning'>This cyborg does not have an MMI to augment!</span>")
			return
		else if(mmi.radio)
			to_chat(user, "<span class='warning'>A radio upgrade is already installed in the MMI!</span>")
			return
		else if(user.drop_item())
			to_chat(user, "<span class='notice'>You apply the upgrade to [src].</span>")
			to_chat(src, "<span class='notice'>MMI radio capability installed.</span>")
			mmi.install_radio()
			qdel(W)
	else
		return ..()

/mob/living/silicon/robot/wirecutter_act(mob/user, obj/item/I)
	if(!(cover_flags & OPENED))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(cover_flags & WIRES_EXPOSED)
		wires.Interact(user)

/mob/living/silicon/robot/multitool_act(mob/user, obj/item/I)
	if(!(cover_flags & OPENED))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(cover_flags & WIRES_EXPOSED)
		wires.Interact(user)

/mob/living/silicon/robot/screwdriver_act(mob/user, obj/item/I)
	if(!(cover_flags & OPENED))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(!cell)	// haxing
		var/wires_exposed = (cover_flags & WIRES_EXPOSED)
		wires_exposed ? (cover_flags &= ~WIRES_EXPOSED) : (cover_flags |= WIRES_EXPOSED)
		to_chat(user, "<span class='notice'>The wires have been [!wires_exposed ? "exposed" : "unexposed"]</span>")
		update_icons()
		I.play_tool_sound(user, I.tool_volume)
	else //radio check
		if(radio)
			radio.screwdriver_act(user, I)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		update_icons()

/mob/living/silicon/robot/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!(cover_flags & OPENED))
		if(cover_flags & LOCKED)
			to_chat(user, "The cover is locked and cannot be opened.")
			return
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
		to_chat(user, "You open the cover.")
		cover_flags |= OPENED
		update_icons()
		return
	else if(cell)
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
		to_chat(user, "You close the cover.")
		cover_flags &= ~OPENED
		update_icons()
		return
	else if((cover_flags & WIRES_EXPOSED) && wires.is_all_cut())
		//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
		if(!mmi)
			to_chat(user, "[src] has no brain to remove.")
			return
		to_chat(user, "You jam the crowbar into the robot and begin levering the securing bolts...")
		if(I.use_tool(src, user, 30, volume = I.tool_volume))
			user.visible_message("[user] deconstructs [src]!", "<span class='notice'>You unfasten the securing bolts, and [src] falls to pieces!</span>")
			deconstruct()
		return
	// Okay we're not removing the cell or an MMI, but maybe something else?
	var/list/removable_components = list()
	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		if(C.installed == 1 || C.installed == -1)
			removable_components += V
	if(module)
		removable_components += module.custom_removals
	var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
	if(!remove)
		return
	if(module && module.handle_custom_removal(remove, user, I))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/datum/robot_component/C = components[remove]
	var/obj/item/robot_parts/robot_component/thing = C.wrapped
	to_chat(user, "You remove \the [thing].")
	if(istype(thing))
		thing.brute = C.brute_damage
		thing.burn = C.electronics_damage

	thing.loc = loc
	var/was_installed = C.installed
	C.installed = 0
	if(was_installed == 1)
		C.uninstall()

/mob/living/silicon/robot/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	..()

// Here so admins can unemag borgs.
/mob/living/silicon/robot/unemag()
	SetEmagged(FALSE)
	if(!module)
		return
	uneq_all()
	module.module_type = initial(module.module_type)
	update_module_icon()
	module.unemag()
	clear_supplied_laws()
	laws = new /datum/ai_laws/crewsimov

/mob/living/silicon/robot/emag_act(mob/user)
	if(!ishuman(user) && !issilicon(user))
		return
	var/mob/living/M = user
	if(!(cover_flags & OPENED))//Cover is closed
		if(!(protection_flags & EMAG_PROOF))
			to_chat(user, "The emag sparks, and flashes red. This mechanism does not appear to be emaggable.")
		else if(cover_flags & LOCKED)
			to_chat(user, "You emag the cover lock.")
			cover_flags &= ~LOCKED
		else
			to_chat(user, "The cover is already unlocked.")
		return

	if(cover_flags & OPENED)//Cover is open
		if(emagged)
			return //Prevents the X has hit Y with Z message also you cant emag them twice
		if(cover_flags & WIRES_EXPOSED)
			to_chat(user, "You must close the panel first")
			return
		else
			sleep(6)
			SetEmagged(TRUE)
			SetLockdown(1) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
			if(hud_used)
				hud_used.update_robot_modules_display()	//Shows/hides the emag item if the inventory screen is already open.
			disconnect_from_ai()
			to_chat(user, "You emag [src]'s interface.")
			log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
			clear_supplied_laws()
			clear_inherent_laws()
			laws = new /datum/ai_laws/syndicate_override
			var/time = time2text(world.realtime,"hh:mm:ss")
			GLOB.lawchanges.Add("[time] <B>:</B> [M.name]([M.key]) emagged [name]([key])")
			set_zeroth_law("Only [M.real_name] and people [M.p_they()] designate[M.p_s()] as being such are Syndicate Agents.")
			playsound_local(src, 'sound/voice/aisyndihack.ogg', 75, FALSE)
			to_chat(src, "<span class='warning'>ALERT: Foreign software detected.</span>")
			sleep(5)
			to_chat(src, "<span class='warning'>Initiating diagnostics...</span>")
			sleep(20)
			to_chat(src, "<span class='warning'>SynBorg v1.7 loaded.</span>")
			sleep(5)
			to_chat(src, "<span class='warning'>LAW SYNCHRONISATION ERROR</span>")
			sleep(5)
			to_chat(src, "<span class='warning'>Would you like to send a report to NanoTraSoft? Y/N</span>")
			sleep(10)
			to_chat(src, "<span class='warning'>> N</span>")
			sleep(25)
			to_chat(src, "<span class='warning'>ERRORERRORERROR</span>")
			to_chat(src, "<b>Obey these laws:</b>")
			laws.show_laws(src)
			to_chat(src, "<span class='boldwarning'>ALERT: [M.real_name] is your new master. Obey your new laws and [M.p_their()] commands.</span>")
			SetLockdown(0)
			if(module)
				module.emag_act()
				module.module_type = "Malf" // For the cool factor
				update_module_icon()
				module.rebuild_modules() // This will add the emagged items to the borgs inventory.
			update_icons()
		return

/**
 * Verb which allows the cyborg to toggle the lock on it's own cover.
 */
/mob/living/silicon/robot/verb/toggle_own_cover()
	set category = "Robot Commands"
	set name = "Toggle Cover"
	set desc = "Toggles the lock on your cover."

	var/locked = (cover_flags & LOCKED)
	if(cover_flags & SELF_LOCKABLE)
		if(alert("Are you sure?", locked ? "Unlock Cover" : "Lock Cover", "Yes", "No") == "Yes")
			locked ? (cover_flags &= ~LOCKED) : (cover_flags |= LOCKED)
			update_icons()
			to_chat(usr, "<span class='notice'>You [!locked ? "lock" : "unlock"] your cover.</span>")
		return
	if(!locked)
		to_chat(usr, "<span class='warning'>You cannot lock your cover yourself. Find a robotocist.</span>")
		return
	if(alert("You cannnot lock your own cover again. Are you sure?\n           You will need a robotocist to re-lock you.", "Unlock Own Cover", "Yes", "No") == "Yes")
		locked ? (cover_flags &= ~LOCKED) : (cover_flags |= LOCKED)
		update_icons()
		to_chat(usr, "<span class='notice'>You unlock your cover.</span>")

/mob/living/silicon/robot/attack_ghost(mob/user)
	if(cover_flags & WIRES_EXPOSED)
		wires.Interact(user)
	else
		..() //this calls the /mob/living/attack_ghost proc for the ghost health/cyborg analyzer

// An absolutely terrible proc that shouldn't handle access like this. Needs a refactor in the future.
/mob/living/silicon/robot/proc/allowed(obj/item/I)
	var/obj/dummy = new /obj(null) // Create a dummy object to check access on as to avoid having to snowflake check_access on every mob
	dummy.req_access = req_access
	dummy.req_one_access = req_one_access

	if(dummy.check_access(I))
		qdel(dummy)
		return 1

	qdel(dummy)
	return 0

/mob/living/silicon/robot/update_icons()
	overlays.Cut()
	if(stat != DEAD && !(paralysis || stunned || IsWeakened() || low_power_mode)) //Not dead, not stunned.
		if(custom_panel in custom_eye_names)
			overlays += "eyes-[custom_panel]"
		else
			overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"
	if(cover_flags & OPENED)
		var/panelprefix = "ov"
		if(custom_sprite) //Custom borgs also have custom panels, heh
			panelprefix = "[ckey]"
		if(custom_panel in custom_panel_names) //For default borgs with different panels
			panelprefix = custom_panel
		if(cover_flags & WIRES_EXPOSED)
			overlays += "[panelprefix]-openpanel +w"
		else if(cell)
			overlays += "[panelprefix]-openpanel +c"
		else
			overlays += "[panelprefix]-openpanel -c"
	update_fire()

/mob/living/silicon/robot/Topic(href, href_list)
	if(..())
		return 1

	if(usr != src)
		return 1

	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
		return 1

	if(href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if(istype(O) && (O.loc == src))
			O.attack_self(src)
		return 1

	if(href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(!istype(O) || !(O.loc == src || O.loc == src.module))
			return 1

		activate_module(O)

	//Show alerts window if user clicked on "Show alerts" in chat
	if(href_list["showalerts"])
		robot_alerts()
		return TRUE

	if(href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				to_chat(src, "Module isn't activated.")
		else
			to_chat(src, "Module isn't activated")
		return 1

	return 1

/**
 * TODO
 */
/mob/living/silicon/robot/proc/control_headlamp()
	if(stat || lamp_recharging || low_power_mode)
		to_chat(src, "<span class='danger'>This function is currently offline.</span>")
		return
	if(is_ventcrawling(src))
		return

	// Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
	lamp_intensity = (lamp_intensity+2) % (lamp_max+2)
	to_chat(src, "[lamp_intensity ? "Headlamp power set to Level [lamp_intensity/2]" : "Headlamp disabled."]")
	update_headlamp()

/**
 * TODO
 */
/mob/living/silicon/robot/proc/update_headlamp(turn_off = 0, cooldown = 100, show_warning = TRUE)
	set_light(0)

	if(lamp_intensity && (turn_off || stat || low_power_mode))
		if(show_warning)
			to_chat(src, "<span class='danger'>Your headlamp has been deactivated.</span>")
		lamp_intensity = 0
		lamp_recharging = TRUE
		spawn(cooldown) //10 seconds by default, if the source of the deactivation does not keep stat that long.
			lamp_recharging = FALSE
	else
		set_light(light_range + lamp_intensity)

	if(lamp_button)
		lamp_button.icon_state = "lamp[lamp_intensity]"

	update_icons()

/**
 * TODO: refactor this trash
 */
/mob/living/silicon/robot/proc/deconstruct()
	var/turf/T = get_turf(src)
	if(robot_suit)
		robot_suit.forceMove(T)
		robot_suit.l_leg.forceMove(T)
		robot_suit.l_leg = null
		robot_suit.r_leg.forceMove(T)
		robot_suit.r_leg = null
		new /obj/item/stack/cable_coil(T, robot_suit.chest.wired)
		robot_suit.chest.forceMove(T)
		robot_suit.chest.wired = FALSE
		robot_suit.chest = null
		robot_suit.l_arm.forceMove(T)
		robot_suit.l_arm = null
		robot_suit.r_arm.forceMove(T)
		robot_suit.r_arm = null
		robot_suit.head.forceMove(T)
		robot_suit.head.flash1.forceMove(T)
		robot_suit.head.flash1.burn_out()
		robot_suit.head.flash1 = null
		robot_suit.head.flash2.forceMove(T)
		robot_suit.head.flash2.burn_out()
		robot_suit.head.flash2 = null
		robot_suit.head = null
		robot_suit.updateicon()
	else
		new /obj/item/robot_parts/robot_suit(T)
		new /obj/item/robot_parts/l_leg(T)
		new /obj/item/robot_parts/r_leg(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/robot_parts/chest(T)
		new /obj/item/robot_parts/l_arm(T)
		new /obj/item/robot_parts/r_arm(T)
		new /obj/item/robot_parts/head(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/flash/F = new /obj/item/flash(T)
			F.burn_out()
	if(cell) //Sanity check.
		cell.forceMove(T)
		cell = null
	qdel(src)

#define BORG_CAMERA_BUFFER 3 SECONDS

/mob/living/silicon/robot/Move(atom/newloc, direct = 0, movetime)
	var/oldLoc = loc
	. = ..()
	if(. && camera && !camera_updating)
		camera_updating = TRUE
		addtimer(CALLBACK(src, .proc/update_camera_on_move, oldLoc), BORG_CAMERA_BUFFER)

#undef BORG_CAMERA_BUFFER

/**
 * TODO
 */
/mob/living/silicon/robot/proc/update_camera_on_move(oldLoc)
	if(camera && oldLoc != loc)
		GLOB.cameranet.updatePortableCamera(camera)
	camera_updating = FALSE

/**
 * TODO
 */
/mob/living/silicon/robot/proc/self_destruct()
	if(emagged)
		if(mmi)
			qdel(mmi)
		explosion(loc, 1, 2, 4, flame_range = 2)
	else
		explosion(loc, -1, 0, 2)
	gib()
	return

/**
 * TODO
 */
/mob/living/silicon/robot/proc/UnlinkSelf()
	disconnect_from_ai()
	lawupdate = FALSE
	locked_down = FALSE
	canmove = TRUE
	visible_on_console = TRUE
	//Disconnect it's camera so it's not so easily tracked.
	QDEL_NULL(camera)
	// I'm trying to get the Cyborg to not be listed in the camera list
	// Instead of being listed as "deactivated". The downside is that I'm going
	// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
	// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/W = get_active_hand()
	if(W)
		W.attack_self(src)

/**
 * TODO
 */
/mob/living/silicon/robot/proc/SetLockdown(state = 1)
	// They stay locked down if their wire is cut.
	if(wires.is_cut(WIRE_BORG_LOCKED))
		state = 1
	if(state)
		throw_alert("locked", /obj/screen/alert/locked)
	else
		clear_alert("locked")
	locked_down = state
	update_canmove()

/**
 * TODO
 */
/mob/living/silicon/robot/proc/choose_icon(triesleft, list/module_sprites)
	if(triesleft < 1 || !length(module_sprites))
		return
	else
		triesleft--

	var/icontype
	locked_down = TRUE  //Locks borg until it select an icon to avoid secborgs running around with a standard sprite
	icontype = input("Select an icon! [triesleft ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) in module_sprites

	if(icontype)
		if(icontype == "Custom")
			icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		else
			icon = 'icons/mob/robots.dmi'
		icon_state = module_sprites[icontype]
		if(icontype == "Bro")
			module.module_type = "Brobot"
			update_module_icon()
		locked_down = FALSE
		var/list/names = splittext(icontype, "-")
		custom_panel = trim(names[1])
	else
		to_chat(src, "<span class='warning'>Something is badly wrong with the sprite selection. Notify a coder.</span>")
		icon_state = module_sprites[1]
		locked_down = FALSE
		return

	update_icons()

	if(triesleft >= 1)
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(triesleft, module_sprites)
			return
		else
			triesleft = 0
			return
	else
		to_chat(src, "<span class='notice'>Your icon has been set. You now require a module reset to change it.</span>")

/**
 * Notifies the AI this cyborg was either just created, chose a new name, or chose a module.
 */
/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(NOTIFY_NEW_CYBORG)
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg connection detected: <a href='byond://?src=[connected_ai.UID()];track2=\ref[connected_ai];track=\ref[src]'>[name]</a></span><br>")
		if(NOTIFY_MODULE_CHOSEN)
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.</span><br>")
		if(NOTIFY_NEW_NAME)
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].</span><br>")

/**
 * Unconnects the cyborg from the AI.
 */
/mob/living/silicon/robot/proc/disconnect_from_ai()
	if(connected_ai)
		sync() // One last sync attempt
		connected_ai.connected_robots -= src
		connected_ai = null

/**
 * Unlinks the cyborg with their current AI, and connects theem to a new AI.
 *
 * If no `AI` arugment is given, it will attempt to connect to the AI with the fewest borgs
 *
 * Arguments:
 * * mob/living/silicon/ai/AI - The AI the cyborg will connect to (optional).
 */
/mob/living/silicon/robot/proc/connect_to_ai(mob/living/silicon/ai/AI)
	if(AI == connected_ai)
		return FALSE
	if(!AI)
		AI = select_active_ai_with_fewest_borgs()
	if(!AI)
		lawupdate = FALSE
		return FALSE
	disconnect_from_ai()
	lawupdate = TRUE
	connected_ai = AI
	connected_ai.connected_robots |= src
	notify_ai(NOTIFY_NEW_CYBORG)
	sync()
	return TRUE

/mob/living/silicon/robot/adjustOxyLoss(amount)
	if(suiciding)
		return ..()
	else
		return STATUS_UPDATE_NONE

/mob/living/silicon/robot/regenerate_icons()
	..()
	update_module_icon()

/mob/living/silicon/robot/emp_act(severity)
	if(protection_flags & EMP_PROOF)
		return
	..()
	switch(severity)
		if(1)
			disable_component("comms", 160)
		if(2)
			disable_component("comms", 60)

/mob/living/silicon/robot/deathsquad
	icon_state = "nano_bloodhound"
	designation = "SpecOps"
	lawupdate = FALSE
	auto_snyc_to_AI = FALSE
	visible_on_console = TRUE
	has_camera = FALSE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	magpulse = TRUE
	pdahide = TRUE
	damage_protection = 10 // Reduce all incoming damage by this number
	allow_rename = FALSE
	modtype = "Commando"
	faction = list("nanotrasen")
	protection_flags = EMAG_PROOF | FLASH_PROOF | FLASHBANG_SOUND_PROOF
	cover_flags = LOCKED | SELF_LOCKABLE
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	see_reagents = TRUE
	creation_sound = 'sound/mecha/nominalnano.ogg'
	radio_type = /obj/item/radio/borg/deathsquad
	law_type_override = /datum/ai_laws/deathsquad
	module_type = /obj/item/robot_module/deathsquad

/mob/living/silicon/robot/deathsquad/Initialize(mapload, mob/living/silicon/ai/AI_to_sync_to)
	. = ..()
	var/obj/item/borg/upgrade/thrusters/thrusters = new(src)
	thrusters.do_install(src)

/mob/living/silicon/robot/deathsquad/bullet_act(obj/item/projectile/P)
	if(istype(P) && P.is_reflectable && P.starting)
		visible_message("<span class='danger'>[P] gets reflected by [src]!</span>", "<span class='userdanger'>[P] gets reflected by [src]!</span>")
		P.reflect_back(src)
		return -1
	return ..(P)


/mob/living/silicon/robot/ert
	designation = "ERT"
	lawupdate = FALSE
	auto_snyc_to_AI = FALSE
	visible_on_console = TRUE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	available_modules = list("Engineering", "Medical", "Security")
	static_radio_channels = TRUE
	allow_rename = FALSE
	cover_flags = LOCKED | SELF_LOCKABLE
	see_reagents = TRUE
	default_cell_type = /obj/item/stock_parts/cell/super
	law_type_override = /datum/ai_laws/ert_override
	radio_type = /obj/item/radio/borg/ert
	/// The prefix to be placed in front of the cyborg's name, i.e. "[Amber, Red, Gamma] ERT 123"
	var/ert_type_prefix = "Amber"

/mob/living/silicon/robot/ert/Initialize(mapload, mob/living/silicon/ai/AI_to_sync_to)
	. = ..()
	var/obj/item/borg/upgrade/thrusters/thrusters = new(src)
	thrusters.do_install(src)
	var/obj/item/borg/upgrade/syndicate/safety_override = new(src)
	safety_override.do_install(src)
	name = "[ert_type_prefix] ERT [rand(1, 1000)]"
	custom_name = name
	real_name = name
	mind = new
	mind.current = src
	mind.original = src
	mind.assigned_role = SPECIAL_ROLE_ERT
	mind.special_role = SPECIAL_ROLE_ERT
	SSticker.minds |= mind

/mob/living/silicon/robot/ert/red
	ert_type_prefix = "Red"
	default_cell_type = /obj/item/stock_parts/cell/hyper

/mob/living/silicon/robot/ert/gamma
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	available_modules = list("Combat", "Engineering", "Medical")
	damage_protection = 5 // Reduce all incoming damage by this number
	ert_type_prefix = "Gamma"
	magpulse = TRUE


/mob/living/silicon/robot/destroyer
	// admin-only borg, the seraph / special ops officer of borgs
	icon_state = "droidcombat"
	modtype = "Destroyer"
	designation = "Destroyer"
	lawupdate = FALSE
	auto_snyc_to_AI = FALSE
	visible_on_console = TRUE
	has_camera = FALSE
	req_one_access = list(ACCESS_CENT_SPECOPS)
	magpulse = TRUE
	pdahide = TRUE
	protection_flags = EMP_PROOF | FLASH_PROOF | FLASHBANG_SOUND_PROOF
	damage_protection = 20 // Reduce all incoming damage by this number. Very high in the case of /destroyer borgs, since it is an admin-only borg.
	cover_flags = LOCKED | SELF_LOCKABLE
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	see_reagents = TRUE
	law_type_override = /datum/ai_laws/deathsquad
	radio_type = /obj/item/radio/borg/ert/specops
	module_type = /obj/item/robot_module/destroyer
	creation_sound = 'sound/mecha/nominalnano.ogg'

/mob/living/silicon/robot/destroyer/Initialize(mapload, mob/living/silicon/ai/AI_to_sync_to)
	. = ..()
	var/obj/item/borg/upgrade/thrusters/thrusters = new(src)
	thrusters.do_install(src)
	status_flags &= ~CANPUSH

/mob/living/silicon/robot/destroyer/update_icons()
	. = ..()
	if(module_active && istype(module_active, /obj/item/borg/destroyer/mobility))
		icon_state = "[icon_state]-roll"
	else
		overlays += "[icon_state]-shield"


/mob/living/silicon/robot/extinguish_light()
	update_headlamp(1, 150)

/mob/living/silicon/robot/rejuvenate()
	..()
	var/brute = 1000
	var/burn = 1000
	var/list/datum/robot_component/borked_parts = get_damaged_components(TRUE, TRUE, TRUE, TRUE)
	for(var/datum/robot_component/borked_part in borked_parts)
		brute = borked_part.brute_damage
		burn = borked_part.electronics_damage
		borked_part.installed = 1
		borked_part.wrapped = new borked_part.external_type
		if(ispath(borked_part.external_type, /obj/item/stock_parts/cell)) // is the broken part a cell?
			cell = new borked_part.external_type // borgs that have their cell destroyed have their `cell` var set to null. we need create a new cell for them based on their old cell type.
		borked_part.heal_damage(brute,burn)
		borked_part.install()

/**
 * Returns true if the given icon state `spritename` is present in the `custom-synthetic.dmi` file.
 *
 * Arguments:
 * * spritename - The name of an icon state to search for
 */
/mob/living/silicon/robot/proc/check_sprite(spritename)
	var/static/all_borg_icon_states = icon_states('icons/mob/custom_synthetic/custom-synthetic.dmi')
	if(spritename in all_borg_icon_states)
		return TRUE
	return FALSE

/mob/living/silicon/robot/check_eye_prot()
	return (protection_flags & FLASH_PROOF) ? 2 : 0

/mob/living/silicon/robot/check_ear_prot()
	return (protection_flags & FLASHBANG_SOUND_PROOF) ? 1 : 0

/mob/living/silicon/robot/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_flags & BORGMESON)
		sight |= SEE_TURFS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	if(sight_flags & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_invisible = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		see_in_dark = 8

	if(sight_flags & BORGTHERM)
		sight |= SEE_MOBS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	return ..()

/**
 * Drops the cyborg gripper's currently held item, if there is one.
 *
 * Used in `robot_bindings.dm` when the user presses "A" if on AZERTY mode, or "Q" on QWERTY mode.
 */
/mob/living/silicon/robot/proc/on_drop_hotkey_press()
	var/obj/item/gripper/G = get_active_hand()
	if(istype(G) && G.gripped_item)
		G.drop_gripped_item() // if the active module is a gripper, try to drop its held item.
	else
		uneq_active() // else unequip the module and put it back into the robot's inventory.
		return

/**
 * Checks if the cyborg has sustained enough damage to disable it's modules (hand slots).
 *
 * If the cyborg is under a certain threshold for a module to shut down, that current active item will be unequipped from that slot.
 *
 * Arguments:
 * * makes_sound - If there should be a sound played whenever a damage threshold is crossed.
 */
/mob/living/silicon/robot/proc/check_module_damage(makes_sound = TRUE)
	if(health < 50 && uneq_module(module_state_3)) // Gradual break down of modules as more damage is sustained
		if(makes_sound)
			audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module 3 OFFLINE.\"</span>")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module 3 OFFLINE.</span>")

	if(health < 0 && uneq_module(module_state_2))
		if(makes_sound)
			audible_message("<span class='warning'>[src] sounds an alarm! \"SYSTEM ERROR: Module 2 OFFLINE.\"</span>")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 60, TRUE)
		to_chat(src, "<span class='userdanger'>SYSTEM ERROR: Module 2 OFFLINE.</span>")

	if(health < -50 && uneq_module(module_state_1))
		if(makes_sound)
			audible_message("<span class='warning'>[src] sounds an alarm! \"CRITICAL ERROR: All modules OFFLINE.\"</span>")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)
		to_chat(src, "<span class='userdanger'>CRITICAL ERROR: All modules OFFLINE.</span>")

/mob/living/silicon/robot/can_see_reagents()
	return see_reagents
