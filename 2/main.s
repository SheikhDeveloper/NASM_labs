bits 64
;Task: Implement the selection sort algorithm for matrix rows with binary search.
;Input: 32-bit integer array
;Output: Sorted array
section .data
    array dd 0
    size dd 0
    temp dd 0
    search dd 0

section .text
global _start
