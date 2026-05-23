section .text

global remrep

remrep:
    ; --- prolog ---
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    ; --- prolog ---
    mov eax, [ebp+8]    ; getting the char* = eax
    mov ebx, eax        ; second char* = ebx
mainloop:
    mov dl, [ebx]       ; 1 byte of the char*
    cmp dl, 0
    jz end

    mov dh, [eax]       ; 1 byte of the char*
    cmp dl, dh
    jne chars_different
    inc ebx
    jmp mainloop
chars_different:
    inc eax
    mov [eax], dl
    jmp mainloop
end:
    inc eax
    mov [eax], dl
    ; --- epilog ---
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ; --- epilog ---
    ret
