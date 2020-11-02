{
	"contact": "diagonaldevice@gmail.com",
	"id": "ExpHP",
	"patches": {
		"anm_leak": "(15-17) Fixes TH16's crashes on large releases, and adds some related performance improvements.",
		"base_exphp": "Provides functions that help other patches support patches like bullet_cap without directly depending on them.",
		"bullet_cap": "(07-08, 10-17 STGs) Makes the bullet cap, laser cap, and cancel cap configurable.\nDefaults to 16x everything. To configure, see http://exphp.github.io/thpages/#/mods/bullet-cap",
		"c_key": "(17) Make Ctrl and C behave as separate keys internally, for use by other patches. (C maps to 0x4)",
		"continue": "(10-12) Fixes the continue system. plz don't save cursed 3cc replays kthx",
		"ctrl_speedup": "(10-17, 128) Makes Ctrl to speedup work outside of replays.",
		"debug_counters": "(06-17 STGs) Show sprite, bullet, laser, enemy, and item counts.",
		"free_release": "(16) Makes season releases not consume season power. (Request.)",
		"nopause_enm": "(11-17, 125) a.k.a. the Za Warudo mod.  Enemies don't stop when you pause.  nopauseblur recommended where available.",
		"nopauseblur": "(15-17, 165) Disables blur on pause.  Not available yet for DDC and earlier due to technical difficulties.",
		"sp_resources": "(13, 14, 16, 17) Spell practice with lives, bombs and Max Season",
		"sprite_death_fix": "(06-08, 10-17 STGs) Fixes crashes and black screens from drawing too many sprites.",
		"subseason_doyou": "(16) Use Dog Days subseason outside of the Extra stage. (Not required to watch replays)",
		"subseason_fall": "(16) Use Fall subseason, even in Extra stage. (Not required to watch replays)",
		"subseason_spring": "(16) Use Spring subseason, even in Extra stage. (Not required to watch replays)",
		"subseason_summer": "(16) Use Summer subseason, even in Extra stage. (Not required to watch replays)",
		"subseason_winter": "(16) Use Winter subseason, even in Extra stage. (Not required to watch replays)"
	},
	"servers": [
		"https://raw.githubusercontent.com/ExpHP/thcrap-patches/master/patches/"
	],
	"title": "Patches by ExpHP"
}
