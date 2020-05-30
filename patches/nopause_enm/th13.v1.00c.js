{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x0b": {
			"addr":     "0x418880",
			"expected": "bb 15000000",
			"code":     "bb 06000000"
		},
		"nopause: Change Stage::on_tick priority to below 0x0b to retain background cues": {
			"addr":     "0x406250",
			"expected": "bb 0d000000",
			"code":     "bb 05000000"
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x0b to ensure enemies actually appear": {
			"addr":     "0x46be89",
			"expected": "8d 59 1d",
			"code":     "8d 59 07"
		}
	}
}
