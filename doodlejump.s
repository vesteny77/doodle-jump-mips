#####################################################################
#
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Student: Steven Yuan, 1005712873
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# Milestone 4: 
# 	a. Score board/score count
# 	b. Game Over/Retry
# MileStone 5:
# 	a. Realistic physics: speed up when jump on top of a platform and slow down otherwise
# 	e. Dynamic on-screen notifications:
# 		- Display "Awesome" when the score reaches 10
# 		- Display "Poggers" when the score reaches 15
# 		- Display "Wow" when the score reaches 20
# 	f. Sound effects:
# 		- Play a sound when the doodle lands on a platform
# 		- Play a sound when the platform updates
# 		- Play a sound when the game is over
#
# Any additional information that the TA needs to know:
# None
#
#####################################################################


.data
displayAddress: .word 0x10008000

# background
bgCol: .word 0x00f7fcd4

# platform
lenPlatform: .word 28  # in bytes
initPos: .word 0x10008f34
initPosStruct: .space 8
newPos: .word 0x10008f34
newPosStruct: .space 8
colPl: .word 0x004edb12
platformArray: .space 128  # an array of platforms (max 32 platforms)
lenPlatformArray: .word 0

# doodle
jumpDist: .word 13  # in pixels
lrDistBeforeFall: .word 16 # how much the doodle can move left or right before falling (in pixels)
colDoodle: .word 0x00b5651d
doodleStruct: .space 24  # in bytes

# store score (number of platforms jumped)
score: .word 0
numCol: .word 0x000000ff

# notification variables
letterCol: .word 0x00ff0000


.text
Restart:
la $t0, displayAddress
addi $t1, $zero, 0x10008000
sw $t1, 0($t0)

la $t0, initPos
addi $t1, $zero, 0x10008f34
sw $t1, 0($t0)

la $t0, initPosStruct
add $t1, $zero, $zero
sw $t1, 0($t0)
sw $t1, 4($t0)

la $t0, newPos
addi $t1, $zero, 0x10008f34
sw $t1, 0($t0)

la $t0, newPosStruct
add $t1, $zero, $zero
sw $t1, 0($t0)
sw $t1, 4($t0)

la $t0, platformArray
add $t1, $zero, $zero
add $t2, $zero, $zero  # index
InitPlatformArrayLoop:
bge $t2, 128, InitLenPlatformArray
add $t0, $t0, $t2
sw $t1, 0($t0)
addi $t2, $t2, 4
j InitPlatformArrayLoop

InitLenPlatformArray:
la $t0, lenPlatformArray
add $t1, $zero, $zero
sw $t1, 0($t0)

InitDoodleStruct:
la $t0, doodleStruct
add $t1, $zero, $zero
add $t2, $zero, $zero  # index
InitDoodleStructLoop:
bge $t2, 24, ResetScore
add $t0, $t0, $t2
sw $t1, 0($t0)
addi $t2, $t2, 4
j InitDoodleStructLoop

ResetScore:
la $t0, score
add $t1, $zero, $zero
sw $t1, 0($t0)



#############################################
# paint background
#############################################

PaintBg:
lw $t0, displayAddress # $t0 stores the base address for display
add $t1, $zero, $zero  # initialize index i to 0
add $t2, $zero, $zero  # initialize index j to 0
add $t5, $zero, $zero  # initialize a register that stores a temporary address in the block PaintBgRow
addi $t3, $zero, 128  # upper bound for index j
addi $t4, $zero, 4096  # upper bound for index i
add $t9, $t0, $zero  # the display address value (doesn't change)
lw $t8, bgCol  # bg color

PaintBgLoop:
bge $t1, $t4, PaintPlatform  # if i >= 32, exit loop

PaintBgRow:
bge $t2, $t3, PBIncrementI  # if j >= 32, exit inner loop
sw $t8, 0($t0)
addi $t2, $t2, 4  # increment the row offset
add $t5, $t1, $t2  # add $t1(row offset) to $t2(col offset) to obtain the correct offset
add $t0, $t9, $t5  # add the offset to the displayAddress
add $t5, $zero, $zero  # clear the temporary address holder
j PaintBgRow

PBIncrementI:
addi $t1, $t1, 128  # increment i to start at the beginning of the next row; increment the column offset
add $t0, $t9, $t1  # change the display address to the beginning of the next row
add $t2, $zero, $zero  # make the offset 0
j PaintBgLoop

#############################################
# end of paint background
#############################################


#############################################
# paint platform
#############################################

