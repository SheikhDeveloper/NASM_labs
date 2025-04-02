bits 64
;Task: Implement the insertion sort algorithm for matrix rows with binary search.
;Input: 32-bit integer array
;Output: Sorted array
section .data
%define MAX_SIZE 10

struc Array
    .shape : resq 2 ; shape[0] = rows, shape[1] = columns
    .ndim : resd 1 ; number of dimensions
    .dtype : resd 1 ; data type(0=int32)
    .strides : resq 2 ; strides[0] = row stride, strides[1] = column stride
    .data : resd MAX_SIZE
endstruc

arr:
    istruc Array
    at .shape, dq 3, 3 ; shape 3x3
    at .ndim, dd 2 ; 2 dims
    at .dtype, dd 0 ; int32
    at .strides, dq 12, 4 ; strides 12, 4
    at .data, dd 3, 4, 7, 8, 5, 6, 1, 2, 9, 0
    iend

section .text
global _start

; Binary search for insertion sort
; Input: rdi = arr, esi = key, rdx = size, bx = direction
; Output: rax = index of searched element
binary_search:
    xor r8, r8 ; left = 0
    mov r9, rdx ; right = size
    mov ecx, esi

    .search_loop:
    cmp r8, r9
    jg .end
    lea r10, [r8 + r9]
    shr r10, 1 ; r10 = mid = (left + right) / 2

    mov eax, [rdi + r10 * 4] ; eax = arr[mid]

    cmp bx, 0 ; if (direction == 0)
    jne .inverse
    cmp ecx, eax
    jl .move_left ; if (key < arr[mid])
    jge .move_right

    .inverse:
    cmp ecx, eax
    jg .move_left ; if (key > arr[mid])
    jle .move_right

    .move_right:
    mov r8, r10
    inc r8 ; left = mid + 1
    jmp .search_loop

    .move_left:
    mov r9, r10 ; right = mid
    jmp .search_loop


insertion_sort_1d:
; rdi = arr, rsi = size
    dec rsi
    jz .end

    .outer:
    mov eax, [rdi + rsi * 4 - 4]
    cmp eax, [rdi + rsi * 4]
    jle .no_swap

    .end:
    ret
