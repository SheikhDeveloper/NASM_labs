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
    mov ecx, dword[c]
    imul ebx, ecx

    jo ovf_err

    add ebx, eax

    jo ovf_err

    mov ecx, dword[d]

    imul ecx

    jo ovf_err

    test ebx, ebx

    jz div_zero_err

    idiv ebx

    mov rsi, rax
    movsx eax, word[b]
    movsx ebx, word[a]
    add eax, ecx

    jo ovf_err

    mov ecx, dword[e] 
    sub ecx, ebx

    jo ovf_err

    test ecx, ecx

    jz div_zero_err

    cdq
    idiv ecx

    add rax, rsi

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
