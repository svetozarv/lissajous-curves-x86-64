section .data
    align 32
    start:      dd 0.00000,  0.00025, 0.00050, 0.00075, 0.00100, 0.00125, 0.00150, 0.00175, 0.00200, 0.00225, 0.00250, 0.00275, 0.00300, 0.00325, 0.00350, 0.00375
    step_4x:    dd 0.00400,  0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400, 0.00400    ; step = start[-1] - start[0]
    half:       dd 0.5,      0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5

    ; minimax polynomial (sine approximation) coefficients
    c1: dd  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516
    c3: dd -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550
    c5: dd  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041
    c7: dd -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823
    c9: dd  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060,  39.5367060


section .text
DEFAULT REL
global lissajousAVX512

lissajousAVX512:
    ; --- prolog ---
    push rbp
    mov rbp, rsp
    ; --- prolog ---
    mov rcx, 250                            ; rcx <- iterations (t <= 1.0 - one rotation; 1 / step_4x = 250 iter) (DO NOT CHANGE)

    shufps zmm0, zmm0, 0x00                 ; zmm0 = [ A | A | A | A ]
    shufps zmm1, zmm1, 0x00                 ; zmm1 = [ B | B | B | B ]
    shufps zmm2, zmm2, 0x00                 ; zmm2 = [ a | a | a | a ]
    shufps zmm3, zmm3, 0x00                 ; zmm3 = [ b | b | b | b ]
    shufps zmm4, zmm4, 0x00                 ; zmm4 = [ delta | delta | delta | delta ]

    movaps zmm5, [start]                   ; zmm5 <- [ t3 | t2 | t1 | t0 ], future [ x3 | x2 | x1 | x0 ]
    movaps zmm6, zmm5                       ; zmm6 <- [ t3 | t2 | t1 | t0 ], future [ y3 | y2 | y1 | y0 ]
    movaps zmm15, zmm5                      ; zmm15 <- [ curr_t | curr_t | curr_t | curr_t ] = [ t3 | t2 | t1 | t0 ]
    movaps zmm14, [step_4x]                 ; zmm14 <- [ 0.004 | 0.004 | 0.004 | 0.004 ]

    cvtsi2ss zmm9, esi                      ; zmm9 = [ 0 | 0 | 0 | Width ]
    shufps zmm9, zmm9, 0x00                 ; [ Width | Width | Width | Width ]
    mulps zmm9, [half]                      ; zmm14 = [ 0.5*Width | 0.5*Width | 0.5*Width | 0.5*Width ]

    cvtsi2ss zmm10, edx                     ; zmm15 = [ 0 | 0 | 0 | Height ]
    shufps   zmm10, zmm10, 0x00             ; [ Height | Height | Height | Height ]
    mulps    zmm10, [half]                  ; zmm15 = [ 0.5*Height | 0.5*Height | 0.5*Height | 0.5*Height ]

mainloop:
    ; ====== compute x(t) ======
    mulps zmm5, zmm2                        ; zmm5 = [ a*t3 | a*t2 | a*t1 | a*t0 ]
    addps zmm5, zmm4                        ; zmm5 = [ a*t3+delta | a*t2+delta | a*t1+delta | a*t0+delta ]

    ; normalize z := a*t+delta for sine
    movaps zmm7, zmm5
    roundps zmm7, zmm7, 0x00
    subps zmm5, zmm7

    ; compute sine
    movaps zmm7, zmm5                       ; x = zmm5
    mulps zmm7, zmm7                        ; x^2 = zmm7
    movaps zmm8, [c9]
    mulps zmm8, zmm7
    addps zmm8, [c7]
    mulps zmm8, zmm7
    addps zmm8, [c5]
    mulps zmm8, zmm7
    addps zmm8, [c3]
    mulps zmm8, zmm7
    addps zmm8, [c1]
    mulps zmm8, zmm5
    movaps zmm5, zmm8
    ; zmm5 = [ sin(a*t3+delta) | sin(a*t2+delta) | sin(a*t1+delta) | sin(a*t0+delta) ]

    mulps zmm5, zmm0                        ; zmm5 = [ A*sin(a*t3+delta) | A*sin(a*t2+delta) | A*sin(a*t1+delta) | A*sin(a*t0+delta) ]


    ; ====== compute y(t) ======
    mulps zmm6, zmm3                        ; zmm6 = [ b*t3 | b*t2 | b*t1 | b*t0 ]

    ; normalize z := b*t for sine
    movaps zmm7, zmm6
    roundps zmm7, zmm7, 0x00
    subps zmm6, zmm7

    ; compute sine
    movaps zmm7, zmm6                       ; y = zmm6
    mulps zmm7, zmm7                        ; y^2 = zmm7
    movaps zmm8, [c9]
    mulps zmm8, zmm7
    addps zmm8, [c7]
    mulps zmm8, zmm7
    addps zmm8, [c5]
    mulps zmm8, zmm7
    addps zmm8, [c3]
    mulps zmm8, zmm7
    addps zmm8, [c1]
    mulps zmm8, zmm6
    movaps zmm6, zmm8
    ; zmm6 = [ sin(b*t3) | sin(b*t2) | sin(b*t1) | sin(b*t0) ]

    mulps zmm6, zmm1                        ; zmm6 = [ B*sin(b*t3) | B*sin(b*t2) | B*sin(b*t1) | B*sin(b*t0) ]

    addps zmm5, zmm9                        ; x = A*sin(a*t+delta) + 0.5*Width
    addps zmm6, zmm10                       ; y = B*sin(b*t) + 0.5*Height

    ; ====== draw points ======
    cvttps2dq zmm5, zmm5                    ; convert x to int
    cvttps2dq zmm6, zmm6                    ; convert y to int
    pextrd r8d, zmm5, 0                     ; r8d = x0
    pextrd r9d, zmm6, 0                     ; r9d = y0
    mov eax, r9d                            ; y
    imul eax, esi                           ; y*width
    add eax, r8d                            ; y*width + x
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    pextrd r8d, zmm5, 1                     ; r8d = x1
    pextrd r9d, zmm6, 1                     ; r9d = y1
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    pextrd r8d, zmm5, 2                     ; r8d = x2
    pextrd r9d, zmm6, 2                     ; r9d = y2
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    pextrd r8d, zmm5, 3                     ; r8d = x3
    pextrd r9d, zmm6, 3                     ; r9d = y3
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white


    ; ====== update t ======
    addps zmm15, zmm14                      ; t += 0.004
    movaps zmm5, zmm15                      ; current t
    movaps zmm6, zmm15                      ; current t

    dec rcx
    test rcx, rcx
    jnz mainloop
end:
    ; --- epilog ---
    mov rsp, rbp
    pop rbp
    ; --- epilog ---
    ret
