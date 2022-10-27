
GLOBAL_LIST_EMPTY(admin_commands)

/**
 * # Admin Command
 *
 * TODO
 */
/datum/admin_command
	/// A text string used for this command, such as "make_antag" or "openticket".
	var/href_key = ""
	/// The rights required to execute this admin command, such as `R_SPAWN`. See `code\__DEFINES\admin.dm` for a list.
	var/rights_required = R_ADMIN
	///
	var/in_progress = FALSE

/**
 * Checks if the admin has the correct rights to run the command, then calls `execute` to actually run the command.
 *
 * Arguments:
 * * datum/admins/admin_datum - the admins datum belonging to the admin_mob
 * * mob/admin_mob - the admin mob executing this proc (`usr` passed from [/datum/admins/Topic])
 * * href - the `href` data passed from [/datum/admins/Topic])
 * * href_list - `href_list` data passed from [/datum/admins/Topic])
 */
/datum/admin_command/proc/try_execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	if(!can_execute(admin_datum, admin_mob, href, href_list))
		return FALSE
	execute(admin_datum, admin_mob, href, href_list)
	in_progress = FALSE
	return TRUE

/**
 * By default, checks if the admin has the correct rights to run the command.
 *
 * Arguments are identical to those received in `try_execute`.
 */
/datum/admin_command/proc/can_execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	SHOULD_CALL_PARENT(TRUE)
	if(!check_rights(rights_required, user = admin_mob))
		return FALSE
	return TRUE

/**
 * Proc which contains code to execute when the command is invoked.
 *
 * Arguments are identical to those received in `try_execute`.
 */
/datum/admin_command/proc/execute(datum/admins/admin_datum, mob/admin_mob, href, href_list)
	return
