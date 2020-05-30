{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x0b": {
			"addr":     "0x4223c3",
			"expected": "6a 15",
			"code":     "6a 06"
		},
		"nopause: Change Stage::on_tick priority to below 0x0b to retain background cues": {
			"addr":     "0x40d513",
			"expected": "6a 0d",
			"code":     "6a 05"
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x0b to ensure enemies actually appear": {
			"addr":     "0x47aa58",
			"expected": "6a 1d",
			"code":     "6a 07"
		}
	}
}
