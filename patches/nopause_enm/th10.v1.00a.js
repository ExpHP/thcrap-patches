{
	"binhacks": {
		"nopause: Change EnemyManager::on_tick priority to below 0x0a": {
			"addr":     "0x40d317",
			"expected": "bf 12000000",
			"code":     "bf 07000000"
		},
		"nopause: Change Stage::on_tick priority to below 0x0a to retain background cues": {
			"addr":     "0x402379",
			"expected": "8d 7d 0c",
			"code":     "8d 7d 05",
			"COMMENT": "also uses priority 06"
		},
		"nopause: Change AnmManager::on_tick_world priority to below 0x0a to ensure enemies actually appear": {
			"addr":     "0x445b35",
			"expected": "bf 1a000000",
			"code":     "bf 09000000",
			"COMMENT": "clashes with AnmManager::on_tick_ui but it shouldn't matter.  Also unfortunately in MoF the pause blur is opaque so you'll need another patch for that..."
		}
	}
}
