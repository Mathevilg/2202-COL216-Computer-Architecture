# First line - Input size of array (n) (n is positive integer)
# Next n lines - Elements of the array (must be integers and in non decreasing order)
# Final line - Integer which needs to be searched in the array (x)
# Note - In case of repeated ocurrence of x in array, only one correct index is returned
# Output - "Yes at index [index]" if integer exists in the array else "Not Found"
.data
prompt: .asciiz "Enter the size of array: "
prompt1: .asciiz "Enter array element: "
prompt2: .asciiz "Enter number to be found: "
prompty: .asciiz "Yes at index "
promptn: .asciiz "Not Found"
.text
.globl main
main:
    li $v0, 4                   # service : print string
    la $a0, prompt              # argument : prompt
    syscall                     # console now has "Enter the size of array: " printed
    li $v0, 5                   # service : read integer
    syscall                     # $v0 contains the integer "n" when we enter the integer
    add $a0, $v0, $zero         # store the integer n to $a0 
    addi $t3, $v0, 0            # store the integer n to $t3
    addi $t4, $v0, -1           # store the integer n-1 to $t4
    add $s1, $zero, $zero       # counter s1 initialised to 0 for taking n inputs

    sll $a0, $a0, 2             # $a0 has integer 4n, the memory required to store the array
    li $v0, 9                   # Service - sbrk for allocating 4n heap memory
    syscall                     # $v0 has base address of the heap memory allocated
    add $t0, $v0, $zero         # dynamic address of start of the heap memory, points to end after Loop
    add $t1, $v0, $zero         # static address of start of the heap memory 

Loop:                           # reads input array and stores in heap
    beq $s1, $t3, binarysearch  # if counter s1 = n then branch to "binarysearch" after storing inputs
    li $v0, 4                   # service : print string
    la $a0, prompt1             # argument : prompt1
    syscall                     # console now has "Enter array element: " printed
    li $v0, 5                   # service : read integer
    syscall                     # $v0 contains the integer "a[i]" when we enter the integer
    sw $v0, 0($t0)              # store the array integer in current memory pointer
    addi $t0, $t0, 4            # increment the memory pointer by 4 bytes
    addi $s1, $s1, 1            # increment the counter by 1, until it is n 
    j Loop                      # jump to Loop

binarysearch:                   # reads number to be found and processes
    li $v0, 4                   # service : print string
    la $a0, prompt2             # argument : prompt2
    syscall                     # console now has "Enter number to be found: " printed
    li $v0, 5                   # service : read integer
    syscall                     # $v0 contains the integer "x" when we enter the integer
    add $t2, $v0, $zero         # store the integer x to $t2
    add $s1 $zero $zero         # store integer 0 to $s1, where the invariant: s1 has left and t4 has right pointer

Loop2:                          # binary search by iteration
    ble $s1, $t4, Search        # if left <= right, jump to search, else the number is not found.
    li $v0, 4                   # service : print string
    la $a0, promptn             # argument : promptn
    syscall                     # console now has "Not found: " printed
    jr $ra                      # jump to return address, so program terminates
Search:
    add $t5, $t4, $s1           # $t5 has left+right
    srl $t6, $t5, 1             # $t6 has (left+right)/2 (integer division)  
    sll $t7, $t6, 2             # $t7 has ((left+right)/2)*4 which is the offset from the base address $t1
    add $t7, $t7, $t1           # $t7 now has the address in memory where a[(left+right)/2] is stored
    lw $s2, 0($t7)              # $s2 has the number stored at a[(left+right)/2] in memory
    beq $s2, $t2, return        # if a[(left+right)/2]==x, jump to return and return mid
    blt $s2, $t2, less          # if a[(left+right)/2]<x, jump to less and make the left pointer mid+1
    add $t4, $t6, -1            # else if a[(left+right)/2]>x, make right pointer mid-1
    j Loop2                     # jump to Loop2
less:
    addi $s1, $t6, 1            # Make the left pointer mid+1 if a[(left+right)/2]<x
    j Loop2                     # jump to Loop2
return:
    li $v0, 4                   # service : print string
    la $a0, prompty             # argument : prompty
    syscall                     # console now has "Yes at index: " printed
    li $v0, 1                   # service : print integer
    addi $a0, $t6, 0            # $a0 has mid, the index where x is
    syscall                     # console now has the mid value (or index where it is found) printed
    jr $ra                      # jump to return address, so program terminates