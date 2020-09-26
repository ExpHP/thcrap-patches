# `bullet_cap`

**Supports:** TH10-TH12, TH125.

This patch can be used to increase or reduce the following caps:

* **Bullet cap** (2000 in all games TH10-TH17).
* **Laser cap** (256 in MoF, 512 in WBaWC).
* **Cancel item cap** (2048 in MoF, 4096 in WBaWC).

**By default, all three caps will be increased by a factor of 16.**

## Configuration

The limits can be configured by writing another thcrap patch to apply after this patch.  In that patch, you can put the the following in `<patch>/global.js` (or e.g. `<patch>/th11.v1.00a.js` to configure per-game):

```json
{"codecaves": {
    "bullet-cap": "00007d00",
    "laser-cap": "00001000",
    "cancel-cap": "00008000"
}}
```

The strings (which must contain 8 hexadecimal characters) are 4-byte integers encoded in **big-endian hexadecimal**.  The example value shown here is `0x7d00` bullets, `0x1000` lasers, and `0x8000` cancel items, which are the default settings in this patch for MoF.

### Additional options

Here are some additional options, with their default values.  As above, all strings must be zero-padded to the correct number of digits, and all integers are big endian hexadecimal.

```json
{"codecaves": {
    "bullet-cap-config.mof-sa-lag-spike-size": "00002000"
}}
```

* **`bullet-cap-config.mof-sa-lag-spike-size`**:  This patch automatically softens some quadratic lag spike behavior when canceling many bullets in MoF and SA.  You can configure the softening here; bigger number here = more lag. `"00000000"` will remove the lag spikes completely, while `"7fffffff"` will bring back the full vanilla behavior (but be prepared to wait several minutes if you cancel 50k+ bullets at once!).

---

## How does it work?

*Hoo boy.*  So, basically, bullets are stored in a big array on one of the game's global objects.  Because the array is in the middle of the object (and the object is used for other purposes), we can't just easily e.g. replace a pointer with our own allocation.  However, gererally speaking, there are only a small number of fields after the array. So......

Basically, this patch changes the size of that array by searching for and replacing a whole bunch of dword-sized values all over the program.  E.g. in SA it does a search and replace for the integer 2000, for the integer 2001, for the integer 0x46d678 (the size of the struct with the array), for the integer 0x46d216 (the offset where a sentinel value is written that marks the final array entry), and etc.

*Astonishingly,* this works.

Granted, obviously, not every instance of the number 2000 is related to bullet cap (though the *vast majority* of them are), so there are also blacklists of addresses not to replace.

## `bullet_cap` breaks my patch!

This patch can potentially break other patches if they contain a binhack whose new code *incidentally* contains a copy of one of the values replaced by this patch.  If this happens to you, [leave an issue](https://github.com/ExpHP/thcrap-patches/issues/new) and we can try to work something out.  (please do not try to modify the blacklist from your patch if you are publishing to `thcrap_configure` as I may change its format in the future!)
