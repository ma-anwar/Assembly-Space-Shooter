########################################
# CSCB58 Winter 2021 Final Project
# University of Toronto, Scarborough
# Student: Mohammad Anwar
##Bitmap Display Configuration:
# -Unit width in pixels: 8
# -Unit height in pixels: 8
# -Display width in pixels: 256
# -Display height in pixels: 256
# -Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in the submission?
# Milestone 4

# Which approved features have been implemented for milestone 4
# 1. Smooth Graphics
# 2. Pickups
# 3. Shooting (press spacebar to shoot)
#
# Link to Video
# https://www.youtube.com/watch?v=11fht1JKuMo
#
# Are you okay with sharing the video with people outside course staff?
# Yes 
#################################

.eqv BASE_ADDRESS 0x10008000
.eqv HORIZONTAL 128
.eqv white 0x00ffffff
.eqv green 0x00ff00
.eqv yellow 0xffff00
.eqv black 0x000000
.eqv blue 0x00000ff
.eqv objectColor 0x01ff22
.eqv playerStart 1792
.eqv firstStart 0x10008120
.eqv secondStart  0x10009408
.eqv thirdStart 0x10010688
.eqv goodStart 0x10008800
.eqv badStart 0x10008420
.eqv goodColor 0xffc0cb
.eqv badColor 0xff0000
.eqv bulletColor 0xff66cc

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

bullets: .word 0:2



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
# Pickup Object:
#0: Location
#4:
#8: Collision Flag
#12: Color
pickGood: .word 0:4
pickBad: .word 0:4




.text
init:
# INITIALIZE GAME STATE
 # Paint screen black
  li $t0, BASE_ADDRESS 
  move $a0, $t0
  li $a1, 32
  li $a2, 32
  jal paintBlack

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

  # initialize bullets
  la $t0, bullets
  sw $0, 0($t0)
  sw $0, 4($t0)
  sw $0, 8($t0)



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
  # Initialize third obstacle
  la $t0, objectThird
  li $t1, thirdStart
  sw $t1, 0($t0)
  li $t1, 21
  sw $t1, 4($t0 )



  # Initialize Pickup
  la $t0, pickGood
  li $t1, goodStart
  sw $t1, 0($t0)
  li $t1, 116
  sw $t1, 4($t0)
  li $t1, goodColor
  sw $t1, 12($t0)
    # Initialize bad Pickup
  la $t0, pickBad
  li $t1, badStart
  sw $t1, 0($t0)
  li $t1, 12
  sw $t1, 4($t0)
  li $t1, badColor
  sw $t1, 12($t0)

main:
  #get movement
  li $s7, 0xffff0000
  lw $s6, 0($s7)
  beq $s6, 1, keypress
afterPress:
  jal drawBullets
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
      # Redraw player
  lw $a0, playerLocation
  la $a1, player
  jal drawImage
    # Calculate pick up locations and collisions
  la $a0, pickGood
  jal checkPick
  la $a0, pickBad
  jal checkPick

  jal checkGood
  jal checkBad
    # Draw pickups
  la $a0, pickGood
  jal drawPick
  la $a0, pickBad
  jal drawPick
  

  li $v0, 32     # sleep
  li $a0, 40
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
  beq $s2, 0x20, respondSpace 

 j afterPress

# RESPONSES TO KEYS
respondA:
     # prevent player from moving left
  la $s3, playerLocation
  lw $t1, 0($s3)
  addi $t2, $0, BASE_ADDRESS    # subtract base address from player location
  sub $t1, $t1, $t2  
  li $t3, 128     # Divided by one twenty eight to check if it's at the right end
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
# block player from going right if at end of bound
  lw $t1, 0($s3)
  addi $t2, $0, BASE_ADDRESS
  addi $t2, $t2, -12
  sub $t1, $t1, $t2 

  beq $t1, $0, skipD
  li $t3, 128     # divided by one twenty eight to check a fits at the left end
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
  la $s3, playerLocation
	lw $t1, 0($s3)
  addi $t2, $0, BASE_ADDRESS    # subtract base address from player location
  sub $t1, $t1, $t2  
  li $t3, 124     # Check it for at the very top
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
  li $t3, 3712     # check for at the very bottom
  bgt $t1, $t3, afterPress
	jal moveDown 

  la $s3, playerLocation
  lw $s4, 0($s3)
  addi $s4, $s4, 128     # Move player down
  sw $s4, 0($s3)
  
  j afterPress    # finished handling it
