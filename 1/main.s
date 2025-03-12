bits 64
;res = (d * a) / (a + b * c) + (d + b) / (e - a)
section .data
res:
    dq 0
a:
    dw 30
b:
    dw 10
c:
    dd 35
d:
    dd 25
e:
    dd 15

section .text
global _start
_start:
    movsx eax, word[b]
    movsx ebx, word[a]
    mov ecx, dword[c]
    mov r11d, ebx ; r11d = a
    mov r12d, eax ; r12d = b

    imul ecx ; edx:eax = b * c

    sal rdx, 32
    or rdx, rax ; rdx = b * c

    jo ovf_err

    mov r13, rdx ; r13 = b * c

    add rbx, r13 ; rbx = a + b * c

    jo ovf_err

    mov ecx, dword[d]
    mov rax, 0
    mov eax, ebx ; eax = a

    imul ecx ; edx:eax = d * a

    sal rdx, 32
    or rdx, rax ; rdx = d * a

    jo ovf_err

    mov rax, rdx ; rax = d * a

    test rbx, rbx ; Check if (a + b * c) == 0

    jz div_zero_err

    cdq
    idiv rbx ; rax = (d * a) / (a + b * c)

    mov rsi, rax
    movsx eax, r12d
    movsx ebx, r11d
    add eax, ecx ; eax = (d + b)

    jo ovf_err

    mov ecx, dword[e] ; ecx = e 
    sub ecx, ebx ; ecx = e - a

    jo ovf_err

    test ecx, ecx ; Check if (e - a) == 0

    jz div_zero_err

    cdq
    idiv ecx ; eax = (d + b) / (e - a)

    add rax, rsi ; rax = (d * a) / (a + b * c) + (d + b) / (e - a)

    jo ovf_err

    mov [res], rax

    mov rax, 60
    mov rdi, 0
    syscall
ovf_err:
    mov rax, 60
    mov rdi, 1
    syscall
div_zero_err:
    mov rax, 60
    mov rdi, 2
    syscall
