{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x0a": {
			"addr":     "0x410c71",
			"expected": "bb 12000000",
			"code":     "bb 06000000"
		},
		"nopause: Change Stage::on_tick priority to below 0x0a to retain background cues": {
			"addr":     "0x402612",
			"expected": "bb 0c000000",
			"code":     "bb 05000000"
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x0a to ensure enemies actually appear": {
			"addr":     "0x4528aa",
			"expected": "8d 5d 17",
			"code":     "8d 5d 04",
			"COMMENT": "3 + 4 = 7"
		}
	}
}