respondP:
  j init

respondSpace:
        # Start a bullet if one is not already in action
  la $s2, bullets
  lw $s3, 0($s2)
  beq $s3, $0,  startBullet

  j afterPress
startBullet:
    # set bullet location to right of player
  la $s1, playerLocation
  lw $s4, 0($s1)
  
  addi $s4, $s4, 144#
  sw $s4, 0($s2)
  j afterPress

drawBullets:
  la $t0, bullets
  lw $t1, 0($t0)


  # if the bullet is not being fired then skip it
  beq $t1, $0, skipFirst
# check of the bullet is hitting the right bound and ifs0 reset
  addi $t1, $t1, 4
  addi $t2, $0, BASE_ADDRESS
  sub $t1, $t1, $t2 

  li $t3, 128
  div $t1, $t3
  mfhi $t1
  #beq $t1, $0, skipReset

  blt $t1, $0, skipReset
  bgt $t1, $0, skipReset
    # he reset the bullet, and paint old location black
  lw $t4, 0($t0)
  li $t5, black
  sw $t5, -4($t4)
  sw $t5, -8($t4)
  sw $t5, 0($t4)

  sw $0, 0($t0)
  j skipFirst
  
skipReset:
    # draw the bullet
  lw $t1, 0($t0)
  li $t2, bulletColor
  sw $t2, 0($t1)
  sw $t2, 4($t1)
  li $t2, black
  sw $t2, -4($t1)
      # move bullet to the right for next iteration
  addi $t1, $t1, 4
  sw $t1, 0($t0)

skipFirst:
  jr $ra



# END PROGRAM, loop until restart 
exit:
  li $s7, 0xffff0000
  lw $s6, 0($s7)
  beq $s6, 1, potentialStart
  li $v0, 32     # sleep
  li $a0, 40
  syscall
  j exit
potentialStart:
  lw $s2, 4($s7)
  beq $s2, 0x70, respondP
  j exit
  

# GENERIC FUNCTION TO DRAW 3x3 IMAGE AT GIVEN IN LOCATION
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
    # SHIFT PLAYER IMAGE TO WRITE
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

#SHIFT PLAYER IMAGE LEFT
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

#SHIFT PLAYER IMAGE DOWN
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

#SHIFT PLAYER IMAGE UP
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

# generic function for quick prototyping TO PRINT AREA BLaCK
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

#Function to completely erase player
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

#MOVE OBJECT AND CHECK FOR COLLISIONS
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
  li $t3, goodColor
  li $t4, badColor
  li $t5, bulletColor
  beq $t1, $t5, resetToStart     # If we hit a bullet the obstacle must reset
  beq $t1, $t3, checkSecond    # If we hit a pickup no problem
  beq $t1, $t4, checkSecond    # If we hit a pickup no problem
  bne $t1, $t2, collision     # If we hit the player(any other color), bullet reset and player loses health
  checkSecond:
  addi $t1, $t1, 4    # Check top right square for hitting bullet
  beq $t1, $t5, resetToStart
  # Check bottom two squares
  lw $t1, 128($t0)    # Start checking the bottom left square
  beq $t1, $t5, resetToStart
  beq $t1, $t3, checkForth
  beq $t1, $t4, checkForth
  bne $t1, $t2, collision
  checkForth:    # Check bottom right square for hitting bullet
  addi $t1, $t1, 4
  beq $t1, $t5, resetToStart
# MOVE OBJECT one to the left
moveObject:
  lw $t0, 0($a0)
  addi $t1, $t0, -4
  sw $t1, 0($a0)
  jr $ra
  collision:    # set collision flag
  li $t0, 1 
  sw $t0, 16($a0) 
  
    # Erase obstacle and reset to start from the right side of the screen
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
  li $t1, 128     # constant to calculate row number
  lw $t2, 4($t0)    # get the lower bound
  add  $t2, $t2, $a0     # set the lower bound
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
      # If there was a collision than handle it
  bgt $t2, $0, handleCollision
  afterCollision:

  #Draw obstacle
  li $t0, objectColor
  lw $t1, 0($a0)
  sw $t0, 0($t1)
  sw $t0, 128($t1)
      # Erase the tail of the obstacle
  li $t0, black
  sw $t0, 8($t1)
  sw $t0, 136($t1)

  jr $ra
     # If there was a previous collision than we erase the previous location of the obstacle
 erasePrevious:
     # Get previous location
  lw $t2, 12($a0)
  li $t0, black
  # erase to black
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
  #Look for a block with a shield to erase

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
  # If a block without a shield is not found then game over
  j gameOver
  j afterCollision
  removeShield:
    # If a block with a shield this found than erase the shield
  li $t0, black
  sw $t0, 0($t3)
  sw $0, 16($a0)
  j afterCollision

