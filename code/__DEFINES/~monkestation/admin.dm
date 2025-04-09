///Sends all admins the chosen sound
#define SEND_ADMINS_NOTFICATION_SOUND(sound_to_play) for(var/client/X in GLOB.admins){X << sound(sound_to_play);}
///Sends a message in adminchat
#define SEND_ADMINCHAT_MESSAGE(message) to_chat(GLOB.admins, type = MESSAGE_TYPE_ADMINCHAT, html = message, confidential = TRUE)
///Sends a message in adminchat with the chosen notfication sound
#define SEND_NOTFIED_ADMIN_MESSAGE(sound, message) SEND_ADMINS_NOTFICATION_SOUND(sound); SEND_ADMINCHAT_MESSAGE(message)

#define POLICY_DEATH			"Death"
#define POLICY_REVIVAL			"Revival"
#define POLICY_REVIVAL_CLONER	"Revival via Cloning"

#define AHELP_CLOSETYPE_CLOSE 0
#define AHELP_CLOSETYPE_REJECT 1
#define AHELP_CLOSETYPE_RESOLVE 2

#define AHELP_CLOSEREASON_NONE 0
#define AHELP_CLOSEREASON_IC 1
#define AHELP_CLOSEREASON_MENTOR 2

#define ADMIN_SUSINFO(user) "[ADMIN_LOOKUP(user)] [ADMIN_PP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"

// Command reports
#define DEFAULT_COMMANDREPORT_SOUND "default_commandreport"
#define DEFAULT_ALERT_SOUND "default_alert"
#define CUSTOM_ALERT_SOUND "custom_alert"
