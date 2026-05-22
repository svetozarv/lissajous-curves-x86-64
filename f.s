section .text

global f

f:
    push ebp            ; prolog
    mov ebp, esp        ; prolog
    mov eax, [ebp+8]    ; getting the char*

begin:
    mov cl, [eax]       ; 1 byte of the char*
    cmp cl, 0
    jz end

    add cl, 1
    mov [eax], cl
    inc eax
    jmp begin

end:
    mov esp, ebp        ; epilog
    pop ebp             ; epilog
    ret
