{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x0b": {
			"addr":     "0x410614",
			"expected": "bb 14000000",
			"code":     "bb 06000000"
		},
		"nopause: Change Stage::on_tick priority to below 0x0b to retain background cues": {
			"addr":     "004035d2",
			"expected": "bb 0d000000",
			"code":     "bb 05000000"
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x0b to ensure enemies actually appear": {
			"addr":     "0x45d368",
			"expected": "8d 5d 1a",
			"code":     "8d 5d 04",
			"COMMENT": "3 + 4 = 7"
		}
	}
}
