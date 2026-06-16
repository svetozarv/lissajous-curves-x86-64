section .data
    align 32
    start:      dd 0.00000, 0.00025, 0.00050, 0.00075, 0.00100, 0.00125, 0.00150, 0.00175
    step_4x:    dd 0.00200, 0.00200, 0.00200, 0.00200, 0.00200, 0.00200, 0.00200, 0.00200   ; step = start[-1] - start[0]
    half:       dd 0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5,     0.5

    ; minimax polynomial (sine approximation; abs. error minimized, degree 13) coefficients
    c1:  dd   6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516,  6.28318516
    c3:  dd -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550, -41.3416550
    c5:  dd  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041,  81.6010041
    c7:  dd -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823, -76.5497823
    c9:  dd  42.0579638,  42.0579638,  42.0579638,  42.0579638,  42.0579638,  42.0579638,  42.0579638,  42.0579638
    c11: dd -15.0792949, -15.0792949, -15.0792949, -15.0792949, -15.0792949, -15.0792949, -15.0792949, -15.0792949
    c13: dd   3.6550839,  3.6550839,   3.6550839,    3.6550839,   3.6550839,   3.6550839,   3.6550839,   3.6550839

section .text
DEFAULT REL
global lissajousAVX

lissajousAVX:
    ; --- prolog ---
    push rbp
    mov rbp, rsp
    ; --- prolog ---
    mov rcx, 500                            ; rcx <- iterations (t <= 1.0 - one rotation; 1 / step_4x = 500 iter) (DO NOT CHANGE)

    vbroadcastss ymm0, xmm0                 ; copies xmm0[0] to all 8 slots of ymm0 => ymm0 = [ A, A, A, A | A, A, A, A ]
    vbroadcastss ymm1, xmm1                 ; ymm1 = [ B, B, B, B | B, B, B, B ]
    vbroadcastss ymm2, xmm2                 ; ymm2 = [ a, a, a, a | a, a, a, a ]
    vbroadcastss ymm3, xmm3                 ; ymm3 = [ b, b, b, b | b, b, b, b ]
    vbroadcastss ymm4, xmm4                 ; ymm4 = [ delta, delta, delta, delta | delta, delta, delta, delta ]

    vmovaps ymm5, [start]                   ; ymm5 <- [ t3 | t2 | t1 | t0 ], future [ x3 | x2 | x1 | x0 ]
    vmovaps ymm6, ymm5                       ; ymm6 <- [ t3 | t2 | t1 | t0 ], future [ y3 | y2 | y1 | y0 ]
    vmovaps ymm15, ymm5                      ; ymm15 <- [ curr_t | curr_t | curr_t | curr_t ] = [ t3 | t2 | t1 | t0 ]
    vmovaps ymm14, [step_4x]                 ; ymm14 <- [ 0.004 | 0.004 | 0.004 | 0.004 ]

    vcvtsi2ss xmm9, xmm9, esi                      ; ymm9 = [ 0 | 0 | 0 | Width ]
    vbroadcastss ymm9, xmm9                 ; [ Width | Width | Width | Width ]
    vmulps ymm9, ymm9, [half]                      ; ymm14 = [ 0.5*Width | 0.5*Width | 0.5*Width | 0.5*Width ]

    vcvtsi2ss xmm10, xmm10, edx                     ; ymm15 = [ 0 | 0 | 0 | Height ]
    vbroadcastss   ymm10, xmm10             ; [ 0, 0, 0, 0 | 0, 0, 0, H ] -> [ H, H, H, H | H, H, H, H ]
    vmulps    ymm10, ymm10, [half]                  ; ymm15 = [ 0.5*Height | 0.5*Height | 0.5*Height | 0.5*Height ]

