; move all the digits to the end of string
section .text

global bubbleupdigits

bubbleupdigits:
    ; --- prolog ---
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    ; --- prolog ---
    mov eax, [ebp+8]    ; getting the char* = eax
    mov ebx, eax        ; second char* = ebx
    inc ebx
mainloop:
    mov dl, [eax]       ; 1 byte of the char*
    cmp dl, 0
    jz end
    mov dh, [ebx]       ; 2 byte of the char*
    cmp dh, 0
    jz end

    mov [eax], dh
    mov [ebx], dl
    add eax, 2
    add ebx, 2
    jmp mainloop
end:
    mov [eax], dl
    ; --- epilog ---
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ; --- epilog ---
    ret
