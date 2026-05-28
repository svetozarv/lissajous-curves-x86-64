section .text

global lissajous

lissajous:
    ; --- prolog ---
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    ; --- prolog ---

end:
    ; --- epilog ---
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ; --- epilog ---
    ret
