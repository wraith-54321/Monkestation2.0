GLOBAL_LIST_INIT(used_sound_channels, list(
	CHANNEL_MASTER_VOLUME,
	CHANNEL_LOBBYMUSIC,
	CHANNEL_ADMIN,
	CHANNEL_VOX,
	CHANNEL_JUKEBOX,
	CHANNEL_HEARTBEAT,
	CHANNEL_AMBIENCE,
	CHANNEL_BUZZ,
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_SOUND_FOOTSTEPS,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_INSTRUMENTS,
	CHANNEL_INSTRUMENTS_ROBOT,
	CHANNEL_MOB_SOUNDS,
	CHANNEL_PRUDE,
	CHANNEL_SQUEAK,
	CHANNEL_MOB_EMOTES,
	CHANNEL_SILICON_EMOTES,
))

GLOBAL_LIST_INIT(proxy_sound_channels, list(
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_SOUND_FOOTSTEPS,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_INSTRUMENTS,
	CHANNEL_INSTRUMENTS_ROBOT,
	CHANNEL_MOB_SOUNDS,
	CHANNEL_PRUDE,
	CHANNEL_SQUEAK,
	CHANNEL_MOB_EMOTES,
	CHANNEL_SILICON_EMOTES,
))

GLOBAL_LIST_EMPTY(cached_mixer_channels)