PaintPlatform:
# paint first platform
lw $t0, displayAddress
lw $t1, lenPlatform
lw $t2, initPos
add $s4, $zero, $zero

add $a0, $zero, $t2 # place the initial position into an argument register

jal paintGenPlatformProc  # paint the first platform


# generate random platforms
RandPlatform:
# load values into the struct of initial position of the platform
la $t0, initPosStruct
la $t3, newPosStruct
addi $t1, $zero, 0x00000034  # x position
sw $t1, 0($t0)
sw $t1, 0($t3)  # store a copy of x position into the newPosStruct
addi $t2, $zero, 0x00000f00  # y position
sw $t2, 4($t0)
sw $t2, 4($t3)  # store a copy of y position into the newPosStruct

la $s4, platformArray  # get the address of the array of platforms in memory
la $a3, lenPlatformArray  # get the length of the platform array
addi $t1, $zero, 0x10008f34
sw $t1, 0($s4)  # add the initial position to the platform array
addi $s5, $zero, 1  # length increments by 1
# sw $s5, 0($a3)

addi $s7, $zero, 2  # will change later
# addi $s6, $zero, 0x00000f00  # distance between the platform and the top of the frame (which is the y pos of current platform)
add $s6, $zero, $zero
# lw $t3, jumpDist

RandPlatformLoop:
bge $s6, $s7, StoreLengthOfArray
lw $t0, displayAddress
lw $t1, lenPlatform
lw $t2, newPos
lw $t3, jumpDist
addi $t4, $zero, 25
add $t5, $zero, $zero  # will store vertical displacement
add $t6, $zero, $zero  # will store horizontal displacement
add $t7, $zero, $zero  # position of new platform


# generate a random vertical distance
# randomly generate a number between 0 and 10(exclusive)
# addi $t3, $t3, 1  # make exclusive upper bound to 11
# add $a2, $t3, $zero
# jal randProc
# multiply by 128 to get the vertical displacement
# add $t5, $v1, $zero
# sll $t5, $t5, 7 # vertical displacement
# sub $s6, $s6, $t5
addi $t5, $zero, 1280

# generate a random horizontal distance
# randomly generate a number between 0 and 16(exclusive)
add $a2, $t4, $zero
jal randProc
# multiply by 4 to get the horizontal displacement
add $t6, $v1, $zero
sll $t6, $t6, 2 # horizontal displacement

# store the random address to paint at in $t7
lw $s1, newPosStruct  # get x position
sub $t7, $t2, $s1  # subtract off the x position
# subi $t7, $t7, 128  # make sure that the new platform will start at least 1 level higher than before
sub $t7, $t7, $t5  # subtract vertical offset
add $t7, $t7, $t6  # add horizontal offset

# paint random generated platform
add $a0, $t7, $zero
jal paintGenPlatformProc

# get x and y position of the new platform to be used in the next iteration
la $s3, newPos  # address of the platform
sw $t7, 0($s3)
la $s0, newPosStruct  # address of the platform struct
sw $t6, 0($s0)  # load x position into the platform struct
sub $s1, $t7, $t6  # subtract the x displacement, left with y displacement
lw $t0, displayAddress
sub $s1, $s1, $t0  # y displacement
sw $s1, 4($s0)  # update the platform struct according to the position of the new generated platform

# add the new address to the array of platforms
addi $s4, $s4, 4  # update the pointer
sw $t7, 0($s4)
addi $s5, $s5, 1  # length increments by 1

addi $s6, $s6, 1
j RandPlatformLoop

StoreLengthOfArray:
sw $s5, 0($a3)  # store the length of the platform array

#############################################
# end of paint platform
#############################################


#############################################
# paint doodle
#############################################

##############################
# what the doodle looks like:
#       --
#      |6 |
#    -- -- --
#   |3 |4 |5 |
#    -- -- --
#   |1 |  |2 |
#    --    --
##############################

PaintDoodle:
lw $t0, displayAddress
lw $t1, initPos # the position of the first platform
lw $t8, colDoodle
subi $t2, $t1, 120  # block 1
subi $t3, $t1, 112  # block 2
subi $t4, $t1, 248  # block 3
subi $t5, $t1, 244  # block 4
subi $t6, $t1, 240  # block 5
subi $t7, $t1, 372  # block 6
sw $t8, 0($t2)
sw $t8, 0($t3)
sw $t8, 0($t4)
sw $t8, 0($t5)
sw $t8, 0($t6)
sw $t8, 0($t7)

# store the positions in doodleStruct
la $s0, doodleStruct
sw $t2, 0($s0)
sw $t3, 4($s0)
sw $t4, 8($s0)
sw $t5, 12($s0)
sw $t6, 16($s0)
sw $t7, 20($s0)

