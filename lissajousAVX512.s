; Lissajous curve generator, AVX-512 version
; Before running, make sure your CPU supports AVX-512 and it is enabled:
;       grep -o 'avx512f' /proc/cpuinfo | head -n 1
;
; NOTE: On some Intel CPUs (such as 12th, 13th, or 14th Gen chips),
;    AVX-512 is natively disabled unless you manually deactivate the efficiency cores (E-cores) in the BIOS
;

%macro V_COMPUTE_SINE 1
; %1 - zmm register containing the input values (x)
; uses zmm7, zmm8 as temporary registers
; results are stored in %1
    vmovaps zmm7, %1                     ; x = ymm5
    vmulps zmm7, zmm7, zmm7              ; x^2 = ymm7
    vmovaps zmm8, [c9]
    vmulps zmm8, zmm8, zmm7
    vaddps zmm8, zmm8, [c7]
    vmulps zmm8, zmm8, zmm7
    vaddps zmm8, zmm8, [c5]
    vmulps zmm8, zmm8, zmm7
    vaddps zmm8, zmm8, [c3]
    vmulps zmm8, zmm8, zmm7
    vaddps zmm8, zmm8, [c1]
    vmulps zmm8, zmm8, %1
    vmovaps %1, zmm8
%endmacro

%macro WRITE_PIXEL_IN_BUFFER 3
; %1 - xmm register containing x coordinates
; %2 - xmm register containing y coordinates
; %3 the desired pixel index in the current xmm register (0, 1, 2, or 3)
; uses r8d, r9d, eax
    vpextrd r8d, %1, %3                  ; r8d = x5
    vpextrd r9d, %2, %3                  ; r9d = y5
    mov eax, r9d
    imul eax, esi
    add eax, r8d
    mov dword [rdi + 4*rax], 0xFFFFFFFF
%endmacro

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
    mov rcx, 250                            ; rcx <- iterations (t <= 1.0 - one rotation; 1 / step_4x = 500 iter) (DO NOT CHANGE)

    vbroadcastss zmm0, xmm0                 ; copies xmm0[0] to all 8 slots of ymm0 => ymm0 = [ A, A, A, A | A, A, A, A ]
    vbroadcastss zmm1, xmm1                 ; ymm1 = [ B, B, B, B | B, B, B, B ]
    vbroadcastss zmm2, xmm2                 ; ymm2 = [ a, a, a, a | a, a, a, a ]
    vbroadcastss zmm3, xmm3                 ; ymm3 = [ b, b, b, b | b, b, b, b ]
    vbroadcastss zmm4, xmm4                 ; ymm4 = [ delta, delta, delta, delta | delta, delta, delta, delta ]

    vmovaps zmm5, [start]                   ; ymm5 <- [ t3 | t2 | t1 | t0 ], future [ x3 | x2 | x1 | x0 ]
    vmovaps zmm6, zmm5                      ; ymm6 <- [ t3 | t2 | t1 | t0 ], future [ y3 | y2 | y1 | y0 ]
    vmovaps zmm15, zmm5                     ; ymm15 <- [ curr_t | curr_t | curr_t | curr_t ] = [ t3 | t2 | t1 | t0 ]
    vmovaps zmm14, [step_4x]                ; ymm14 <- [ 0.004 | 0.004 | 0.004 | 0.004 ]

    vcvtsi2ss xmm9, xmm9, esi               ; ymm9 = [ 0 | 0 | 0 | Width ]
    vbroadcastss zmm9, xmm9                 ; [ Width | Width | Width | Width ]
    vmulps zmm9, zmm9, [half]               ; ymm14 = [ 0.5*Width | 0.5*Width | 0.5*Width | 0.5*Width ]

    vcvtsi2ss xmm10, xmm10, edx             ; ymm15 = [ 0 | 0 | 0 | Height ]
    vbroadcastss   xmm10, xmm10             ; [ Height | Height | Height | Height ]
    vmulps    zmm10, zmm10, [half]          ; ymm15 = [ 0.5*Height | 0.5*Height | 0.5*Height | 0.5*Height ]

mainloop:
    ; ================== compute x(t) ==================
    vmulps zmm5, zmm5, zmm2                 ; ymm5 = [ a*t3 | a*t2 | a*t1 | a*t0 ]
    vaddps zmm5, zmm5, zmm4                 ; ymm5 = [ a*t3+delta | a*t2+delta | a*t1+delta | a*t0+delta ]

    ; normalize z := a*t+delta for sine
    vmovaps zmm7, zmm5
    vrndscaleps zmm7, zmm7, 0x00
    vsubps zmm5, zmm5, zmm7


    V_COMPUTE_SINE zmm5                     ; ymm5 = [ sin(a*t3+delta) | sin(a*t2+delta) | sin(a*t1+delta) | sin(a*t0+delta) ]
    vmulps zmm5, zmm5, zmm0                 ; ymm5 = [ A*sin(a*t3+delta) | A*sin(a*t2+delta) | A*sin(a*t1+delta) | A*sin(a*t0+delta) ]

    ; ================== compute y(t) ==================
    vmulps zmm6, zmm6, zmm3                  ; ymm6 = [ b*t3 | b*t2 | b*t1 | b*t0 ]

    ; normalize z := b*t for sine
    vmovaps zmm7, zmm6
    vrndscaleps zmm7, zmm7, 0x00             ; Round Scale Packed Single-Precision Floating-Point Values
    vsubps zmm6, zmm6, zmm7

    V_COMPUTE_SINE zmm6                      ; zmm6 = [ sin(b*t3) | sin(b*t2) | sin(b*t1) | sin(b*t0) ]
    vmulps zmm6, zmm6, zmm1                  ; ymm6 = [ B*sin(b*t3) | B*sin(b*t2) | B*sin(b*t1) | B*sin(b*t0) ]

    vaddps zmm5, zmm5, zmm9                   ; x = A*sin(a*t+delta) + 0.5*Width
    vaddps zmm6, zmm6, zmm10                  ; y = B*sin(b*t) + 0.5*Height

    ; ================== draw points ==================
    vcvttps2dq zmm5, zmm5                    ; convert x to int
    vcvttps2dq zmm6, zmm6                    ; convert y to int
    WRITE_PIXEL_IN_BUFFER xmm5, xmm6, 0
    WRITE_PIXEL_IN_BUFFER xmm5, xmm6, 1
    WRITE_PIXEL_IN_BUFFER xmm5, xmm6, 2
    WRITE_PIXEL_IN_BUFFER xmm5, xmm6, 3

    vextractf32x4 xmm12, zmm5, 1             ; xmm11 = [ x7 | x6 | x5 | x4 ]
    vextractf32x4 xmm12, zmm6, 1             ; xmm12 = [ y7 | y6 | y5 | y4 ]

    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 0
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 1
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 2
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 3

    vextractf32x4 xmm12, zmm5, 2             ; xmm11 = [ x7 | x6 | x5 | x4 ]
    vextractf32x4 xmm12, zmm6, 2             ; xmm12 = [ y7 | y6 | y5 | y4 ]

    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 0
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 1
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 2
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 3

    vextractf32x4 xmm12, zmm5, 3             ; xmm11 = [ x7 | x6 | x5 | x4 ]
    vextractf32x4 xmm12, zmm6, 3             ; xmm12 = [ y7 | y6 | y5 | y4 ]

    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 0
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 1
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 2
    WRITE_PIXEL_IN_BUFFER xmm11, xmm12, 3

    ; ====== update t ======
    vaddps ymm15, ymm15, ymm14               ; t += dt
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
