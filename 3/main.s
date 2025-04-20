bits 64

section .data
    file_buffer times 256 db 0
    shift_buffer dq 0
    descriptor dd "input", 0

section .text
global _start

; Ceasar Cipher function
; rcx - shift value
; rbx - string
; rdx - string length
; return: rax = encoded string
ceasar_cipher:
    mov r9, rcx
    mov rcx, 0
    
    .loop:
    cmp rcx, rdx
    jge .exit
    cmp byte [rbx + rcx], 0
    je .loop
    mov r12, [rbx + rcx]
    add r12, r9
    mov [rbx + rcx], r12
    inc rcx
    jmp .loop

    .exit:
    mov rax, rbx
    ret

_start:
    .read_size:
    mov rax, 0
    mov rdi, descriptor
    mov rsi, shift_buffer
    mov rdx, 8
    syscall
    cmp rax, 0
    jle .exit
    cmp rax, 8
    jl .file_format_error
    mov r8, [shift_buffer]
    mov rcx, 0
    jmp .process_loop

    .process_loop:
    mov rax, 0
    mov rdi, descriptor
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
    mov rax, 60
    xor rdi, rdi
    syscall

    .file_format_error:
    mov rax, 1
    mov rdi, 1
    mov rsi, "IO error"
    mov rdx, 256
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
