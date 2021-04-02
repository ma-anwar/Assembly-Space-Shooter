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





.text

  li $t0, BASE_ADDRESS # $t0 stores the base address for display1
  move $a0, $t0
  li $a1, 32
  li $a2, 32
  jal paintBlack
  lw $a0, playerLocation
  
  la $a1, player
  jal drawImage
  

main:
  #get movement
  li $s7, 0xffff0000
  lw $s6, 0($s7)
  beq $s6, 1, keypress
afterPress:

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
 # beq $t2, 0x70, respondP
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
  sub $t1, $t1, $t2 

  beq $t1, $0, skipD
  li $t3, 116
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
