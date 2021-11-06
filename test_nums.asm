.data
numCol: .word 0x000000ff
displayAddress: .word 0x10008000

.text
lw $a0, displayAddress
jal draw_0
jal draw_1
jal draw_2
jal draw_3
jal draw_4
jal draw_5
jal draw_6
jal draw_7
jal draw_8
lw $a0, displayAddress
addi $a0, $a0, 768
jal draw_9

j Exit

Exit:
li $v0, 10 # terminate the program gracefully
syscall

# functions

draw_0:
# $a0 is the address of the top left pixel
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 8($a0)
sw $t0, 128($a0)
sw $t0, 256($a0)
sw $t0, 384($a0)
sw $t0, 512($a0)
sw $t0, 516($a0)
sw $t0, 136($a0)
sw $t0, 264($a0)
sw, $t0, 392($a0)
sw, $t0, 520($a0)

addi $a0, $a0, 16
jr $ra

draw_1:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 128($a0)
sw $t0, 256($a0)
sw $t0, 384($a0)
sw $t0, 512($a0)

addi $a0, $a0, 8
jr $ra

draw_2:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 132($a0)
sw $t0, 260($a0)
sw $t0, 256($a0)
sw $t0, 384($a0)
sw $t0, 512($a0)
sw $t0, 516($a0)

addi $a0, $a0, 12
jr $ra

draw_3:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 132($a0)
sw $t0, 260($a0)
sw $t0, 256($a0)
sw $t0, 388($a0)
sw $t0, 516($a0)
sw $t0, 512($a0)

addi $a0, $a0, 12
jr $ra

draw_4:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 128($a0)
sw $t0, 256($a0)
sw $t0, 260($a0)
sw $t0, 8($a0)
sw $t0, 136($a0)
sw $t0, 264($a0)
sw $t0, 392($a0)
sw $t0, 520($a0)

addi $a0, $a0, 16
jr $ra

draw_5:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 128($a0)
sw $t0, 256($a0)
sw $t0, 260($a0)
sw $t0, 388($a0)
sw $t0, 516($a0)
sw $t0, 512($a0)

addi $a0, $a0, 12
jr $ra

draw_6:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 8($a0)
sw $t0, 128($a0)
sw $t0, 256($a0)
sw $t0, 384($a0)
sw $t0, 512($a0)
sw $t0, 516($a0)
sw $t0, 520($a0)
sw $t0, 392($a0)
sw $t0, 264($a0)
sw $t0, 260($a0)

addi $a0, $a0, 16
jr $ra

draw_7:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 8($a0)
sw $t0, 136($a0)
sw $t0, 264($a0)
sw $t0, 392($a0)
sw $t0, 520($a0)

addi $a0, $a0, 16
jr $ra

draw_8:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 8($a0)
sw $t0, 128($a0)
sw $t0, 136($a0)
sw $t0, 256($a0)
sw $t0, 260($a0)
sw $t0, 264($a0)
sw $t0, 384($a0)
sw $t0, 392($a0)
sw $t0, 512($a0)
sw $t0, 516($a0)
sw $t0, 520($a0)

addi $a0, $a0, 16
jr $ra

draw_9:
lw $t0, numCol
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t0, 8($a0)
sw $t0, 128($a0)
sw $t0, 136($a0)
sw $t0, 256($a0)
sw $t0, 260($a0)
sw $t0, 264($a0)
sw $t0, 392($a0)
sw $t0, 512($a0)
sw $t0, 516($a0)
sw $t0, 520($a0)

addi $a0, $a0, 16
jr $ra