j DoodleJumpLoop


# doodle jumping loop

DoodleJumpLoop:
add $s7, $zero, $zero  # inner loop index for jump up
lw $s1, jumpDist  # upper bound for jumping up
li $v0, 31
addi $a0, $zero, 67
addi $a1, $zero, 350
addi $a2, $zero, 121
addi $a3, $zero, 50
syscall


DoodleJumpInnerLoopUp:
# paint dynamic on-screen notifications
lw $t0, score
bne $t0, 8, Poggers
bge $s7, $s1, RemoveNotificationAwesome
lw $t2, displayAddress
addi $t2, $t2, 3984
add $a0, $zero, $t2
jal draw_a
jal draw_w
jal draw_e
jal draw_s
jal draw_o
jal draw_m
jal draw_e
j ContDoodleJumpInnerLoopUp

Poggers:
bne $t0, 13, Wow
bge $s7, $s1, RemoveNotificationPoggers
lw $t2, displayAddress
addi $t2, $t2, 3988
add $a0, $zero, $t2
jal draw_p
jal draw_o
jal draw_g
jal draw_g
jal draw_e
jal draw_r
jal draw_s
j ContDoodleJumpInnerLoopUp

Wow:
bne $t0, 18, ContDoodleJumpInnerLoopUp
bge $s7, $s1, RemoveNotificationWow
lw $t2, displayAddress
addi $t2, $t2, 4036
add $a0, $zero, $t2
jal draw_w
jal draw_o
jal draw_w
j ContDoodleJumpInnerLoopUp

RemoveNotificationAwesome:
lw $t2, displayAddress
addi $t2, $t2, 3984
add $a0, $zero, $t2
jal remove_a
jal remove_w
jal remove_e
jal remove_s
jal remove_o
jal remove_m
jal remove_e
j DoodleJumpInnerLoopDownSetup

RemoveNotificationPoggers:
lw $t2, displayAddress
addi $t2, $t2, 3988
add $a0, $zero, $t2
jal remove_p
jal remove_o
jal remove_g
jal remove_g
jal remove_e
jal remove_r
jal remove_s
j DoodleJumpInnerLoopDownSetup

RemoveNotificationWow:
lw $t2, displayAddress
addi $t2, $t2, 4036
add $a0, $zero, $t2
jal remove_w
jal remove_o
jal remove_w
j DoodleJumpInnerLoopDownSetup

ContDoodleJumpInnerLoopUp:
bge $s7, $s1, RemoveInitialPlatform
lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)

lw $s2, bgCol

# move doodle left
checkKeyPress:
lw $t1, 0xffff0000
beq $t1, 1, keyboard_input
j DoodleJumpUp

keyboard_input:
lw $t1, 0xffff0004
beq $t1, 106, respond_to_j
beq $t1, 107, respond_to_k

respond_to_j:  # move to the left one pixel
jal sleepProc
sw $s2, 0($t2)
sw $s2, 0($t3)
sw $s2, 0($t4)
sw $s2, 0($t5)
sw $s2, 0($t6)
sw $s2, 0($t7)

# repaint all the platforms
la $s3, platformArray
lw $t1, lenPlatformArray
add $s6, $zero, $zero

RepaintPlatformLoopUp_j:
lw $s5, 0($s3)  # position to write at
lw $t1, lenPlatformArray


bge $s6, $t1, UpdateDoodleAddressUpLeft
add $a0, $zero, $s5  # address to write at
jal paintGenPlatformProc  # paint the platform

addi $s3, $s3, 4
addi $s6, $s6, 1
j RepaintPlatformLoopUp_j

# move left
UpdateDoodleAddressUpLeft:
la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)

subi $t2, $t2, 4
subi $t3, $t3, 4
subi $t4, $t4, 4
subi $t5, $t5, 4
subi $t6, $t6, 4
subi $t7, $t7, 4

sw $t2, 0($s0)
sw $t3, 4($s0)
sw $t4, 8($s0)
sw $t5, 12($s0)
sw $t6, 16($s0)
sw $t7, 20($s0)

lw $t8, colDoodle
sw $t8, 0($t2)
sw $t8, 0($t3)
sw $t8, 0($t4)
sw $t8, 0($t5)
sw $t8, 0($t6)
sw $t8, 0($t7)
j DoodleJumpUp

respond_to_k:  # move to the right one pixel
jal sleepProc
sw $s2, 0($t2)
sw $s2, 0($t3)
sw $s2, 0($t4)
sw $s2, 0($t5)
sw $s2, 0($t6)
sw $s2, 0($t7)

