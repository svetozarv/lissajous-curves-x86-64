section .data
    align 16
    start:      dd 0.00000, 0.00025, 0.00050, 0.00075
    step_4x:    dd 0.00100, 0.00100, 0.00100, 0.00100   ; step = start[-1] - start[0]
    half:       dd 0.5,     0.5,     0.5,     0.5

    ; minimax polynomial (sine approximation) coefficients
    c1: dd  6.28318516,  6.28318516,  6.28318516,  6.28318516
    c3: dd -41.3416550, -41.3416550, -41.3416550, -41.3416550
    c5: dd  81.6010041,  81.6010041,  81.6010041,  81.6010041
    c7: dd -76.5497823, -76.5497823, -76.5497823, -76.5497823
    c9: dd  39.5367060,  39.5367060,  39.5367060,  39.5367060

section .text
DEFAULT REL
global lissajous

lissajous:
    ; --- prolog ---
    push rbp
    mov rbp, rsp
    ; --- prolog ---
    mov rcx, 1000                            ; rcx <- iterations (t = 1.0 <- one rotation; 1 / step_4x = 1000 iters) (DO NOT CHANGE)

    shufps xmm0, xmm0, 0x00                 ; xmm0 = [ A | A | A | A ]
    shufps xmm1, xmm1, 0x00                 ; xmm1 = [ B | B | B | B ]
    shufps xmm2, xmm2, 0x00                 ; xmm2 = [ a | a | a | a ]
    shufps xmm3, xmm3, 0x00                 ; xmm3 = [ b | b | b | b ]
    shufps xmm4, xmm4, 0x00                 ; xmm4 = [ delta | delta | delta | delta ]

    movaps xmm5, [start]                   ; xmm5 <- [ t3 | t2 | t1 | t0 ], future [ x3 | x2 | x1 | x0 ]
    movaps xmm6, xmm5                       ; xmm6 <- [ t3 | t2 | t1 | t0 ], future [ y3 | y2 | y1 | y0 ]
    movaps xmm15, xmm5                      ; xmm15 <- [ curr_t | curr_t | curr_t | curr_t ] = [ t3 | t2 | t1 | t0 ]
    movaps xmm14, [step_4x]                 ; xmm14 <- [ 0.004 | 0.004 | 0.004 | 0.004 ]

    cvtsi2ss xmm9, esi                      ; xmm9 = [ 0 | 0 | 0 | Width ]
    shufps xmm9, xmm9, 0x00                 ; [ Width | Width | Width | Width ]
    mulps xmm9, [half]                      ; xmm14 = [ 0.5*Width | 0.5*Width | 0.5*Width | 0.5*Width ]

    cvtsi2ss xmm10, edx                     ; xmm15 = [ 0 | 0 | 0 | Height ]
    shufps   xmm10, xmm10, 0x00             ; [ Height | Height | Height | Height ]
    mulps    xmm10, [half]                  ; xmm15 = [ 0.5*Height | 0.5*Height | 0.5*Height | 0.5*Height ]

mainloop:
    ; ====== compute x(t) ======
    mulps xmm5, xmm2                        ; xmm5 = [ a*t3 | a*t2 | a*t1 | a*t0 ]
    addps xmm5, xmm4                        ; xmm5 = [ a*t3+delta | a*t2+delta | a*t1+delta | a*t0+delta ]

    ; normalize z := a*t+delta for sine
    movaps xmm7, xmm5
    roundps xmm7, xmm7, 0x00
    subps xmm5, xmm7

    ; compute sine
    movaps xmm7, xmm5                       ; x = xmm5
    mulps xmm7, xmm7                        ; x^2 = xmm7
    movaps xmm8, [c9]
    mulps xmm8, xmm7
    addps xmm8, [c7]
    mulps xmm8, xmm7
    addps xmm8, [c5]
    mulps xmm8, xmm7
    addps xmm8, [c3]
    mulps xmm8, xmm7
    addps xmm8, [c1]
    mulps xmm8, xmm5
    movaps xmm5, xmm8
    ; xmm5 = [ sin(a*t3+delta) | sin(a*t2+delta) | sin(a*t1+delta) | sin(a*t0+delta) ]

    mulps xmm5, xmm0                        ; xmm5 = [ A*sin(a*t3+delta) | A*sin(a*t2+delta) | A*sin(a*t1+delta) | A*sin(a*t0+delta) ]


    ; ====== compute y(t) ======
    mulps xmm6, xmm3                        ; xmm6 = [ b*t3 | b*t2 | b*t1 | b*t0 ]

    ; normalize z := b*t for sine
    movaps xmm7, xmm6
    roundps xmm7, xmm7, 0x00
    subps xmm6, xmm7

    ; compute sine
    movaps xmm7, xmm6                       ; y = xmm6
    mulps xmm7, xmm7                        ; y^2 = xmm7
    movaps xmm8, [c9]
    mulps xmm8, xmm7
    addps xmm8, [c7]
    mulps xmm8, xmm7
    addps xmm8, [c5]
    mulps xmm8, xmm7
    addps xmm8, [c3]
    mulps xmm8, xmm7
    addps xmm8, [c1]
    mulps xmm8, xmm6
    movaps xmm6, xmm8
    ; xmm6 = [ sin(b*t3) | sin(b*t2) | sin(b*t1) | sin(b*t0) ]

    mulps xmm6, xmm1                        ; xmm6 = [ B*sin(b*t3) | B*sin(b*t2) | B*sin(b*t1) | B*sin(b*t0) ]

    addps xmm5, xmm9                        ; x = A*sin(a*t+delta) + 0.5*Width
    addps xmm6, xmm10                       ; y = B*sin(b*t) + 0.5*Height

    ; ====== draw points ======
    cvttps2dq xmm5, xmm5                    ; convert x to int
    cvttps2dq xmm6, xmm6                    ; convert y to int
    pextrd r8d, xmm5, 0                     ; r8d = x0
    pextrd r9d, xmm6, 0                     ; r9d = y0
    mov eax, r9d                            ; y
    imul eax, esi                           ; y*width
    add eax, r8d                            ; y*width + x
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    pextrd r8d, xmm5, 1                     ; r8d = x1
    pextrd r9d, xmm6, 1                     ; r9d = y1
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    pextrd r8d, xmm5, 2                     ; r8d = x2
    pextrd r9d, xmm6, 2                     ; r9d = y2
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    pextrd r8d, xmm5, 3                     ; r8d = x3
    pextrd r9d, xmm6, 3                     ; r9d = y3
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white


    ; ====== update t ======
    addps xmm15, xmm14                      ; t += 0.004
    movaps xmm5, xmm15                      ; current t
    movaps xmm6, xmm15                      ; current t

    dec rcx
    test rcx, rcx
    jnz mainloop
end:
    ; --- epilog ---
    mov rsp, rbp
    pop rbp
    ; --- epilog ---
    ret
