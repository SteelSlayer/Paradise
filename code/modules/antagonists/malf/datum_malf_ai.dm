/datum/antagonist/malf_ai
	name = "Malfunctioning AI"
	roundend_category = "malf"
	job_rank = ROLE_MALF
	special_role = SPECIAL_ROLE_MALF
	give_objectives = TRUE
	antag_hud_name = "hudsyndicate"
	antag_hud_type = ANTAG_HUD_TRAITOR
	wiki_page_name = "AI"
	/// Should the AI get codewords?
	var/give_codewords = TRUE

/datum/antagonist/malf_ai/Destroy(force, ...)
	// Remove all associated malf AI abilities.
	if(isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.clear_zeroth_law()
		var/obj/item/radio/headset/heads/ai_integrated/radio = A.get_radio()
		radio.channels.Remove("Syndicate")  // De-traitored AIs can still state laws over the syndicate channel without this
		A.laws.sorted_laws = A.laws.inherent_laws.Copy() // AI's 'notify laws' button will still state a law 0 because sorted_laws contains it
		A.show_laws()
		A.remove_malf_abilities()
		QDEL_NULL(A.malf_picker)
	return ..()

/datum/antagonist/malf_ai/add_owner_to_gamemode()
	SSticker.mode.traitors |= owner

/datum/antagonist/malf_ai/remove_owner_from_gamemode()
	SSticker.mode.traitors -= owner

/datum/antagonist/malf_ai/give_objectives()
	add_objective(/datum/objective/block)
	add_objective(/datum/objective/assassinate)
	add_objective(/datum/objective/survive)

/datum/antagonist/malf_ai/finalize_antag()
	if(give_codewords)
		give_announce_traitor_codewords(owner)

	var/mob/living/silicon/ai/malf_AI = owner.current
	malf_AI.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	malf_AI.set_syndie_radio()
	malf_AI.add_malf_picker()
	to_chat(malf_AI, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")

	malf_AI.playsound_local(get_turf(malf_AI), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	malf_AI.show_laws()
