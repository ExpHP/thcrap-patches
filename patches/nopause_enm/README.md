# `nopause_enm`

> **_ZA WAAAAARUDO!_**

Makes enemies continue to run even while the game is paused, producing giant waves of bullets when you unpause.  **Including the `nopauseblur` patch is recommended.**

**Supports TH11-TH17 and Double Spoiler**.  (future support for VD, GFW, and ISC is possible, I just haven't reversed them yet)

There is also partial support for TH10; however, that game is virtually unplayable because its pause blur is an opaque surface.

## How?

Touhou has a set of update functions that run each frame.  There's one for updating enemies, one for updating the player, one for navigating the Pause menu, etc.  Each one of these functions also has a number associated with it, called its **priority.**  The ones with lower priorities always run first.

One of these functions has the special responsibility of *preventing the rest of the functions after it from running* while the game is paused.  All this patch does is adjust the priorities of some update funcs to run before that special function.

(on that note, TH08 cannot be supported because the same update func that prevents things from running on pause (priority 0x02) is also the one that crucially prevents them from running while the stage is still being loaded!)