# repaint all the platforms
la $s3, platformArray
lw $t1, lenPlatformArray
add $s6, $zero, $zero

RepaintPlatformLoopUp_k:
lw $s5, 0($s3)  # position to write at
lw $t1, lenPlatformArray


bge $s6, $t1, UpdateDoodleAddressUpRight
add $a0, $zero, $s5  # address to write at
jal paintGenPlatformProc  # paint the platform

addi $s3, $s3, 4
addi $s6, $s6, 1
j RepaintPlatformLoopUp_k

# move right
UpdateDoodleAddressUpRight:
la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)

addi $t2, $t2, 4
addi $t3, $t3, 4
addi $t4, $t4, 4
addi $t5, $t5, 4
addi $t6, $t6, 4
addi $t7, $t7, 4

sw $t2, 0($s0)
sw $t3, 4($s0)
sw $t4, 8($s0)
sw $t5, 12($s0)
sw $t6, 16($s0)
sw $t7, 20($s0)

lw $t8, colDoodle
sw $t8, 0($t2)
sw $t8, 0($t3)
sw $t8, 0($t4)
sw $t8, 0($t5)
sw $t8, 0($t6)
sw $t8, 0($t7)

# jump up
DoodleJumpUp:
# bge $s7, $s1, DoodleJumpInnerLoopDownSetup
jal sleepProc
sw $s2, 0($t2)
sw $s2, 0($t3)
sw $s2, 0($t4)
sw $s2, 0($t5)
sw $s2, 0($t6)
sw $s2, 0($t7)

# repaint all the platforms
la $s3, platformArray
lw $t1, lenPlatformArray
add $s6, $zero, $zero

RepaintPlatformLoopLeft:
lw $s5, 0($s3)  # position to write at
lw $t1, lenPlatformArray


bge $s6, $t1, UpdateDoodleAddressUp
add $a0, $zero, $s5  # address to write at
jal paintGenPlatformProc  # paint the platform

addi $s3, $s3, 4
addi $s6, $s6, 1
j RepaintPlatformLoopLeft


# move the doodle up one
UpdateDoodleAddressUp:
la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)

subi $t2, $t2, 128
subi $t3, $t3, 128
subi $t4, $t4, 128
subi $t5, $t5, 128
subi $t6, $t6, 128
subi $t7, $t7, 128

sw $t2, 0($s0)
sw $t3, 4($s0)
sw $t4, 8($s0)
sw $t5, 12($s0)
sw $t6, 16($s0)
sw $t7, 20($s0)

# paint at the new addresses
lw $t8, colDoodle
sw $t8, 0($t2)
sw $t8, 0($t3)
sw $t8, 0($t4)
sw $t8, 0($t5)
sw $t8, 0($t6)
sw $t8, 0($t7)

# check if the pixels below block 1 and 2 of the doodle are in the highest platform
add $t0, $zero, 0x01010101
bne $k0, $t0, ContinueJumpUpLoop

# la $t0, platformArray
# lw $t1, lenPlatformArray
# subi $t1, $t1, 1
# sll $t1, $t1, 2
# add $t0, $t0, $t1  # pointer address of the last platform
# lw $t4, 0($t0)  # address of the first pixel of the last platform

# lw $t2, 0($s0)
# lw $t3, 4($s0)
# addi $t2, $t2, 128  # the pixel below the first block of doodle
# addi $t3, $t3, 128  # the pixel below the second block of doodle

# beq $t4, $t2, MovePlatformDown # $t4 = 0
# beq $t4, $t3, MovePlatformDown
# addi $t4, $t4, 4
# beq $t4, $t2, MovePlatformDown # $t4 = 4
# beq $t4, $t3, MovePlatformDown
# addi $t4, $t4, 4
# beq $t4, $t2, MovePlatformDown # $t4 = 8
# beq $t4, $t3, MovePlatformDown
# addi $t4, $t4, 4
# beq $t4, $t2, MovePlatformDown # $t4 = 12
# beq $t4, $t3, MovePlatformDown
# addi $t4, $t4, 4
# beq $t4, $t2, MovePlatformDown # $t4 = 16
# beq $t4, $t3, MovePlatformDown
# addi $t4, $t4, 4
# beq $t4, $t2, MovePlatformDown # $t4 = 20
# beq $t4, $t3, MovePlatformDown
# addi $t4, $t4, 4
# beq $t4, $t2, MovePlatformDown # $t4 = 24
# beq $t4, $t3, MovePlatformDown
# addi $v0, $zero, 0x02020202  # not on the highest platform
# j ContinueJumpUpLoop

