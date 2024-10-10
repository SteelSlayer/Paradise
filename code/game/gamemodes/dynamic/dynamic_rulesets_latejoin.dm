//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	for(var/mob/P in candidates)
		if(!P.client || !P.mind || !P.mind.assigned_role) // Are they connected?
			candidates.Remove(P)
		else if(P.client.player_age > minimum_required_age)
			candidates.Remove(P)
		else if(P.mind.assigned_role in restricted_roles) // Does their job allow for it?
			candidates.Remove(P)
		else if(length(exclusive_roles) && !(P.mind.assigned_role in exclusive_roles)) // Is the rule exclusive to their job?
			candidates.Remove(P)
		else if(!((antag_preference || antag_flag) in P.client.prefs.be_special) || jobban_isbanned(P, antag_flag_override || antag_flag) || jobban_isbanned(P, ROLE_SYNDICATE))
			candidates.Remove(P)

/datum/dynamic_ruleset/latejoin/ready(forced = FALSE)
	if(forced)
		return ..()

	var/job_check = 0
	if(length(enemy_roles))
		for(var/mob/M in GLOB.alive_player_list)
			if(M.stat == DEAD)
				continue // Dead players cannot count as opponents
			if(M.mind && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
				job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

	var/threat = round(mode.threat_level / 10)

	if(job_check < required_enemies[threat])
		log_dynamic("FAIL: [src] is not ready, because there are not enough enemies: [required_enemies[threat]] needed, [job_check] found")
		return FALSE

	return ..()

/datum/dynamic_ruleset/latejoin/execute()
	var/mob/M = pick(candidates)
	assigned += M.mind
	M.mind.special_role = antag_flag
	M.mind.add_antag_datum(antag_datum)
	return TRUE

// Syndicate Traitors
/datum/dynamic_ruleset/latejoin/traitor
	name = "Syndicate Traitor"
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_TRAITOR
	antag_flag_override = ROLE_TRAITOR
	protected_roles = list(
		"Captain",
		"Detective",
		"Head of Personnel",
		"Head of Security",
		"Security Officer",
		"Warden",
	)
	restricted_roles = list(
		"AI",
		"Cyborg",
	)
	required_candidates = 1
	weight = 7
	cost = 5
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	repeatable = TRUE
