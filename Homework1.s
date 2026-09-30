.data
one:     .float 1.0
minone:  .float -1.0

.text
.globl main



binomialSeries:
        addi  $sp, $sp, -32            # create 8 words worth of stack
        sw    $ra, 28($sp)             # save return address to jump again
        sw    $s0, 24($sp)             # $s0 = n
        s.s   $f20, 20($sp)            # $f20 = x
        s.s   $f22, 16($sp)            # f22 = k
        s.s   $f24, 12($sp)            # f24 = sum
        s.s   $f26, 8($sp)             # f26 = term
        s.s   $f28, 4($sp)             # f28 = e
        s.s   $f30, 0($sp)             # f30 for results
 




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