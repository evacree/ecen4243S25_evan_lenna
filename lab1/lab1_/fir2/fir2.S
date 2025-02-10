# fir.S 
# assembly language of Finite Impulse Response (FIR)

// a0: base address of x
// a1: base address of c
// a2: base address of y, later used as pointer to y[j] in j loop
// a3: n
// a4: m

// t0: &y[n-m] to check termination of j loop (memory location of the last index of the array)
// t1: &c[m] to check termination of i loop (memory location of the mth element of c)
// t2: &x[j+m-1]
// t3: sum
// t4: pointer to c[i] in i loop
// t5: pointer to x[j-i+(m-1)] 
// t6: value of c[i]
// a5: value of x[j-1+(m-1)]

.global fir

# --- TODO: work on inner parts of j, i loops, including incrementing instructions

fir:                            # start of FIR function:

                                # 1st loop init:

                                # goal is to get final mem address stopping point for each array

    sub t0, a3, a4              # t0 = n-m (word, 32 bits)

    slli t0, t0, 2              # shift t0 by 2 to left (*4) to make byte-addressable (move by 4 in mem each time) (1st loop), j++
    add t0, a2, t0              # getting where y[n-m] is in mem


                                # 2nd loop init:

    slli t1, a4, 2              # shift a4 by 2 to left (2nd loop m)
    add t1, a1, t1              # get where c[m] is in mem

                                # x array init:

    addi t2, a4, -1             # t2 = m-1   
    slli t2, t2, 2              # shift t2 by 2 (for byte addressing)
    add t2, a0, t2              # t2= &x[m-1] 

# Ignore what you wrote above:

# This is what the initialization needs to change to:
sub t0, a3, a4              # t0 = n-m (word, 32 bits)
addi t0, t0, 1    #REMOVE?
addi t6, zero, 4   // c array holds the value 4
mul t0, t0, t6
add t0, t0, a2

mul t1, a4, t6
add t1, t1, a1

addi t2, a4, -1
mul t2, t2, t6
add t2, t2, a0

add a0, a2, zero


forj:                           # start of outer for loop
    
    bge a2, t0, donej          # if &y[j] >= &y[n-m], exit j loop (finished with j loop)
    add t3, zero, zero         # initialize sum to zero (Lenna). Jacob confirmed this is correct
    add t4, a1, zero           #initialize t4 and a1 to zero       
    add t5, t2, zero           #initialize t5 and t2 to zero       

fori:                           # start of inner for loop

    bge a1, t1, donei           # if &c[i] >= &c[m], exit i loop (finished with i loop)

    # t2 is incrementing by 4*4
    # t5 is decrementing by 4. basically t5 = t5-4
    
    # t3 should be the sum of each 4 values of c[] (which is t6)
    # y[] each value of this array stores the sum of the previous 4 values in c

    #t2=t5
    #t5-4
    #t2=t2+16
    #a2++

    
    lw t6, 0(t4)      #load the value of t4 into t6
    lw a5, 0(t5)        # load the value of t5 into a5

    mul a6, a5, t6     # define register a6 to hold the multiplication 
    
    srli a6, a6, 31    #shift a6 right by 31       

    add t3, t3, a6     # add the product  
    
    addi t4, t4, 4     # t4 is incrementing by 4           
    addi t5, t5, -4       # t5 decrementing by 4              


    blt t4, t1, fori           #continue loop i
    sw t3, 0(a2)        #store the value of t3 into a2, which is the y array. This is the sum
    addi a2, a2, 4
    addi t2, t2, 4

    j forj             #jump back to loop j

   


donei:
    j forj                      #go back to start of j loop

donej:
    ret                         # all done; return	