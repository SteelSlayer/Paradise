
/*
	TODO:

	* Issue: when clicking on the mob holder in your opposite hand: object transfers, sprite turns invisible and mob drops to floor.
 */

/**
 * # Scoopable Element
 *
 * Element that can be attached to living mobs.
 * Allows said mob to be picked up by a carbon mob via the use of a [holder object][/obj/item/holder].
 */
/datum/element/scoopable
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	/// The object to create when someone picks up the parent mob. Must be a type of `/obj/item/holder`.
	var/holder_type

/datum/element/scoopable/Attach(datum/target, holder_typepath)
	. = ..()
	if(!isliving(target) || (holder_typepath && !ispath(holder_typepath)))
		return ELEMENT_INCOMPATIBLE
	// If no holder_typepath is given, we just use the generic holder which will take the appearance of the mob.
	holder_type = holder_typepath || /obj/item/holder
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)

/datum/element/scoopable/proc/on_attack_hand(mob/living/mob_to_scoop, mob/living/carbon/grabber, proximity)
	if(!istype(grabber) || grabber.a_intent != INTENT_HELP)
		return
	new holder_type(get_turf(grabber), mob_to_scoop, grabber)
	return COMPONENT_NO_ATTACK_HAND
