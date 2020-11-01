# `sprite_death_fix`

**Supports:** All STGs TH06-TH17.<br/>
**Notice:** *PoFV and StB are not fully tested (I need to port `bullet_cap` to test them!).*

Fixes crashes in games prior to DDC that occur when so many sprites are drawn in one frame.  Also fixes that thing that happens in DDC and later where the screen can go black except for a few borders and gradients.

---

Basically, these crashes are due to how the game implements batch rendering for sprites.  When sprites are drawn, their vertices are simply written to a large vertex buffer.  Whenever the game needs to change a property on the Direct3D device, it flushes this buffer in a call to `IDirect3DDevice9::DrawPrimitiveUP`.  For some reason, after flushing, it doesn't reset the pointers back to the beginning of the buffer; it only does this at the beginning of each frame.  So if enough sprites are drawn in one frame, the game will attempt to write a sprite outside the buffer and crash.

(Games from DDC onwards don't crash simply because they do a bounds check beforehand; however, in that case they draw nothing, which leads to a black screen when none of the VMs for the back buffer get drawn)

This patch fixes the bug by doing a bounds check before writing in games that don't, then flushing *and* resetting the pointers if the sprite wouldn't fit.
