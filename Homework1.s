.data
one:     .float 1.0
minone:  .float -1.0
epsilon: .float 0.01

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

    mov.s $f20, $f12 #move x to the args register
    mov.s $f22, $f14 #move k to the other arg register

    jal absolute #get the abs value of x
    l.s $f4, one #save 1.0 for comparison
    c.le.s $f4, $f0 #|X|>=1.0
    bc1t binomialZero #if true skip the rest

    #if false continue from here
    l.s $f26, one #term = 1.0
    l.s $f24, one #sum = 1.0
    li $s0, 1  #n=1
    l.s $f28, epsilon #e=0.01
    li $s1, 100000 #loop limit

binomialLoop:
    mov.s $f12, $f26 #move term to arg register
    jal absolute #$f0 is now |term|
    c.le.s $f0, $f28 #|term| <= epsilon
    bc1t binomialDone #if true then we are done
   
    #if not continue from here
    mov.s $f12, $22 #move k to arg register
    move $a0, $s0 #move n to arg register
    jal fallingFact #f0 is now fallingFact(k,n)
    mov.s $f26, $f0 #temporarily overwrite term, gonna get overwritten anyways

    move $a0, $s0 #n -> arg again, last function reset it to 0
    jal factorial #v0 is now n!
    mtc1 $v0, $f4 #copy the bits of n to a float register
    cvt.s.w $f4, $f4 #convert int to float
    div.s $f26, $f26, $f4 #term = fallingFact(k,n)/n!

    mov.s $f12, $f20 #move x to arg register
    move $a0, $s0 #move n to args reg
    jal power #$f0 is now x^n
    mul.s $f26, $f26, $f0 #term is now (falingFact/Factorial)*x^n

    add.s $f24, $f24, $f26 #sum+=term
    addi $s0, $s0, 1 #n++
    bgt $s0, $s1, binomialDone
    j binomialLoop #back to loop


binomialZero:
    mtc1 $zero, $f24

binomialDone:
    mov.s $f0, $f24 #return value = sum
    lw $ra, 28($sp) #restore everything from binomialSeries
    lw $s0, 24($sp)
    l.s $f20, 20($sp)
    l.s $f22 16($sp)
    l.s $f24, 12($sp)
    l.s $f26, 8($sp)
    l.s $f26, 4($sp)
    addi $sp, $sp, 32 #free stack space
    jr $ra #return

binomialRecursiveR:
    addi $sp, $sp, -24 #create 6 words worth of stack
    sw $ra, 20($sp) #save the return address
    sw $s0, 16($sp) #s0 = x
    s.s $f20,12($sp) #$f20 - x
    s.s $f22 8($sp) #$f22=k
    s.s $f24, 4($sp) #$f24=e
    s.s $f26, 0($sp) #$f26=next_term

    mov.s $f20, $f12, #copy x to arg reg
    mov.s $f22, $f14 #copy k to args reg
    move $s0, $a0 #copy n to args reg
    mov.s $f24, $f18 #copy epsilon to arg reg

    
 




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