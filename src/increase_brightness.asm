.data
input_filename: .asciiz "/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample_images/house_64_in_ascii_cr.ppm"
input_buffer: .space 49171
output_filename: .asciiz "/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample__output_images/house_64_in_ascii_cr_output_brighness.ppm"
output_buffer: .space 49171
ascii_buffer: .word 0
avg_input_prompt: .asciiz "Average pixel value of the original image:\n"
avg_output_prompt: .asciiz "\nAverage pixel value of new image:\n"

.text
.globl main

main:
    # Open input file
    li $v0, 13 
    la $a0, input_filename
    li $a1, 0 
    syscall 
    bltz $v0, exit 
    move $s0, $v0 

    # Read input file into buffer
    li $v0, 14 
    move $a0, $s0
    la $a1, input_buffer
    li $a2, 49171
    syscall 
    bltz $v0, close_file 

    move $t7, $a1 
    li $s7, 0 
    li $s6, 0
    li $t6, 0
    la $t4, output_buffer 

find_pixels:
    lb $t0, 0($t7) 
    beq $t6, 4, increment_pixels 

    beq $t0, 10, inc_count 
    sb $t0, 0($t4)
    addiu $t4, $t4, 1
    addiu $t7, $t7, 1 
    j find_pixels 

inc_count:
    addiu $t6, $t6, 1 
    j find_pixels 

increment_pixels:
    jal parse_int 
    add $s7, $s7, $t0 
    addi $t0, $t0, 10 
    li $t3, 255
    min $t0, $t0, $t3 
    add $s6, $s6, $t0 
    la $t5, ascii_buffer
    li $t1, 10 
    sb $t1, 0($t5) 
    addiu $t5, $t5, 1 
    jal parse_ascii
    jal write_output_buffer 
    addiu $t7, $t7, 1
    bne $t6, 12292, increment_pixels
    j write_output

parse_int:
    lb $t1, 0($t7)
    beq $t1, 10, return_int
    addiu $t1, $t1, -48 
    mul $t0, $t0, 10 
    add $t0 $t0, $t1 
    addiu $t7, $t7, 1 
    j parse_int

return_int:
    addiu $t6, $t6, 1
    jr $ra

parse_ascii:
    divu $t0, $t0, 10
    mfhi $t1
    addiu $t1, $t1, 48 
    sb $t1, 0($t5) 
    addiu $t5, $t5, 1
    bnez $t0, parse_ascii 
    jr $ra

write_output_buffer:
    lb $t0, 0($t5) 
    sb $t0, 0($t4)
    addiu $t4, $t4, 1
    addiu $t5, $t5, -1 
    bne $t0, 10, write_output_buffer 
    jr $ra

write_output:
    li $v0, 13
    la $a0, output_filename
    li $a1, 1 
    syscall 
    move $s1, $v0
    bltz $v0, exit 
    la $t0, output_buffer
    sub $t1, $t4, $t0
    li $v0, 15 
    move $a2, $t1 
    move $a0, $s1
    la $a1, output_buffer 
    syscall 

    # Close output file
    move $a0, $s1
    li $v0, 16 
    syscall

print_avg:
    la $a0, avg_input_prompt 
    li $v0, 4 
    syscall
    li $t1, 3134460
    mtc1 $s7, $f0
    mtc1 $t1, $f1 
    div.s $f12, $f0, $f1
    li $v0, 2 
    syscall
    la $a0, avg_output_prompt 
    li $v0, 4 
    syscall 
    mtc1 $s6, $f0
    div.s $f12, $f0, $f1 
    li $v0, 2 
    syscall
    j exit

close_file:
    li $v0, 16 
    syscall

exit:
    li $v0, 10 
    syscall