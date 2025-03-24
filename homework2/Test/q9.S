# HW2 Q9
.section .text
.globl _start

_start:
lui s1, 0x12345        # Load upper 32-bit (0x1234500000000000)
addi s1, s1, 0x678     # Add next significant bits (0x1234567800000000)
slli s1, s1, 8        # Shift left by 16 (prepare space for next part)
ori s1, s1, 0x9A 
slli s1, s1, 8        # Shift left by 16 (prepare space for next part)
ori s1, s1, 0xBC    # Insert next 16 bits (0x123456789ABC0000)
slli s1, s1, 8        # Shift left by 16 (prepare space for next part)
ori s1, s1, 0xDE
slli s1, s1, 4        # Shift left by 16 (prepare space for next part)
ori s1, s1, 0xF      # Insert lower 16 bits (0x123456789ABCDEF)



