# `ctrl-c` - Bringing back the C

In past Touhou games, `Ctrl` mapped to bit `0x200` in the input mask, while `C` mapped to `0x04`.  In TH17, *both* of these keys map to `0x200`.

This moves the C key back to `0x04`, so that it can be easily detected and used by other patches.

## How can I make use of this in my patch?

* [Priw8's ECLPlus](https://github.com/Priw8/ECLplus) includes an `INPUT` global exposing the input mask. (as well as plenty of functionality that may help you use pure ECL to accomplish whatever it is that you want the C key to do!)
* You could also make a binhack that looks at the input mask and does things.  The mask is stored at `0x4b3448`.  (and for those who are really lazy, I *think* `0x4b344c` is the previous frame input, `0x4b3454` is `cur & ~prev`, and `0x4b3458` is `prev & ~cur`).
