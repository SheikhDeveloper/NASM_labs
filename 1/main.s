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
    movsx eax, word[a]
    movsx ebx, word[b]
    imul ebx, dword[c]

    jo ovf_err

    add ebx, eax

    jo ovf_err

    imul eax, dword[d]

    jo ovf_err

    idiv ebx

    jz div_zero_err

    mov [res], rax
    movsx eax, word[b]
    movsx ebx, word[a]
    mov edx, 0
    mov ecx, dword[e] 
    sub ecx, ebx
    add eax, dword[d]

    jo ovf_err

    idiv ecx

    jz div_zero_err

    add rax, [res]

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
