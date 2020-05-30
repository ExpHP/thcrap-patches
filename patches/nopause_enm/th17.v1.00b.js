{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x10": {
			"addr":     "0x41e61f",
			"expected": "6a 1b",
			"code":     "6a 0d"
		},
		"nopause: Change Stage::on_tick priority to below 0x10 to retain background cues": {
			"addr":     "0x409c21",
			"expected": "6a 12",
			"code":     "6a 0c",
			"comment":  "same as HelpManual but this should have no noticeable effect. Probably."
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x10 to ensure enemies actually appear": {
			"addr":     "0x471d5d",
			"expected": "6a 23",
			"code":     "6a 0f"
		}
	}
}
