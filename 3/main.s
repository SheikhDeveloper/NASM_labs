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
    mov r9, rcx ; save shift value
    xor rcx, rcx ; counter = 0
    
    .loop:
    cmp rcx, rdx 
    jge .exit ; if counter >= string length, exit
    movzx r12, byte [rbx + rcx] ; get char
    cmp r12, 'a' 
    jl .isalpha_else ; if char < 'a', skip
    cmp r12, 'z'
    jle .islower_condition ; if 'a' <= char <= 'z', then it is lower case
    cmp r12, 'A'
    jl .isalpha_else ; if 'z' < char < 'A', skip
    cmp r12, 'Z'
    jle .isupper_condition ; if 'A' <= char <= 'Z', then it is upper case
    jmp .loop

    .islower_condition:
    sub r12, 'a'
    add r12, r9
    mov rax, r12
    push rdx
    xor rdx, rdx
    mov r12, 26
    div r12
    add rdx, 'a' ; rdx = (char - 'a' + shift) % 26 + 'a'
    mov byte [rbx + rcx], dl ; mov char to string
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
    add rdx, 'A' ; rdx = (char - 'A' + shift) % 26 + 'A'
    mov byte [rbx + rcx], dl ; mov char to string
    pop rdx
    jmp .loop_step

    .isalpha_else:

    .loop_step:
    inc rcx ; increment counter
    jmp .loop

    .exit:
    mov rax, rbx ; return encoded string
    ret

_start:
    mov rax, 2 ; open file filename
    mov rdi, filename
    mov rsi, 0 ; read only
    mov rdx, 0 ; no flags
    syscall

    cmp rax, 0 ; check if file opened successfully
    jle .file_format_error
    mov [descriptor], eax ; save file descriptor

    .read_key:
    mov rax, 0 ; read from descriptor
    mov edi, [descriptor] ; file descriptor
    mov rsi, shift_buffer
    mov rdx, 2 ; read 2 bytes
    syscall
    cmp rax, 0 ; check if read was successful
    jle .file_format_error
    cmp rax, 2 ; check if read 2 bytes
    jl .file_format_error
    movzx r8, byte [shift_buffer]
    sub r8, '0' ; key = int(string(shift_buffer))
    mov rcx, 0
    jmp .process_loop

    .process_loop:
    mov rax, 0 ; read from descriptor
    mov edi, [descriptor]
    mov rsi, file_buffer
    mov rdx, 256 ; read 256(buffer size) bytes
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
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, r13 ; encoded string
    mov rdx, rdx ; length of encoded string
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
