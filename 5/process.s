bits 64

section .bss
    buffer: resq 64

section .text
global process_image_asm

process_image_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Сохраняем аргументы
    mov r14, rdi        ; image pointer
    mov r15, rsi        ; width
    mov rbx, rdx        ; height
    mov r12, rcx        ; channels

    ; Вычисляем размер буфера: width * height * channels
    mov rax, r15
    imul rax, rbx
    imul rax, r12
    mov r8, rax         ; сохраняем размер

    ; Копируем исходное изображение в буфер
    mov rsi, r14        ; источник (image)
    mov rdi, [buffer]        ; приемник (buffer)
    mov rcx, r8         ; количество байт
    cld
    rep movsb

    ; Обработка изображения: отражение по вертикали
    xor rbp, rbp        ; y = 0

.loop_y:
    cmp rbp, rbx        ; y < height?
    jge .end_loop_y

    ; mirrored_y = height - 1 - y
    mov rax, rbx
    dec rax
    sub rax, rbp

    ; buffer_row_start = mirrored_y * (width * channels)
    mov rdx, r15
    imul rdx, r12
    imul rdx, rax

    ; image_row_start = y * (width * channels)
    mov r10, rbp
    imul r10, r15
    imul r10, r12

    xor r11, r11        ; x = 0

.loop_x:
    cmp r11, r15        ; x < width?
    jge .end_loop_x

    ; buffer_pixel_start = buffer_row_start + x * channels
    mov rax, r11
    imul rax, r12
    add rax, rdx

    ; image_pixel_start = image_row_start + x * channels
    mov r9, r11
    imul r9, r12
    add r9, r10

    ; Копируем каналы из буфера в изображение
    mov rsi, r13
    add rsi, rax        ; источник: buffer + buffer_pixel_start
    mov rdi, r14
    add rdi, r9         ; приемник: image + image_pixel_start

    mov rcx, r12        ; количество байт (channels)
    rep movsb           ; копируем

    inc r11             ; x++
    jmp .loop_x

.end_loop_x:
    inc rbp             ; y++
    jmp .loop_y

.end_loop_y:
    ; Освобождаем буфер

.error:
    ; Восстанавливаем регистры и возвращаемся
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
