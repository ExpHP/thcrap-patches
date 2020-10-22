; Push several things.
%macro multipush  0-*.nolist
    %rep  %0
        push    %1
        %rotate 1
    %endrep
%endmacro

; Pop several things, in reverse order.
%macro multipop  0-*.nolist
    %rep %0 
        %rotate -1
        pop     %1
    %endrep 
%endmacro

; side-effect-free absolute jump
%macro abs_jmp_hack  1.nolist
    call %%next
%%next:
    mov dword [esp], %1
    ret
%endmacro

; Absolute call, clobbering eax.
;
; eax is almost universally a good choice since it's used for return values,
; but some functions from the ugly ABI era pass an argument in eax.
;
; (if this were x86-64, we could use the red zone, but it doesn't exist in x86)
%macro call_eax  1.nolist
    mov eax, %1
    call eax
%endmacro

%macro die  0.nolist
    push __LINE__
    int 3
%endmacro

%define SIGN_MASK 0x80000000

;================================================================
; Simple stack frame automation that just saves esi/edi.
;
; NOTE: These have been superceded by the func_* macros but are still used in older code.

; Create a stack frame and push esi and edi.  Clean up with epilogue_sd.
%macro prologue_sd  0.nolist
    push ebp
    mov  ebp, esp
    push esi
    push edi
%endmacro

; Create a stack frame, decrease the stack pointer by a specified number of bytes to create locals,
; and push esi and edi.  Clean up with epilogue_sd.
%macro prologue_sd  1.nolist
    push ebp
    mov  ebp, esp
    sub  esp, %1
    push esi
    push edi
%endmacro

; Clean up for prologue_sd.
%macro epilogue_sd  0.nolist
    pop  edi
    pop  esi
    mov  esp, ebp
    pop  ebp
%endmacro

;================================================================
; Automation of stack locals and stdcall returns.
;
; Yes, nasm has %arg and %local but:
;
; - They are only capable of creating globally scoped variables, leading to some of
;   the nastiest bugs to pin down (accidental reuse of an old variable when there is
;   a typo or omission in your arg list).  These support '%$name'.
; - %arg can't automate the stdcall 'ret N'.
;
; Usage:
;
;    func_begin          ; enables the use of the other macros
;    func_arg    %$x, %$y, %$z   ; these will be set to 'ebp+0x08', 'ebp+0x0c', 'ebp+0x10'
;    func_local  %$a, %$b, %$c   ; these will be set to 'ebp-0x04', 'ebp-0x08', 'ebp-0x0c'
;    func_prologue esi, edi  ; creates stack frame, creates space for func_locals, saves esi/edi
;    .....code.....
;    func_epilogue       ; restores esi/edi, cleans stack frame
;    func_ret            ; will do 'ret 0xc' (computing correct size from func_args)
;    func_end            ; cleans up preprocessor state
;
; These macros use named contexts (__func__meta and __func__body) only to help catch mistakes
; in their usage.

; Use once at the beginning of a function to enables the use of func_arg and func_local.
; It merely creates a context for '%$name' variables, and does not generate any instructions.
%macro func_begin  0.nolist
    %ifctx __func__meta
        %error "func_end was not called"
    %elifctx __func__body
        %error "func_end was not called"
    %endif
    %push __func__meta
    %assign %$__argsize 0
    %assign %$__localsize 0
%endmacro

; Define names for dword-sized stack arguments.  The first name will be set to 'ebp+0x08'
; (anticipating the creation of a stack frame), the second will be set to 'ebp+0x0c', etc.
;
; You can split the args up over multiple invocations of this macro (e.g. to add comments).
;
; The total number of args will determine the argument to 'ret' later.
%macro func_arg  0-*.nolist
    %ifctx __func__body
        %error "func_arg after prologue"
    %elifnctx __func__meta
        %error "func_arg without func_begin"
    %endif

    %define __things_to_pop %{-1:1}
    %rep %0
        %xdefine %1 ebp+0x08+%$__argsize
        %assign %$__argsize %$__argsize+4
    %rotate 1
    %endrep
%endmacro

; Define names for dword-sized stack locals.  The first name will be set to 'ebp-0x04'
; (anticipating the creation of a stack frame), the second will be set to 'ebp-0x08', etc.
;
; You can split the vars up over multiple invocations of this macro (e.g. to add comments).
;
; The total size of the vars will be subtracted from 'esp' at the appropriate point during
; stack frame creation in 'func_prologue'.
%macro func_local  0-*.nolist
    %ifctx __func__body
        %error "func_local after prologue"
    %elifnctx __func__meta
        %error "func_local without func_begin"
    %endif

    %rep %0
        %xdefine %1 ebp-0x04-%$__localsize
        %assign %$__localsize %$__localsize+4
    %rotate 1
    %endrep
%endmacro

; Generates a function prologue that creates a stack frame (with space for the locals
; declared in func_local) and saves the listed registers.  This must be called even
; if no locals are created, because func_arg still assumes that a stack frame is created.
;
; For best practices, it is recommended to save esi and edi even if they are not used,
; so that uses of them can be comfortably added to any function. (i.e. if a function does
; not save edi/esi, it should stick out like a sore thumb, and be done with purpose)
;
; A function must have exactly one call to this macro.
%macro func_prologue  0-1+.nolist
    %ifctx __func__meta
        %repl __func__body
    %else
        %error "func_prologue without func_begin"
    %endif

    push ebp
    mov  ebp, esp
    sub  esp, %$__localsize
    multipush %1
    %define  %$__things_to_pop  %1
%endmacro

; Cleanup for func_prologue.
;
; You can use this multiple times if you have multiple exit points.
%macro func_epilogue  0.nolist
    %ifnctx __func__body
        %error "func_epilogue without func_prologue"
    %endif

    multipop  %$__things_to_pop
    mov  esp, ebp
    pop  ebp
%endmacro

; A stdcall-style 'ret num_bytes' that automatically computes the number of bytes from
; the calls to the func_arg macro.
;
; You can use this multiple times if you have multiple exit points.
%macro func_ret  0.nolist
    ret %$__argsize
%endmacro

; This must be called once at the very end of a function definition.
; It does not generate any code.
%macro func_end  0.nolist
    %ifctx __func__meta
        %error "function had no prologue!"
    %else
        ; this is inside an %else because otherwise the automatic error message from a
        ; mismatched %pop would prevent all of our nicer error messages from being shown
        %pop __func__body
    %endif
%endmacro
