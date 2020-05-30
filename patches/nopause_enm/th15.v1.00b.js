{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x0f": {
			"addr":     "0x426523",
			"expected": "6a 1a",
			"code":     "6a 0d"
		},
		"nopause: Change Stage::on_tick priority to below 0x0f to retain background cues": {
			"addr":     "0x40e0fc",
			"expected": "6a 11",
			"code":     "6a 0c"
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x0f to ensure enemies actually appear": {
			"addr":     "0x483446",
			"expected": "6a 22",
			"code":     "6a 0e"
		}
	}
}