MovePlatformDown:  # move all the platforms down 1 pixel
addi $k0, $zero, 0x01010101
la $s3, platformArray
lw $t1, lenPlatformArray
# subi $t1, $t1, 1
sll $t1, $t1, 2
add $s6, $zero, $zero

PaintPlatformOneBelow:
lw $t1, lenPlatformArray
sll $t1, $t1, 2
bge $s6, $t1, ContinueJumpUpLoop
la $s3, platformArray
add $s3, $s3, $s6
lw $s5, 0($s3)  # current position
add $a0, $zero, $s5
jal removePlatformProc
addi $s5, $s5, 128  # one row below the current position
# lw $t1, lenPlatformArray

add $a0, $zero, $s5  # address to write at
jal paintGenPlatformProc  # paint the platform
sw $s5, 0($s3)  # store new address in platformArray

# addi $s3, $s3, 4
addi $s6, $s6, 4
j PaintPlatformOneBelow

ContinueJumpUpLoop:
addi $s7, $s7, 1
j DoodleJumpInnerLoopUp

# if the platforms were updated
RemoveInitialPlatform:
addi $s3, $zero, 0x01010101
bne $k0, $s3, DoodleJumpInnerLoopDownSetup
la $s3, platformArray
lw $t1, lenPlatformArray
addi $t0, $zero, 4  # offset
sll $t1, $t1, 2

ShiftPlatformLoop:
bge $t0, $t1, UpdateLengthOfArrayAfterShifting
la $s3, platformArray
add $s3, $s3, $t0
lw $t3, 0($s3)
subi $s3, $s3, 4
sw $t3, 0($s3)
addi $t0, $t0, 4
j ShiftPlatformLoop

UpdateLengthOfArrayAfterShifting:
lw $t1, lenPlatformArray 
subi $t1, $t1, 1  # update the length of platform array
la $t2, lenPlatformArray
sw $t1, 0($t2)


## jump down loop
DoodleJumpInnerLoopDownSetup:
# add $t0, $zero, $zero  # inner loop index for jump down
lw $s2, bgCol

DoodleJumpInnerLoopDown:
# check if the pixels below the doodle have the color of platform
# lw $t8, colPl
# lw $t2, 0($s0)
# lw $t3, 4($s0)
# addi $t2, $t2, 128
# addi $t3, $t3, 128
# lw $t0, 0($t2)
# lw $t1, 0($t3)

# check if the doodle dies
la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
addi $t2, $t2, 128  # the pixel below the first block of doodle
addi $t3, $t3, 128  # the pixel below the second block of doodle
addi $t1, $zero, 0x10009000
bge $t2, $t1, Exit
bge $t3, $t1, Exit


# check if the doodle is at the highest platform
la $t0, platformArray
lw $t1, lenPlatformArray
subi $t1, $t1, 1
sll $t1, $t1, 2
add $t0, $t0, $t1  # pointer address of the last platform
lw $t4, 0($t0)  # address of the first pixel of the last platform

la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
addi $t2, $t2, 128  # the pixel below the first block of doodle
addi $t3, $t3, 128  # the pixel below the second block of doodle

beq $t4, $t2, ProducePlatformTop # $t4 = 0
beq $t4, $t3, ProducePlatformTop
addi $t4, $t4, 4
beq $t4, $t2, ProducePlatformTop # $t4 = 4
beq $t4, $t3, ProducePlatformTop
addi $t4, $t4, 4
beq $t4, $t2, ProducePlatformTop # $t4 = 8
beq $t4, $t3, ProducePlatformTop
addi $t4, $t4, 4
beq $t4, $t2, ProducePlatformTop # $t4 = 12
beq $t4, $t3, ProducePlatformTop
addi $t4, $t4, 4
beq $t4, $t2, ProducePlatformTop # $t4 = 16
beq $t4, $t3, ProducePlatformTop
addi $t4, $t4, 4
beq $t4, $t2, ProducePlatformTop # $t4 = 20
beq $t4, $t3, ProducePlatformTop
addi $t4, $t4, 4
beq $t4, $t2, ProducePlatformTop # $t4 = 24
beq $t4, $t3, ProducePlatformTop
# j DoodleJumpLoop
addi $k0, $zero, 0x02020202
j CheckOnPlatform

# generate a randome platform with random x position(y pos = 0)
ProducePlatformTop:
# generate a random horizontal distance
# randomly generate a number between 0 and 25(exclusive)
addi $k0, $zero, 0x01010101

