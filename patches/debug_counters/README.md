# `debug_counters`

**Supports:** TH10

Adds debug counters so you can see how much your dank memes are tormenting the game

![Debug counters example image](https://raw.githubusercontent.com/ExpHP/thcrap-patches/master/patches/debug_counters/debug-counters.png)

Legend:

* `itemN`: Number of normal items onscreen.
* `itemC`: Number of cancel items onscreen (includes season items in TH16).  These have their own count because they live in a separate, *significantly larger* array.
* `laser`: Number of lasers.
* `etama`: Number of bullets.
* `anmid`: Number of automatically-managed ANM VMs.  This counts certain types of sprites that the game refers to by ID rather than storing them directly on a game object.

The numbers are colored orange when within 75% of maximum capacity, and red when they hit the max.  (`anmid` doesn't really have a maximum, but it is colored red when the count exceeds the length of the "fast VM" array, which is expected to impact performance).
