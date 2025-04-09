GLOBAL_LIST_EMPTY(used_monthly_token)

/// Token for each player in the round, used to backup tokens to logs at roundend.
GLOBAL_LIST_EMPTY(saved_token_values)

///assoc list of how many event tokens each role gets each month
GLOBAL_LIST_INIT(patreon_etoken_values, list(
	NO_RANK = 0,
	THANKS_RANK = 100,
	ASSISTANT_RANK = 500,
	COMMAND_RANK = 1000,
	TRAITOR_RANK = 2500,
	NUKIE_RANK = 5000,
))

/client
	var/datum/meta_token_holder/client_token_holder

/datum/meta_token_holder
	///the client that owns this holder
	var/client/owner
	///our total donator tokens
	var/donator_token = 0
	///total amount of antag tokens
	var/total_antag_tokens = 0
	///high threat antag tokens
	var/total_high_threat_tokens = 0
	///medium threat antag tokens
	var/total_medium_threat_tokens = 0
	///low threat antag_tokens
	var/total_low_threat_tokens = 0
	///the antagonist we are currently waiting for a reply on whether we can use
	var/datum/antagonist/in_queue
	var/in_queued_tier
	///is the queued token a donor token
	var/queued_donor = FALSE
	///how many event tokens we currently have
	var/event_tokens = 0
	///the month we last used event tokens on
	var/event_token_month = 0
	///what token event do we currently have queued
	var/datum/twitch_event/queued_token_event
	/// The timer for the antag token timeout
	var/antag_timeout
	/// The timer for the event token timeout
	var/event_timeout
	/// The month we last used a donator token on
	var/token_month = 0

/datum/meta_token_holder/New(client/creator)
	. = ..()
	if(!creator)
		return
	owner = creator

	var/datum/preferences/owners_prefs = creator.prefs
	backup_tokens()
	convert_list_to_tokens(owners_prefs.saved_tokens)
	check_for_donator_token()

/datum/meta_token_holder/proc/convert_list_to_tokens(list/saved_tokens)
	if(!length(saved_tokens))
		return
	for(var/token in saved_tokens)
		if(isnull(saved_tokens[token]))
			saved_tokens[token] = 0
		if(!("donator" in saved_tokens))
			saved_tokens |= "donator"
			saved_tokens["donator"] = 0

	total_low_threat_tokens = saved_tokens["low_threat"]
	total_medium_threat_tokens = saved_tokens["medium_threat"]
	total_high_threat_tokens = saved_tokens["high_threat"]
	event_tokens = saved_tokens["event_tokens"]
	event_token_month = saved_tokens["event_token_month"]
	donator_token = saved_tokens["donator"]
	token_month = saved_tokens["donator_token_month"]

	total_antag_tokens = total_low_threat_tokens + total_medium_threat_tokens + total_high_threat_tokens

/// Backs up the owner's tokens to [GLOB.saved_token_values],
/// with sanity checks to make damn sure we don't write invalid data.
/datum/meta_token_holder/proc/backup_tokens()
	if(QDELETED(src) || QDELETED(owner) || !owner.ckey || QDELETED(owner.prefs) || !owner.prefs.saved_tokens)
		return
	GLOB.saved_token_values[owner.ckey] = owner.prefs.saved_tokens.Copy()

/datum/meta_token_holder/proc/convert_tokens_to_list()
	owner.prefs.saved_tokens = list(
		"low_threat" = total_low_threat_tokens,
		"medium_threat" = total_medium_threat_tokens,
		"high_threat" = total_high_threat_tokens,
		"event_tokens" = event_tokens,
		"event_token_month" = event_token_month,
		"donator" = donator_token,
		"donator_token_month" = token_month,
	)
	backup_tokens()
	owner.prefs.save_preferences()

/datum/meta_token_holder/proc/check_for_donator_token()
	var/datum/patreon_data/patreon = owner?.player_details?.patreon

	if(!patreon?.has_access(ACCESS_TRAITOR_RANK))
		return FALSE

	var/month_number = text2num(time2text(world.time, "MM"))

	if(token_month != month_number)
		if(patreon.has_access(ACCESS_NUKIE_RANK))    ///if nukie rank, get coins AND token
			owner.prefs.adjust_metacoins(owner?.ckey, 10000, "Monthly Monkecoin rations", donator_multiplier = FALSE)

		donator_token++
		token_month = month_number  ///update per-person month counter
		convert_tokens_to_list()
		return TRUE

	else
		token_month = month_number
		convert_tokens_to_list()
		return FALSE

