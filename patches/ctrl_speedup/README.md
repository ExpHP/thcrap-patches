# `ctrl_speedup`

**Supports:** TH10-TH17 integer games.
**Partially supports:** TH128. (C key still speeds up though)

Makes CTRL speed up normal game play just like it does on replays.  Basically this just nops out an `if ReplayManager.is_in_playback_mode` test.

....well, okay, it has to do a bit more than that, because in TH13 and beyond, the Z and C keys speed up replays, so those features also needs to be disabled for the game to be playable.  It's all described in `binhacks.yaml`.
