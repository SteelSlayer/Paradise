/**
 *
 *
 */
/datum/admin_command/mob_transform
	rights_required = R_SPAWN
	/// The prompt
	var/prompt = "Confirm make <ERROR>?"
	///
	var/transform_verb = "transform"

/datum/admin_command/mob_transform/can_execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/target = locateUID(href_list[href_key])
	if(!istype(target))
		to_chat(admin_mob, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human!</span>")
		return FALSE
	if(alert(admin_mob, prompt, "Transform Mob", "Yes", "No") == "No")
		return FALSE
	return TRUE

/datum/admin_command/mob_transform/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	var/mob/living/carbon/human/target = locateUID(href_list[href_key])
	log_admin("[key_name(admin_mob)] attempting to [transform_verb] [key_name(target)]")
	message_admins("<span class='notice'>[key_name_admin(admin_mob)] attempting to [transform_verb] [key_name_admin(target)]</span>")
	transform_mob(target)

/datum/admin_command/mob_transform/proc/transform_mob(mob/living/carbon/human/target)
	return


/datum/admin_command/mob_transform/monkey
	href_key = "make_monkey"
	prompt = "Confirm make monkey?"
	transform_verb = "monkeyize"

/datum/admin_command/mob_transform/monkey/transform_mob(mob/living/carbon/human/target)
	target.monkeyize()


/datum/admin_command/mob_transform/corgi
	href_key = "make_corgi"
	prompt = "Confirm make corgi?"
	transform_verb = "corgize"

/datum/admin_command/mob_transform/corgi/transform_mob(mob/living/carbon/human/target)
	target.corgize()


/datum/admin_command/mob_transform/pAI
	href_key = "makePAI"
	prompt = "Confirm make pAI?"
	transform_verb = "pAIze"

/datum/admin_command/mob_transform/pAI/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	var/mob/living/carbon/human/target = locateUID(href_list[href_key])
	var/painame = "Default"
	var/name = ""
	if(alert(admin_mob, "Do you want to set their name or let them choose their own name?", "Name Choice", "Set Name", "Let them choose") == "Set Name")
		name = sanitize(copytext(input(admin_mob, "Enter a name for the new pAI. Default name is [painame].", "pAI Name", painame),1,MAX_NAME_LEN))
	else
		name = sanitize(copytext(input(target, "An admin wants to make you into a pAI. Choose a name. Default is [painame].", "pAI Name", painame), 1, MAX_NAME_LEN))
	if(!name)
		name = painame
	..()

/datum/admin_command/mob_transform/pAI/transform_mob(mob/living/carbon/human/target)
	target.paize(name) // TODO: need to pass name


/datum/admin_command/mob_transform/ai
	href_key = "make_ai"
	prompt = "Confirm make ai?"
	transform_verb = "AIized"

/datum/admin_command/mob_transform/ai/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	var/mob/living/silicon/ai/AI_core = H.AIize()
	AI_core.moveToAILandmark()


/datum/admin_command/mob_transform/alien
	href_key = "make_alien"

/datum/admin_command/mob_transform/alien/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	usr.client.cmd_admin_alienize(H)


/datum/admin_command/mob_transform/slime
	href_key = "make_slime"

/datum/admin_command/mob_transform/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	usr.client.cmd_admin_slimeize(H)


/datum/admin_command/mob_transform/superhero
	href_key = "make_super"
	prompt = "Confirm make superhero?"

/datum/admin_command/mob_transform/superhero/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	usr.client.cmd_admin_super(H)


/datum/admin_command/mob_transform/robot
	href_hey = "make_robot"
	prompt = "Confirm make robot?"

/datum/admin_command/mob_transform/robot/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	usr.client.cmd_admin_robotize(H)


/datum/admin_command/mob_transform/animal
	href_key = "make_animal"
	prompt = "Confirm make animal?"

/datum/admin_command/mob_transform/animal/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	usr.client.cmd_admin_animalize(M)
