# `sprite_death_fix`

**Supports:** TH10. <br/>
*Can be easily adapted to add support for all STG titles TH10-TH17.*

Fixes crashes in games prior to DDC that occur when so many sprites are drawn in one frame that the sprite vertex buffer overflows.  It probably also fixes that thing that you see in later games where the screen goes black and only primitive shapes are drawn.  I dunno.

It does this by totally disabling ZUN's batch rendering for sprites and just drawing each one immediately after it's written into the vertex buffer.  I don't measure any notable performance drop from this.  (the batch rendering can be added back if later found to be necessary, it would just put the binhack code in a very cold path, making it harder to test and debug)
