# HW2 Q10
.section .text
.globl _start

_start:
 li t0, 0x42
 li t1, 0x37
 li t2, 0xFD
 li t3, 0x83
 li t4, 0x11
 lui a5, 0x80000

 sb t0, 0(a5)
 sb t1, 1(a5)
 sb t2, 2(a5)
 sb t3, 3(a5)
 sb t4, 4(a5)

find_max: 
# computes the max of 5 numbers stored in memory sequentially and stores it in a2.
 lbu a0, 0(a5) # a0 = 1st num var
 add a2, a0, zero # a2 = temp max = a0
 lbu a1, 1(a5) # a1 = 2nd num var
 li t1, 1 # t1 = 1 for branch comparisons
 
max2:
 slt t0, a2, a1 # t0 = 1 if new max found
 bne t0, t1, max3 # skip max assignment if no new max found.
 lbu a2, 1(a5)

max3:
 lbu a1, 2(a5)
 slt t0, a2, a1 # t0 = 1 if new max found
 bne t0, t1, max4 # skip max assignment if no new max found.
 lbu a2, 2(a5)

max4:
 lbu a1, 3(a5)
 slt t0, a2, a1 # t0 = 1 if new max found
 bne t0, t1, max5 # skip max assignment if no new max found.
 lbu a2, 3(a5)

max5:
 lbu a1, 4(a5)
 slt t0, a2, a1 # t0 = 1 if new max found
 bne t0, t1, max6 # if (a2(max) >= a1), skip new max assignment
 lbu a2, 4(a5)

max6:
 ret # max value stored in a2


