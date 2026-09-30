.data
promptX: .asciiz "Enter x: "
promptN: .asciiz "Enter n: "
sAbs:    .asciiz "absolute(n):          "
sPow:    .asciiz "power(x,n):           "
sPowR:   .asciiz "powerRec(x,n):        "
sFact:   .asciiz "factorial(n):         "
sFactR:  .asciiz "factorialRec(n):      "
sFF:     .asciiz "fallingFact(x,n):     "
sFFR:    .asciiz "fallingFactRec(x,n):  "
nl:      .asciiz "\n"
one:     .float 1.0
minone:  .float -1.0

.text
.globl main
main:
# read float x
li   $v0, 4
la   $a0, promptX
syscall
li   $v0, 6              # read_float -> $f0
syscall
mov.s $f20, $f0          # keep x in $f20 (survives calls)

# read int n
li   $v0, 4
la   $a0, promptN
syscall
li   $v0, 5              # read_int -> $v0
syscall
move $s0, $v0            # keep n in $s0 (survives calls)

# absolute(n): $a0 -> $v0
move $a0, $s0
jal  absolute
move $a1, $v0
la   $a0, sAbs
jal  printIntLine

# power(x, n): $f12, $a1 -> $f0
mov.s $f12, $f20
move  $a1, $s0
jal   power
mov.s $f12, $f0
la    $a0, sPow
jal   printFltLine

# powerRec(x, n): $f12, $a1 -> $f0
mov.s $f12, $f20
move  $a1, $s0
jal   powerRec
mov.s $f12, $f0
la    $a0, sPowR
jal   printFltLine

# factorial(n): $a0 -> $v0
move $a0, $s0
jal  factorial
move $a1, $v0
la   $a0, sFact
jal  printIntLine

# factorialRec(n): $a0 -> $v0
move $a0, $s0
jal  factorialRec
move $a1, $v0
la   $a0, sFactR
jal  printIntLine

# fallingFact(x, n): $f12, $a0 -> $f0
mov.s $f12, $f20
move  $a0, $s0
jal   fallingFact
mov.s $f12, $f0
la    $a0, sFF
jal   printFltLine

# fallingFactRec(x, n): $f12, $a0 -> $f0
mov.s $f12, $f20
move  $a0, $s0
jal   fallingFactRec
mov.s $f12, $f0
la    $a0, sFFR
jal   printFltLine

li   $v0, 10
syscall

# ---- print helpers ----
printIntLine:            # $a0 = label, $a1 = int
li   $v0, 4
syscall
move $a0, $a1
li   $v0, 1
syscall
la   $a0, nl
li   $v0, 4
syscall
jr   $ra

printFltLine:            # $a0 = label, $f12 = float
li   $v0, 4
syscall
li   $v0, 2
syscall
la   $a0, nl
li   $v0, 4
syscall
jr   $ra

# ---------- paste your functions below ----------
    
    absolute:
        mov.s  $f0, $f12       # copy value to return register
        mtc1   $zero, $f4      # $f4 = 0.0
        c.lt.s $f12, $f4       # flag = ($f12 < 0.0)
        bc1f   absdone         # not negative -> done
        l.s    $f6, minone     # $f6 = -1.0
        mul.s $f0, $f12, $f6

    absdone:
        jr $ra 


    power:
        l.s $f0, one  #initiate result with 1 for later multiplications
        move $t0, $a1 #store the exponent to be incremented without losing
                    #the og value
        
    powerloop:
        blez $t0, powerdone #if exponent <= 0 finish

        mul.s $f0, $f0, $f12 #result *= base
        addi $t0, $t0, -1   #exponent--

        j powerloop

    powerdone:
        jr $ra

    powerRec:
        bne $a1, $zero, powerRecurse #if exp >0 continiue multiplications
        l.s $f0, one    #base^0 = 1 so return 1

        jr $ra


    powerRecurse:
        addi $sp, $sp, -8   #create 2 spaces worth of bytes in the stack
        sw $ra, 4($sp)      #store return adress in stack to get back later
        s.s $f12, 0($sp)    #store value in stack
        
        addi $a1, $a1, -1 #exponent --

        jal powerRec   
        
        l.s $f12, 0($sp) #restore base from stack
        lw $ra, 4($sp)  #restore return adress
        addi $sp, $sp, 8  #free 2 stack spaces

        mul.s $f0, $f12, $f0 #result = base* base ^exp-1
        jr $ra
        
    factorial:
        li $t0, 1 #use 1 for comparing base case
        li $v0, 1 #initialise result as 1

    factLoop:
        beq $a0, $zero, factDone #0!=1, so if x = 0 return 1
        beq $a0, $t0, factDone #1! = 1, so if x=1 return 1

        mul $v0, $v0, $a0  #result *=x
        addi $a0, $a0, -1 #i--

        j factLoop

    factDone:
        jr $ra

    factorialRec:
        beq $a0, $zero, factorialBase #same case for other factorial
        li $t0, 1
        beq $a0, $t0, factorialBase

    factorialRecursion:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        sw $a0, 0($sp)

        addi $a0, $a0, -1 #x--
        jal factorialRec

        lw $a0, 0($sp)
        lw $ra, 4($sp)
        addi $sp, $sp, 8

        mul $v0, $a0, $v0 #result = x*(x-1)!
        jr $ra

    factorialBase:
        li $v0, 1
        jr $ra

    fallingFact:
        l.s $f0, one #initiate result as 1
        l.s $f1, one  #store 1.0 to decrement x
        mov.s $f2, $f12 #copy x to be decremented but also keep og value

    falFactLoop:
        blez $a0, falFactDone #if n<= 0 finish
        mul.s $f0, $f0, $f2 #result *= x
        sub.s $f2, $f2, $f1 #x--
        addi $a0, $a0, -1 #n--
        j falFactLoop

    falFactDone:
        jr $ra


    fallingFactRec:
        blez $a0, fallingFactBase
        
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        s.s $f12, 0($sp)

        l.s $f1, one
        sub.s $f12, $f12, $f1
        addi $a0, $a0, -1
        jal fallingFactRec

        l.s $f12, 0($sp)
        mul.s $f0, $f0, $f12 
        lw $ra, 4($sp)
        addi $sp, $sp, 8

        jr $ra 

    fallingFactBase:
        l.s $f0, one
        jr $ra