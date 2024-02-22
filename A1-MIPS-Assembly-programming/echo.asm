# First line - input string consisting of 100 or less characters
# Output - prints the string
.data
    prompt : .asciiz "Echo what : "
.text
.globl main
main:
    li $v0, 4                
    la $a0, prompt
    syscall                  # prints "Echo what : " in the console

    li $v0, 9                # to take the input onto heap, $v0 contains the base address
    li $a0, 105              # allocating memory in heap for the input string
    syscall                  

    add $a0, $v0, $zero      # $a0 contains address of input buffer
    li $a1, 105              # maximum number of characters to read
    li $v0, 8                # service 8: read string
    syscall

    li $v0, 4                # service 4: print string, $a0 already contains address of string
    syscall                  # prints string

    li $v0, 10               # service 10: termination/exit
    syscall 