li $v0, 31
addi $a0, $zero, 65
addi $a1, $zero, 700
addi $a2, $zero, 26
addi $a3, $zero, 50
syscall

li $v0, 31
addi $a0, $zero, 69
addi $a1, $zero, 500
addi $a2, $zero, 26
addi $a3, $zero, 60
syscall

# increment score by 1
la $t1, score
lw $t4, score
addi $t4, $t4, 1
sw $t4, 0($t1)

addi $t4, $zero, 25
add $a2, $t4, $zero
jal randProc
# multiply by 4 to get the horizontal displacement
add $t6, $v1, $zero
sll $t6, $t6, 2 # horizontal displacement

# paint the new platform
la $s3, platformArray
add $a0, $t6, 0x10008000
jal paintGenPlatformProc
lw $t1, lenPlatformArray
sll $t1, $t1, 2  # get the address offset of the new platform
add $s3, $s3, $t1
sw $a0, 0($s3)
lw $t1, lenPlatformArray
addi $t1, $t1, 1  # update the length of platform array
la $t2, lenPlatformArray
sw $t1, 0($t2)

CheckOnPlatform:
# check if the pixels below the doodle have the color of platform (not at the highest platform)
lw $t8, colPl
lw $t2, 0($s0)
lw $t3, 4($s0)
addi $t2, $t2, 128
addi $t3, $t3, 128
lw $t0, 0($t2)
lw $t1, 0($t3)
beq $t0, $t8, DoodleJumpLoop
beq $t1, $t8, DoodleJumpLoop


lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)


lw $s2, bgCol

# move doodle left
checkKeyPress_2:
lw $t1, 0xffff0000
beq $t1, 1, keyboard_input_2
j DoodleJumpDown

keyboard_input_2:
lw $t1, 0xffff0004
beq $t1, 106, respond_to_j_2
beq $t1, 107, respond_to_k_2

respond_to_j_2:  # move to the left one pixel
jal sleepProc
sw $s2, 0($t2)
sw $s2, 0($t3)
sw $s2, 0($t4)
sw $s2, 0($t5)
sw $s2, 0($t6)
sw $s2, 0($t7)

# repaint all the platforms
la $s3, platformArray
lw $t1, lenPlatformArray
add $s6, $zero, $zero

RepaintPlatformLoopDown_j:
lw $s5, 0($s3)  # position to write at
lw $t1, lenPlatformArray
 

bge $s6, $t1, UpdateDoodleAddressDownLeft
add $a0, $zero, $s5  # address to write at
jal paintGenPlatformProc  # paint the platform

addi $s3, $s3, 4
addi $s6, $s6, 1
j RepaintPlatformLoopDown_j

# move left
UpdateDoodleAddressDownLeft:
la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)

subi $t2, $t2, 4
subi $t3, $t3, 4
subi $t4, $t4, 4
subi $t5, $t5, 4
subi $t6, $t6, 4
subi $t7, $t7, 4

sw $t2, 0($s0)
sw $t3, 4($s0)
sw $t4, 8($s0)
sw $t5, 12($s0)
sw $t6, 16($s0)
sw $t7, 20($s0) 

lw $t8, colDoodle
sw $t8, 0($t2)
sw $t8, 0($t3)
sw $t8, 0($t4)
sw $t8, 0($t5)
sw $t8, 0($t6)
sw $t8, 0($t7)
j DoodleJumpDown

respond_to_k_2:  # move to the right one pixel
jal sleepProc
sw $s2, 0($t2)
sw $s2, 0($t3)
sw $s2, 0($t4)
sw $s2, 0($t5)
sw $s2, 0($t6)
sw $s2, 0($t7)

# repaint all the platforms
la $s3, platformArray
lw $t1, lenPlatformArray
add $s6, $zero, $zero

RepaintPlatformLoopDown_k:
lw $s5, 0($s3)  # position to write at
lw $t1, lenPlatformArray
 

bge $s6, $t1, UpdateDoodleAddressDownRight
add $a0, $zero, $s5  # address to write at
jal paintGenPlatformProc  # paint the platform

addi $s3, $s3, 4
addi $s6, $s6, 1
j RepaintPlatformLoopDown_k

# move right
UpdateDoodleAddressDownRight:
la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)

addi $t2, $t2, 4
addi $t3, $t3, 4
addi $t4, $t4, 4
addi $t5, $t5, 4
addi $t6, $t6, 4
addi $t7, $t7, 4

