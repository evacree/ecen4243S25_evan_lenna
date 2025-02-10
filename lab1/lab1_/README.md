####### INTRO ############################

In this lab, we assembled & disassembled programs using the RISC-V GNU compiler,
simulated RISC-V programs using Spike and Questa, compared performance metrics such as # of clock cycles, and built functioning assembly
code from C code in order to understand how the system operates. Included in this lab is the study of 
Finite Impulse Response filtering (FIR) and its translation from C to assembly code.

####### Section 2 COMMAND HISTORY #######################

    1  git
    2  git clone --recurse-submodules https://github.com/evacree/cvw
    3  cd cvw
    4  source ./setup.sh
    5  echo $WALLY$
    6  cd examples/C/hello
    7  ls
    8  make
    9  wsim --sim questa rv64gc --elf hello

To set up our environment, we followed the steps outlined in the lab report and
cloned the /cvw repository to our system. We ran source ./setup.sh, and confirmed
with echo $WALLY$. We were then able to simulate hello.c using Questa. No issues were encountered along the way.

####### Section 3 COMMAND HISTORY #########################

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



####### Section 3 RESULTS (Spike, Questa) ###############################

| sum.c Results: | s  | mcycle | minstret |   |
|----------------|----|--------|----------|---|
| Spike          | 10 | 31     | 38       |   |
| Questa (wsim)  | 10 | 80     | 38       |   |
|                |    |        |          |   |

We were able to successfully run each example (example.S, sumtest.S, sum.c) with no issues along the way. Results and history are shown above.


####### HOW TO RUN fir1 & fir2 ####################################

To run fir1/fir2 in Spike: 

make
spike fir(1/2)


To run fir1/fir2 in Questa:

wsim --sim questa rv64gc --elf fir(1/2)