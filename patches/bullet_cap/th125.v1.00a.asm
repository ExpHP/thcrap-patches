; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x496305

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x7d0
    at ListHeader.elem_size, dd 0xa34
iend
    dd 0x7d0
    dd SCALE_1
    dd BLACKLIST_BEGIN
    dd 0x4398f9 - 4  ; unknown
    dd 0x463ca7 - 4  ; weird, possibly unused function
    dd 0x4734de + 2  ; coincidental appearance in a jump
    dd BLACKLIST_END

    dd 0x7d1
    dd SCALE_1
    dd REPLACE_ALL

    dd 0x4fbbb6  ; offset of dummy bullet state
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x4fc0d8  ; offset of bullet.anm
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x4fc0dc  ; size of bullet manager
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x4fc074  ; size of bullet array
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0
iend
    dd 0x100
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x420411 - 4  ; LaserManager::allocate_new_laser
    ; The rest are inlined calls to the above function.
    ; Find them via crossrefs to the Laser subclass constructors, as well as crossrefs to
    ; the subclass vtables in case a constructor was inlined.
    dd 0x422466 - 4
    dd 0x422f32 - 4
    dd 0x4240c0 - 4
    dd 0x424b59 - 4
    dd 0x4276fe - 4
    dd WHITELIST_END
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0xc8
    at ListHeader.elem_size, dd 0x4f4
iend
    dd 0xc8
    dd SCALE_1
    dd WHITELIST_BEGIN
    ; (to find these I searched for 0x4f4 to find item loops...)
    dd 0x41f04f - 4
    dd 0x41fa3e - 4
    dd 0x41fa6a - 4
    dd 0x41fa82 - 4
    dd 0x41f882 - 4
    dd 0x41f40a - 4
    dd 0x41f320 - 4
    dd 0x41f28e - 4
    dd 0x495b0a - 4
    dd WHITELIST_END

    ; offsets of fields after array
    dd 0x3deb4  ; next cancel item index
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x3deb8  ; num items alive
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x3debc  ; cancel camera charge multiplier
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x3dec0  ; on_tick  (why is it here in this game?
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x3dec4  ; on_draw  (why is it here in this game?)
    dd SCALE_SIZE
    dd REPLACE_ALL
    dd 0x3dec8  ; struct size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd 0x3dea0  ; array size
    dd SCALE_SIZE
    dd REPLACE_ALL

    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; unused

iat_funcs:  ; HEADER: ExpHP.bullet-cap.iat-funcs
.GetLastError: dd 0x4971c8
.GetModuleHandleA: dd 0
.GetModuleHandleW: dd 0x497178
.GetProcAddress: dd 0x4970ec
