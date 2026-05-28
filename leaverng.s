section .text

global leaverng

leaverng:
    ; --- prolog ---
    push ebp
    mov ebp, esp
    push esi
    push ebx
    ; --- prolog ---
    mov ebx, [ebp+16]   ; getting b = ebx
    mov edx, [ebp+12]   ; getting a = edx
    mov eax, [ebp+8]    ; getting the char* = eax
    mov esi, eax        ; second char* = esi
mainloop:
    mov cl, [eax]       ; 1 byte of the char*
    cmp cl, 0
    jz end

    cmp cl, dl
    jl remove_char
    cmp cl, bl
    jg remove_char
    mov [esi], cl
    inc eax
    inc esi
    jmp mainloop
remove_char:
    inc eax
    jmp mainloop
end:
    mov byte [esi], 0
    ; --- epilog ---
    pop ebx
    pop esi
    mov esp, ebp
    pop ebp
    ; --- epilog ---
    ret