gameOver:
    # Paint the whole screen block
  li $t0, BASE_ADDRESS 
  move $a0, $t0
  li $a1, 32
  li $a2, 32
  jal paintBlack
  # Paint the skull on the ending screen
  li $t0, BASE_ADDRESS 
  li $t1, white
  sw $t1, 1052($t0)
  sw $t1, 1056($t0)
  sw $t1, 1112($t0)
  sw $t1, 1116($t0)

  sw $t1, 1180($t0)
  sw $t1, 1184($t0)
  sw $t1, 1240($t0)
  sw $t1, 1244($t0)

  sw $t1, 1316($t0)
  sw $t1, 1364($t0)

  sw $t1, 1448($t0)
  sw $t1, 1456($t0)
  sw $t1, 1460($t0)
  sw $t1, 1464($t0)
  sw $t1, 1468($t0)
  sw $t1, 1472($t0)
  sw $t1, 1476($t0)
  sw $t1, 1480($t0)
  sw $t1, 1488($t0)

  sw $t1, 1580($t0)
  sw $t1, 1584($t0)
  sw $t1, 1588($t0)
  sw $t1, 1592($t0)
  sw $t1, 1596($t0)
  sw $t1, 1600($t0)
  sw $t1, 1604($t0)
  sw $t1, 1608($t0)
  sw $t1, 1612($t0)

  sw $t1, 1704($t0)
  sw $t1, 1708($t0)
  sw $t1, 1712($t0)
  sw $t1, 1716($t0)
  sw $t1, 1720($t0)
  sw $t1, 1724($t0)
  sw $t1, 1728($t0)
  sw $t1, 1732($t0)
  sw $t1, 1736($t0)
  sw $t1, 1740($t0)
  sw $t1, 1744($t0)

  sw $t1, 1832($t0)
  sw $t1, 1836($t0)
  sw $t1, 1852($t0)
  sw $t1, 1868($t0)
  sw $t1, 1872($t0)

  sw $t1, 1960($t0)
  sw $t1, 1964($t0)
  sw $t1, 1980($t0)
  sw $t1, 1996($t0)
  sw $t1, 2000($t0)

  sw $t1, 2088($t0)
  sw $t1, 2092($t0)
  sw $t1, 2100($t0)
  sw $t1, 2104($t0)
  sw $t1, 2108($t0)
  sw $t1, 2112($t0)
  sw $t1, 2116($t0)
  sw $t1, 2124($t0)
  sw $t1, 2128($t0)


  sw $t1, 2216($t0)
  sw $t1, 2220($t0)
  sw $t1, 2228($t0)
  sw $t1, 2232($t0)
  sw $t1, 2240($t0)
  sw $t1, 2244($t0)
  sw $t1, 2252($t0)
  sw $t1, 2256($t0)
  
  sw $t1, 2344($t0)
  sw $t1, 2348($t0)
  sw $t1, 2352($t0)
  sw $t1, 2356($t0)
  sw $t1, 2360($t0)
  sw $t1, 2364($t0)
  sw $t1, 2368($t0)
  sw $t1, 2372($t0)
  sw $t1, 2376($t0)
  sw $t1, 2380($t0)
  sw $t1, 2384($t0)

  sw $t1, 2468($t0)
  sw $t1, 2476($t0)
  sw $t1, 2480($t0)
  sw $t1, 2484($t0)
  sw $t1, 2488($t0)
  sw $t1, 2492($t0)
  sw $t1, 2496($t0)
  sw $t1, 2500($t0)
  sw $t1, 2504($t0)
  sw $t1, 2508($t0)
  sw $t1, 2516($t0)
  
  sw $t1, 2592($t0)
  sw $t1, 2608($t0)
  sw $t1, 2612($t0)
  sw $t1, 2620($t0)
  sw $t1, 2628($t0)
  sw $t1, 2632($t0)
  sw $t1, 2648($t0)

  sw $t1, 2712($t0)
  sw $t1, 2716($t0)
  sw $t1, 2736($t0)
  sw $t1, 2740($t0)
  sw $t1, 2748($t0)
  sw $t1, 2756($t0)
  sw $t1, 2760($t0)
  sw $t1, 2780($t0)
  sw $t1, 2784($t0)

  sw $t1, 2840($t0) 
  sw $t1, 2844($t0) 
  sw $t1, 2864($t0) 
  sw $t1, 2868($t0) 
  sw $t1, 2884($t0) 
  sw $t1, 2888($t0) 
  sw $t1, 2908($t0) 
  sw $t1, 2912($t0) 
  j exit

