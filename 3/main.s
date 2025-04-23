bits 64

section .data
    file_buffer times 256 db 0
    shift_buffer dq 0
    filename db "input", 0
    descriptor dd 0
    error_msg db "Input Format error", 0
    newline db 0xA ; '\n' symbol

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

; Trim spaces function
; Input: rbx - buffer, rdx - length
; Output: rdx - new length
trim_spaces:
    push rbx
    push rsi
    push rdi
    push rcx
    push rax

    mov rsi, rbx        ; Source pointer
    mov rdi, rbx        ; Destination pointer
    xor rcx, rcx        ; Source index
    xor rax, rax        ; Current char
    mov r9, 0           ; Previous char (0 - non-space, 1 - space)

    ; Skip leading spaces
    .skip_leading:
    cmp rcx, rdx
    jge .end_leading
    mov al, [rsi + rcx]
    cmp al, ' '
    jne .end_leading
    inc rcx
    jmp .skip_leading

    .end_leading:

    ; Main processing loop
    .loop:
    cmp rcx, rdx
    jge .end_loop
    mov al, [rsi + rcx]

    ; Check for newline character
    cmp al, 0x0A        ; '\n'
    je .handle_newline

    cmp al, ' '
    jne .not_space

    ; Handle space character
    cmp r9, 1
    je .skip_copy
    mov r9, 1
    mov [rdi], al
    inc rdi
    jmp .next

    .handle_newline:
    ; Copy newline and skip leading spaces after it
    mov [rdi], al
    inc rdi
    mov r9, 0           ; Reset previous space flag

    .skip_after_newline:
    inc rcx
    cmp rcx, rdx
    jge .end_loop       ; End of buffer
    mov al, [rsi + rcx]
    cmp al, ' '
    je .skip_after_newline
    dec rcx             ; Re-process the non-space character
    jmp .next

    .not_space:
    mov r9, 0
    mov [rdi], al
    inc rdi

    .skip_copy:
    .next:
    inc rcx
    jmp .loop

    .end_loop:

    ; Trim trailing spaces
    cmp rdi, rbx
    je .no_trailing
    dec rdi
    cmp byte [rdi], ' '
    jne .no_trailing_inc

    .trim_trailing_loop:
    cmp rdi, rbx
    jl .trim_done
    cmp byte [rdi], ' '
    jne .trim_done
    dec rdi
    jmp .trim_trailing_loop

    .trim_done:
    inc rdi

    .no_trailing_inc:
    inc rdi

    .no_trailing:
    mov rdx, rdi
    sub rdx, rbx        ; New length

    pop rax
    pop rcx
    pop rdi
    pop rsi
    pop rbx
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

    call trim_spaces

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
