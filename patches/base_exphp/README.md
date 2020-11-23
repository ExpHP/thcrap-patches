# `base_exphp`

Patch for supporting `bullet_cap` without depending on it.

`bullet_cap` is a fairly hefty patch with numerous dependencies, and which applies a very large number of binhacks.  And yet, it's exactly the kind of patch that is intended to be used together with other patches.  Thus, it may be desirable for a patch to support bullet_cap when it is installed, yet continue to work when bullet_cap is not installed.

This patch provides functions (in the form of thcrap codecaves) for locating fields on structs that may have been moved by `bullet_cap`.  When `bullet_cap` is not installed, these functions use trivial default implementations that reflect the behavior of the vanilla game.

**NOTE:** For your convenience, **all functions documented here preserve the values of the volatile `ecx` and `edx` registers** in addition to the requirements of the `__stdcall` ABI (so that all general-purpose integer registers other than `eax` are preserved).

# Functions

## `codecave:base-exphp.adjust-field-ptr`

Obtain the true location of a field in a global struct, given the location where you would expect to find it in the vanilla game.

```C++
void* __stdcall AdjustFieldPtr(StructId what, void* field_ptr, void* struct_base)
```

**Arguments:**

* `what`: a [`StructId`](#struct-id) indicating which struct the field belongs to. (e.g. BulletManager, ItemManager...)
* `field_ptr`: a pointer to where the desired field would normally exist on the struct, given its base address.  `field_ptr` must point to somewhere within the range from `struct_base` to `struct_base + original_struct_size`.  This range is doubly-inclusive (i.e. the pointer is permitted to point just past the end of the struct). If `field_ptr` points into an array resized by `bullet_cap`, then it must point to somewhere inside (not past the end of!) either the first or last element of the array.
* `struct_base`: the current base address of the struct.

`field_ptr` is listed before `struct_base` in the signature because it is generally easier to supply the arguments this way. (you can push the base pointer, add the field offset, and push again)

The output of the function is where the field actually lives.

### Examples

In modern games, the most frequently used field of BulletManager is its pointer to `bullet.anm`.  `bullet_cap`'s resizing of the bullet array causes this field to move, but using `codecave:base-exphp.adjust-field-ptr` you can find it.

```
Example: Getting the pointer to bullet.anm on BulletManager in TH16.
Typically the game accesses this as [[0x4a6dac] + 0x1403b24].
Here, [0x4a6dac] is the base of the BulletManager struct.

ASSEMBLY                   THCRAP HEX STRING
mov  eax, [0x4a6dac]       a1ac6d4a00
push eax                   50
add  eax, 0x1403b24        05243b4001
push eax                   50
push 0x100                 6800010000
call adjust_field_ptr      e8[codecave:base-exphp.adjust-field-ptr]
```

The last bullet in the bullet array is always a dummy entry, with a sentinel value for its state field.  For instance, the instruction at `th08.exe+0x2f38a` sets such a field.  `bullet_cap` both resizes this array and moves this array behind a pointer, making it difficult to locate normally. However, because this field is on the last entry of the array, it is a valid argument for `field_ptr`:

```
Example: Setting the dummy bullet state in TH08.
Normally this would be at [0xf54e90 + 0x660638].

ASSEMBLY                   THCRAP HEX STRING
mov  eax, 0xf54e90         b8904ef500
push eax                   50
add  eax, 0x660638         0538066600
push eax                   50
push 0x100                 6800010000
call adjust_field_ptr      e8[codecave:base-exphp.adjust-field-ptr]
mov  word [eax], 0x6       66c7000600
```

# Older functions

## `codecave:base-exphp.adjust-*-array`

* `codecave:base-exphp.adjust-bullet-array`
* `codecave:base-exphp.adjust-laser-array`
* `codecave:base-exphp.adjust-cancel-array`

These three codecaves are old, special cases of `codecave:base-exphp.adjust-field-ptr`.  Given what would originally be the address of the bullet array, laser array, or cancel item array, they return the true address of the array.  The purpose is to handle pre-PoFV games where these arrays are relocated behind pointers by `bullet_cap`.  This only handles the primary array on each type (e.g. in LoLK it is valid to use this on the main bullet array, but not on the pointdevice snapshot bullet array).

`codecave:base-exphp.adjust-field-ptr` is much more general and should generally be preferred.

Calling convention:

```C++
Bullet* __stdcall AdjustBulletArray(Bullet* old_array_location);
Item* __stdcall AdjustCancelArray(Item* old_array_location);
Laser* __stdcall AdjustLaserArray(Laser* old_array_location);
```

# Special constants

## <span id="struct-id">StructId constants</span>

`StructId` is a dword-sized enumeration type identifying a global struct that is modified by `bullet_cap`.  Here are its values:

|  Value  |Name of struct in [th-re-data](https://github.com/exphp-share/th-re-data) | ZUN's name (if known) | Notes |
|  :---:  | :---: | :---: | :--- |
| `0x100` | `BulletManager` | `BulletInf` | Prior to StB, this also contains the laser array. (in StB onwards, they live in a linked list on another struct) |
| `0x101` | `ItemManager`   | `ItemInf`   | |

The constants mostly serve to identify the *type* of the global, not a specific global.  So e.g. in PoFV, the ID `0x100` is suitable for both of the two instances of `BulletManager`, and what differentiates them is the `struct_base` (which would be `[0x4a7d98]` for Player 1 and `[0x4a7dd0]` for Player 2).