checkPick:
  #$a0 pick up object
  lw $t0, 0($a0)
  lw $t1, playerLocation

  # Check if player is within three by three area of pickup 
  sub $t2, $t0, $t1
  li $t3, 0
  beq $t2, $t3, pickConfirm
  li $t3, 4
  beq $t2, $t3, pickConfirm
  li $t3, 8
  beq $t2, $t3, pickConfirm
  li $t3, 128
  beq $t2, $t3, pickConfirm
  li $t3, 132
  beq $t2, $t3, pickConfirm
  li $t3, 136
  beq $t2, $t3, pickConfirm
  li $t3, 256
  beq $t2, $t3, pickConfirm
  li $t3, 260
  beq $t2, $t3, pickConfirm
  li $t3, 264
  beq $t2, $t3, pickConfirm
  jr $ra
pickConfirm:
    # If the players in the area than we set the pick flag to true
  li $t0, 1
  sw $t0, 8($a0)
  jr $ra

checkGood:
  la $t0, pickGood
  lw $t1, 8($t0)
      # If it has not been picked up then we can return
  beq $t1, $0, returnCheck
  sw $0, 8($t0)
    # Get a random rule number
  li $a1, 31
  li $v0, 42
  syscall
  li $t1, 128     # constant to calculate row number
  
  
  mult $t1, $a0     # calculate row
  mflo $t1
  addi $t1, $t1, 80
  addi $t1, $t1, BASE_ADDRESS
  sw $t1, 0($t0)
  # check for empty shield and replace with blue shield
  la $t0, player
  li $t2, black
    # Whichever shield is black, a shield to it
  lw $t1, 4($t0) 
  addi $t3,$t0, 4
  beq $t1, $t2, addShield
  lw $t1, 8($t0) 
  addi $t3, $t0, 8
  beq $t1, $t2, addShield
  lw $t1, 12($t0) 
  addi $t3,$t0, 12
  beq $t1, $t2, addShield
  lw $t1, 28($t0) 
  addi $t3, $t0, 28
  beq $t1, $t2, addShield
  lw $t1, 32($t0) 
  addi $t3, $t0, 32
  beq $t1, $t2, addShield
      # If every shield is blue than we can return
  j returnCheck

  addShield:
      # set address of shield to blue
  li $t0, blue
  sw $t0, 0($t3)

  returnCheck:
  jr $ra

drawPick:
    # Draw the pickup
        # $a0, pick up object to be drawn
  lw $t0, 12($a0)
  lw $t1, 0($a0) 
  sw $t0, 0($t1)
  jr $ra
checkBad:

  la $t0, pickBad
  lw $t1, 8($t0)
  # If it has not been picked up and we can return
  beq $t1, $0, returnCheckOther
  sw $0, 8($t0)

  li $a1, 31
  li $v0, 42
  syscall     # get a random row number
  li $t1, 128     # constant to calculate row number
  
  
  mult $t1, $a0     # calculate row
  mflo $t1
  addi $t1, $t1, 12     # bad pickups were always beyond the left side of the screen, 12 away from the left
  addi $t1, $t1, BASE_ADDRESS
  sw $t1, 0($t0)
  # Replace all shields with black
  la $t0, player
  li $t2, black
  sw $t2, 4($t0)
  sw $t2, 8($t0)
  sw $t2, 12($t0)
  sw $t2, 28($t0)
  sw $t2, 32($t0)

  returnCheckOther:
  jr $ra
