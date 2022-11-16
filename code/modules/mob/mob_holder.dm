/**
 * # Holder object
 *
 * An object used when mobs are picked up by a carbon mob.
 * Used with the [scoopable element][/datum/element/scoopable].
 */
/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_HEAD|SLOT_EARS
	/// UID of the mob this holder object is representing.
	var/parent_mob_UID

/obj/item/holder/Initialize(mapload, mob/living/scooped_mob, mob/living/carbon/human/grabber)
	. = ..()
	name = scooped_mob.name
	desc = scooped_mob.desc
	parent_mob_UID = scooped_mob.UID()
	assign_icon_state(scooped_mob)

	scooped_mob.forceMove(src)
	attack_hand(grabber)
	to_chat(grabber, "<span class='notice'>You scoop up \the [src].")
	to_chat(scooped_mob, "<span class='notice'>\The [grabber] scoops you up.</span>")

/**
 * Handles Logic for determination of the holder's sprite.
 *
 * By default, this will recreate the `scooped_mob`'s icon state with a south facing direction, and apply it to the src holder.
 *
 * Arguments:
 * * mob/living/scooped_mob - the mob that this holder object is representing
 */
/obj/item/holder/proc/assign_icon_state(mob/living/scooped_mob)
	scooped_mob.resting = FALSE
	icon = scooped_mob.icon
	icon_state = scooped_mob.icon_state
	item_state = scooped_mob.icon_state
	for(var/overlay in scooped_mob.overlays)
		add_overlay(overlay)

/obj/item/holder/pickup(mob/user)
	. = ..()
	user.status_flags |= PASSEMOTES

/obj/item/holder/dropped(mob/user, silent)
	..()
	// If they have a borer or another holder object, don't remove `PASSEMOTES`, the user still needs it.
	for(var/atom/A as anything in user.contents)
		if(!istype(A, /obj/item/holder))
			continue
		user.status_flags &= ~PASSEMOTES
	addtimer(CALLBACK(src, .proc/try_drop_mob), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

// `dropped()` is called whenever someone puts an object into storage, or takes it out of storage.
// Since the object is deleted when dropped, we need to actually make sure this is a real drop before deleting it. Not the ideal way to do this, but it works.
/obj/item/holder/proc/try_drop_mob()
	if(!isturf(loc))
		return
	var/mob/living/L = locateUID(parent_mob_UID)
	L.forceMove(get_turf(src))
	qdel(src)

// Instead of throwing the holder, we throw the parent mob.
/obj/item/holder/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force)
	var/mob/living/L = locateUID(parent_mob_UID)
	L.forceMove(get_turf(src))
	L.throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force)
	qdel(src)

/obj/item/holder/attackby(obj/item/I, mob/user, params)
	var/mob/living/L = locateUID(parent_mob_UID)
	L.attackby(I, user, params)

/obj/item/holder/proc/show_message(message, m_type)
	var/mob/living/L = locateUID(parent_mob_UID)
	L.show_message(message, m_type)

/obj/item/holder/emp_act(intensity)
	var/mob/living/L = locateUID(parent_mob_UID)
	L.emp_act(intensity)

/obj/item/holder/ex_act(intensity)
	var/mob/living/L = locateUID(parent_mob_UID)
	L.ex_act(intensity)

/obj/item/holder/examine(mob/user)
	for(var/mob/living/M in contents)
		. += M.examine(user)

/obj/item/holder/container_resist(mob/living/L)
	if(isliving(loc))
		var/mob/living/holder_mob = loc
		holder_mob.unEquip(src)
		to_chat(holder_mob, "[src] wriggles out of your grip!")
		to_chat(L, "You wriggle out of [holder_mob]'s grip!")
	else if(isitem(loc))
		to_chat(L, "You struggle free of [loc].")
		L.forceMove(get_turf(src))
		qdel(src)

/obj/item/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	item_state = "drone"

/obj/item/holder/drone/assign_icon_state(mob/living/scooped_mob)
	. = ..()
	// The drone appears very low in the hand slot, so this bumps it up a bit to make it more centered. Default is "CENTER: 16,SOUTH:5"
	screen_loc = "CENTER: 16,SOUTH:8"

/obj/item/holder/pai
	name = "pAI"
	desc = "It's a little robot."
	icon_state = "pai"

/obj/item/holder/pai/assign_icon_state(mob/living/silicon/pai/scooped_mob)
	if(scooped_mob.stat == DEAD)
		icon = 'icons/mob/pai.dmi'
		icon_state = "[scooped_mob.chassis]_dead"
		return
	if(scooped_mob.resting)
		icon_state = "[scooped_mob.chassis]"
		scooped_mob.resting = FALSE
	if(scooped_mob.custom_sprite)
		icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		icon_override = 'icons/mob/custom_synthetic/custom_head.dmi'
		lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		icon_state = "[scooped_mob.icon_state]"
		item_state = "[scooped_mob.icon_state]_hand"
	else
		icon_state = "pai-[scooped_mob.icon_state]"
		item_state = "pai-[scooped_mob.icon_state]"
