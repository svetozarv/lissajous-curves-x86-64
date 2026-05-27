section .text

global compress

compress:
    ; --- prolog ---
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    ; --- prolog ---
    mov eax, [ebp+8]    ; getting the char* = eax
    mov ebx, eax        ; second char* = ebx
    mov cl, 48          ; counter = 0 (ascii)
    mov edi, eax        ; writing pointer
mainloop:
    mov dl, [ebx]       ; 1 byte of the char*
    cmp dl, 0
    jz met_end

    mov dh, [eax]       ; 1 byte of the char*
    cmp dl, dh
    jne chars_different
    inc ebx
    inc cl
    jmp mainloop
chars_different:
    mov [edi], cl    ; rozmiar ????
    inc edi
    mov [edi], dh
    inc edi
    mov cl, 48
    mov eax, ebx
    jmp mainloop

    
met_end:
    mov [edi], cl
    inc edi
    mov [edi], dh
end:
    inc edi
    mov byte [edi], 0
    ; --- epilog ---
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ; --- epilog ---
    ret
