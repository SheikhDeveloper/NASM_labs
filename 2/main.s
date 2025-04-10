bits 64
;Task: Implement the insertion sort algorithm for matrix rows with binary search.
;Input: 32-bit integer array
;Output: Sorted array

section .data

matr1: dd 4  ; matrix 1
                                    ; 4 5 7 2
                                    ; 8 5 6 3
                                    ; 9 2 1 4
matr1_shape: dd 1, 1 ; shape 2x2
section .text
global _start

; Binary search for insertion sort
; Input: edi = arr, esi = key, r9d = right bound, bx = direction, r8d = left bound
; Output: r8d = index of searched element
binary_search:

    mov r8d, r13d

    .search_loop:
    cmp r8d, r9d ; left < right
    jge .end
    lea r10d, [r8d + r9d]
    shr r10d, 1 ; r10d = mid = (left + right) / 2

    mov eax, [edi + r10d * 4] ; eax = arr[mid]

    cmp bx, 0 ; if (direction == 0)
    jne .inverse
    cmp esi, eax
    jg .move_right ; if (key < arr[mid])
    jle .move_left

    .inverse:
    cmp esi, eax
    jl .move_right ; if (key > arr[mid])
    jge .move_left

    .move_right:
    mov r8d, r10d
    inc r8d ; left = mid + 1
    jmp .search_loop

    .move_left:
    mov r9d, r10d ; right = mid
    jmp .search_loop

    .end:
    ret


; Insertion sort with binary search
; Input: rdi = array, edx = size, bx = direction, r8d = left bound
insertion_sort:
    cmp edx, 1
    jle .end

    mov ecx, r8d ; i = left

    add edx, r8d ; size = left + size
     
    mov r13d, r8d ; r13d = left bound

    .loop:
    cmp ecx, edx ; i < size
    jge .end
    mov esi, [edi + ecx * 4] ; esi = key = arr[i]

    mov r9d, ecx
    inc r9d ; r12d = right = i + 1
    call binary_search
    mov r11d, [edi + ecx * 4] ; r11d = arr[i]
    mov eax, ecx ; j = i
    jmp .inner_loop

    .inner_loop:
    cmp eax, r8d ; j > left
    jle .post_inner_loop
    push rcx
    mov ecx, [edi + eax * 4 - 4] ; arr[j] = arr[j - 1]
    mov [edi + eax * 4], ecx
    pop rcx
    dec eax
    jmp .inner_loop

    .post_inner_loop:
    mov dword [edi + r8d * 4], r11d ; arr[left] = arr[i]
    inc ecx
    jmp .loop

    .end:
    ret

_start:
    mov r14d, [matr1_shape] ; r14d = number of rows
    mov edx, [matr1_shape + 4] ; edx = number of columns
    mov edi, matr1
    mov r8d, 0 ; left = 0
    mov r13d, 0

    ; r13d = i, r14d = number of rows
    .loop1:
    cmp r13d, r14d
    jge .post_loop1

    mov r15d, r13d
    imul r15d, edx
    mov r8d, r15d ; r8d = i * number of columns
    %ifdef REVERSE
    mov bx, 1
    %else
    mov bx, 0
    %endif
    push rdx
    push r13
    call insertion_sort
    pop r13
    pop rdx

    inc r13d
    jmp .loop1

    .post_loop1:
    mov r13d, 0
    imul edx, r14d ; edx = number of rows * number of columns
    jmp .loop2

    .loop2:
    cmp r13d, edx
    jge .end
    mov eax, [edi + r13d * 4]
    mov [matr1 + r13d * 4], eax ; mov matrix to memory
    inc r13d
    jmp .loop2

    .end:
    mov eax, 60
    xor rdi, rdi
    syscall
