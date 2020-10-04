# `base_exphp`

This patch can be used to support `bullet-cap` without directly depending on it.  It defines the following codecaves:

* `codecave:base-exphp.adjust-bullet-array`
* `codecave:base-exphp.adjust-laser-array`
* `codecave:base-exphp.adjust-cancel-array`

These three codecaves define functions that take an address to where the game would normally have put an array, and tells you where the array can actually be found.  The default definitions here are the identity function, but `bullet_cap` redefines some of them in some games where it relocates the array. (notably pre-PoFV games)

Calling convention:

```
__stdcall Bullet* AdjustBulletArray(Bullet* old_array_location);
__stdcall Item* AdjustCancelArray(Item* old_array_location);
__stdcall Laser* AdjustLaserArray(Laser* old_array_location);
```

For your convenience they additionally preserve the values of the volatile `ecx` and `edx` registers (so that all general-purpose integer registers other than `eax` are preserved).
