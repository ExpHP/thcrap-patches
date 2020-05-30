{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x0f": {
			"addr":     "0x41af3a",
			"expected": "6a 1a",
			"code":     "6a 0d"
		},
		"nopause: Change Stage::on_tick priority to below 0x0f to retain background cues": {
			"addr":     "0x4098da",
			"expected": "6a 11",
			"code":     "6a 0c"
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x0f to ensure enemies actually appear": {
			"addr":     "0x46a6e1",
			"expected": "6a 21",
			"code":     "6a 0e"
		}
	}
}
