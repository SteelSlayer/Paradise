

// Test so I can see the checkers. TODO: remove this before PR.
/obj/effect/abstract/proximity_checker
	invisibility = 0
	icon = 'icons/turf/areas.dmi'
	icon_state = "DJ"
// Test so I can see the checkers. TODO: remove this before PR.

/datum/component/proximity_monitor/advanced/turret_field
	name = "turret detection field"
	/// A list of doors in view of the turret.
	var/list/doors
	/// A list of walls in view of the turret.
	var/list/walls
	/// List of mob UIDs the turret is aware of inside the field.
	var/list/mobs_tracked
	/// The turret this field is attached to.
	var/turret_UID

/datum/component/proximity_monitor/advanced/turret_field/Initialize(_radius = 7, _always_active = TRUE)
	. = ..()
	if(!istype(parent, /obj/machinery/porta_turret))
		return COMPONENT_INCOMPATIBLE
	turret_UID = parent.UID()
	map_the_room()
	assess_visibility()

/datum/component/proximity_monitor/advanced/turret_field/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_SET_ANCHORED, .proc/on_set_anchored)

/**
 *
 */
/datum/component/proximity_monitor/advanced/turret_field/proc/on_set_anchored(datum/source, anchor_value)
	// TODO

// In case the turret gets teleported or something.
/datum/component/proximity_monitor/advanced/turret_field/on_receiver_move(datum/source, atom/old_loc, dir)
	// TODO

/datum/component/proximity_monitor/advanced/turret_field/proc/assess_visibility()
	toggle_checkers(FALSE)
	recenter_prox_checkers()
	var/list/view = view(7, parent)
	for(var/obj/effect/abstract/proximity_checker/checker as anything in proximity_checkers)
		if(checker in view)
			checker.active = TRUE
			continue
		// Tiles that the turret can't "see" get put into nullspace, so they won't detect anything.
		// And also so they can be set back in place and reused later without having to `new` more checkers.
		checker.loc = null

/datum/component/proximity_monitor/advanced/turret_field/proc/map_the_room()
	for(var/T in walls)
		UnregisterSignal(locateUID(T), COMSIG_TURF_CHANGE)
	for(var/D in doors)
		UnregisterSignal(locateUID(D), list(COMSIG_MOVABLE_MOVED, COMSIG_DOOR_OPEN, COMSIG_DOOR_CLOSE, COMSIG_AIRLOCK_OPEN, COMSIG_AIRLOCK_CLOSE))
	doors = list()
	walls = list()
	var/list/range = range(7, parent)
	for(var/turf/T in range)
		if(!T.density)
			continue
		RegisterSignal(T, COMSIG_TURF_CHANGE, .proc/assess_visibility)
		walls += T.UID()
	for(var/obj/machinery/door/D in range)
		if(istype(D, /obj/machinery/door/airlock))
			RegisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_AIRLOCK_OPEN, COMSIG_AIRLOCK_CLOSE), .proc/assess_visibility)
		else
			RegisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_DOOR_OPEN, COMSIG_DOOR_CLOSE), .proc/assess_visibility)
		doors += D.UID()

#define CHECK_TARGET_LEAVING(AM) ;\
	for(var/obj/prox_checker as anything in proximity_checkers) { ;\
		if(!prox_checker.loc || (AM in prox_checker.loc.contents)) { ;\
			continue ;\
		} ;\
		LAZYREMOVE(mobs_tracked, AM.UID()) ;\
		if(!LAZYLEN(mobs_tracked)) { ;\
			var/obj/turret = locate(turret_UID) ;\
			STOP_PROCESSING(SSobj, turret) ;\
		} ;\
	};

/datum/component/proximity_monitor/advanced/turret_field/inner_field_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner_field/F)
	if(!isliving(AM))
		return
	for(var/obj/prox_checker as anything in proximity_checkers)
		if(!prox_checker.loc || (AM in prox_checker.loc.contents))
			continue
		LAZYREMOVE(mobs_tracked, AM.UID())
		if(!LAZYLEN(mobs_tracked))
			var/obj/turret = locate(turret_UID)
			STOP_PROCESSING(SSobj, turret)

/datum/component/proximity_monitor/advanced/turret_field/handle_proximity(atom/movable/AM)
	if((AM.UID() in mobs_tracked) || !isliving(AM))
		return
	// Tell the turret to wake up and start assessing the new target, if it wasn't already.
	LAZYADD(mobs_tracked, AM.UID())
	var/obj/turret = locate(turret_UID)
	START_PROCESSING(SSobj, turret)

#undef CHECK_TARGET_LEAVING
