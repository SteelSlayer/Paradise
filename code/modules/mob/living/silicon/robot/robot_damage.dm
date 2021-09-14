/mob/living/silicon/robot/updatehealth(reason = "none given")
	..(reason)
	check_module_damage()

/mob/living/silicon/robot/getBruteLoss(repairable_only = FALSE)
	var/amount = 0
	for(var/comp in components)
		var/obj/item/robot_component/C = components[comp]
		if(!C && (!repairable_only || !C.is_broken())) // Installed ones only and if repair only remove the borked ones
			amount += C.brute_damage
	return amount

/mob/living/silicon/robot/getFireLoss(repairable_only = FALSE)
	var/amount = 0
	for(var/comp in components)
		var/obj/item/robot_component/C = components[comp]
		if(!C && (!repairable_only || !C.is_broken())) // Installed ones only and if repair only remove the borked ones
			amount += C.burn_damage
	return amount

/mob/living/silicon/robot/adjustBruteLoss(amount, updating_health = TRUE)
	if(amount > 0)
		take_overall_damage(amount, 0, updating_health)
	else
		heal_overall_damage(-amount, 0, updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/silicon/robot/adjustFireLoss(amount, updating_health = TRUE)
	if(amount > 0)
		take_overall_damage(0, amount, updating_health)
	else
		heal_overall_damage(0, -amount, updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/silicon/robot/proc/get_damaged_components(get_brute, get_burn, get_broken = FALSE, get_missing = FALSE)
	var/list/obj/item/robot_component/parts = list()
	for(var/comp in components)
		var/obj/item/robot_component/C = components[comp]
		if((!C || (get_broken && !C.is_broken()) || (get_missing && !C)) && ((get_brute && C.brute_damage) || (get_burn && C.burn_damage)))
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_missing_components()
	var/list/obj/item/robot_component/parts = list()
	for(var/comp in components)
		var/obj/item/robot_component/C = components[comp]
		if(!C)
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_damageable_components()
	var/list/rval = new
	for(var/comp in components)
		var/obj/item/robot_component/C = components[comp]
		if(C)
			rval += C
	return rval

/mob/living/silicon/robot/heal_organ_damage(brute, burn, updating_health = TRUE)
	var/list/obj/item/robot_component/parts = get_damaged_components(brute, burn)
	if(!LAZYLEN(parts))
		return
	var/obj/item/robot_component/picked = pick(parts)
	picked.heal_damage(brute, burn, updating_health)

/mob/living/silicon/robot/take_organ_damage(brute = 0, burn = 0, updating_health = TRUE, sharp = 0, edge = 0)
	var/list/components = get_damageable_components()
	if(!LAZYLEN(components))
		return

	var/obj/item/robot_component/armor/A = components["armor"]
	if(A)
		A.take_damage(burn, BURN)
		A.take_damage(brute, BRUTE)
		return

	var/obj/item/robot_component/C = pick(components)
	C.take_damage(brute, burn, sharp, updating_health)

/mob/living/silicon/robot/heal_overall_damage(brute, burn, updating_health = TRUE)
	var/list/obj/item/robot_component/parts = get_damaged_components(brute, burn)

	while(LAZYLEN(parts) && (brute > 0 || burn > 0) )
		var/obj/item/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.burn_damage

		picked.heal_damage(brute,burn, updating_health)

		brute -= (brute_was - picked.brute_damage)
		burn -= (burn_was - picked.burn_damage)

		parts -= picked

	if(updating_health)
		updatehealth("heal overall damage")

/mob/living/silicon/robot/take_overall_damage(brute = 0, burn = 0, updating_health = TRUE, used_weapon = null, sharp = 0)
	if(status_flags & GODMODE)
		return

	brute = max((brute - damage_protection) * brute_mod, 0)
	burn = max((burn - damage_protection) * burn_mod, 0)

	var/list/obj/item/robot_component/parts = get_damageable_components()

	var/obj/item/robot_component/armor/A = components["armor"]
	if(A)
		A.take_damage(burn, BURN)
		A.take_damage(brute, BRUTE)
		return

	while(LAZYLEN(parts) && (brute > 0 || burn > 0) )
		var/obj/item/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.burn_damage

		picked.take_damage(burn, BURN)
		picked.take_damage(brute, BRUTE)

		brute	-= (picked.brute_damage - brute_was)
		burn	-= (picked.burn_damage - burn_was)

		parts -= picked
	updatehealth()