sw $t2, 0($s0)
sw $t3, 4($s0)
sw $t4, 8($s0)
sw $t5, 12($s0)
sw $t6, 16($s0)
sw $t7, 20($s0) 

lw $t8, colDoodle
sw $t8, 0($t2)
sw $t8, 0($t3)
sw $t8, 0($t4)
sw $t8, 0($t5)
sw $t8, 0($t6)
sw $t8, 0($t7)

# jump down
DoodleJumpDown:
# bge $t0, $s1, DoodleJumpLoop
jal sleepProc
sw $s2, 0($t2)
sw $s2, 0($t3)
sw $s2, 0($t4)
sw $s2, 0($t5)
sw $s2, 0($t6)
sw $s2, 0($t7)

# repaint all the platforms
la $s3, platformArray
lw $t1, lenPlatformArray
add $s6, $zero, $zero


RepaintPlatformLoopDown:
lw $s5, 0($s3)  # position to write at
lw $t1, lenPlatformArray

bge $s6, $t1, UpdateDoodleAddressDown
add $a0, $zero, $s5  # address to write at
jal paintGenPlatformProc  # paint the platform

addi $s3, $s3, 4
addi $s6, $s6, 1
j RepaintPlatformLoopDown


# move the doodle down one
UpdateDoodleAddressDown:
la $s0, doodleStruct
lw $t2, 0($s0)
lw $t3, 4($s0)
lw $t4, 8($s0)
lw $t5, 12($s0)
lw $t6, 16($s0)
lw $t7, 20($s0)

addi $t2, $t2, 128
addi $t3, $t3, 128
addi $t4, $t4, 128
addi $t5, $t5, 128
addi $t6, $t6, 128
addi $t7, $t7, 128

sw $t2, 0($s0)
sw $t3, 4($s0)
sw $t4, 8($s0)
sw $t5, 12($s0)
sw $t6, 16($s0)
sw $t7, 20($s0) 

# paint at the new addresses
lw $t8, colDoodle
sw $t8, 0($t2)
sw $t8, 0($t3)
sw $t8, 0($t4)
sw $t8, 0($t5)
sw $t8, 0($t6)
sw $t8, 0($t7)
# addi $t0, $t0, 1
j DoodleJumpInnerLoopDown
# j DoodleJumpLoop

#############################################
# end of paint doodle
#############################################

#############################################
# update platforms
#############################################
# UpdatePlatforms:
# la $s0, doodleStruct
# lw $t2, 0($s0)
# lw $t3, 4($s0)


# move all the platforms down
# la $s3, platformArray
# lw $t1, lenPlatformArray
# add $s6, $zero, $zero

# generate a randome platform with random x position(y pos = 0)

# generate a random horizontal distance
# randomly generate a number between 0 and 25(exclusive)
# addi $t4, $zero, 25
# add $a2, $t4, $zero
# jal randProc
# multiply by 4 to get the horizontal displacement
# add $t6, $v1, $zero
# sll $t6, $t6, 2 # horizontal displacement

# paint the new platform
# add $a0, $t6, 0x10008000
# jal paintGenPlatformProc
# lw $t1, lenPlatformArray
# sll $t1, $t1, 2  # get the address offset of the new platform
# sw $t1, 0($s3)
# addi $t1, $t1, 1  # update the length of platform array


# TODO: add the new platform to the platform array and move all the plotforms down; remove the first platform from the array and shift
# all the addresses of platforms in the array to the left

# MovePlatformDownLoop:
# lw $s5, 0($s3)  # position to write at
# lw $t1, lenPlatformArray

# bge $s6, $t1, UpdateDoodleAddressDown
# add $a0, $zero, $s5  # address to write at
# jal paintGenPlatformProc  # paint the platform

# addi $s3, $s3, 4
# addi $s6, $s6, 1
# j MovePlatformDownLoop



#############################################
# end of update platforms
#############################################


Exit:
li $v0, 31
addi $a0, $zero, 50
addi $a1, $zero, 3000
addi $a2, $zero, 3
addi $a3, $zero, 70
syscall

la $t0, score
lw $t1, score
addi $t1, $t1, 2
sw $t1, 0($t0)

PaintEnd:
lw $t0, displayAddress # $t0 stores the base address for display
add $t1, $zero, $zero  # initialize index i to 0
add $t2, $zero, $zero  # initialize index j to 0
add $t5, $zero, $zero  # initialize a register that stores a temporary address in the block PaintBgRow
addi $t3, $zero, 128  # upper bound for index j
addi $t4, $zero, 4096  # upper bound for index i
add $t9, $t0, $zero  # the display address value (doesn't change)
lw $t8, colPl # game over color