/proc/guess_mixer_channel(soundin)
	var/sound_text_string
	if(istype(soundin, /sound))
		var/sound/bleh = soundin
		sound_text_string = "[bleh.file]"
	else
		sound_text_string = "[soundin]"
	if(GLOB.cached_mixer_channels[sound_text_string])
		return GLOB.cached_mixer_channels[sound_text_string]
	else if(findtext(sound_text_string, "effects/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else if(findtext(sound_text_string, "machines/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MACHINERY
	else if(findtext(sound_text_string, "creatures/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MOB_SOUNDS
	else if(findtext(sound_text_string, "/ai/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_VOX
	else if(findtext(sound_text_string, "chatter/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MOB_SOUNDS
	else if(findtext(sound_text_string, "items/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else if(findtext(sound_text_string, "weapons/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else
		return FALSE

///Default override for echo
/sound
	echo = list(
		0, // Direct
		0, // DirectHF
		-10000, // Room, -10000 means no low frequency sound reverb
		-10000, // RoomHF, -10000 means no high frequency sound reverb
		0, // Obstruction
		0, // ObstructionLFRatio
		0, // Occlusion
		0.25, // OcclusionLFRatio
		1.5, // OcclusionRoomRatio
		1.0, // OcclusionDirectRatio
		0, // Exclusion
		1.0, // ExclusionLFRatio
		0, // OutsideVolumeHF
		0, // DopplerFactor
		0, // RolloffFactor
		0, // RoomRolloffFactor
		1.0, // AirAbsorptionFactor
		0, // Flags (1 = Auto Direct, 2 = Auto Room, 4 = Auto RoomHF)
	)
	environment = SOUND_ENVIRONMENT_NONE //Default to none so sounds without overrides dont get reverb

/**
 * playsound is a proc used to play a 3D sound in a specific range. This uses SOUND_RANGE + extra_range to determine that.
 *
 * source - Origin of sound.
 * soundin - Either a file, or a string that can be used to get an SFX.
 * vol - The volume of the sound, excluding falloff and pressure affection.
 * vary - bool that determines if the sound changes pitch every time it plays.
 * extrarange - modifier for sound range. This gets added on top of SOUND_RANGE.
 * falloff_exponent - Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * frequency - playback speed of audio.
 * channel - The channel the sound is played at.
 * pressure_affected - Whether or not difference in pressure affects the sound (E.g. if you can hear in space).
 * ignore_walls - Whether or not the sound can pass through walls.
 * falloff_distance - Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 */
/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff_exponent = SOUND_FALLOFF_EXPONENT, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, use_reverb = TRUE, mixer_channel)
	if(isarea(source))
		CRASH("playsound(): source is an area")

	if(islist(soundin))
		CRASH("playsound(): soundin attempted to pass a list! Consider using pick()")

	var/turf/turf_source = get_turf(source)

	if (!turf_source || !soundin || !vol)
		return

	if(!mixer_channel)
		mixer_channel = guess_mixer_channel(soundin)

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

	var/sound/S = sound(get_sfx(soundin))
	var/maxdistance = SOUND_RANGE + extrarange
	var/source_z = turf_source.z
	var/list/listeners = SSmobs.clients_by_zlevel[source_z].Copy()

	. = list()//output everything that successfully heard the sound

	var/turf/above_turf = GET_TURF_ABOVE(turf_source)
	var/turf/below_turf = GET_TURF_BELOW(turf_source)

	if(ignore_walls)

		if(above_turf && istransparentturf(above_turf))
			listeners += SSmobs.clients_by_zlevel[above_turf.z]

		if(below_turf && istransparentturf(turf_source))
			listeners += SSmobs.clients_by_zlevel[below_turf.z]

	else //these sounds don't carry through walls
		listeners = get_hearers_in_view(maxdistance, turf_source)

		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_view(maxdistance, above_turf)

		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_view(maxdistance, below_turf)

	for(var/mob/listening_mob in listeners | SSmobs.dead_players_by_zlevel[source_z])//observers always hear through walls
		if(get_dist(listening_mob, turf_source) <= maxdistance)
			listening_mob.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, maxdistance, falloff_distance, 1, use_reverb, mixer_channel)
			. += listening_mob

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff_exponent = SOUND_FALLOFF_EXPONENT, channel = 0, pressure_affected = TRUE, sound/sound_to_use, max_distance, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, distance_multiplier = 1, use_reverb = TRUE, mixer_channel = 0)
	if(!client || !can_hear())
		return

	if(!sound_to_use)
		sound_to_use = sound(get_sfx(soundin))

	sound_to_use.wait = 0 //No queue
	sound_to_use.channel = channel || SSsounds.random_available_channel()
	sound_to_use.volume = vol
	if("[CHANNEL_MASTER_VOLUME]" in client?.prefs?.channel_volume)
		sound_to_use.volume *= client.prefs.channel_volume["[CHANNEL_MASTER_VOLUME]"] * 0.01

	if((mixer_channel == CHANNEL_PRUDE) && client?.prefs.read_preference(/datum/preference/toggle/prude_mode))
		sound_to_use.volume *= 0

	if(vary)
		if(frequency)
			sound_to_use.frequency = frequency
		else
			sound_to_use.frequency = get_rand_frequency()

	if(isturf(turf_source))
		var/turf/turf_loc = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(turf_loc, turf_source) * distance_multiplier

		if(max_distance && falloff_exponent) //If theres no max_distance we're not a 3D sound, so no falloff. MONKESTATION EDIT
			sound_to_use.volume -= (max(distance - falloff_distance, 0) ** (1 / falloff_exponent)) / ((max(max_distance, distance) - falloff_distance) ** (1 / falloff_exponent)) * sound_to_use.volume
			//https://www.desmos.com/calculator/sqdfl8ipgf

		if(pressure_affected)
			//Atmosphere affects sound
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = turf_loc.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			sound_to_use.volume *= pressure_factor
			//End Atmosphere affecting sound

		if((channel in GLOB.used_sound_channels) || (mixer_channel in GLOB.used_sound_channels))
			var/used_channel = 0
			if(channel in GLOB.used_sound_channels)
				used_channel = channel
				mixer_channel = channel
			else
				used_channel = mixer_channel
			if("[used_channel]" in client.prefs.channel_volume)
				sound_to_use.volume *= (client.prefs.channel_volume["[used_channel]"] * 0.01)

		else if(!mixer_channel)
			mixer_channel = guess_mixer_channel(soundin)
			if("[mixer_channel]" in client.prefs.channel_volume)
				sound_to_use.volume *= (client.prefs.channel_volume["[mixer_channel]"] * 0.01)

		if(sound_to_use.volume <= 0)
			return //No sound

		var/dx = turf_source.x - turf_loc.x // Hearing from the right/left
		sound_to_use.x = dx * distance_multiplier
		var/dz = turf_source.y - turf_loc.y // Hearing from infront/behind
		sound_to_use.z = dz * distance_multiplier
		var/dy = (turf_source.z - turf_loc.z) * 5 * distance_multiplier // Hearing from  above / below, multiplied by 5 because we assume height is further along coords.
		sound_to_use.y = dy

		sound_to_use.falloff = max_distance || 1 //use max_distance, else just use 1 as we are a direct sound so falloff isnt relevant.

		// Sounds can't have their own environment. A sound's environment will be:
		// 1. the mob's
		// 2. the area's (defaults to SOUND_ENVRIONMENT_NONE)
		if(sound_environment_override != SOUND_ENVIRONMENT_NONE)
			sound_to_use.environment = sound_environment_override
		else
			var/area/A = get_area(src)
			sound_to_use.environment = A.sound_environment

		if(turf_source != get_turf(src))
			sound_to_use.echo = list(0,0,0,0,0,0,-10000,1.0,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
		else
			sound_to_use.echo = list(0,0,0,0,0,0,0,0.25,1.5,1.0,0,1.0,0,0,0,0,1.0,7)

		if(!use_reverb)
			sound_to_use.echo[3] = -10000
			sound_to_use.echo[4] = -10000

	SEND_SOUND(src, sound_to_use)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.playsound_local(M, null, volume, vary, frequency, null, channel, pressure_affected, S)

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/mob/proc/set_sound_channel_volume(channel, volume)
	var/sound/S = sound(null, FALSE, FALSE, channel, volume)
	S.status = SOUND_UPDATE
	SEND_SOUND(src, S)

/client/proc/playtitlemusic(vol = 85)
	set waitfor = FALSE
	UNTIL(SSticker.login_music_done) //wait for SSticker init to set the login music // monkestation edit: fix-lobby-music
	UNTIL(fully_created)
	if("[CHANNEL_LOBBYMUSIC]" in prefs.channel_volume)
		if(prefs.channel_volume["[CHANNEL_LOBBYMUSIC]"] != 0)
			vol = prefs.channel_volume["[CHANNEL_LOBBYMUSIC]"]
			vol *= prefs.channel_volume["[CHANNEL_MASTER_VOLUME]"] * 0.01
	if((prefs && (!prefs.read_preference(/datum/preference/toggle/sound_lobby))) || CONFIG_GET(flag/disallow_title_music))
		return

	if(!media) ///media is set on creation thats weird
		media = new /datum/media_manager(src)
		media.open()
		media.update_music()
	media.lobby_music = TRUE

	if(!length(SSmedia_tracks.lobby_tracks))
		return

	if(SSmedia_tracks.first_lobby_play)
		SSmedia_tracks.current_lobby_track = pick(SSmedia_tracks.lobby_tracks)
		// monkestation edit start: fix-lobby-music
		if (fexists("data/last_round_lobby_music.txt"))
			fdel("data/last_round_lobby_music.txt")
		text2file(SSmedia_tracks.current_lobby_track.url, "data/last_round_lobby_music.txt")
		// monkestation edit end
		SSmedia_tracks.first_lobby_play = FALSE

	var/datum/media_track/T = SSmedia_tracks.current_lobby_track
	media.push_music(T.url, world.time, 1)
	media.update_volume(vol) // this makes it easier if we modify volume later on
	to_chat(src,"<span class='notice'>Lobby music: <b>[T.title]</b> by <b>[T.artist]</b>.</span>")

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if (SFX_SHATTER)
				soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
			if (SFX_EXPLOSION)
				soundin = pick('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')
			if (SFX_EXPLOSION_CREAKING)
				soundin = pick('sound/effects/explosioncreak1.ogg', 'sound/effects/explosioncreak2.ogg')
			if (SFX_HULL_CREAKING)
				soundin = pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg')
			if (SFX_SPARKS)
				soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if (SFX_RUSTLE)
				soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if (SFX_BODYFALL)
				soundin = pick('sound/effects/bodyfall1.ogg','sound/effects/bodyfall2.ogg','sound/effects/bodyfall3.ogg','sound/effects/bodyfall4.ogg')
			if (SFX_PUNCH)
				soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if (SFX_CLOWN_STEP)
				soundin = pick('sound/effects/footstep/clownstep1.ogg','sound/effects/footstep/clownstep2.ogg')
			if (SFX_SUIT_STEP)
				soundin = pick('sound/effects/suitstep1.ogg','sound/effects/suitstep2.ogg')
			if (SFX_SWING_HIT)
				soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if (SFX_HISS)
				soundin = pick('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
			if (SFX_PAGE_TURN)
				soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			if (SFX_RICOCHET)
				soundin = pick( 'sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg','sound/weapons/effects/ric3.ogg','sound/weapons/effects/ric4.ogg','sound/weapons/effects/ric5.ogg')
			if (SFX_TERMINAL_TYPE)
				soundin = pick(list(
					'sound/machines/terminal_button01.ogg',
					'sound/machines/terminal_button02.ogg',
					'sound/machines/terminal_button03.ogg',
					'sound/machines/terminal_button04.ogg',
					'sound/machines/terminal_button05.ogg',
					'sound/machines/terminal_button06.ogg',
					'sound/machines/terminal_button07.ogg',
					'sound/machines/terminal_button08.ogg',
				))
			if (SFX_DESECRATION)
				soundin = pick('sound/misc/desecration-01.ogg', 'sound/misc/desecration-02.ogg', 'sound/misc/desecration-03.ogg')
			if (SFX_IM_HERE)
				soundin = pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg')
			if (SFX_CAN_OPEN)
				soundin = pick('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
			if(SFX_BULLET_MISS)
				soundin = pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg')
			if(SFX_REVOLVER_SPIN)
				soundin = pick('sound/weapons/gun/revolver/spin1.ogg', 'sound/weapons/gun/revolver/spin2.ogg', 'sound/weapons/gun/revolver/spin3.ogg')
			if(SFX_LAW)
				soundin = pick(list(
					'sound/voice/beepsky/creep.ogg',
					'sound/voice/beepsky/god.ogg',
					'sound/voice/beepsky/iamthelaw.ogg',
					'sound/voice/beepsky/insult.ogg',
					'sound/voice/beepsky/radio.ogg',
					'sound/voice/beepsky/secureday.ogg',
				))
			if(SFX_HONKBOT_E)
				soundin = pick(list(
					'sound/effects/pray.ogg',
					'sound/effects/reee.ogg',
					'sound/items/AirHorn.ogg',
					'sound/items/AirHorn2.ogg',
					'sound/items/bikehorn.ogg',
					'sound/items/WEEOO1.ogg',
					'sound/machines/buzz-sigh.ogg',
					'sound/machines/ping.ogg',
					'sound/magic/Fireball.ogg',
					'sound/misc/sadtrombone.ogg',
					'sound/voice/beepsky/creep.ogg',
					'sound/voice/beepsky/iamthelaw.ogg',
					'sound/voice/hiss1.ogg',
					'sound/weapons/bladeslice.ogg',
					'sound/weapons/flashbang.ogg',
				))
			if("goose")
				soundin = pick('sound/creatures/goose1.ogg', 'sound/creatures/goose2.ogg', 'sound/creatures/goose3.ogg', 'sound/creatures/goose4.ogg')
			if(SFX_WARPSPEED)
				soundin = 'sound/runtime/hyperspace/hyperspace_begin.ogg'
			if(SFX_SM_CALM)
				soundin = pick(list(
					'sound/machines/sm/accent/normal/1.ogg',
					'sound/machines/sm/accent/normal/2.ogg',
					'sound/machines/sm/accent/normal/3.ogg',
					'sound/machines/sm/accent/normal/4.ogg',
					'sound/machines/sm/accent/normal/5.ogg',
					'sound/machines/sm/accent/normal/6.ogg',
					'sound/machines/sm/accent/normal/7.ogg',
					'sound/machines/sm/accent/normal/8.ogg',
					'sound/machines/sm/accent/normal/9.ogg',
					'sound/machines/sm/accent/normal/10.ogg',
					'sound/machines/sm/accent/normal/11.ogg',
					'sound/machines/sm/accent/normal/12.ogg',
					'sound/machines/sm/accent/normal/13.ogg',
					'sound/machines/sm/accent/normal/14.ogg',
					'sound/machines/sm/accent/normal/15.ogg',
					'sound/machines/sm/accent/normal/16.ogg',
					'sound/machines/sm/accent/normal/17.ogg',
					'sound/machines/sm/accent/normal/18.ogg',
					'sound/machines/sm/accent/normal/19.ogg',
					'sound/machines/sm/accent/normal/20.ogg',
					'sound/machines/sm/accent/normal/21.ogg',
					'sound/machines/sm/accent/normal/22.ogg',
					'sound/machines/sm/accent/normal/23.ogg',
					'sound/machines/sm/accent/normal/24.ogg',
					'sound/machines/sm/accent/normal/25.ogg',
					'sound/machines/sm/accent/normal/26.ogg',
					'sound/machines/sm/accent/normal/27.ogg',
					'sound/machines/sm/accent/normal/28.ogg',
					'sound/machines/sm/accent/normal/29.ogg',
					'sound/machines/sm/accent/normal/30.ogg',
					'sound/machines/sm/accent/normal/31.ogg',
					'sound/machines/sm/accent/normal/32.ogg',
					'sound/machines/sm/accent/normal/33.ogg',
				))
			if(SFX_SM_DELAM)
				soundin = pick(list(
					'sound/machines/sm/accent/delam/1.ogg',
					'sound/machines/sm/accent/delam/2.ogg',
					'sound/machines/sm/accent/delam/3.ogg',
					'sound/machines/sm/accent/delam/4.ogg',
					'sound/machines/sm/accent/delam/5.ogg',
					'sound/machines/sm/accent/delam/6.ogg',
					'sound/machines/sm/accent/delam/7.ogg',
					'sound/machines/sm/accent/delam/8.ogg',
					'sound/machines/sm/accent/delam/9.ogg',
					'sound/machines/sm/accent/delam/10.ogg',
					'sound/machines/sm/accent/delam/11.ogg',
					'sound/machines/sm/accent/delam/12.ogg',
					'sound/machines/sm/accent/delam/13.ogg',
					'sound/machines/sm/accent/delam/14.ogg',
					'sound/machines/sm/accent/delam/15.ogg',
					'sound/machines/sm/accent/delam/16.ogg',
					'sound/machines/sm/accent/delam/17.ogg',
					'sound/machines/sm/accent/delam/18.ogg',
					'sound/machines/sm/accent/delam/19.ogg',
					'sound/machines/sm/accent/delam/20.ogg',
					'sound/machines/sm/accent/delam/21.ogg',
					'sound/machines/sm/accent/delam/22.ogg',
					'sound/machines/sm/accent/delam/23.ogg',
					'sound/machines/sm/accent/delam/24.ogg',
					'sound/machines/sm/accent/delam/25.ogg',
					'sound/machines/sm/accent/delam/26.ogg',
					'sound/machines/sm/accent/delam/27.ogg',
					'sound/machines/sm/accent/delam/28.ogg',
					'sound/machines/sm/accent/delam/29.ogg',
					'sound/machines/sm/accent/delam/30.ogg',
					'sound/machines/sm/accent/delam/31.ogg',
					'sound/machines/sm/accent/delam/32.ogg',
					'sound/machines/sm/accent/delam/33.ogg',
				))
			if(SFX_HYPERTORUS_CALM)
				soundin = pick(list(
					'sound/machines/sm/accent/normal/1.ogg',
					'sound/machines/sm/accent/normal/2.ogg',
					'sound/machines/sm/accent/normal/3.ogg',
					'sound/machines/sm/accent/normal/4.ogg',
					'sound/machines/sm/accent/normal/5.ogg',
					'sound/machines/sm/accent/normal/6.ogg',
					'sound/machines/sm/accent/normal/7.ogg',
					'sound/machines/sm/accent/normal/8.ogg',
					'sound/machines/sm/accent/normal/9.ogg',
					'sound/machines/sm/accent/normal/10.ogg',
					'sound/machines/sm/accent/normal/11.ogg',
					'sound/machines/sm/accent/normal/12.ogg',
					'sound/machines/sm/accent/normal/13.ogg',
					'sound/machines/sm/accent/normal/14.ogg',
					'sound/machines/sm/accent/normal/15.ogg',
					'sound/machines/sm/accent/normal/16.ogg',
					'sound/machines/sm/accent/normal/17.ogg',
					'sound/machines/sm/accent/normal/18.ogg',
					'sound/machines/sm/accent/normal/19.ogg',
					'sound/machines/sm/accent/normal/20.ogg',
					'sound/machines/sm/accent/normal/21.ogg',
					'sound/machines/sm/accent/normal/22.ogg',
					'sound/machines/sm/accent/normal/23.ogg',
					'sound/machines/sm/accent/normal/24.ogg',
					'sound/machines/sm/accent/normal/25.ogg',
					'sound/machines/sm/accent/normal/26.ogg',
					'sound/machines/sm/accent/normal/27.ogg',
					'sound/machines/sm/accent/normal/28.ogg',
					'sound/machines/sm/accent/normal/29.ogg',
					'sound/machines/sm/accent/normal/30.ogg',
					'sound/machines/sm/accent/normal/31.ogg',
					'sound/machines/sm/accent/normal/32.ogg',
					'sound/machines/sm/accent/normal/33.ogg',
				))
			if(SFX_HYPERTORUS_MELTING)
				soundin = pick(list(
					'sound/machines/sm/accent/delam/1.ogg',
					'sound/machines/sm/accent/delam/2.ogg',
					'sound/machines/sm/accent/delam/3.ogg',
					'sound/machines/sm/accent/delam/4.ogg',
					'sound/machines/sm/accent/delam/5.ogg',
					'sound/machines/sm/accent/delam/6.ogg',
					'sound/machines/sm/accent/delam/7.ogg',
					'sound/machines/sm/accent/delam/8.ogg',
					'sound/machines/sm/accent/delam/9.ogg',
					'sound/machines/sm/accent/delam/10.ogg',
					'sound/machines/sm/accent/delam/11.ogg',
					'sound/machines/sm/accent/delam/12.ogg',
					'sound/machines/sm/accent/delam/13.ogg',
					'sound/machines/sm/accent/delam/14.ogg',
					'sound/machines/sm/accent/delam/15.ogg',
					'sound/machines/sm/accent/delam/16.ogg',
					'sound/machines/sm/accent/delam/17.ogg',
					'sound/machines/sm/accent/delam/18.ogg',
					'sound/machines/sm/accent/delam/19.ogg',
					'sound/machines/sm/accent/delam/20.ogg',
					'sound/machines/sm/accent/delam/21.ogg',
					'sound/machines/sm/accent/delam/22.ogg',
					'sound/machines/sm/accent/delam/23.ogg',
					'sound/machines/sm/accent/delam/24.ogg',
					'sound/machines/sm/accent/delam/25.ogg',
					'sound/machines/sm/accent/delam/26.ogg',
					'sound/machines/sm/accent/delam/27.ogg',
					'sound/machines/sm/accent/delam/28.ogg',
					'sound/machines/sm/accent/delam/29.ogg',
					'sound/machines/sm/accent/delam/30.ogg',
					'sound/machines/sm/accent/delam/31.ogg',
					'sound/machines/sm/accent/delam/32.ogg',
					'sound/machines/sm/accent/delam/33.ogg',
				))
			if(SFX_CRUNCHY_BUSH_WHACK)
				soundin = pick('sound/effects/crunchybushwhack1.ogg', 'sound/effects/crunchybushwhack2.ogg', 'sound/effects/crunchybushwhack3.ogg')
			if(SFX_TREE_CHOP)
				soundin = pick('sound/effects/treechop1.ogg', 'sound/effects/treechop2.ogg', 'sound/effects/treechop3.ogg')
			if(SFX_ROCK_TAP)
				soundin = pick('sound/effects/rocktap1.ogg', 'sound/effects/rocktap2.ogg', 'sound/effects/rocktap3.ogg')
			if(SFX_MUFFLED_SPEECH)
				soundin = pick(
					'sound/effects/muffspeech/muffspeech1.ogg',
					'sound/effects/muffspeech/muffspeech2.ogg',
					'sound/effects/muffspeech/muffspeech3.ogg',
					'sound/effects/muffspeech/muffspeech4.ogg',
					'sound/effects/muffspeech/muffspeech5.ogg',
					'sound/effects/muffspeech/muffspeech6.ogg',
					'sound/effects/muffspeech/muffspeech7.ogg',
					'sound/effects/muffspeech/muffspeech8.ogg',
					'sound/effects/muffspeech/muffspeech9.ogg',
				)
			// monkestation start: more sound effects
			if(SFX_BUTTON_CLICK)
				soundin = 'monkestation/sound/effects/hl2/button-click.ogg'
			if(SFX_BUTTON_FAIL)
				soundin = 'monkestation/sound/effects/hl2/button-fail.ogg'
			if(SFX_LIGHTSWITCH)
				soundin = 'monkestation/sound/effects/hl2/lightswitch.ogg'
			if(SFX_MEOW)
				if(prob(98))
					soundin = pick(
						'monkestation/sound/voice/feline/meow1.ogg',
						'monkestation/sound/voice/feline/meow2.ogg',
						'monkestation/sound/voice/feline/meow3.ogg',
						'monkestation/sound/voice/feline/meow4.ogg',
					)
				else
					soundin = pick(
						'monkestation/sound/voice/feline/mggaow.ogg',
						'monkestation/sound/voice/feline/funnymeow.ogg',
					)
			// monkestation end
	return soundin