/datum/meta_token_holder/proc/spend_antag_token(tier, use_donor = FALSE)
	if(use_donor)
		if(donator_token)
			donator_token--
			logger.Log(LOG_CATEGORY_META, "[owner], used donator token on [token_month].")
			convert_tokens_to_list()
			return

	switch(tier)
		if(HIGH_THREAT)
			total_high_threat_tokens--
		if(MEDIUM_THREAT)
			total_medium_threat_tokens--
		if(LOW_THREAT)
			total_low_threat_tokens--

	convert_tokens_to_list()

///adjusts the users tokens, yes they can be in antag token debt
/datum/meta_token_holder/proc/adjust_antag_tokens(tier, amount)
	var/list/old_token_values = list(HIGH_THREAT = total_high_threat_tokens, MEDIUM_THREAT = total_medium_threat_tokens, LOW_THREAT = total_low_threat_tokens)
	switch(tier)
		if(HIGH_THREAT)
			total_high_threat_tokens += amount
		if(MEDIUM_THREAT)
			total_medium_threat_tokens += amount
		if(LOW_THREAT)
			total_low_threat_tokens += amount

	log_admin("[key_name(owner)] had their antag tokens adjusted from high: [old_token_values[HIGH_THREAT]], medium: [old_token_values[MEDIUM_THREAT]], \
				low: [old_token_values[LOW_THREAT]], to, high: [total_high_threat_tokens], medium: [total_medium_threat_tokens], low: [total_low_threat_tokens]")
	convert_tokens_to_list()

/datum/meta_token_holder/proc/approve_antag_token()
	if(!in_queue)
		return

	to_chat(owner, span_boldnicegreen("Your request to play as [in_queue] has been approved."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s antag token for [in_queue] has been approved")
	spend_antag_token(in_queued_tier, queued_donor)
	if(!owner.mob.mind)
		owner.mob.mind_initialize()
	in_queue.antag_token(owner.mob.mind, owner.mob) //might not be in queue

	qdel(in_queue)
	in_queue = null
	in_queued_tier = null
	queued_donor = FALSE
	if(antag_timeout)
		deltimer(antag_timeout)
		antag_timeout = null

/datum/meta_token_holder/proc/reject_antag_token()
	if(!in_queue)
		return

	to_chat(owner, span_boldwarning("Your request to play as [in_queue] has been denied."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s antag token for [in_queue] has been denied.")
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	in_queue = null
	in_queued_tier = null
	queued_donor = FALSE
	if(antag_timeout)
		deltimer(antag_timeout)
		antag_timeout = null

/datum/meta_token_holder/proc/timeout_antag_token()
	if(!in_queue)
		return
	to_chat(owner, span_boldwarning("Your request to play as [in_queue] wasn't answered within 5 minutes. Better luck next time!"))
	logger.Log(LOG_CATEGORY_META, "[owner]'s antag token for [in_queue] has timed out.")
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	in_queue = null
	in_queued_tier = null
	queued_donor = FALSE
	antag_timeout = null

/datum/meta_token_holder/proc/adjust_event_tokens(amount)
	check_event_tokens(owner)
	var/old_value = event_tokens
	event_tokens += amount
	log_admin("[key_name(owner)] had their event tokens adjusted from [old_value] to, [event_tokens].")
	convert_tokens_to_list()

/datum/meta_token_holder/proc/check_event_tokens(client/checked_client)
	var/month_number = text2num(time2text(world.time, "MM"))
	if(event_token_month != month_number)
		event_token_month = month_number
		event_tokens = GLOB.patreon_etoken_values[checked_client.player_details.patreon.owned_rank]
		convert_tokens_to_list()

/datum/meta_token_holder/proc/approve_token_event()
	if(!queued_token_event)
		return

	to_chat(owner, span_boldnicegreen("Your request to trigger [queued_token_event] has been approved."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s event token for [queued_token_event] has been approved.")
	adjust_event_tokens(-queued_token_event.token_cost)
	SStwitch.add_to_queue(initial(queued_token_event.id_tag))
	queued_token_event = null
	if(event_timeout)
		deltimer(event_timeout)
		event_timeout = null

/datum/meta_token_holder/proc/reject_token_event()
	if(!queued_token_event)
		return

	to_chat(owner, span_boldwarning("Your request to trigger [queued_token_event] has been denied."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s event token for [queued_token_event] has been denied.")
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	queued_token_event = null
	if(event_timeout)
		deltimer(event_timeout)
		event_timeout = null

/datum/meta_token_holder/proc/timeout_event_token()
	if(!queued_token_event)
		return
	logger.Log(LOG_CATEGORY_META, "[owner]'s event token for [queued_token_event] has timed out.")
	to_chat(owner, span_boldwarning("Your request to trigger [queued_token_event] wasn't answered within 5 minutes. Better luck next time!"))
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	queued_token_event = null
	event_timeout = null