PaintEndLoop:
bge $t1, $t4, PaintScore  # if i >= 32, exit loop

PaintEndRow:
bge $t2, $t3, PEIncrementI  # if j >= 32, exit inner loop
sw $t8, 0($t0)
addi $t2, $t2, 4  # increment the row offset
add $t5, $t1, $t2  # add $t1(row offset) to $t2(col offset) to obtain the correct offset
add $t0, $t9, $t5  # add the offset to the displayAddress
add $t5, $zero, $zero  # clear the temporary address holder
j PaintEndRow

PEIncrementI:
addi $t1, $t1, 128  # increment i to start at the beginning of the next row; increment the column offset
add $t0, $t9, $t1  # change the display address to the beginning of the next row
add $t2, $zero, $zero  # make the offset 0
j PaintEndLoop

PaintScore:
lw $a0, displayAddress
lw $t2, score
PaintDigit:
bne $t2, 0, Paint1
# add $a0, $zero, $t1
jal draw_0
j CheckOnEnter
Paint1:
bne $t2, 1, Paint2
# add $a0, $zero, $t1
jal draw_1
j CheckOnEnter
Paint2:
bne $t2, 2, Paint3
# add $a0, $zero, $t1
jal draw_2
j CheckOnEnter
Paint3:
bne $t2, 3, Paint4
# add $a0, $zero, $t1
jal draw_3
j CheckOnEnter
Paint4:
bne $t2, 4, Paint5
# add $a0, $zero, $t1
jal draw_4
j CheckOnEnter
Paint5:
bne $t2, 5, Paint6
# add $a0, $zero, $t1
jal draw_5
j CheckOnEnter
Paint6:
bne $t2, 6, Paint7
# add $a0, $zero, $t1
jal draw_6
j CheckOnEnter
Paint7:
bne $t2, 7, Paint8
# add $a0, $zero, $t1
jal draw_7
j CheckOnEnter
Paint8:
bne $t2, 8, Paint9
# add $a0, $zero, $t1
jal draw_8
j CheckOnEnter
Paint9:
bne $t2, 9, g10_l20
# add $a0, $zero, $t1
jal draw_9
j CheckOnEnter

g10_l20:
# bge $t2, 10, l20
bge $t2, 20, g20_l30
subi $t2, $t2, 10
# add $a0, $zero, $t1
jal draw_1
j PaintDigit

g20_l30:
# bge $t2, 20, l30
# bge $t2, 30, g20_l30
subi $t2, $t2, 20
# add $a0, $zero, $t1
jal draw_2
j PaintDigit


# check if "enter" is pressed
CheckOnEnter:
lw $t8, 0xffff0000
beq $t8, 1, EndKeyboardInput
EndKeyboardInput:
lw $t8, 0xffff0004
beq $t8, 0x0000000a, Restart
# li $v0, 10 # terminate the program gracefully
# syscall


#############################################
# functions
#############################################

# paint a platform with a specified address
paintGenPlatformProc:
lw $t1, lenPlatform
lw $t8, colPl
add $t3, $zero, $zero  # initialize index for painting platform
# add $a0, $zero, $t2 # place the initial position into an argument register
add $t9, $a0, $zero  # address to write at
PaintGenPlatformLoop:
bge $t3, $t1, returnPaintGenPlatformProc  # if j >= 28
sw $t8, 0($t9)
addi $t3, $t3, 4  # increment the row offset
add $t9, $a0, $t3  # add the offset to the displayAddress
j PaintGenPlatformLoop
returnPaintGenPlatformProc: jr $ra

# remove a platform with a specified address
removePlatformProc:
lw $t1, lenPlatform
lw $t8, bgCol
add $t3, $zero, $zero  # initialize index for painting platform
# add $a0, $zero, $t2 # place the initial position into an argument register
add $t9, $a0, $zero  # address to write at
RemovePlatformLoop:
bge $t3, $t1, returnRemovePlatformProc  # if j >= 28
sw $t8, 0($t9)
addi $t3, $t3, 4  # increment the row offset
add $t9, $a0, $t3  # add the offset to the displayAddress
j RemovePlatformLoop
returnRemovePlatformProc: jr $ra

# random generator
randProc:
li $v0, 42
li $a0, 0
add $a1, $a2, $zero
syscall
add $v1, $a0, $zero
jr $ra

# sleep
sleepProc:
li $v0, 32
li $a0, 70  # in milliseconds
syscall
jr $ra

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

# draw letters
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

#############################################
# end of functions
#############################################
