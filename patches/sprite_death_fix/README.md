# `sprite_death_fix`

**Supports:** TH10. <br/>
*Can be easily adapted to add support for all STG titles TH10-TH17.*

Fixes crashes in games prior to DDC that occur when so many sprites are drawn in one frame.  It probably also fixes that thing that you see in later games where the screen can go black except for a few borders and gradients.  I dunno.

---

Basically, these crashes are due to how the game implements batch rendering for sprites.  When sprites are drawn, their vertices are simply written to a large vertex buffer.  Whenever the game needs to change a property on the Direct3D device, it flushes this buffer in a call to `IDirect3DDevice9::DrawPrimitiveUP`.  For some reason, after flushing, it doesn't reset the pointers back to the beginning of the buffer; it only does this at the beginning of each frame.  So if enough sprites are drawn in one frame, the game will attempt to write a sprite outside the buffer and crash.  (Games from DDC onwards don't crash simply because they do a bounds check beforehand)

This patch fixes the bug by doing a bounds check before writing in games that don't, then flushing *and* resetting the pointers if the sprite wouldn't fit.
