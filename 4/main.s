section .data
    input_format    db "%f", 0             ; Input format for x
    output_format   db "Result: %.6f", 10, 0 ; Output format
    file_format     db "%d: %.6f", 10, 0   ; File format
    error_args      db "Error: expected filename argument", 10, 0
    error_file      db "Error: could not open file", 10, 0
    error_input     db "Error: invalid input", 10, 0
    epsilon         dd 1e-6                ; Epsilon bound (0.000001)
    mode_w          db "w", 0              ; Open file in write mode
    align 16
    abs_mask        dd 0x7FFFFFFF, 0, 0, 0 ; Mask for absolute value

section .bss
    x               resd 1                 ; Input x value
    sum             resd 1                 ; Series sum
    current_term    resd 1                 ; Current term
    n               resd 1                 ; Current number
    file_handle     resq 1                 ; File pointer

section .text
    global main
    extern scanf, printf, fopen, fprintf, fclose, exit

main:
    push rbp
    mov rbp, rsp

    ; Check the number of command line arguments
    cmp edi, 2
    jl .args_error

    ; Open the file
    mov rdi, qword [rsi + 8]  ; argv[1]
    mov rsi, mode_w
    call fopen
    test rax, rax
    jz .file_error
    mov [file_handle], rax

    ; Input x
    mov rdi, input_format
    mov rsi, x
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .input_error

    ; Initialization
    movss xmm0, [x]
    movss [current_term], xmm0 ; current_term = x
    xorps xmm1, xmm1
    movss [sum], xmm1          ; sum = 0.0
    mov dword [n], 0            ; n = 0

.loop:
    ; Increment n and add current_term to sum
    inc dword [n]
    movss xmm0, [current_term]
    addss xmm0, [sum]
    movss [sum], xmm0

    ; Print current_term to file
    mov rdi, [file_handle]
    mov rsi, file_format
    mov edx, [n]
    cvtss2sd xmm0, [current_term]
    mov rax, 1
    call fprintf

    ; Calculate next term: current_term * x² / ((2n)(2n+1))
    mov eax, [n]
    shl eax, 1              ; 2n
    mov ebx, eax
    inc ebx                 ; 2n + 1
    imul eax, ebx           ; eax = 2n*(2n+1)
    cvtsi2ss xmm1, eax     ; xmm1 = denominator
    movss xmm0, [current_term]
    mulss xmm0, [x]        ; current_term * x
    mulss xmm0, [x]        ; current_term * x²
    divss xmm0, xmm1       ; / (2n*(2n+1))
    movss [current_term], xmm0

    ; Check exit condition (|current_term| < epsilon)
    movss xmm0, [current_term]
    andps xmm0, [abs_mask]
    comiss xmm0, [epsilon]
    jb .end_loop
    jmp .loop

.end_loop:
    ; Print sum
    cvtss2sd xmm0, [sum]
    mov rdi, output_format
    mov rax, 1
    call printf

    ; Close the file
    mov rdi, [file_handle]
    call fclose

    xor eax, eax
    leave
    ret

.args_error:
    mov rdi, error_args
    call printf
    mov eax, 1
    jmp .exit

.file_error:
    mov rdi, error_file
    call printf
    mov eax, 1
    jmp .exit

.input_error:
    mov rdi, error_input
    call printf
    mov eax, 1

.exit:
    leave
    ret
