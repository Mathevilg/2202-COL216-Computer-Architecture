# First line - Input base (non negative integer) (x)
# Second line - Input exponent (non negative integer) (n)s
# Output - Returns the integer x^n computed by fast_expos
# Note - 0^n returns 1 if n=0, else returns 0
# The function only works when x^n < 2^31 as given the result does not overflow
.data
    prompt1 : .asciiz "Base : "
    prompt2 : .asciiz "Exponent : "
.text
.globl main
main:
    li $v0, 4             # service : print string
    la $a0, prompt1       # argument : prompt1
    syscall               # console now has "Base : " printed
    li $v0, 5             # service : read integer
    syscall               # $v0 contains the integer when we enter the integer
    add $s0, $v0, $zero   # store the integer to $s0         

    li $v0, 4             # service : print string
    la $a0, prompt2       # argument : prompt2
    syscall               # console now has "Exponent : " printed
    li $v0, 5             # service : read integer
    syscall               # $v0 contains the integer when we enter the integer
    add $s1, $v0, $zero   # store the integer to $s1      

    add $a0, $zero, $s0   # $a0 now contains the base
    add $a1, $zero, $s1   # $a1 now contains the exponent

    addi $sp, $sp, -4     # adjust stack pointer for 1 item
    sw $ra, 0($sp)        # store return address to the stack  
    jal fastPow           # jump to fastPow with arguments (base, exponent) and link $ra to the next line
    lw $ra, 0($sp)        # restore return address from the stack
    addi $sp, $sp, 4      # re adjust stack pointer

    add $a0, $v0, $zero   # argument : integer
    li $v0, 1             # service : print integer
    syscall

    li $v0, 10            # service 10: termination/exit
    syscall 

fastPow:
    bne $a1, $zero, EVEN  # if exponent != 0 then branch to EVEN case
    addi $v0, $zero, 1    # else return 1
    jr $ra                # jump to return address

EVEN:  
    srl $t1, $a1, 1       
    sll $t1, $t1, 1       # check if exponent is even
    bne $t1, $a1, ODD     # branch to ODD if exponent is odd

    mul $a0, $a0, $a0     # base <- base*base
    srl $a1, $a1, 1       # exponent <- exponent/2

    addi $sp, $sp, -4     # adjust stack pointer for 1 item
    sw $ra, 0($sp)        # store return address to the stack  

    jal fastPow           # jump to fastPow with arguments (base, exponent) and link $ra to the next line

    lw $ra, 0($sp)        # restore return address from the stack
    addi $sp, $sp, 4      # re adjust stack pointer

    jr $ra                # jump to return address

ODD:
    add $t0, $a0, $zero   # store the base
    mul $a0, $a0, $a0     # base <- base*base
    srl $a1, $a1, 1       # exponent <- (exponent-1)/2

    addi $sp, $sp, -8     # adjust stack for 2 items
    sw $ra, 0($sp)        # store return address to the stack   
    sw $t0, 4($sp)        # store base to the stack

    jal fastPow           # jump to fastPow with arguments (base, exponent) and link $ra to the next line

    lw $ra, 0($sp)        # restore return address from the stack
    lw $t0, 4($sp)        # restore base from the stack
    addi $sp, $sp, 8      # re adjust stack pointer

    mul $v0, $v0, $t0     # return value <- base * fastPow(base*base, (exponent-1)/2)

    jr $ra                # jump to return address