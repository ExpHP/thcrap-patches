# `debug_counters`

**Supports:** TH10-TH17 (incl. point titles).

Adds debug counters so you can see how much your dank memes are tormenting the game

![Debug counters example image](https://raw.githubusercontent.com/ExpHP/thcrap-patches/master/patches/debug_counters/debug-counters.png)

Legend:

* `itemN`: Number of normal items onscreen.
* `itemC`: Number of cancel items onscreen (includes season items in TH16).  These have their own count because they live in a separate, *significantly larger* array.
* `laser`: Number of lasers onscreen.
* `etama`: Number of bullets onscreen.
* `anmid`: Number of automatically-managed ANM VMs.  This counts certain types of sprites that the game refers to by ID rather than storing them directly on a game object.
* `lgods`: (TH13) Number of divine spirits onscreen.

The numbers are colored orange when within 75% of maximum capacity, and red when they hit the max.  (`anmid` doesn't really have a maximum, but it is colored red when the count exceeds the length of the "fast VM" array, which is expected to impact performance).

## Notice about performance

If you really want accurate performance data, then be aware that using this patch MIGHT decrease your performance if you're using e.g. a really high bullet cap. Or... it might not impact performance at all.  It is difficult to quantify.

Basically, this patch needs to iterate over some of the game's data structures in order to count living entries.  Of course, the game already iterates over these arrays on every frame, but doing it a second time certainly doesn't help due to the additional cache misses.  When I profiled with the game unpaused at 35k bullets, this patch was found to account for 8.5% of CPU time on my system.  That said, CPU time does not translate straightforwardly to framerate.  YMMV.
