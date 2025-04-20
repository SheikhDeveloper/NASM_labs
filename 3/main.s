bits 64

section .data
    file_buffer times 256 db 0
    shift_buffer dq 0
    filename db "input", 0
    descriptor dd 0
    error_msg db "Input Format error", 0

section .text
global _start

; Ceasar Cipher function
; rcx - shift value
; rbx - string
; rdx - string length
; return: rax = encoded string
ceasar_cipher:
    mov r9, rcx
    xor rcx, rcx
    
    .loop:
    cmp rcx, rdx
    jge .exit
    movzx r12, byte [rbx + rcx]
    cmp r12, 'a'
    jl .isalpha_else
    cmp r12, 'z'
    jl .islower_condition
    cmp r12, 'A'
    jl .isalpha_else
    cmp r12, 'Z'
    jl .isupper_condition
    jmp .loop

    .islower_condition:
    sub r12, 'a'
    add r12, r9
    mov rax, r12
    push rdx
    xor rdx, rdx
    mov r12, 26
    div r12
    add rdx, 'a'
    mov byte [rbx + rcx], dl
    pop rdx
    jmp .loop_step

    .isupper_condition:
    sub r12, 'A'
    add r12, r9
    mov rax, r12
    push rdx
    xor rdx, rdx
    mov r12, 26
    div r12
    add rdx, 'A'
    mov byte [rbx + rcx], dl
    pop rdx
    jmp .loop_step

    .isalpha_else:

    .loop_step:
    inc rcx
    jmp .loop

    .exit:
    mov rax, rbx
    ret

_start:
    mov rax, 2
    mov rdi, filename
    mov rsi, 0
    mov rdx, 0
    syscall

    cmp rax, 0
    jle .file_format_error
    mov [descriptor], eax

    .read_key:
    mov rax, 0
    mov edi, [descriptor]
    mov rsi, shift_buffer
    mov rdx, 2
    syscall
    cmp rax, 0
    jle .file_format_error
    cmp rax, 2
    jl .file_format_error
    movzx r8, byte [shift_buffer]
    sub r8, '0'
    mov rcx, 0
    jmp .process_loop

    .process_loop:
    mov rax, 0
    mov edi, [descriptor]
    mov rsi, file_buffer
    mov rdx, 256
    syscall
    cmp rax, 0
    jle .exit
    mov rbx, file_buffer
    mov rdx, rax
    push rcx
    mov rcx, r8
    call ceasar_cipher
    mov r13, rax
    pop rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, r13
    mov rdx, rdx
    syscall
    jmp .process_loop

    .exit:
    mov rax, 60 ; exit
    xor rdi, rdi ; return code 0
    syscall

    .file_format_error:
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, error_msg ; error message
    mov rdx, 19 ; length of error message
    syscall
    mov rax, 60 ; exit
    xor rdi, rdi 
    mov rdi, 1 ; exit code 1 (error)
    syscall
