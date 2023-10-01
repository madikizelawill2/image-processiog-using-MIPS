.data
    input_filename:     .asciiz"/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample_images/house_64_in_ascii_cr.ppm"
    output_filename:    .asciiz "/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample__output_images/house_64_in_ascii_cr_output_greyscale.ppm"
    input_buffer:    .space  49172
    output_buffer:   .space  16403
    ascii_buffer:    .word   0
    file_format:     .asciiz "P2\n"

.text                              
.globl      main  

main:
    # Open input file
    li      $v0, 13                     # System call code for file open
    la      $a0, input_filename         # Address of filename for input
    li      $a1, 0                      # Mode: read-only
    syscall
    bltz    $v0, exit_program           # Exit if failed to open input file
    move    $s0, $v0                    # Save input file descriptor to $s0 for future use

    # Read contents from input file into buffer
    li      $v0, 14                     # System call code for file read
    move    $a0, $s0                    # Pass input file descriptor
    la      $a1, input_buffer           # Address of buffer to read data into
    li      $a2, 49171                  # Maximum number of bytes to read
    syscall
    bltz    $v0, close_input_file       # Close file if read fails

    # Initialize processing registers
    move    $t7, $a1                    # Address in input buffer
    li      $t6, 0                      # Counter for end-of-line (EOL) characters
    la      $t4, output_buffer          # Address in output buffer
    li      $t5, 0                      # Accumulator for RGB values
    la      $t3, file_format            # P2 file format header

    # Begin processing header
    j       process_header

process_header:
    lb      $t0, 0($t3)                 # Load character from file format string
    sb      $t0, 0($t4)                 # Store character to output buffer

    addi    $t3, $t3, 1                 # Move to next character in file format string
    addi    $t4, $t4, 1                 # Move to next byte in output buffer

    # Check if we've processed the entire header
    bne     $t0, 10, process_header     # If not EOL character, continue processing header

    addi    $t7, $t7, 3                 # Skip to start of pixel data in input buffer
    addi    $t6, $t6, 1                 # Increment EOL character counter

    # Find pixel data after header
    j       identify_pixel_data

identify_pixel_data:
    lb      $t0, 0($t7)                 # Load byte from input buffer

    # Check if we're done processing header
    beq     $t6, 4, convert_to_greyscale
    beq     $t0, 10, increment_eol_count # If EOL character, increment EOL counter
    j       copy_header_to_output       # Otherwise, continue copying header to output

increment_eol_count:
    addi    $t6, $t6, 1                 # Increment EOL count

copy_header_to_output:       
    addi    $t7, $t7, 1                 # Move to next byte in input buffer
    sb      $t0, 0($t4)                 # Store byte to output buffer
    addi    $t4, $t4, 1                 # Move to next byte in output buffer

    j       identify_pixel_data         # Repeat for next byte

convert_to_greyscale:
    # Convert ASCII pixel values to integer
    li      $t0, 0                      # Initialize integer accumulator
    jal     ascii_to_integer            # Call function to convert ASCII to integer

    # Compute greyscale values
    add     $t5, $t5, $t0               # Add integer value to RGB accumulator
    move    $t0, $t6
    addi    $t0, $t0, -4                # Adjust for header lines
    divu    $t1, $t0, 3                # Divide by 3 for RGB channels
    mfhi    $t2                         # Get remainder of division

    # Check if we've processed all 3 RGB channels for this pixel
    beq     $t2, 0, compute_avg_greyscale
    j       convert_to_greyscale        # If not, continue processing

compute_avg_greyscale:
    li      $t0, 3                      # Number of RGB channels
    divu    $t5, $t0                    # Compute average of RGB values

    # Convert integer greyscale value to ASCII and store to output buffer
    jal     integer_to_ascii
    move    $t5, $0                     # Reset RGB accumulator
    j       convert_to_greyscale        # Continue with next pixel

ascii_to_integer:
    # Convert ASCII value to integer
    lb      $t0, 0($t7)                 # Load byte from input buffer

    # Check for space character or end of ASCII value
    bne     $t0, 32, skip_space_character
    j       return_from_function

skip_space_character:
    # Multiply accumulator by 10 for next digit
    li      $t1, 10
    mul     $t0, $t0, $t1

    # Convert ASCII character to integer and add to accumulator
    addi    $t0, $t0, -48

    addi    $t7, $t7, 1                 # Move to next byte in input buffer
    j       ascii_to_integer            # Repeat for next byte

return_from_function:
    jr      $ra                         # Return from function

integer_to_ascii:
    # Convert integer value to ASCII
    # (This function can be expanded with further implementation)
    jr      $ra                         # Return from function

close_input_file:
    # Close input file
    li      $v0, 16                     # System call code for file close
    move    $a0, $s0                    # Pass input file descriptor
    syscall

exit_program:
    # Exit program
    li      $v0, 10                     # System call code for program exit
    syscall
