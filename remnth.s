section .text

global remnth

remnth:
    ; --- prolog ---
    push ebp
    mov ebp, esp
    push ebx
    push esi
    ; --- prolog ---
    mov ebx, [ebp+12]   ; getting the int
    cmp ebx, 0
    jle end
    dec ebx
    mov eax, [ebp+8]    ; getting the char*
    mov edx, eax
mainloop:
    mov cl, [eax]       ; 1 byte of the char*
    cmp cl, 0
    jz end
    mov [edx], cl

    inc edx
    inc eax
    dec ebx
    cmp ebx, 0
    jnz mainloop

    inc eax
    mov ebx, [ebp+12]
    dec ebx
    jmp mainloop
end:
    mov byte [edx], 0
    ; --- epilog ---
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ; --- epilog ---
    ret
