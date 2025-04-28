.section .text.init
.globl rvtest_entry_point

rvtest_entry_point:

    # set up PMP so all of memory is accessible and we don't trap when entering supervisor mode
    # Define region 0 to cover all addresses as RWX
    nop

    # switch to supervisor mode	
    # Set mstatus.MPP to 01, set MPEC to a trampoline address where supervisor should begin, do mret
    
				# TODO: fill in instructions here:	

    # Configure PMP0 TOR to 0xFFFFFFFF to allow all 32-bit addresses
    li t0, 0xFFFFFFFF
    csrw pmpaddr0, t0 


    # Configure PMP0 to TOR RWX
    li t0, 0xF # 0b1_1_1_1
    csrw pmpcfg0, t0 
    

    # Set mstatus (MPP) and set MEPC (in supervisor)

    ##li t1, 0x1800 # mpp = 11 to clear
    ##csrc mstatus, t1
    ##li t1, 0x800 # mpp = 01 for S mode
    ##csrs mstatus, t1

    csrr t0, mstatus
    li t1, (1 << 11)
    or t0, t0, t1
    csrw mstatus, t0

    la t0, supervisorstart      # trampoline address to supervisor
    csrw mepc, t0

    mret                    	# enter supervisor mode at supervisorstart
    nop

# end entry point

supervisorstart:
    la t0, pagetable        	# get address of root page table


				# TODO: fill in instructions here 

    srli t0, t0, 12 # formatting for PPN in satp
    li t1, 0x80000000 # top bit [31] = 1 for MODE = 1
    or t0, t0, t1 # assign top bit as 1 for satp

    csrw satp, t0         	# enable virtual memory
    sfence.vma              # flush after writing to satp
    
    # now we are execuiting on virtual page 0x80000, which is also physical page 0x80000
    # (this can be whatever you want as long as you use the correct address defined in the proj)	
    li t0, 0x90000300       
    li t1, 42
    sw t1, 0(t0)


    la t0, testcode         # address of a routine to run
    lui t1, 0x10000         
    add t0, t0, t1          # address of testcode on virtual page 0x90000 
    jr t0                   # jump to the testcode on Virtual page 0x90000, 
                            #   which still points to same code on physical page 0x80000
    nop                     # shouldn't be executed

testcode:
    li t0, 42                # do something

write_tohost:
    la s1, tohost           # terminate with write tohost
    li t0, 1                # 1 for success, 3 for failure
    sw t0, 0(s1)            # send success code (yay)
    sw zero, 4(s1)          # not obvious why Sail isn't terminating unless this write is done

self_loop:
    j self_loop

tohost:
    .word 0


.data # root/PT1: top page table
.align 16
pagetable:
    .space 2048

    .4byte 0x20004401

    .space 252

    .4byte 0x20004401


.align 12
pagetable_2: # leaf/PT0: bottom page table
    .4byte 0x200000CF



##.align 16   tried but not work :(
# root (L1) Page table situated at 0x80010000
##pagetable:

##.space 2048
##.word 0x20004400

##.space
##.word 0x20004400

##.align 12
# L0 page table situated at 0x80011000
##.word 0x200000_ dAGU_F

##_1111