mainloop:
    ; ====== compute x(t) ======
    vmulps ymm5, ymm5, ymm2                        ; ymm5 = [ a*t3 | a*t2 | a*t1 | a*t0 ]
    vaddps ymm5, ymm5, ymm4                        ; ymm5 = [ a*t3+delta | a*t2+delta | a*t1+delta | a*t0+delta ]

    ; normalize z := a*t+delta for sine
    vmovaps ymm7, ymm5
    vroundps ymm7, ymm7, 0x00
    vsubps ymm5, ymm5, ymm7

    ; compute sine
    vmovaps ymm7, ymm5                       ; x = ymm5
    vmulps ymm7, ymm7, ymm7                        ; x^2 = ymm7
    vmovaps ymm8, [c13]             ; ymm8 = result of sine
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c11]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c9]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c7]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c5]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c3]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c1]
    vmulps ymm8, ymm8, ymm5
    vmovaps ymm5, ymm8
    ; ymm5 = [ sin(a*t3+delta) | sin(a*t2+delta) | sin(a*t1+delta) | sin(a*t0+delta) ]

    vmulps ymm5, ymm5, ymm0                        ; ymm5 = [ A*sin(a*t3+delta) | A*sin(a*t2+delta) | A*sin(a*t1+delta) | A*sin(a*t0+delta) ]


    ; ====== compute y(t) ======
    vmulps ymm6, ymm6, ymm3                        ; ymm6 = [ b*t3 | b*t2 | b*t1 | b*t0 ]

    ; normalize z := b*t for sine
    vmovaps ymm7, ymm6
    vroundps ymm7, ymm7, 0x00
    vsubps ymm6, ymm6, ymm7

    ; compute sine
    vmovaps ymm7, ymm6                       ; y = ymm6
    vmulps ymm7, ymm7, ymm7                        ; y^2 = ymm7
    vmovaps ymm8, [c13]             ; ymm8 = result of sine
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c11]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c9]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c7]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c5]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c3]
    vmulps ymm8, ymm8, ymm7
    vaddps ymm8, ymm8, [c1]
    vmulps ymm8, ymm8, ymm6
    vmovaps ymm6, ymm8
    ; ymm6 = [ sin(b*t3) | sin(b*t2) | sin(b*t1) | sin(b*t0) ]

    vmulps ymm6, ymm6, ymm1                        ; ymm6 = [ B*sin(b*t3) | B*sin(b*t2) | B*sin(b*t1) | B*sin(b*t0) ]

    vaddps ymm5, ymm5, ymm9                        ; x = A*sin(a*t+delta) + 0.5*Width
    vaddps ymm6, ymm6, ymm10                       ; y = B*sin(b*t) + 0.5*Height

    ; ====== draw points ======
    vcvttps2dq ymm5, ymm5                    ; convert x to int
    vcvttps2dq ymm6, ymm6                    ; convert y to int

    ; 1 pixel
    vpextrd r8d, xmm5, 0                     ; r8d = x0
    vpextrd r9d, xmm6, 0                     ; r9d = y0
    mov eax, r9d                            ; y
    imul eax, esi                           ; y*width
    add eax, r8d                            ; y*width + x
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    ; 2 pixel
    vpextrd r8d, xmm5, 1                     ; r8d = x1
    vpextrd r9d, xmm6, 1                     ; r9d = y1
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    ; 3 pixel
    vpextrd r8d, xmm5, 2                     ; r8d = x2
    vpextrd r9d, xmm6, 2                     ; r9d = y2
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    ; 4 pixel
    vpextrd r8d, xmm5, 3                     ; r8d = x3
    vpextrd r9d, xmm6, 3                     ; r9d = y3
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF     ; set pixel (x0, y0) to white

    vextractf128 xmm11, ymm5, 1             ; xmm11 = [ x7 | x6 | x5 | x4 ]
    vextractf128 xmm12, ymm6, 1             ; xmm12 = [ y7 | y6 | y5 | y4 ]

    ; 5 pixel
    vpextrd r8d, xmm11, 0                   ; r8d = x4
    vpextrd r9d, xmm12, 0                   ; r9d = y4
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF

    ; 6 pixel
    vpextrd r8d, xmm11, 1                   ; r8d = x5
    vpextrd r9d, xmm12, 1                   ; r9d = y5
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF

    ; 7 pixel
    vpextrd r8d, xmm11, 2                   ; r8d = x6
    vpextrd r9d, xmm12, 2                   ; r9d = y6
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF

    ; 8 pixel
    vpextrd r8d, xmm11, 3                   ; r8d = x7
    vpextrd r9d, xmm12, 3                   ; r9d = y7
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF

    ; ====== update t ======
    vaddps ymm15, ymm15, ymm14                      ; t += 0.004
    vmovaps ymm5, ymm15                      ; current t
    vmovaps ymm6, ymm15                      ; current t

    dec rcx
    test rcx, rcx
    jnz mainloop
end:
    ; --- epilog ---
    mov rsp, rbp
    pop rbp
    ; --- epilog ---
    ret
