# `bullet_cap`

**Supports:** TH10, TH11, TH12.

This patch can be used to increase or reduce the following caps:

* Bullet cap (which is 2000 in all games TH10-TH17).
* Laser cap (which is either 256 or 512 in all games since TH10).
* Cancel item cap (which is either 2048 or 4096 in all games since TH10).

**By default, all three caps will be increased by a factor of 16.**

## Configuration

The limits can be configured by writing another thcrap patch to apply after this patch.  In that patch, you can put the the following in `<patch>/global.js`:

```json
{"codecaves": {
    "bullet-cap": "00007d00",
    "laser-cap": "00001000",
    "cancel-cap": "00008000"
}}
```

The strings (which must contain 8 hexadecimal characters) are 4-byte integers encoded in **big-endian hexadecimal**.  The example value shown here is `0x7d00` bullets, `0x1000` lasers, and `0x8000` cancel items, which are the default settings in this patch for MoF.

To configure this on a per-game basis, you can put this in e.g. `<patch>/th11.v1.00a.js` instead.

---

## How does it work?

*Hoo boy.*  So, basically, bullets are stored in a big array on one of the game's global objects.  Because the array is in the middle of the object (and the object is used for other purposes), we can't just easily e.g. replace a pointer with our own allocation.  However, gererally speaking, there are only a small number of fields after the array. So......

Basically, this patch changes the size of that array by searching for and replacing a whole bunch of dword-sized values all over the program.  E.g. in SA it does a search and replace for the integer 2000, for the integer 2001, for the integer 0x46d678 (the size of the struct with the array), for the integer 0x46d216 (the offset where a sentinel value is written that marks the final array entry), and etc.

*Astonishingly,* this works.

Granted, obviously, not every instance of the number 2000 is related to bullet cap (though the *vast majority* of them are), so there are also blacklists of addresses not to replace.

## `bullet_cap` breaks my patch!

This patch can potentially break other patches if they contain a binhack whose new code *incidentally* contains a copy of one of the values replaced by this patch.  If this happens to you, [leave an issue](https://github.com/ExpHP/thcrap-patches/issues/new) and we can try to work something out.  (please do not try to modify the blacklist from your patch if you are publishing to `thcrap_configure` as I may change its format in the future!)

## I canceled 50000 bullets at once and the game froze

That sounds like a "you" problem.

...but seriously, go grab a cup of tea and wait a few minutes, the game's not frozen.  I did look into why this happens and I might be able to slip in a simple performance "cure" for it later.
