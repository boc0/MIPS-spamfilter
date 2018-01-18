# v171218

#########################################
# Vorgabe: find_str
#########################################
# $a0: haystack
# $a1: len of haystack
# $a2: needle
# $a3: len of needle
# $v0: relative position of needle, -1 if not found

find_str:
    # save $ra on stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # save beginning of haystack
    move $t5, $a0
    # save len of needle
    move $t4, $a3

    # calc end address of haystick and needle
    add $a1, $a1, $a0
    add $a3, $a3, $a2

haystick_loop:
    bge $a0, $a1, haystick_loop_end

    move $t6, $a0
    move $t7, $a2
needle_loop:
    # load char from haystick
    lbu $t0, 0($t6)
    # load char from needle
    lbu $t1, 0($t7)

    bne $t0, $t1, needle_loop_end

    addi $t6, $t6, 1
    addi $t7, $t7, 1

    # reached end of needle
    bge $t7, $a3, found_str

    # reached end of haystick
    bge $t6, $a1, found_nostr

    j needle_loop
needle_loop_end:

    addi $a0, $a0, 1
    j haystick_loop
haystick_loop_end:

found_nostr:
    # prepare registers so found_str: produces -1
    li $t6, 0
    li $t5, 0
    li $t4, 1

found_str:
    sub $v0, $t6, $t5
    sub $v0, $v0, $t4


    # restore $ra from stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#########################################
# Aufgabe 2: Spamfilter
#########################################
# $v0: Spamscore

spamfilter:
    ### Register gemaess Registerkonventionen sichern
	addi $sp, $sp, -40
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6,	28($sp)
	sw $s7, 32($sp)
	
	li $t0, ','
	sw $t0, 36($sp)

   
	
 	
	### Badwords liegen im Puffer badwords_buffer
	# load start address of badwords_buffer
	la $s3, badwords_buffer
	
	# load badwords_size
	lw $s4, badwords_size
	
	# calc end address of badwords_size
	add $s0, $s3, $s4

	li $s6, 0 # init current spamscore value
	li $s7, 0 # init total spamscore value


### Schleife ueber Bad words (wort1,gewicht1,wort2,gewicht2,...)
badwords_loop:



		### lese ein Wort

########################################_GET_BADWORD_########################################
#                                                                                           #

	bge $s3, $s0, badwords_loop_end		# branch if end of string reached

	# find_str arguments
	move $a0, $s3		# a0 = current start of badwords_buffer = haystack
	move $a1, $s4		# a1 = current badwords_size = len of haystack
	la $a2, 36($sp)		# a2 = load literal ',' from stack = needle
	li $a3, 1 		# a3 = length of literal ',' = len of needle


	li $v0, 0		# $v0 = 0 (for return in find_str value if not found)
	jal find_str		# find ',' character 
	
	move $s5, $v0		# save relative ',' position
	move $s2, $s5		# save badword length
	move $s1, $s3     	# save badword start adress
		
	# set next buffer and buffersize (badwords)
	addi $s3, $s3, 1	# add length of char to new start of buffer (skips ',' character)
	add $s3, $s3, $s5	# add length of string (start to next ',' character)
	addi $s4, $s4, -1	# sub length of ',' character
	sub $s4, $s4, $s5 	# sub length of string from buffersize

#                                                                                           #
#############################################################################################




        ### lese und konvertiere Gewicht

####################################_GET_CURRENT_SCORE_######################################
#                                                                                           #
	# find_str arguments
	move $a0, $s3		# a0 = current start of badwords_buffer = haystack
	move $a1, $s4		# a1 = current badwords_size = len of haystack
	la $a2, 36($sp)		# a2 = load literal ',' from stack = needle
	li $a3, 1 		# a3 = length of literal ',' = len of needle

	li $v0, 0		# $v0 = 0 (for return in find_str value if not found)
	jal find_str		# find ',' character

	li $t0, -1		# beq check value
	bne $v0, $t0, score_else_A		# else if not equal
	sub $v0, $s0, $s3	# if find_str retunrs -1 change $s5 to length of last string	

score_else_A:
	move $s5, $v0		# save relative ',' position
	move $t2, $s5		# save spamscore length 
	move $t1, $s3		# save spamscore start adress	
		
	# convert char to int
	add $t3, $t1, $t2 	# calc end spamscore adress

convert_loop:
	beq $t3, $t1, convert_loop_end		# end loop if all digits are converted
	lbu $t4, 0($t1)		# $t1 = start of score adress
	addi $t4, $t4 -48	# sub ascii code offset to get int
	
	move $t7, $t2		# save spamscore length

	li $t5, 1		# init multiplier
	li $t6, 10		# init base 
