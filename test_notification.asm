.data
displayAddress: .word 0x10008000
letterCol: .word 0x00ff0000
bgCol: .word 0x00f7fcd4

.text
lw $t0, displayAddress
addi $t0, $t0, 3984
add $a0, $zero, $t0
# jal draw_a
# jal draw_w
# jal draw_e
# jal draw_s
# jal draw_o
# jal draw_m
# jal draw_e
# lw $t0, displayAddress
# addi $t0, $t0, 3988
# add $a0, $zero, $t0
# jal draw_p
# jal draw_o
# jal draw_g
# jal draw_g
# jal draw_e
# jal draw_r
# jal draw_s
lw $t0, displayAddress
addi $t0, $t0, 4036
add $a0, $zero, $t0
jal draw_w
jal draw_o
jal draw_w

Exit:
li $v0, 10 # terminate the program gracefully
syscall


# functions
draw_a:
# $a0 is the bottom left pixel
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, 8($a0)
sw $t1, -128($a0)
sw $t1, -124($a0)
sw $t1, -120($a0)
sw $t1, -256($a0)
sw $t1, -248($a0)
sw $t1, -384($a0)
sw $t1, -380($a0)
sw $t1, -376($a0)

addi $a0, $a0, 16
jr $ra

draw_w:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, 4($a0)
sw $t1, 8($a0)
sw $t1, 12($a0)
sw $t1, 16($a0)
sw $t1, -128($a0)
sw $t1, -120($a0)
sw $t1, -112($a0)
sw $t1, -256($a0)
sw $t1, -240($a0)

addi $a0, $a0, 24
jr $ra

draw_e:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, -128($a0)
sw $t1, -256($a0)
sw $t1, -384($a0)
sw $t1, -512($a0)
sw $t1, 4($a0)
sw $t1, -252($a0)
sw $t1, -508($a0)

addi $a0, $a0, 12
jr $ra

draw_s:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, 4($a0)
sw $t1, -124($a0)
sw $t1, -252($a0)
sw $t1, -256($a0)
sw $t1, -384($a0)
sw $t1, -512($a0)
sw $t1, -508($a0)

addi $a0, $a0, 12
jr $ra

draw_o:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, 4($a0)
sw $t1, 8($a0)
sw $t1, -128($a0)
sw $t1, -120($a0)
sw $t1, -256($a0)
sw $t1, -248($a0)
sw $t1, -384($a0)
sw $t1, -380($a0)
sw $t1, -376($a0)

addi $a0, $a0, 16
jr $ra

draw_m:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, 16($a0)
sw $t1, -128($a0)
sw $t1, -120($a0)
sw $t1, -112($a0)
sw $t1, -256($a0)
sw $t1, -252($a0)
sw $t1, -248($a0)
sw $t1, -244($a0)
sw $t1, -240($a0)

addi $a0, $a0, 24
jr $ra

draw_p:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, -128($a0)
sw $t1, -256($a0)
sw $t1, -252($a0)
sw $t1, -248($a0)

addi $a0, $a0, 16
jr $ra

draw_g:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, 4($a0) 
sw $t1, 8($a0)
sw $t1, 12($a0)
sw $t1, -128($a0)
sw $t1, -116($a0)
sw $t1, -256($a0)
sw $t1, -248($a0)
sw $t1, -244($a0)
sw $t1, -384($a0)
sw $t1, -512($a0)
sw $t1, -508($a0)
sw $t1, -504($a0)

addi $a0, $a0, 20
jr $ra

draw_r:
lw $t1, letterCol
sw $t1, 0($a0)
sw $t1, 8($a0)
sw $t1, -128($a0)
sw $t1, -124($a0)
sw $t1, -256($a0)
sw $t1, -252($a0)
sw $t1, -248($a0)
sw $t1, -384($a0)
sw $t1, -376($a0)
sw $t1, -512($a0)
sw $t1, -508($a0)
sw $t1, -504($a0)

addi $a0, $a0, 16
jr $ra


# remove notifications
remove_a:
# $a0 is the bottom left pixel
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, 8($a0)
sw $t1, -128($a0)
sw $t1, -124($a0)
sw $t1, -120($a0)
sw $t1, -256($a0)
sw $t1, -248($a0)
sw $t1, -384($a0)
sw $t1, -380($a0)
sw $t1, -376($a0)

addi $a0, $a0, 16
jr $ra

remove_w:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, 4($a0)
sw $t1, 8($a0)
sw $t1, 12($a0)
sw $t1, 16($a0)
sw $t1, -128($a0)
sw $t1, -120($a0)
sw $t1, -112($a0)
sw $t1, -256($a0)
sw $t1, -240($a0)

addi $a0, $a0, 24
jr $ra

remove_e:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, -128($a0)
sw $t1, -256($a0)
sw $t1, -384($a0)
sw $t1, -512($a0)
sw $t1, 4($a0)
sw $t1, -252($a0)
sw $t1, -508($a0)

addi $a0, $a0, 12
jr $ra

remove_s:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, 4($a0)
sw $t1, -124($a0)
sw $t1, -252($a0)
sw $t1, -256($a0)
sw $t1, -384($a0)
sw $t1, -512($a0)
sw $t1, -508($a0)

addi $a0, $a0, 12
jr $ra

remove_o:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, 4($a0)
sw $t1, 8($a0)
sw $t1, -128($a0)
sw $t1, -120($a0)
sw $t1, -256($a0)
sw $t1, -248($a0)
sw $t1, -384($a0)
sw $t1, -380($a0)
sw $t1, -376($a0)

addi $a0, $a0, 16
jr $ra

remove_m:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, 16($a0)
sw $t1, -128($a0)
sw $t1, -120($a0)
sw $t1, -112($a0)
sw $t1, -256($a0)
sw $t1, -252($a0)
sw $t1, -248($a0)
sw $t1, -244($a0)
sw $t1, -240($a0)

addi $a0, $a0, 24
jr $ra

remove_p:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, -128($a0)
sw $t1, -256($a0)
sw $t1, -252($a0)
sw $t1, -248($a0)

addi $a0, $a0, 16
jr $ra

remove_g:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, 4($a0) 
sw $t1, 8($a0)
sw $t1, 12($a0)
sw $t1, -128($a0)
sw $t1, -116($a0)
sw $t1, -256($a0)
sw $t1, -248($a0)
sw $t1, -244($a0)
sw $t1, -384($a0)
sw $t1, -512($a0)
sw $t1, -508($a0)
sw $t1, -504($a0)

addi $a0, $a0, 20
jr $ra

remove_r:
lw $t1, bgCol
sw $t1, 0($a0)
sw $t1, 8($a0)
sw $t1, -128($a0)
sw $t1, -124($a0)
sw $t1, -256($a0)
sw $t1, -252($a0)
sw $t1, -248($a0)
sw $t1, -384($a0)
sw $t1, -376($a0)
sw $t1, -512($a0)
sw $t1, -508($a0)
sw $t1, -504($a0)

addi $a0, $a0, 16
jr $ra






