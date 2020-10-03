# `bullet_cap`

**Supports:** TH10-TH13, TH125, TH128.

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

The strings (which must contain 8 hexadecimal characters) are 4-byte integers encoded in **big-endian hexadecimal**.  The example value shown here is `0x7d00` bullets, `0x1000` lasers, and `0x8000` cancel items, which are the default settings in this patch for MoF.  **NOTICE:** There are currently some technical limitations in specific games, due to how the compiler compiled various loops:

* Various games may crash if a cap is set to zero.
* In **TH13**, `bullet-cap` must be divisible by 5.
* In **TH13**, `cancel-cap` must be divisible by 4.

### Additional options

Here are some additional options, with their default values.  As above, all strings must be zero-padded to the correct number of digits, and all integers are big endian hexadecimal.

```json
{"codecaves": {
    "bullet-cap-config.anm-search-lag-spike-size": "00002000"
}}
```

* **`bullet-cap-config.anm-search-lag-spike-size`**:  This patch automatically softens some quadratic lag spike behavior when canceling many bullets in the following games: MoF, SA, TD (other games do not have the issue).  You can configure the softening here; bigger number here = more lag. `"00000000"` will remove the lag spikes completely, while `"7fffffff"` will bring back the full vanilla behavior (but be prepared to wait several minutes if you cancel 50k+ bullets at once!).<br>
  *Compatability note: This option was previously named `bullet-cap-config.mof-sa-lag-spike-size`. This old name is still supported for backwards compatibility but is deprecated.*

---

## How does it work?

*Hoo boy.*  So, basically, bullets are stored in a big array on one of the game's global objects.  Because the array is in the middle of the object (and the object is used for other purposes), we can't just easily e.g. replace a pointer with our own allocation.  However, gererally speaking, there are only a small number of fields after the array. So......

Basically, this patch changes the size of that array by searching for and replacing a whole bunch of dword-sized values all over the program.  E.g. in SA it does a search and replace for the integer 2000, for the integer 2001, for the integer 0x46d678 (the size of the struct with the array), for the integer 0x46d216 (the offset where a sentinel value is written that marks the final array entry), and etc.

*Astonishingly,* this works.

Granted, obviously, not every instance of the number 2000 is related to bullet cap (though the *vast majority* of them are), so there are also blacklists of addresses not to replace.

## `bullet_cap` breaks my patch!

This patch can potentially break other patches if they contain a binhack whose new code *incidentally* contains a copy of one of the values replaced by this patch.  If this happens to you, [leave an issue](https://github.com/ExpHP/thcrap-patches/issues/new) and we can try to work something out.  (please do not try to modify the blacklist from your patch if you are publishing to `thcrap_configure` as I may change its format in the future!)

## GFW has huge lag spikes when I freeze many bullets!

Correct.

## My patch needs to know the bullet cap.  How can it be made compatible with `bullet_cap`?

**`bullet_cap` promises to preserve the location of&em;and modify the value of&em;any integer in the code whose value represents something related to a cap. (unless it also depends on the size of each array element)**

In other words, the recommended way to get the current bullet cap is to read the value (or a number related to it) from anywhere it appears in the code.  *Note that must be done at some point **after** the bullet-manager global has been initialized while starting a new game, to ensure that `bullet_cap` has had a chance to apply all of its changes.*

Some examples, looking at Imperishable Night 1.02d:
* The laser cap could be found at `0x430f79` in the function that spawns a laser:
  ```
  00430f76  817dfc00010000     cmp     dword [ebp-0x4], 0x100
  00430f7d  0f8d13020000       jge     0x431196
  ```
* Here, at `0x42f442`, you can find a value of `0x601` that is meant to represent the bullet cap plus 1.  You can use this!  Simply read this address and then subtract one.
  ```
  0042f43c  6800f54200         push    Bullet::constructor
  0042f441  6801060000         push    0x601
  0042f446  68b8100000         push    0x10b8
  ```

And for some examples of what **not** to use, from the same game:
* Here at `0x4aef84`, this appearance of the number `0x100` is not at all related to the laser cap, so you should not use it.
  ```
  004aef83  0d00010000         or      eax, 0x100
  ```
* Here at `0x42f36b` is the value `0x1ae95e`, the size of the BulletManager struct measured in dwords.  Because this structure holds the bullet array, this value technically depends on the bullet cap.  However, it also depends on the size of each bullet, and therefore, `bullet_cap` makes no guarantees about the value at this address and you should not rely on it.
  ```
  0042f36a  b95ee91a00         mov     ecx, 0x1ae95e
  0042f36f  33c0               xor     eax, eax
  0042f371  8b7df4             mov     edi, dword [ebp-0xc]
  0042f374  f3ab               rep stosd dword [edi]
  ```
