//might turn this into a cheap implant upgrade, also I should componentize this at some point
/datum/action/innate/gang_communicate
	name = "Gang Communicator"
	desc = "Use your implant's built-in communication device to send a message to all other members of your gang. \
			Note that you must speak your message out loud so those near by may be able to hear you."
	button_icon = 'icons/obj/radio.dmi'
	button_icon_state = "walkietalkie"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/gang_communicate/Activate()
	var/input = tgui_input_text(usr, "Message to tell to the other gang members.", "Gang Communicator")
	if(!input || !IsAvailable())
		return

	var/list/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(usr) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)
		if(tgui_alert(usr, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", \
						"Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. \
						Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")

	var/mob/living/sender_mob = usr
	if(!istype(sender_mob))
		CRASH("[src] attempting to activate without a living mob.")

	var/datum/antagonist/gang_member/antag_datum = IS_GANGMEMBER(sender_mob)
	if(!antag_datum)
		CRASH("[src] attempting to activate without its owner having a valid gang antag datum.")

	var/datum/team/gang/owner_gang = antag_datum.gang_team
	if(!owner_gang)
		CRASH("[src] attempting to activate without valid owner gang.")

	sender_mob.whisper(input, sanitize = TRUE)
	send_gang_message(antag_datum, owner_gang, sanitize_text(input))

/**
 * sender - The mob sending this message, if any
 * receiving_gang - The gang who's member will hear the message
 * sent_message - The message to send
 * span - The span to wrap the message in
 * append - Extra text to append onto the end of sent_message
 */
/proc/send_gang_message(datum/antagonist/gang_member/sender_datum, datum/team/gang/receiving_gang, sent_message, span = "<span class='syndradio'>", append)
	if(!receiving_gang)
		CRASH("send_gang_message() called without receiving_gang.")

	var/final_message = ""
	var/mob/living/sender_mob = sender_datum?.owner?.current
	if(sender_mob)
		var/sender_rank = "Member"
		if(sender_datum.rank == GANG_RANK_LIEUTENANT)
			sender_rank = "Lieutenant"
			span = "<span class='alertsyndie'>"
		else if(sender_datum.rank == GANG_RANK_BOSS)
			sender_rank = "Boss"
			span = "<span class='alertsyndie'><span class='big'>"
			append = "</span>"
		final_message = span + "<i><b>[sender_rank] \
						[findtextEx(sender_mob.name, sender_mob.real_name) ? sender_mob.name : "[sender_mob.real_name] (as [sender_mob.name])"]</b> transmits, \"" \
						+ sent_message + "\"</i></span>" + append
	else
		final_message = span + sent_message + "</span>" + append

	relay_to_list_and_observers(final_message, receiving_gang.members, sender_datum?.owner?.current)
