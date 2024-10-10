
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	minimum_required_age = 0
	protected_roles = list(
		"Captain",
		"Detective",
		"Head of Security",
		"Security Officer",
		"Warden",
	)
	restricted_roles = list(
		"AI",
		"Cyborg",
	)
	required_candidates = 1
	weight = 5
	cost = 8 // Avoid raising traitor threat above this, as it is the default low cost ruleset.
	scaling_cost = 9
	requirements = list(8,8,8,8,8,8,8,8,8,8)
	antag_cap = list("denominator" = 38)
	var/autotraitor_cooldown = (15 MINUTES)

/datum/dynamic_ruleset/roundstart/traitor/pre_execute(population)
	. = ..()
	var/num_traitors = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_traitors)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_TRAITOR
		M.mind.restricted_roles = restricted_roles
		mode.pre_setup_antags += M.mind
	return TRUE

//////////////////////////////////////////////
//                                          //
//            MALFUNCTIONING AI             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/malf_ai
	name = "Malfunctioning AI"
	antag_flag = ROLE_MALF
	antag_datum = /datum/antagonist/malf_ai
	minimum_required_age = 14
	exclusive_roles = list("AI")
	required_candidates = 1
	weight = 3
	cost = 18
	requirements = list(101,101,101,80,60,50,30,20,10,10)
	antag_cap = 1
	flags = HIGH_IMPACT_RULESET

/datum/dynamic_ruleset/roundstart/malf_ai/ready(forced = FALSE)
	var/datum/job/ai_job = SSjobs.GetJobType(/datum/job/ai)

	// If we're not forced, we're going to make sure we can actually have an AI in this shift,
	if(!forced && min(ai_job.total_positions - ai_job.current_positions, ai_job.spawn_positions) <= 0)
		log_dynamic("FAIL: [src] could not run, because there is nobody who wants to be an AI")
		return FALSE

	return ..()

/datum/dynamic_ruleset/roundstart/malf_ai/pre_execute(population)
	. = ..()

	var/datum/job/ai_job = SSjobs.GetJobType(/datum/job/ai)
	// Maybe a bit too pedantic, but there should never be more malf AIs than there are available positions, spawn positions or antag cap allocations.
	var/num_malf = min(get_antag_cap(population), min(ai_job.total_positions - ai_job.current_positions, ai_job.spawn_positions))
	for (var/i in 1 to num_malf)
		if(candidates.len <= 0)
			break
		var/mob/new_malf = pick_n_take(candidates)
		assigned += new_malf.mind
		new_malf.mind.special_role = ROLE_MALF
		mode.pre_setup_antags += new_malf.mind
		// We need an AI for the malf roundstart ruleset to execute. This means that players who get selected as malf AI get priority, because antag selection comes before role selection.
		LAZYADDASSOC(SSjobs.dynamic_forced_occupations, new_malf, "AI")
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	antag_flag = ROLE_CHANGELING
	antag_datum = /datum/antagonist/changeling
	protected_roles = list(
		"Captain",
		"Detective",
		"Head of Security",
		"Security Officer",
		"Warden",
	)
	restricted_roles = list(
		"AI",
		"Cyborg",
	)
	required_candidates = 1
	weight = 3
	cost = 16
	scaling_cost = 10
	requirements = list(70,70,60,50,40,20,20,10,10,10)
	antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/changeling/pre_execute(population)
	. = ..()
	var/num_changelings = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_changelings)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = ROLE_CHANGELING
		mode.pre_setup_antags += M.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/changeling/execute()
	for(var/datum/mind/changeling in assigned)
		var/datum/antagonist/changeling/new_antag = new antag_datum()
		changeling.add_antag_datum(new_antag)
		mode.pre_setup_antags -= changeling
	return TRUE

//////////////////////////////////////////////
//                                          //
//               VAMPIRES                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampires"
	antag_flag = ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	protected_roles = list(
		"Captain",
		"Detective",
		"Head of Security",
		"Security Officer",
		"Warden",
		"Chaplain"
	)
	restricted_roles = list(
		"AI",
		"Cyborg",
	)
	required_candidates = 1
	weight = 3
	cost = 16
	scaling_cost = 10
	requirements = list(70,70,60,50,40,20,20,10,10,10)
	antag_cap = list("denominator" = 29)

// Admin only rulesets. The threat requirement is 101 so it is not possible to roll them.

//////////////////////////////////////////////
//                                          //
//               EXTENDED                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	antag_flag = null
	antag_datum = null
	restricted_roles = list()
	required_candidates = 0
	weight = 3
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = LONE_RULESET

/datum/dynamic_ruleset/roundstart/extended/pre_execute()
	. = ..()
	message_admins("Starting a round of extended.")
	log_game("Starting a round of extended.")
	mode.spend_roundstart_budget(mode.round_start_budget)
	mode.spend_midround_budget(mode.mid_round_budget)
	mode.threat_log += "[worldtime2text()]: Extended ruleset set threat to 0."
	return TRUE
