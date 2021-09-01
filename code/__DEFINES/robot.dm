// Silicon Defines (/mob/living/silicon)

/// TODO: comment
#define MAIN_CHANNEL "Main Frequency"


// Robot Defines (/mob/living/silicon/robot)

// Flags for a robot's [cover_flags][/mob/living/silicon/robot/var/cover_flags] variable.
/// Determines if the cyborg's cover is locked.
#define LOCKED (1<<0)
/// Determines if the cyborg's cover is opened.
#define OPENED (1<<1)
/// Determines if the cyborg's wires are exposed.
#define WIRES_EXPOSED (1<<3)
/// Determines if the cyborg can lock it's own cover.
#define SELF_LOCKABLE (1<<4)

// Flags for a robot's [protection_flags][/mob/living/silicon/robot/var/protection_flags] variable.
/// Makes cyborgs immune to EMPs.
#define EMP_PROOF (1<<0)
/// Makes cyborgs immune to getting emagged.
#define EMAG_PROOF (1<<1)
/// makes cyborgs immune to both flashes and the visual portion of flashbangs.
#define FLASH_PROOF (1<<2)
/// Makes cybrogs immune to the sound portion of flashbangs.
#define FLASHBANG_SOUND_PROOF (1<<3)

// Defines for the [notify_ai][/mob/living/silicon/robot/proc/notify_ai] proc.
/// Notifes the AI that a new cyborg was linked to them.
#define NOTIFY_NEW_CYBORG 1
/// Notifes the AI that one of their cyborg's chose a new module.
#define NOTIFY_MODULE_CHOSEN 2
/// Notifes the AI that one of their cyborg's had a name change.
#define NOTIFY_NEW_NAME 3
