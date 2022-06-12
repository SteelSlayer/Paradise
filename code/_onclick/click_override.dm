/*
 * # Middle Click Override
 *
 * These are overrides for a living mob's middle and alt clicks.
 * If the mob in question has their `middle_click_override` var set to one of these datums, when they middle or alt click, the [onClick][/datum/middle_click_override/proc/onClick] proc for this datum is called.
 * See `click.dm`, lines 251 and 196.
 *
 * NOTE:
 * If you're making a subtype of override, ALWAYS make [/datum/middle_click_override/proc/set_override] and [/datum/middle_click_override/proc/unset_override] are called.
 * This is needed so that middle click overrides don't completely cancel eachother out. Once the user's current override is finished, we can revert to their old override using these procs.
 */
/datum/middle_click_override
	/// The UID of the mob using the click override
	var/user_UID
	/// The UID of any middle click override that the user may have set currently.
	var/old_override_UID

/datum/middle_click_override/New(mob/user)
	user_UID = user?.UID() // If you want to give a user here, you can. Otherwise, it will be given when `set_override()` is called.

/datum/middle_click_override/Destroy(force, ...)
	var/mob/living/user = locateUID(user_UID)
	if(user.middle_click_override == src)
		unassign_override(user)
	return ..()

/*
 * Note, when making a new click override it is ABSOLUTELY VITAL that you set the source's `middle_click_override` to `null` at some point if you don't want them to be stuck with it forever.
 */
/datum/middle_click_override/proc/onClick(atom/A, mob/living/user)
	unassign_override(user)

/**
 * Sets the user's `middle_click_override` to the src override. Store their old override UID if they have one.
 *
 * Arguments:
 * * mob/living/user - the user of the src middle click override
 * * replace_override - TRUE if this should replace whatever the user currently has set as their middle click override
 */
/datum/middle_click_override/proc/assign_override(mob/living/user, replace_override = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(isnull(user_UID))
		user_UID = user.UID()
	if(!replace_override && user.middle_click_override)
		return FALSE
	old_override_UID = user.middle_click_override?.UID()
	user.middle_click_override = src
	return TRUE

/**
 * Sets the user's `middle_click_override` to their old override, if they had one, or null if they did not.
 *
 * Arguments:
 * * mob/living/user - the user of the src middle click override
 */
/datum/middle_click_override/proc/unassign_override(mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || user.middle_click_override != src)
		// Either no user was passed, OR the src datum is not in use right now, so do nothing.
		return FALSE
	user.middle_click_override = locateUID(old_override_UID) // Will be null if we have no `old_override_UID`.
	return TRUE

/obj/item/badminBook
	name = "old book"
	desc = "An old, leather bound tome."
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	var/datum/middle_click_override/badminClicker/click_behavior = new

/obj/item/badminBook/Destroy()
	QDEL_NULL(click_behavior)
	return ..()

/obj/item/badminBook/attack_self(mob/living/user)
	if(click_behavior.assign_override(user, FALSE))
		to_chat(user, "<span class='notice'>You draw a bit of power from [src], you can use <b>middle click</b> or <b>alt click</b> to release the power!</span>")
	else
		to_chat(user, "<span class='warning'>You try to draw power from [src], but you cannot hold the power at this time!</span>")

/datum/middle_click_override/badminClicker
	var/summon_path = /obj/item/reagent_containers/food/snacks/cookie

/datum/middle_click_override/badminClicker/onClick(atom/A, mob/living/user)
	var/atom/movable/newObject = new summon_path
	newObject.loc = get_turf(A)
	to_chat(user, "<span class='notice'>You release the power you had stored up, summoning \a [newObject.name]! </span>")
	usr.loc.visible_message("<span class='notice'>[user] waves [user.p_their()] hand and summons \a [newObject.name]</span>")
	..()

/datum/middle_click_override/power_gloves

/datum/middle_click_override/power_gloves/onClick(atom/A, mob/living/carbon/human/user)
	if(A == user || user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB)
		return
	if(user.incapacitated())
		return
	var/obj/item/clothing/gloves/color/yellow/power/P = user.gloves
	if(world.time < P.last_shocked + P.shock_delay)
		to_chat(user, "<span class='warning'>The gloves are still recharging.</span>")
		return
	var/turf/T = get_turf(user)
	var/obj/structure/cable/C = locate() in T
	if(!P.unlimited_power)
		if(!C || !istype(C))
			to_chat(user, "<span class='warning'>There is no cable here to power the gloves.</span>")
			return
	var/turf/target_turf = get_turf(A)
	target_turf.hotspot_expose(2000, 400)
	playsound(user.loc, 'sound/effects/eleczap.ogg', 40, 1)

	var/atom/beam_from = user
	var/atom/target_atom = A

	for(var/i in 0 to 3)
		beam_from.Beam(target_atom, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 6)
		if(isliving(target_atom))
			var/mob/living/L = target_atom
			if(user.a_intent == INTENT_DISARM)
				add_attack_logs(user, L, "shocked and weakened with power gloves")
				L.Weaken(6 SECONDS)
			else
				add_attack_logs(user, L, "electrocuted with[P.unlimited_power ? " unlimited" : null] power gloves")
				if(P.unlimited_power)
					L.electrocute_act(1000, P, flags = SHOCK_NOGLOVES) //Just kill them
				else
					electrocute_mob(L, C, P)
			break
		var/list/next_shocked = list()
		for(var/atom/movable/AM in orange(3, target_atom))
			if(AM == user || istype(AM, /obj/effect) || isobserver(AM))
				continue
			next_shocked.Add(AM)

		beam_from = target_atom
		target_atom = pick(next_shocked)
		A = target_atom
		next_shocked.Cut()

	P.last_shocked = world.time

/**
 * # Callback invoker middle click override datum
 *
 * Middle click override which accepts a callback as an arugment in the `New()` proc.
 * When the living mob that has this datum middle-clicks or alt-clicks on something, the callback will be invoked.
 */
/datum/middle_click_override/callback_invoker
	var/datum/callback/callback

/datum/middle_click_override/callback_invoker/New(mob/living/user, datum/callback/_callback)
	. = ..()
	callback = _callback

/datum/middle_click_override/callback_invoker/onClick(atom/A, mob/living/user)
	callback.Invoke(user, A)
