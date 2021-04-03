# Bitmap display starter code
##Bitmap Display Configuration:
# -Unit width in pixels: 8
# -Unit height in pixels: 8
# -Display width in pixels: 256
# -Display height in pixels: 256
# -Base Address for Display: 0x10008000 ($gp)
#
.eqv BASE_ADDRESS 0x10008000
.eqv HORIZONTAL 128
.eqv white 0x00ffffff
.eqv green 0x00ff00
.eqv yellow 0xffff00
.eqv black 0x000000
.eqv blue 0x0000ff
.eqv objectColor 0x01ff22
.eqv playerStart 1792
.eqv firstStart 0x10008120
.eqv secondStart  0x10009408
.eqv thirdStart 0x10010688
.macro print (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
	.end_macro
.data
player: .word
green, blue, blue, 
blue, green, green, 
green, blue, blue



playerLocation: .word 0x10008000
# Obstacle Object: 
#0: Location 
#4: Minimum Row 
#8: Reset Flag 
#12: Previous Location
#16: Collision Flag
objectFirst: .word 0:5
objectSecond: .word 0:5
objectThird: .word 0:5





.text
init:
# INITIALIZE GAME STATE
 # Paint screen black
  li $t0, BASE_ADDRESS 
  move $a0, $t0
  li $a1, 32
  li $a2, 32
  jal paintBlack

  # initialize player start location
  li $t0, BASE_ADDRESS 
  addi $t1, $t0, playerStart
  la $t2, playerLocation
  sw $t1, 0($t2)

  # draw player
  lw $a0, playerLocation
  la $a1, player
  jal drawImage

  # Initialize first object location
  la $t0, objectFirst
  li $t1, firstStart
  sw $t1, 0($t0)

  # Initialized second obstacle
  la $t0, objectSecond
  li $t1, secondStart
  sw $t1, 0($t0)
  li $t1, 11
  sw $t1, 4($t0 )
  # Initialized third obstacle
  la $t0, objectThird
  li $t1, thirdStart
  sw $t1, 0($t0)
  li $t1, 21
  sw $t1, 4($t0 )

  # Initialize player colors
  la $t0, player
  li $t1, blue
  sw $t1, 4($t0)
  sw $t1, 8($t0)
  sw $t1, 12($t0)
  sw $t1, 28($t0)
  sw $t1, 32($t0)
  li $t1, green
  sw $t1, 0($t0)
  sw $t1, 16($t0)
  sw $t1, 20($t0)
  sw $t1, 24($t0)

  

main:
  #get movement
  li $s7, 0xffff0000
  lw $s6, 0($s7)
  beq $s6, 1, keypress
afterPress:
    # Calculate Obstacle Locations
  la $a0, objectFirst
  jal moveandCollide
  la $a0, objectSecond
  jal moveandCollide
  la $a0, objectThird
  jal moveandCollide
      # Draw Obstacles
  la $a0, objectFirst
  jal drawObject  
  la $a0, objectSecond
  jal drawObject  
  la $a0, objectThird
  jal drawObject
  
  lw $a0, playerLocation
  la $a1, player
  jal drawImage

  li $v0, 32     # sleep
  li $a0, 20
  syscall
  j main


keypress:
  
  #get movement key
  lw $s2, 4($s7)
  beq $s2, 0x61, respondA
  beq $s2, 0x77, respondW        # 
  beq $s2, 0x64, respondD
  beq $s2, 0x73, respondS
  beq $s2, 0x70, respondP
 j afterPress

# RESPONSES TO KEYS
respondA:
     # prevent player from moving left
  la $s3, playerLocation
  lw $t1, 0($s3)
  addi $t2, $0, BASE_ADDRESS    # subtract base address from player location
  sub $t1, $t1, $t2  
  li $t3, 128
  div $t1, $t3
  mfhi $t1
  beq $t1, $0, afterPress


  la $s3, playerLocation    # move player location left
  lw $s4, 0($s3)
  addi $s4, $s4, -4
  sw $s4, 0($s3)

  jal moveLeft
  
  j afterPress    # finished handling it
respondD:
  la $s3, playerLocation
# block player from going right if at end of found
  lw $t1, 0($s3)
  addi $t2, $0, BASE_ADDRESS
  addi $t2, $t2, -12
  sub $t1, $t1, $t2 

  beq $t1, $0, skipD
  li $t3, 128
  div $t1, $t3
  mfhi $t1
  beq $t1, $0, afterPress
  
# draw right
  skipD:
  jal moveRight
# move player location right
  
  lw $s4, 0($s3)
  addi $s4, $s4, 4
  sw $s4, 0($s3)
  
  j afterPress    # finished handling it
respondW:

	lw $t1, 0($s3)
  addi $t2, $0, BASE_ADDRESS    # subtract base address from player location
  sub $t1, $t1, $t2  
  li $t3, 124
  blt $t1, $t3, afterPress
  
  la $s3, playerLocation
  lw $s4, 0($s3)
  addi $s4, $s4, -128     # Move player down
  sw $s4, 0($s3)

  jal moveUp
  
  j afterPress    # finished handling it
respondS:

  la $s3, playerLocation
  lw $t1, 0($s3)
  addi $t2, $0, BASE_ADDRESS    # subtract base address from player location
  sub $t1, $t1, $t2  
  li $t3, 3712
  bgt $t1, $t3, afterPress
	jal moveDown 

  la $s3, playerLocation
  lw $s4, 0($s3)
  addi $s4, $s4, 128     # Move player down
  sw $s4, 0($s3)
  
  j afterPress    # finished handling it
respondP:
  j init

# END PROGRAM
exit:
  li $v0, 10 # terminate the program gracefully
  syscall

# GENERIC FUNCTION TO DRAW IMAGE AT GIVEN IN LOCATION
drawImage:
# a0 start
# a1 image 
  lw $t0, 0($a1)
  sw $t0, 0($a0)
  lw $t0, 4($a1)
  sw $t0, 4($a0)
  lw $t0, 8($a1)
  sw $t0, 8($a0) 
  


  lw $t0, 12($a1)
  sw $t0, 128($a0)
  lw $t0, 16($a1)
  sw $t0, 132($a0)
  lw $t0, 20($a1)
  sw $t0, 136($a0) 

  
  lw $t0, 24($a1)
  sw $t0, 256($a0)
  lw $t0, 28($a1)
  sw $t0, 260($a0)
  lw $t0, 32($a1)
  sw $t0, 264($a0) 
  jr $ra

#MOVEMENT FUNCTIONS FOR PLAYER
moveRight:
# a0 start
  lw $a0, playerLocation
 # lw $a0, 0($a3)
  la $a1, player    # Lord player image into $a1, 
  #lw $a1, 0($a2)

  li $t0, black
  sw $t0, 0($a0)
  sw $t0, 128($a0)
  sw $t0, 256($a0)



  lw $t0, 0($a1)
  sw $t0, 4($a0)
  lw $t0, 4($a1)
  sw $t0, 8($a0)
  lw $t0, 8($a1)
  sw $t0, 12($a0) 
  


  lw $t0, 12($a1)
  sw $t0, 132($a0)
  lw $t0, 16($a1)
  sw $t0, 136($a0)
  lw $t0, 20($a1)
  sw $t0, 140($a0) 

  
  lw $t0, 24($a1)
  sw $t0, 260($a0)
  lw $t0, 28($a1)
  sw $t0, 264($a0)
  lw $t0, 32($a1)
  sw $t0, 268($a0) 
  jr $ra 
  
moveLeft:
# a0 start
  lw $a0, playerLocation
 
  la $a1, player    # Lord player image into $a1, 

    li $t0, black
  sw $t0, 12($a0)
  sw $t0, 140($a0)
  sw $t0, 268($a0)



  lw $t0, 0($a1)
  sw $t0, 0($a0)
  lw $t0, 4($a1)
  sw $t0, 4($a0)
  lw $t0, 8($a1)
  sw $t0, 8($a0) 
  


  lw $t0, 12($a1)
  sw $t0, 128($a0)
  lw $t0, 16($a1)
  sw $t0, 132($a0)
  lw $t0, 20($a1)
  sw $t0, 136($a0) 

  
  lw $t0, 24($a1)
  sw $t0, 256($a0)
  lw $t0, 28($a1)
  sw $t0, 260($a0)
  lw $t0, 32($a1)
  sw $t0, 264($a0) 


  jr $ra 

  
moveDown:
# a0 start
  lw $a0, playerLocation
 # lw $a0, 0($a3)
  la $a1, player    # Lord player image into $a1, 
  #lw $a1, 0($a2)

  li $t0, black
  sw $t0, 0($a0)
  sw $t0, 4($a0)
  sw $t0, 8($a0)

  lw $t0, 0($a1)
  sw $t0, 128($a0)
  lw $t0, 4($a1)
  sw $t0, 132($a0)
  lw $t0, 8($a1)
  sw $t0, 136($a0) 

  
  lw $t0, 12($a1)
  sw $t0, 256($a0)
  lw $t0, 16($a1)
  sw $t0, 260($a0)
  lw $t0, 20($a1)
  sw $t0, 264($a0) 

  lw $t0, 24($a1)
  sw $t0, 384($a0)
  lw $t0, 28($a1)
  sw $t0, 388($a0)
  lw $t0, 32($a1)
  sw $t0, 392($a0) 
  jr $ra  

moveUp:
# a0 start
  lw $a0, playerLocation
 # lw $a0, 0($a3)
  la $a1, player    # Lord player image into $a1, 
  #lw $a1, 0($a2)

  li $t0, black
  sw $t0, 384($a0)
  sw $t0, 388($a0)
  sw $t0, 392($a0)

  lw $t0, 0($a1)
  sw $t0, 0($a0)
  lw $t0, 4($a1)
  sw $t0, 4($a0)
  lw $t0, 8($a1)
  sw $t0, 8($a0)

  lw $t0, 12($a1)
  sw $t0, 128($a0)
  lw $t0, 16($a1)
  sw $t0, 132($a0)
  lw $t0, 20($a1)
  sw $t0, 136($a0) 

  
  lw $t0, 24($a1)
  sw $t0, 256($a0)
  lw $t0, 28($a1)
  sw $t0, 260($a0)
  lw $t0, 32($a1)
  sw $t0, 264($a0) 

  jr $ra  

# generic function for quick prototyping TO PRINT AREA BLOCK
paintBlack:
    # a0 start
    # a1 vertical
    # a2 horizontal
  li $t0, black    # color to fill
  li $t1, HORIZONTAL    # width off row
	li $t3, -4
  mult	$a2, $t3			# $t1 * 4 = Hi and Lo registers
  mflo	$t3					# copy Lo to $t3

  add $t1, $t1, $t3    # $t1->quantity to jump too next row


  move $t2, $a2     # $t2, holds reference to width of square to be painted black
beginFill:
  beq $a1, $0 donePainting    # loop as long as we are not done painting the full height
  sw $t0, 0($a0)
  addi $a2, $a2, -1    # subtract one from horizontal
  addi $a0, $a0, 4
  bne $a2, $0, beginFill     # lop again if we haven't finished filling the width
  move $a2, $t2    # restore horizontal
  add $a0, $a0, $t1    # mov to next row
  addi $a1, $a1, -1     # subtract one from vertical
  j beginFill
donePainting:
  jr $ra

erasePlayer:
# a0 start
  li $t0, black
  
  sw $t0, 0($a0)
  
  sw $t0, 4($a0)
  
  sw $t0, 8($a0) 

  
  sw $t0, 128($a0)
  
  sw $t0, 132($a0)
  
  sw $t0, 136($a0) 

  
  sw $t0, 256($a0)
  
  sw $t0, 260($a0)
  
  sw $t0, 264($a0) 


  
  jr $ra

moveandCollide:
#a0 object to update
#a1 object bound
    # CHECK IF WE ARE AT THE LEFT MOST BOUND
  lw $t1, 0($a0)
  addi $t2, $0, BASE_ADDRESS    # subtract base address from player location
  sub $t1, $t1, $t2  
  li $t3, 128
  div $t1, $t3
  mfhi $t1
  beq $t1, $0, resetToStart
# CHECK COLLISION
  lw $t0, 0($a0)
  addi $t0, $t0, -4
  lw $t1, 0($t0)
  li $t2, black
  bne $t1, $t2, collision 
  lw $t1, 128($t0)
  bne $t1, $t2, collision
# MOVE PLAYER
  lw $t0, 0($a0)
  addi $t1, $t0, -4
  sw $t1, 0($a0)
  jr $ra
  collision:
  li $t0, 1 
  sw $t0, 16($a0) 
  

  resetToStart:
  li $t0, 1
  sw $t0, 8($a0)    # set reset flag to one
  lw $t0, 0($a0)
  sw $t0, 12($a0)    # save previous location
  move $t0, $a0
  
  move $a0,  $0    # generate random number between zero and ten
  li $a1, 10
  li $v0, 42
  syscall
  li $t1, 128     # constant to calculate rone number
  lw $t2, 4($t0)    # get the lower bound
  add  $t2, $t2, $a0     # at the lower bound
  mult $t1, $t2     # calculate row
  mflo $t1
  addi $t1, $t1, 120
  addi $t1, $t1, BASE_ADDRESS
  sw $t1, 0($t0)


  jr $ra

drawObject:
#a0 object to draw
  # Check for reset
  lw $t2, 8($a0)
  bgt $t2, $0, erasePrevious
  afterErase:

  # Check for previous collision
  lw $t2, 16($a0)
  
  bgt $t2, $0, handleCollision
  afterCollision:

  #Draw obstacle
  li $t0, objectColor
  lw $t1, 0($a0)
  sw $t0, 0($t1)
  sw $t0, 128($t1)
  li $t0, black
  sw $t0, 8($t1)
  sw $t0, 136($t1)

  jr $ra
 
 erasePrevious:
  lw $t2, 12($a0)
  li $t0, black
  sw $t0, 0($t2)
  sw $t0, 4($t2)
  sw $t0, 128($t2)
  sw $t0, 132($t2)
  li $t0, 0    # Reset erase flag
  lw $t0, 8($a0)
  j afterErase
handleCollision:
  la $t0, player
  li $t2, blue

  lw $t1, 4($t0) 
  addi $t3,$t0, 4
  
  beq $t1, $t2, removeShield
  lw $t1, 8($t0) 
  addi $t3, $t0, 8
  beq $t1, $t2, removeShield
  lw $t1, 12($t0) 
  addi $t3,$t0, 12
  beq $t1, $t2, removeShield
  lw $t1, 28($t0) 
  addi $t3, $t0, 28
  beq $t1, $t2, removeShield
  lw $t1, 32($t0) 
  addi $t3, $t0, 32
  beq $t1, $t2, removeShield
  j gameOver
  removeShield:
  li $t0, black
  sw $t0, 0($t3)
  sw $0, 16($a0)
  j afterCollision

gameOver:
  li $t0, BASE_ADDRESS 
  move $a0, $t0
  li $a1, 32
  li $a2, 32
  jal paintBlack
  j exit

