# Define target program name
TARGET = matvecmul_program

# Define the common directory path
COMMON_DIR = ../../examples/C/common

# Define the source files
SRC = $(TARGET).c

# Define the output file and object dump name
OBJDUMP = $(TARGET).objdump

# Create object dump from the target executable
$(OBJDUMP): $(TARGET)
	riscv64-unknown-elf-objdump -S $(TARGET) > $(OBJDUMP)

# The main target: compile the program
$(TARGET): $(SRC) Makefile
	riscv64-unknown-elf-gcc -o $(TARGET) -g -O \
	-march=rv64gc -mabi=lp64d -mcmodel=medany \
	-nostdlib -static -lm -fno-tree-loop-distribute-patterns \
	-T$(COMMON_DIR)/test.ld -I$(COMMON_DIR) \
	$(SRC) $(COMMON_DIR)/crt.S $(COMMON_DIR)/syscalls.c

# Clean up the build files
clean:
	rm -f $(TARGET) $(OBJDUMP)
