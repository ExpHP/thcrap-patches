# `bullet_cap`

**Supports:** TH10, TH11.

This patch can be used to increase or reduce the bullet cap (which defaults to 2000 in most games).

**This patch does not currently affect lasers, which have their own cap.**

## Configuration

**By default, the patch sets the bullet cap to 4000,** which is double its size in most games.

You can configure this further in a downstream thcrap patch by having the following in `<patch>/global.js`:

```json
{
    "codecaves": {
        "bullet-cap": "00000fa0"
    }
}
```

The string (which must contain 8 hexadecimal characters) is a 4-byte integer encoded in **big-endian hexadecimal**.  The example value shown here is `0xfa0`, i.e. the default setting of 4000.

To configure this on a per-game basis, you can put this in e.g. `<patch>/th11.v1.00a.js` instead.

---

## How does it work?

*Hoo boy.*  So, basically, bullets are stored in a big array on one of the game's global objects.  Because the array is in the middle of the object (and the object is used for other purposes), we can't just easily e.g. replace a pointer with our own allocation.  However, gererally speaking, there are only a small number of fields after the array. So......

Basically, this patch changes the size of that array by searching for and replacing a whole bunch of dword-sized values all over the program.  E.g. in SA it does a search and replace for the integer 2000, for the integer 2001, for the integer 0x46d678 (the size of the struct with the array), for the integer 0x46d216 (the offset where a sentinel value is written that marks the final array entry), and etc.

*Astonishingly,* this works.

Granted, obviously, not every instance of the number 2000 is related to bullet cap (though the *vast majority* of them are), so there are also blacklists of addresses not to replace.

## `bullet_cap` breaks my patch!

This patch can potentially break other patches if they contain a binhack whose new code *incidentally* contains a copy of one of the values replaced by this patch.  If this happens to you, [leave an issue](https://github.com/ExpHP/thcrap-patches/issues/new) and we can try to work something out.  (please do not try to modify the blacklist from your patch if you are publishing to `thcrap_configure` as I may change its format in the future!)
