.data          
    input_filename:     .asciiz "/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample_images/house_64_in_ascii_cr.ppm"
    input_buffer:       .space  49171
    output_filename:    .asciiz "/Users/willmadikizela/My Drive/UCT/CSC2002S/Assignemnts/image-processiog-using-MIPS/sample__output_images/house_64_in_ascii_cr_output_brighness.ppm"
    output_buffer:      .space  49171
    ascii_buffer:       .word   0
    avg_input_prompt:   .asciiz "Average pixel value of the original image:\n"
    avg_output_prompt:  .asciiz "\nAverage pixel value of new image:\n"
.text                              
.globl      main     

main:
    # Open the input image file
    li      $v0, 13                     
    la      $a0, input_filename         
    li      $a1, 0                     
    syscall
    bltz    $v0, exit_program                 
    move    $s0, $v0                          		

    # Read the input image file into a buffer
    li      $v0, 14                     
    move    $a0, $s0                    
    la      $a1, input_buffer           
    li      $a2, 49171                  
    syscall
    bltz    $v0, close_input_file        

    move    $t7, $a1                        
    li      $s7, 0                      
    li      $s6, 0                     
    li      $t6, 0                      
    la      $t4, output_buffer          

find_headers:
    lb		$t0, 0($t7)                 
    beq     $t6, 4, process_pixel_values    
    beq		$t0, 10, increase_eol_count      
    bne     $t0, 10, increase_buffer_address     

    increase_eol_count:
        addi    $t6, $t6, 1             

    increase_buffer_address:                        
        sb      $t0, 0($t4)             
        addi    $t4, $t4, 1             
        addi    $t7, $t7,1              
    
    j       find_headers                 

process_pixel_values:
    # Convert ASCII value to integer for pixel processing
    li      $t0, 0                      
    jal     convert_ascii_to_int                   

    # Adjust the brightness of the pixel
    add     $s7, $s7, $t0               
    addi    $t0, $t0, 10                
    bgt		$t0, 255, adjust_max_pixel_value    

    j       save_pixel_to_output        

adjust_max_pixel_value:
    li      $t0, 255                    

save_pixel_to_output:
    add     $s6, $s6, $t0               

    # Convert the integer pixel value to ASCII for output
    la      $t5, ascii_buffer           
    li      $t1, 10                     
    sb      $t1, 0($t5)                 
    addi    $t5, $t5, 1                 
    jal     convert_int_to_ascii	

    # Store the new ASCII pixel value in the output buffer
    addi    $t5, $t5, -1                
    jal     write_to_output_buffer        

    addi    $t7, $t7, 1                 

    # If we haven't processed the entire image, continue to the next pixel
    bne     $t6, 12292, process_pixel_values
    
    # Store the modified image data in the output file
    j       save_output_to_file

convert_ascii_to_int:
    lb      $t1, 0($t7)                 
    beq     $t1, 10, return_int_value   
    addi    $t1, $t1, -48               
    mul     $t0, $t0, 10                
    add     $t0 $t0, $t1                
    addi    $t7, $t7, 1                 

    j       convert_ascii_to_int	               

    return_int_value:                     
        addi    $t6, $t6, 1             
        jr		$ra	

convert_int_to_ascii:
    divu    $t0, $t0, 10                
    mfhi    $t1                         
    addi    $t1, $t1, 48                
    sb      $t1, 0($t5)                 
    addi    $t5, $t5, 1                 
    bnez    $t0, convert_int_to_ascii            

    jr      $ra

write_to_output_buffer:
    lb      $t0, 0($t5)                 
    sb      $t0, 0($t4)                 
    addi    $t4, $t4, 1                 
    addi    $t5, $t5, -1                

    bne     $t0, 10, write_to_output_buffer

    jr      $ra

save_output_to_file:
    # Open the output file to store the modified image
    li      $v0, 13                     
    la      $a0, output_filename        
    li      $a1, 1                      
    syscall
    move    $s1, $v0                    
    bltz    $v0, exit_program                 

    # Determine the number of characters to write to the output file
    la      $t0, output_buffer          
    sub     $t1, $t4, $t0               

    # Write the modified image data to the output file
    li      $v0, 15                     
    move    $a2, $t1                    
    move    $a0, $s1                    
    la      $a1, output_buffer          
    syscall

    # Close the output file after writing
    move    $a0, $s1                    
    li      $v0, 16                     
    syscall	

print_averages:
    # Display the average pixel values before and after modification
    la      $a0, avg_input_prompt       
    li      $v0, 4                      
    syscall

    li      $t1, 3134460                
    mtc1    $s7, $f2                    
    mtc1    $t1, $f4                    
    div.d   $f12, $f2, $f4              
    li      $v0, 3                      
    syscall

    la      $a0, avg_output_prompt      
    li      $v0, 4                      
    syscall
                 
    mtc1    $s6, $f2                    
    div.d   $f12, $f2, $f4              
    li      $v0, 3                      
    syscall

    # Close the input image file and exit the program
    j       close_input_file            
    j       exit_program                

close_input_file:
    move    $a0, $s0                    
    li      $v0, 16                     
    syscall

exit_program:
    # End of program
    li      $v0, 10                     
    syscall

