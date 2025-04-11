Group Members: Evan & Lenna
Lab Group: Monday, Computer 06

These are the HDL files for the pipelined RV32 RISC-V

Currently, the memory model is written to output little endian. To run
the design through, just type:

vsim -do riscv_pipelined.do -c

or

vsim -do riscv_pipelined.do

ALL instructions for the base RV32I instruction set are implemented in this project, and
each instruction was tested for correctness.

Implementation was performed with no issues, and we were able to showcase that the default test
(fib.objdump) ran as expected when compared with its .objdump.

Please refer to the included images, .sv files, & .do file for proof of completion.






