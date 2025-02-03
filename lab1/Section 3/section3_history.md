--- example.S: ---

.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
    li a0, 42

self_loop:
    j self_loop


--- VS example.objdump: ---


example:     file format elf32-littleriscv


Disassembly of section .text:

80000000 <rvtest_entry_point>:
80000000:	02a00513          	li	a0,42

80000004 <self_loop>:
80000004:	0000006f          	j	80000004 <self_loop>

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	1941                	.insn	2, 0x1941
   2:	0000                	.insn	2, 0x
   4:	7200                	.insn	2, 0x7200
   6:	7369                	.insn	2, 0x7369
   8:	01007663          	bgeu	zero,a6,14 <rvtest_entry_point-0x7fffffec>
   c:	0000000f          	fence	unknown,unknown
  10:	7205                	.insn	2, 0x7205
  12:	3376                	.insn	2, 0x3376
  14:	6932                	.insn	2, 0x6932
  16:	7032                	.insn	2, 0x7032
  18:	0031                	.insn	2, 0x0031







--- SUMTEST SPIKE result: ---

000000000000001d000000000000000a

--- VS SUMTEST reference result:

000000000000000A
000000000000001D






--- sum.C SPIKE performance counters: ---

s = 10
mcycle = 31
minstret = 38

--- VS sum.C wsim (Questa) performance counters: ---

# s = 10
# mcycle = 80
# minstret = 38







TOTAL HISTORY for Section 3:

  105  cd examples
  106  cd asm
  107  cd example
  108  riscv64-unknown-elf-gcc -o example -march=rv32i -mabi=ilp32 -mcmodel=medany -nostartfiles -T../../link/link.ld example.S
  109  riscv64-unknown-elf-objdump -D example > example.objdump
  110  cat common/test.ld
  111  cd ..
  112  ls
  113  cd ..
  114  ls
  115  cd ..
  116  ls
  117  cat common/test.ld
  118  cd cvw/examples/asm/example
  119  cd cvw/examples/asm/example/
  120  cd examples/asm/example/
  121  cat Makefile
  122  make
  123  make clean
  124  cd ..
  125  cd sumtest
  126  make
  127  spike +signature=sumtest.signature.output sumtest
  128  diff sumtest.signature.output sumtest.reference_output
  129  make
  130  riscv64-unknown-elf-readelf -a sumtest
  131  cd ..
  132  cd c
  133  cd C
  134  cd sum
  135  ls
  136  make
  137  spike sum
  138  lint-wally
  139  wsim --sim questa rv64gc --elf sum


We were able to successfully run each example (example.S, sumtest.S, sum.c) with no issues along the way. Results and history are shown above.