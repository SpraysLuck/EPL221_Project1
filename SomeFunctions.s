        .data
promptK:  .asciiz "Enter k (float): "
promptN:  .asciiz "Enter n (int): "
msgIter:  .asciiz "falFact  = "
msgRec:   .asciiz "\nfalFactR = "
newline:  .asciiz "\n"

        .text
        .globl main
main:
        # --- read k (float) ---
        li    $v0, 4
        la    $a0, promptK
        syscall
        li    $v0, 6            # read float -> $f0
        syscall
        mov.s $f20, $f0         # keep k in $f20 (callee-saved)

        # --- read n (int) ---
        li    $v0, 4
        la    $a0, promptN
        syscall
        li    $v0, 5            # read int -> $v0
        syscall
        move  $s0, $v0          # keep n in $s0 (callee-saved)

        # --- iterative version ---
        mov.s $f12, $f20        # arg k
        move  $a0, $s0          # arg n
        jal   falFact           # result in $f0

        li    $v0, 4
        la    $a0, msgIter
        syscall
        mov.s $f12, $f0
        li    $v0, 2            # print float
        syscall

        # --- recursive version ---
        mov.s $f12, $f20
        move  $a0, $s0
        jal   falFactR          # result in $f0

        li    $v0, 4
        la    $a0, msgRec
        syscall
        mov.s $f12, $f0
        li    $v0, 2
        syscall

        li    $v0, 4
        la    $a0, newline
        syscall

        li    $v0, 10           # exit
        syscall

# ------------------------------------------------
# float falFact(float k, int n)
#   in:  $f12 = k, $a0 = n
#   out: $f0  = product
falFact:
        li.s $f0, 1.0
        li.s $f1, 1.0
        mov.s $f2, $f12 

falFactLoop:
        blez $a0, falFactDone
        mul.s $f0, $f0, $f2
        sub.s $f2, $f2, $f1
        addi $a0, $a0, -1
        j falFactLoop


falFactDone:
        jr    $ra

# ------------------------------------------------
# float falFactR(float k, int n)
#   in:  $f12 = k, $a0 = n
#   out: $f0  = result
falFactR:
        blez $a0, falFactBase
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        s.s $f12, 0($sp)

        li.s $f1, 1.0
        sub.s $f12, $f12, $f1
        addi $a0, $a0, -1
        jal falFactR

        l.s $f12, 0($sp)
        mul.s $f0, $f0, $f12
        lw $ra, 4($sp)
        addi $sp, $sp, 8

        jr $ra


falFactBase:
        li.s $f0, 1
        jr $ra