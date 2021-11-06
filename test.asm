.data
struct1: .space 8

.text
# store values to struct
la $t0, struct1
addi $t1, $zero, 0x00000011
addi $t2, $zero, 0x00000022
sw $t1, 0($t0)
sw $t2, 4($t0)

# get values from struct
la $t0, struct1
lw $t3, 0($t0)
lw $t4, 4($t0)
addi $v0, $zero, 1
add $a0, $zero, $t3
syscall
addi $v0, $zero, 1
add $a0, $zero, $t4
syscall

li $v0, 10
syscall

# print to console
sumNumbers:
numberLoop:
bge $t0, $a0, return
add $v1, $v1, $t0
addi $t0, $t0, 1
j numberLoop
return: jr $ra
