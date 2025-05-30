bits 64

section .text
global process_image_asm

process_image_asm:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r9, [rdi]       ; r9 = *image (указатель на данные изображения)
    mov eax, esi        ; width
    imul eax, ecx       ; eax = width * channels (line_size)
    mov r8d, eax        ; r8d = line_size
    mov r10d, edx       ; r10d = height

    mov eax, r10d
    shr eax, 1          ; eax = height / 2
    test eax, eax
    jz .end_func        ; Если 0, выход

    mov r14, r9         ; r14 = начало верхней строки (y)
    mov r15, r9         ; r15 = будет началом нижней строки (mirrored_y)
    mov eax, r10d
    dec eax             ; eax = height - 1
    imul eax, r8d       ; eax = (height-1) * line_size
    add r15, rax        ; r15 = адрес последней строки

    mov r12d, r10d      ; Сохраняем height в r12d
    shr r12d, 1         ; r12d = количество итераций (height/2)

.loop_y:
    mov rsi, r14        ; rsi = текущая верхняя строка
    mov rdi, r15        ; rdi = текущая нижняя строка
    mov ecx, r8d        ; ecx = line_size (счетчик байт)

    mov r11, rcx
    shr r11, 3          ; r11 = количество 8-байтовых блоков
    jz .rest_bytes      ; Если нет полных блоков, перейти к остатку

.loop_qword:
    mov rax, [rsi]      ; Загружаем 8 байт из верхней строки
    mov rdx, [rdi]      ; Загружаем 8 байт из нижней строки
    mov [rsi], rdx      ; Сохраняем в верхнюю строку
    mov [rdi], rax      ; Сохраняем в нижнюю строку
    add rsi, 8
    add rdi, 8
    dec r11
    jnz .loop_qword

.rest_bytes:
    ; Обработка оставшихся байтов (0-7)
    mov rcx, r8
    and rcx, 7          ; rcx = остаток байтов
    jz .next_line       ; Если остатка нет, перейти к след. строке

.loop_byte:
    mov al, [rsi]       ; Читаем байт из верхней строки
    mov dl, [rdi]       ; Читаем байт из нижней строки
    mov [rsi], dl       ; Пишем в верхнюю строку
    mov [rdi], al       ; Пишем в нижнюю строку
    inc rsi
    inc rdi
    loop .loop_byte

.next_line:
    ; Переход к следующим строкам
    add r14, r8         ; Сдвигаем верхний указатель вниз
    sub r15, r8         ; Сдвигаем нижний указатель вверх
    dec r12d            ; Уменьшаем счетчик итераций
    jnz .loop_y

.end_func:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
