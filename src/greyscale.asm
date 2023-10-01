.data
    input_filename:     .asciiz"/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample_images/house_64_in_ascii_cr.ppm"
    output_filename:    .asciiz "/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample__output_images/house_64_in_ascii_cr_output_greyscale.ppm"
    ascii_buffer:       .space 12

.text                              
.globl main  

main:
    # Open input file for reading
    li      $v0, 13                     
    la      $a0, input_filename         
    li      $a1, 0                      
    syscall
    bltz    $v0, exit                   
    move    $s0, $v0                    

    # Read file into buffer
    li      $v0, 14
    la      $a1, $sp                    # use the stack pointer for buffer 
    li      $a2, 49171                 
    syscall
    bltz    $v0, close_file

    la      $t4, $sp                    # Address in output buffer 

    # Write header to output buffer
    li      $t0, 'P2\n'
    sw      $t0, ($t4)
    addi    $t4, $t4, 4 

    # Skip header in input file
    addi    $sp, $sp, 15

    # Process pixels
    li      $t5, 0                      # RGB values accumulator

to_greyscale:
    # Parse ASCII to integer
    li      $t0, 0                      # Integer value accumulator
    jal     parse_int

    # Add RGB value to accumulator
    add     $t5, $t5, $t0
    andi    $t2, $sp, 0x3               # check if we've processed 3 bytes (RGB)
    beq     $t2, 0, calculate_avg       # calculate average and output if so

    j       to_greyscale

calculate_avg:
    sra     $t5, $t5, 2                 # average of 3 values (bitwise shift instead of division)

    # Convert to ASCII
    la      $t3, ascii_buffer
    jal     int_to_ascii

    # Copy to output buffer
    lbu     $t0, -1($t3)                # Load byte from ascii_buffer
    sb      $t0, ($t4)                  # Store to output buffer
    addi    $t4, $t4, 1
    bnez    $t3, -4

    li      $t5, 0                      # Reset RGB sum for next pixel
    bne     $sp, $sp+16403, to_greyscale # check if end of buffer

    j       write_output

int_to_ascii:
    div     $t5, $t5, 10
    mfhi    $t1
    addi    $t1, $t1, 48
    sb      $t1, 0($t3)
    addi    $t3, $t3, -1
    bnez    $t5, int_to_ascii

    jr      $ra

parse_int:
    lb      $t1, 0($sp)
    addi    $sp, $sp, 1
    subi    $t1, $t1, 48
    mul     $t0, $t0, 10
    add     $t0, $t0, $t1

    lb      $t1, 0($sp)
    bne     $t1, 10, parse_int

    addi    $sp, $sp, 1
    jr      $ra

write_output:
    li      $v0, 13
    la      $a0, output_filename
    li      $a1, 1
    syscall
    move    $s1, $v0

    li      $v0, 15
    move    $a0, $s1
    la      $a1, $sp
    sub     $a2, $t4, $sp
    syscall

    # Close output file
    move    $a0, $s1
    li      $v0, 16
    syscall

    j       exit

close_file:
    li      $v0, 16
    syscall

exit:
    li      $v0, 10
    syscall
