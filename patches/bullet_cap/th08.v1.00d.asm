; AUTO_PREFIX: ExpHP.bullet-cap.

%include "util.asm"
%include "common.asm"

; Address range spanned by .text
address_range:  ; HEADER: AUTO
    dd 0x401000
    dd 0x4b3b78

bullet_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x600
    at ListHeader.elem_size, dd 0x10b8
iend
    dd 0x600
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x00423a9c
    dd 0x00423e5c
    dd 0x0042421c
    dd 0x00424a54
    dd 0x00424c74
    dd 0x00424e8c
    dd 0x0042510c
    dd 0x0042520e
    dd 0x004252d3
    dd 0x0042f3c8
    dd 0x0042f623
    dd 0x0042f665
    dd 0x00430862
    dd 0x00430ae6
    dd 0x00430d73
    dd 0x00430e3e
    dd 0x004312aa
    dd WHITELIST_END

    dd 0x601
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x42f442
    dd WHITELIST_END

    ; something wierd in BulletManager::on_tick where it needs to wrap, idfk why
    dd 0x645000  ; offset of dummy bullet in bullet array
    dd SCALE_SIZE
    dd WHITELIST_BEGIN
    dd 0x431b5a
    dd WHITELIST_END

    dd 0x5ff  ; index of last bullet in bullet array
    dd SCALE_1
    dd WHITELIST_BEGIN
    dd 0x431b51
    dd WHITELIST_END

    ; No need to adjust field offsets because we use binhacks to replace the
    ; embedded array with a pointer.

    dd LIST_END

laser_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x100
    at ListHeader.elem_size, dd 0x59c
iend
    dd LIST_END

cancel_replacements:  ; HEADER: AUTO
istruc ListHeader
    at ListHeader.old_cap, dd 0x830
    at ListHeader.elem_size, dd 0x2e4
iend
    dd LIST_END

perf_fix_data:  ; HEADER: AUTO
    dd 0  ; irrelevant, this game has no VM lists

iat_funcs:  ; HEADER: AUTO
.GetLastError: dd 0x4b4074
.GetModuleHandleA: dd 0x4b40e0
.GetModuleHandleW: dd 0
.GetProcAddress: dd 0x4b40d8
.MessageBoxA: dd 0x4b41e8
