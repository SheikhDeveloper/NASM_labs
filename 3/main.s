bits 64

%define BUFFER_SIZE 10

section .data
    file_buffer times BUFFER_SIZE db 0
    shift_buffer dq 0
    filename db "input", 0
    env_src db "SRC=", 0
    env_key db "KEY=", 0
    descriptor dd 0
    error_msg db "Input Format error", 0
    env_error_msg db "ENV arguments error", 0
    newline db 0xA ; '\n' symbol

section .bss
    src_ptr resq 1
    key_ptr resq 1

section .text
global _start

; String length function
; Input: rbx - string
; Output: rax - string length
string_len:
    mov rax, 0
    .loop:
    cmp byte [rbx + rax], 0
    je .exit
    inc rax
    jmp .loop
    .exit:
    ret

; Ceasar Cipher function
; rcx - shift value
; rbx - string
; rdx - string length
; return: rax = encoded string
ceasar_cipher:
    push r9
    mov r9, rcx ; save shift value
    xor rcx, rcx ; counter = 0
    
    .loop:
    cmp rcx, rdx 
    jge .exit ; if counter >= string length, exit
    movzx r12, byte [rbx + rcx] ; get char
    cmp r12, 'A' 
    jl .isalpha_else ; if char < 'A', skip
    cmp r12, 'Z'
    jle .isupper_condition ; if 'A' <= char <= 'Z', then it is lower case
    cmp r12, 'a'
    jl .isalpha_else ; if 'Z' < char < 'a', skip
    cmp r12, 'z'
    jle .islower_condition ; if 'a' <= char <= 'z', then it is upper case
    jg .isalpha_else ; if char > 'z', skip
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
    pop r9
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
    ;mov r9, 0           ; Previous char (0 - non-space, 1 - space, 2 - newline)

    ; Skip leading spaces
    .skip_leading:
    cmp r9, 1
    cmp r9, 2
    jne .end_leading
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
    mov r9, 2           ; Reset previous space flag

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

    mov rax, [rsp] ; get argc
    lea rsi, [rsp + 8] ; rsi = argv[0]
    mov rcx, rax
    shl rcx, 3 ; rcx = rcx * 8 (8 bytes per argument)
    add rsi, rcx ; rsi = address of argv[argc]
    add rsi, 8 ; skip NULL argument
    mov rbx, rsi ; rbx = envp[0]
    mov r12, rsi ; r12 = envp[0], to search for KEY

    mov r9, 1

    .find_src:
    mov rdx, [rbx] ; rdx = envp[i] pointer
    test rdx, rdx
    jz .env_args_error
    mov rsi, rdx ; rsi = envp[i] string
    mov rdi, env_src ; rdi = "SRC="
    mov rcx, 4
    repe cmpsb
    je .found_src
    add rbx, 8 ; go to next envp string
    mov r12, rbx
    jmp .find_src
    
    .found_src:
    mov rax, [rbx] 
    lea rax, [rax + 4]
    mov [src_ptr], rax

    .after_src:
    mov rbx, r12 ; rbx = envp[0]

    .find_key:
    mov rdx, [rbx] ; rdx = envp[i] pointer
    test rdx, rdx
    jz .env_args_error
    mov rsi, rdx ; rsi = envp[i] string
    mov rdi, env_key ; rdi = "KEY="
    mov rcx, 4
    repe cmpsb
    je .found_key
    add rbx, 8
    jmp .find_key

    .found_key:
    mov rax, [rbx]
    lea rax, [rax + 4]
    mov [key_ptr], rax

    .open_file:
    mov rax, 2 ; open file src_ptr
    mov rdi, [src_ptr]
    mov rsi, 0 ; read only
    mov rdx, 0 ; no flags
    syscall

    cmp rax, 0 ; check if file opened successfully
    jle .file_format_error
    mov [descriptor], eax ; save file descriptor

    .read_key:
    mov r11, [key_ptr]
    mov rcx, 0 
    mov rbx, r11
    call string_len
    mov r15, rax
    mov rcx, rax
    sub rcx, 1
    mov r8, 0

    .read_key_loop:
    cmp rcx, -1
    jle .get_true_key
    movzx r14, byte [r11 + rcx]
    sub r14, '0' ; convert char digit of key to int
    mov r13, r15
    sub r13, rcx
    dec r13
    jmp .inner_key_loop

    .inner_key_loop:
    cmp r13, 0 
    jle .post_inner_key_loop
    push rax
    push rcx
    mov rax, r14
    mov rcx, 10
    mul rcx
    mov r14, rax
    pop rcx
    pop rax
    dec r13
    jmp .inner_key_loop

    .post_inner_key_loop:
    add r8, r14 ; r14 = key[len - i - 1] * (10 ^ i), r8 sums up to key
    dec rcx
    jmp .read_key_loop

    .get_true_key:
    mov rax, r8
    mov rcx, 26
    xor rdx, rdx
    div rcx
    mov r8, rdx

    .process_loop:
    mov rax, 0 ; read from descriptor
    mov edi, [descriptor]
    mov rsi, file_buffer
    mov rdx, BUFFER_SIZE ; read BUFFER_SIZE bytes
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
    cmp rdx, 0
    jle .process_loop
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

    .env_args_error:
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, env_error_msg ; error message
    mov rdx, 20 ; length of error message
    syscall
    mov rax, 60 ; exit
    xor rdi, rdi 
    mov rdi, 2 ; exit code 2 (error)
    syscall

