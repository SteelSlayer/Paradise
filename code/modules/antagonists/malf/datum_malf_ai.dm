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
	add_antag_objective(/datum/objective/block)
	add_antag_objective(/datum/objective/assassinate)
	add_antag_objective(/datum/objective/survive)

/datum/antagonist/malf_ai/finalize_antag()
	var/list/messages = list()
	if(give_codewords)
		messages.Add(give_codewords())

	var/mob/living/silicon/ai/malf_AI = owner.current
	malf_AI.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	malf_AI.set_syndie_radio()
	malf_AI.add_malf_picker()
	to_chat(malf_AI, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")

	malf_AI.playsound_local(get_turf(malf_AI), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	malf_AI.show_laws()

/**
 * Notify the AI of their codewords and write them to `antag_memory` (notes).
 */
// TODO: Duplicated from /datum/antagonist/traitor/proc/give_codewords(), probably not the best way to do this
/datum/antagonist/malf_ai/proc/give_codewords()
	if(!owner.current)
		return

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")
	var/list/messages = list()
	messages.Add("<u><b>The Syndicate have provided you with the following codewords to identify fellow agents:</b></u>")
	messages.Add("<span class='bold body'>Code Phrase: <span class='codephrases'>[phrases]</span></span>")
	messages.Add("<span class='bold body'>Code Response: <span class='coderesponses'>[responses]</span></span>")

	antag_memory += "<b>Code Phrase</b>: <span class='red'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"

	messages.Add("Use the codewords during regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	messages.Add("<b><font color=red>You memorize the codewords, allowing you to recognize them when heard.</font></b>")

	return messages
