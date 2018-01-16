# v171215

#########################################
# Vorgabe: read_email
#########################################
# $a0: buffer
# $v0: number of characters read

read_email:
    move $t0, $a0

    # read mail from disk
    li $v0, 13
    la $a0, input_file
    li $a1, 0
    li $a2, 0
    syscall

    # save fd
    move $t1, $v0

    # read to buffer
    li $v0, 14
    move $a0, $t1
    move $a1, $t0 # address of buffer
    li $a2, 4096
    syscall

    move $t0, $v0

    # close file
    li $v0, 16
    move $a0, $t1 # fd
    syscall

    move $v0, $t0

    jr $ra

#########################################
# Vorgabe: write_email
#########################################
# $a0: buffer
# $a1: number of characters to write
# $a2: truncate file

write_email:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    move $s0, $a0
    move $s1, $a1

    # open file
    li $v0, 13
    la $a0, output_file

    bne $zero, $a2, write_email_trunc
    j write_email_notrunc
    write_email_trunc:
    li $a1, 0x241       # mode O_WRONLY | O_CREAT | O_TRUNC
    j write_email_else

    write_email_notrunc:
    li $a1, 0x441       # mode O_WRONLY | O_CREAT | O_APPEND

    write_email_else:
    li $a2, 0x1a4
    syscall             # fd in $v0

    move $s2, $v0       # save fd

    li $v0, 15          # write to file
    move $a0, $s2
    move $a1, $s0
    move $a2, $s1
    syscall

    # close file
    li $v0, 16
    move $a0, $s2
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra


#########################################
# Aufgabe 3: Ausgabe
#########################################
# a0: buffer
# a1: buffer length
# a2: relative position of subject
# a3: spam flag // stimmt nicht, bitte signaturen richtig schreiben!!
#########################################
# IDEA: call write_email with first part, then spam flag, then second part

print_email:
    ### Register gemass Konventionen sichern
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    move     $s0, $a0        # save args
    move     $s1, $a1        #
    move     $s2, $a2        #
    move     $s3, $a3        #

    ### First call: truncate
    move     $a0, $s0        # buffer
    move     $a1, $s2        # rel. position of subject (only print first part so spam flag can be appended)
    li       $a2, 1          # truncate in case file isn't empty
    jal      write_email

    beq      $s3, $zero, skip_flag    # if not spam don't print spam flag
    ### Second call: append flag
    la       $a0, spam_flag
    lw       $a1, spam_flag_length
    li       $a2, 0          # do not truncate, append instead
    jal      write_email

    skip_flag:
    ### Third call: append rest of email
    add      $a0, $s0, $s2      # start at adress (buffer + 292), since we already printed the first 292 chars
    sub      $a1, $s1, $s2      # (length - 292) characters yet to write
    li       $a2, 0             # do not truncate, append instead
    jal      write_email




    ### gesicherte Register wieder herstellen
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra


#########################################
#

#
# data
#

.data

input_file: .asciiz "/home/prez/Code/MIPS-spamfilter/email1"
output_file: .asciiz "/home/prez/Code/MIPS-spamfilter/output"
email_buffer: .space 4096

spam_flag: .asciiz "[SPAM] "
spam_flag_length: .word 7

#
# main
#

.text
.globl main

main:
    # Register sichern
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # E-Mail einlesen
    la $a0, email_buffer
    jal read_email

    la $a0, email_buffer

    # Groesse
    move $a1, $v0

    # Position des Subjekts
    li $a2, 292

    # Spam
    li $a3, 1

    # E-Mail ausgeben
    jal print_email

    # Register wieder herstellen
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

#
# end main
#