decimal_loop:
	beq $t7, $zero, decimal_loop_end	# check if end of spamscore value 
	mult $t4, $t5		# multiply spamscore valu 
	mflo $t4		# get only least sign bits -> works under 32 bits result size
	mult $t5, $t6		# increase multiplier
	mflo $t5			
	addi $t7, $t7, -1	# decimal loop: decrease spamscore (digit) length
	j decimal_loop
decimal_loop_end:

	addi $t2, $t2, -1	# convert loop: decrease spamscore (digit) length
	add $s6, $s6, $t4	# increase current spamscore (not total)
	addi $t1, $t1, 1	# next digit
	j convert_loop
convert_loop_end:

	# set next buffer and buffersize (badwords)
	addi $s3, $s3, 1	# add length of char to new start of buffer (skips ',' character)
	add $s3, $s3, $s5	# add length of string (start to next ',' character)
	addi $s4, $s4, -1	# sub length of ',' character
	sub $s4, $s4, $s5 	# sub length of string from buffersize

#                                                                                           #
#############################################################################################




        ### suche alle Vorkommen des Wortes im Text der E-Mail und addiere Gewicht

###################################_CHECK_EMAIL_#############################################
#                                                                                           #
	### Der Text der E-Mail liegt im Puffer email_buffer

		# init arguments for find_str																			
		la $a0, email_buffer		# email_buffer = haystack
		lw $a1, size			# size = haystack len
		move $a2, $s1			# badword = needle
		move $a3, $s2			# badword len = needle len
		
		move $s5, $a0			# save email_buffer
		move $s1, $a1			# save size

email_loop:
		li $v0, 0			# reset return register
		jal find_str			# call find_str with email and badword as argument

		li $t0, -1			# beq check value
		beq $t0, $v0, email_loop_end	# if not found end loop

		add $s7, $s7, $s6		# increase total spamscore
		
		#init current position in string    
		add $s5, $s5, $v0
		add $s5, $s5, $s2
		
		#init current size in string	
		sub $s1, $s1, $v0
		sub $s1, $s1, $s2
		
		move $a0, $s5 			# email_buffer = haystack
		move $a1, $s1			# size = haystack len
		move $a2, $a2 			# badword = needle
		move $a3, $s2			# badword size = needle len	
		j email_loop	

email_loop_end:

#                                                                                           #
#############################################################################################	

	# reset current spamscore
	li $s6, 0
	
	j badwords_loop

badwords_loop_end:

    ### Rueckgabewert setzen
	move $v0, $s7   # $v0 = $s7

    ### Register wieder herstellen
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6,	28($sp)
	lw $s7, 32($sp)

	addi $sp, $sp, 40

    jr $ra

#########################################
# Aufgabe 2 Ende
#########################################


#
# data
#

.data

email_buffer: .asciiz "Hochverehrte Empfaenger,\r\n\r\nbei dieser E-Mail handelt es sich nicht um Spam sondern ich moechte Ihnen\r\nvielmehr ein lukratives Angebot machen: Mein entfernter Onkel hat mir mehr Geld\r\nhinterlassen als in meine Geldboerse passt. Ich muss Ihnen also etwas abgeben.\r\nVorher muss ich nur noch einen Spezialumschlag kaufen. Senden Sie mir noch\r\nheute BTC 1,000 per Western-Union und ich verspreche hoch und heilig Ihnen\r\nalsbald den gerechten Teil des Vermoegens zu vermachen.\r\n\r\nHochachtungsvoll\r\nAchim Mueller\r\nSekretaer fuer Vermoegensangelegenheiten\r\n"

size: .word 550

badwords_buffer: .asciiz "Spam,5,Geld,1,ROrg,0,lukrativ,3,Kohlrabi,10,Weihnachten,3,Onkel,7,Vermoegen,2,Brief,4,Lotto,3"
badwords_size: .word 93

spamscore_text: .asciiz "Der Spamscore betraegt: "

#
# main
#

.text
.globl main

main:
    # Register sichern
    addi $sp, $sp, 8
    sw $ra, 0($sp)
    sw $s0, 4($sp)


    jal spamfilter
    move $s0, $v0


    li $v0, 4
    la $a0, spamscore_text
    syscall
    move $a0, $s0
    li $v0, 1
    syscall

    li $v0, 11
    li $a0, 10
    syscall


    # Register wieder herstellen
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

#
# end main
#
