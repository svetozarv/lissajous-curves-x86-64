section .data
    align 16
    start:      dd 0.0, 0.001, 0.002, 0.003
    align 16
    start2:     dd 0.004, 0.005, 0.006, 0.007
    align 16
    step_4x:    dd 0.004, 0.004, 0.004, 0.004
    align 16
    three_fac:  dd 6.0
    align 16
    five_fac:   dd 120.0
    align 16

section .text
DEFAULT REL
global lissajous

lissajous:
    ; --- prolog ---
    push rbp
    mov rbp, rsp
    ; --- prolog ---
    mov rcx, 50                     ; rcx <- iterations (t <= 8.0)

    shufps xmm0, xmm0, 0x00           ; xmm0 = [ A | A | A | A ]
    shufps xmm1, xmm1, 0x00           ; xmm1 = [ B | B | B | B ]
    shufps xmm2, xmm2, 0x00           ; xmm2 = [ a | a | a | a ]
    shufps xmm3, xmm3, 0x00           ; xmm3 = [ b | b | b | b ]
    shufps xmm4, xmm4, 0x00           ; xmm4 = [ delta | delta | delta | delta ]

    movaps xmm5, [start2]               ; xmm5 <- [ t3 | t2 | t1 | t0 ] = [ x3 | x2 | x1 | x0 ]
    movaps xmm6, xmm5                   ; xmm6 <- [ t3 | t2 | t1 | t0 ] = [ y3 | y2 | y1 | y0 ]
    movaps xmm15, xmm5                  ; xmm15 <- [ curr_t | curr_t | curr_t | curr_t ] = [ t3 | t2 | t1 | t0 ]
    movaps xmm14, [step_4x]             ; xmm14 <- [ 0.004 | 0.004 | 0.004 | 0.004 ]

mainloop:
    test rcx, rcx
    jz end
    ; ====== compute x(t) ======
    mulps xmm5, xmm2                     ; xmm5 = [ a*t3 | a*t2 | a*t1 | a*t0 ]
    addps xmm5, xmm4                     ; xmm5 = [ a*t3+delta | a*t2+delta | a*t1+delta | a*t0+delta ]

    ; compute sine
    movaps xmm7, xmm5                    ; a*t+delta
    mulps xmm7, xmm7                     ; xmm7^2
    mulps xmm7, xmm5
    movaps xmm8, xmm7                    ; save ^3
    mulps xmm8, xmm5                     ; (b*t)^4
    mulps xmm8, xmm5                     ; (b*t)^5
    divps xmm7, [three_fac]              ; (b*t)^3 / 6
    divps xmm8, [five_fac]               ; (b*t)^5 / 120
    subps xmm5, xmm7
    addps xmm5, xmm8
    ; xmm5 = [ sin(a*t3+delta) | sin(a*t2+delta) | sin(a*t1+delta) | sin(a*t0+delta) ]

    mulps xmm5, xmm0                     ; xmm5 = [ A*sin(a*t3+delta) | A*sin(a*t2+delta) | A*sin(a*t1+delta) | A*sin(a*t0+delta) ]


    ; ====== compute y(t) ======
    mulps xmm6, xmm3                     ; xmm6 = [ b*t3 | b*t2 | b*t1 | b*t0 ]

    ; compute sine
    movaps xmm7, xmm6                    ; b*t
    mulps xmm7, xmm7                     ; (b*t)^2
    mulps xmm7, xmm6                     ; (b*t)^3
    movaps xmm8, xmm7                    ; save ^3
    mulps xmm8, xmm6                     ; (b*t)^4
    mulps xmm8, xmm6                     ; (b*t)^5
    divps xmm7, [three_fac]              ; (b*t)^3 / 6
    divps xmm8, [five_fac]               ; (b*t)^5 / 120
    subps xmm6, xmm7
    addps xmm6, xmm8
    ; xmm6 = [ sin(b*t3) | sin(b*t2) | sin(b*t1) | sin(b*t0) ]

    mulps xmm6, xmm1                    ; xmm6 = [ B*sin(b*t3) | B*sin(b*t2) | B*sin(b*t1) | B*sin(b*t0) ]

    ; ====== draw points ======
    cvttps2dq xmm5, xmm5                ; convert x to int
    cvttps2dq xmm6, xmm6                ; convert y to int
    pextrd r8d, xmm5, 0                 ; r8d = x0
    pextrd r9d, xmm6, 0                 ; r9d = y0
    sal r8d, 2
    sal r9d, 2                          ; ORDER influence on overflow??
    imul r9d, esi
    mov r10d, edi
    add r10d, r8d
    add r10d, r9d
    mov dword [r10d], 0xFFFFFF              ; set pixel (x0, y0) to white

    pextrd r8d, xmm5, 1                 ; r8d = x1
    pextrd r9d, xmm6, 1                 ; r9d = y1
    sal r8d, 2
    sal r9d, 2                          ; ORDER influence on overflow??
    imul r9d, esi
    mov r10d, edi
    add r10d, r8d
    add r10d, r9d
    mov dword [r10d], 0xFFFFFF              ; set pixel (x0, y0) to white

    pextrd r8d, xmm5, 2                 ; r8d = x2
    pextrd r9d, xmm6, 2                 ; r9d = y2
    sal r8d, 2
    sal r9d, 2                          ; ORDER influence on overflow??
    imul r9d, esi
    mov r10d, edi
    add r10d, r8d
    add r10d, r9d
    mov dword [r10d], 0xFFFFFF              ; set pixel (x0, y0) to white

    pextrd r8d, xmm5, 3                 ; r8d = x3
    pextrd r9d, xmm6, 3                 ; r9d = y3
    sal r8d, 2
    sal r9d, 2                          ; ORDER influence on overflow??
    imul r9d, esi
    mov r10d, edi
    add r10d, r8d
    add r10d, r9d
    mov dword [r10d], 0xFF              ; set pixel (x0, y0) to white


    ; ====== update t ======
    addps xmm15, xmm14                   ; t += 0.004
    movaps xmm5, xmm15                   ; current t
    movaps xmm6, xmm15                   ; current t
    dec rcx
    jmp mainloop

end:
    ; --- epilog ---
    mov rsp, rbp
    pop rbp
    ; --- epilog ---
    ret
