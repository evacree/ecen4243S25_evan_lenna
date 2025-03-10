// riscvsingle.sv

// RISC-V single-cycle processor
// From Section 7.6 of Digital Design & Computer Architecture
// 27 April 2020
// David_Harris@hmc.edu 
// Sarah.Harris@unlv.edu

// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)

//   Instruction  opcode    funct3    funct7
// TODO:
//   lb           0000011   000       immediate
//   lh           0000011   001       immediate
//   lw           0000011   010       immediate
//   lbu          0000011   100       immediate
//   lhu          0000011   101       immediate
//   sb           0100011   000       immediate
//   sh	          0100011   001       immediate
//   sw           0100011   010       immediate

module testbench();

   logic        clk;
   logic        reset;

   logic [31:0] WriteData;
   logic [31:0] DataAdr;
   logic        MemWrite;

   // instantiate device to be tested
   top dut(clk, reset, WriteData, DataAdr, MemWrite);

   initial
     begin
	string memfilename;
        memfilename = {"../riscvtest/test_hw.memfile"}; // change to run different tests (.memfile)
        $readmemh(memfilename, dut.imem.RAM);
        $readmemh(memfilename, dut.dmem.RAM);
     end

   
   // initialize test
   initial
     begin
	reset <= 1; # 22; reset <= 0;
     end

   // generate clock to sequence tests
   always
     begin
	clk <= 1; # 5; clk <= 0; # 5;
     end


   
endmodule // testbench

module riscvsingle (input  logic        clk, reset,
		    output logic [31:0] PC,
		    input  logic [31:0] Instr,
		    output logic 	MemWrite,
		    output logic [31:0] ALUResult, WriteData,
		    input  logic [31:0] ReadData);
   
   logic 				ALUSrc, RegWrite, Jump, Zero, Negative, Carry, Overflow, jalrsig; //pass through new jalrsig control signal
   logic [1:0] 				ResultSrc; 
   logic [2:0]        ImmSrc;
   logic [3:0] 				ALUControl; //Change from 3 to 4 bits
   
   controller c (Instr[6:0], Instr[14:12], Instr[30], Zero, Negative, Carry, Overflow,
		 ResultSrc, MemWrite, PCSrc,
		 ALUSrc, RegWrite, Jump, 
		 ImmSrc, ALUControl, jalrsig);  //pass through new jalrsig control signal
   datapath dp (clk, reset, ResultSrc, PCSrc,
		ALUSrc, RegWrite,    
		ImmSrc, ALUControl,
		Zero, Negative, Carry, Overflow, PC, Instr,
		ALUResult, WriteData, ReadData, jalrsig); //pass through new jalrsig control signal
   
endmodule // riscvsingle

module controller (input  logic [6:0] op,
		   input  logic [2:0] funct3,
		   input  logic       funct7b5,
		   input  logic       Zero, Negative, Carry, Overflow,
		   output logic [1:0] ResultSrc,
		   output logic       MemWrite, 
       output logic       ALUSrc, PCSrc,
		   output logic       RegWrite, Jump,
		   output logic [2:0] ImmSrc,
		   output logic [3:0] ALUControl, //Change from 3 to 4 bits
       output logic jalrsig);  //pass through new jalrsig control signal
   
   logic [1:0] 			      ALUOp;
   logic 			      Branch;
   logic            Branch_condition;
   
   maindec md (op, ResultSrc, MemWrite, Branch,
	       ALUSrc, RegWrite, Jump, ImmSrc, ALUOp, jalrsig);  //pass through new jalrsig control signal
   aludec ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

   always_comb begin // Branch condition (pass or fail) calculation
    case(funct3)
      3'b000: Branch_condition = (Zero); // beq
      3'b001: Branch_condition = (~Zero); // bne
      3'b100: Branch_condition = (Negative ^ Overflow); // blt
      3'b101: Branch_condition = (~(Negative ^ Overflow)); // bge
      3'b110: Branch_condition = (~Carry); // bltu
      3'b111: Branch_condition = (Carry); // bgeu
    endcase
   end

   assign PCSrc = (Branch & Branch_condition) | Jump;
   
endmodule // controller

module maindec (input  logic [6:0] op,
		output logic [1:0] ResultSrc,
		output logic 	   MemWrite,
		output logic 	   Branch, ALUSrc, 
		output logic 	   RegWrite, Jump,
		output logic [2:0] ImmSrc,
		output logic [1:0] ALUOp,
    output logic jalrsig); //pass through new jalrsig control signal
   
   logic [12:0] 		   controls;
   
   assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
	   ResultSrc, Branch, ALUOp, Jump,jalrsig} = controls;  //pass through new jalrsig control signal
   
   always_comb
     case(op)
       // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_jalrsig
       7'b0000011: controls = 13'b1_000_1_0_01_0_00_0_0; // lw
       7'b0100011: controls = 13'b0_001_1_1_00_0_00_0_0; // sw
       7'b0110011: controls = 13'b1_xxx_0_0_00_0_10_0_0; // R–type
       7'b1100011: controls = 13'b0_010_0_0_00_1_01_0_0; // branches (beq, bne, etc)
       7'b0010011: controls = 13'b1_000_1_0_00_0_10_0_0; // I–type ALU
       7'b1101111: controls = 13'b1_011_0_0_10_0_00_1_0; // jal
       7'b0110111: controls = 13'b1_100_1_0_00_0_11_0_0; //lui
       7'b0010111: controls = 13'b1_100_1_0_11_0_11_0_0; //auipc
       7'b1100111: controls = 13'b1_000_1_0_10_0_00_1_1;  //jalr

       default: controls = 13'bx_xxx_x_x_xx_x_xx_x_x; // ???

     endcase // case (op)
   
endmodule // maindec

module aludec (input  logic       opb5,  //-----------------------------
	       input  logic [2:0] funct3,
	       input  logic 	  funct7b5,
	       input  logic [1:0] ALUOp,
	       output logic [3:0] ALUControl); //Change from 3 to 4 bits
   
   logic 			  RtypeSub;
   
   assign RtypeSub = funct7b5 & opb5; // TRUE for R–type subtract
   always_comb
   //CHANGED ALUControl from 3 to 4 bits
     case(ALUOp)
       2'b00: ALUControl = 4'b0000; // addition
       2'b01: ALUControl = 4'b0001; // subtraction
       2'b11: ALUControl = 4'b1011; // lui
       default: case(funct3) // R–type or I–type ALU
		  3'b000: if (RtypeSub)
		    ALUControl = 4'b0001; // sub
		  else
		    ALUControl = 4'b0000; // add, addi
		  3'b010: ALUControl = 4'b0101; // slt, slti
		  3'b110: ALUControl = 4'b0011; // or, ori
		  3'b111: ALUControl = 4'b0010; // and, andi

      3'b100: ALUControl = 4'b0110; // xor, xori
      3'b001: ALUControl = 4'b0111; //sll, slli
      3'b011: ALUControl = 4'b1000; //sltu, sltiu
      
      3'b101: if (funct7b5) 
        ALUControl = 4'b1010; //sra, srai
      else
        ALUControl = 4'b1001; //srl, srli

		  default: ALUControl = 4'bxxxx; // ???
		endcase // case (funct3)       
     endcase // case (ALUOp)
   
endmodule // aludec

module datapath (input  logic        clk, reset,
		 input  logic [1:0]  ResultSrc,
		 input  logic 	     ALUSrc, PCSrc,
		 input  logic 	     RegWrite,
		 input  logic [2:0]  ImmSrc,
		 input  logic [3:0]  ALUControl, //CHANGE: 3 to 4 bits
		 output logic 	     Zero, Negative, Carry, Overflow,
		 output logic [31:0] PC,
		 input  logic [31:0] Instr,
		 output logic [31:0] ALUResult, WriteData, 
		 input  logic [31:0] ReadData,
     input logic jalrsig); //pass through new jalrsig control signal
   
   logic [31:0] 		     PCNext, PCPlus4, PCTarget,PCNextTemp; //declare temporary variable
   logic [31:0] 		     ImmExt;
   logic [31:0] 		     SrcA, SrcB;
   logic [31:0] 		     Result;

   logic [31:0]          Load_line; //for use in load case statements
   logic [31:0]          Write_line; //for use in store case statements
   logic [31:0]          orig_WriteData;

   always_comb begin // sb
   if (Instr[6:0] == 7'b0100011) begin //begin sb, sh, sw
    if (Instr[14:12] == 3'b000) begin //sb
      case(ALUResult[1:0])
        2'b00: Write_line = {ReadData[31:8],  orig_WriteData[7:0]};
        2'b01: Write_line = {ReadData[31:16],  orig_WriteData[7:0],  ReadData[7:0]};
        2'b10: Write_line = {ReadData[31:24],  orig_WriteData[7:0],  ReadData[15:0]};
        2'b11: Write_line = {orig_WriteData[7:0],  ReadData[24:0]};
        default: Write_line = 32'bx;
      endcase
    end else if (Instr[14:12] == 3'b001) begin //sh
      case(ALUResult[1:0])
        2'b00: Write_line = {ReadData[31:16],  orig_WriteData[15:0]}; 
        2'b10: Write_line = {orig_WriteData[15:0],  ReadData[15:0]};
        default: Write_line = 32'bx;
      endcase
    end else if (Instr[14:12] == 3'b010) begin //sw
        Write_line = orig_WriteData;
    end
   end
   
   if (Instr[6:0] == 7'b0000011) begin //END STORES, BEGIN lb, lh, lw
    if (Instr[14:12] == 3'b000) begin //lb
      case(ALUResult[1:0])
        2'b00: Load_line = {{24{ReadData[7]}},  ReadData[7:0]};
        2'b01: Load_line = {{24{ReadData[15]}},  ReadData[15:8]};
        2'b10: Load_line = {{24{ReadData[23]}},  ReadData[23:16]};
        2'b11: Load_line = {{24{ReadData[31]}},  ReadData[31:24]};
        default: Load_line = 32'bx;
      endcase
    end else if (Instr[14:12] == 3'b001) begin //lh
      case(ALUResult[1:0])
        2'b00: Load_line = {{16{ReadData[15]}},  ReadData[15:0]};
        2'b10: Load_line = {{16{ReadData[31]}},  ReadData[31:16]};
        default: Load_line = 32'bx;
      endcase
    end else if (Instr[14:12] == 3'b010) begin //lw
        Load_line = ReadData;
    end else if (Instr[14:12] == 3'b100) begin //lbu
      case(ALUResult[1:0])
        2'b00: Load_line = {24'b0,  ReadData[7:0]};
        2'b01: Load_line = {24'b0,  ReadData[15:8]};
        2'b10: Load_line = {24'b0,  ReadData[23:16]};
        2'b11: Load_line = {24'b0,  ReadData[31:24]};
        default: Load_line = 32'bx;
      endcase
    end else if (Instr[14:12] == 3'b101) begin //lhu
      case(ALUResult[1:0])
        2'b00: Load_line = {16'b0,  ReadData[15:0]};
        2'b10: Load_line = {16'b0,  ReadData[31:16]};
        default: Load_line = 32'bx;
      endcase
    end 
   end

   end //end always_comb
   

   
   // next PC logic
   flopr #(32) pcreg (clk, reset, PCNext, PC); 
   adder  pcadd4 (PC, 32'd4, PCPlus4);
   adder  pcaddbranch (PC, ImmExt, PCTarget);
   mux2 #(32)  pcmux (PCPlus4, PCTarget, PCSrc, PCNextTemp); //change output from PCNext to PCNextTemp. This gets fed through the new jalrmux

   // register file logic
   regfile  rf (clk, RegWrite, Instr[19:15], Instr[24:20],
	       Instr[11:7], Result, SrcA, orig_WriteData);
   extend  ext (Instr[31:7], ImmSrc, ImmExt);
   // ALU logic

   mux2 #(32)  srcbmux (orig_WriteData, ImmExt, ALUSrc, SrcB); 
   alu  alu (SrcA, SrcB, ALUControl, ALUResult, Zero, Negative, Carry, Overflow);
   
   //mux3 #(32) resultmux (ALUResult, ReadData, PCPlus4,ResultSrc, Result);
   // extend mux for AUIPC
   mux4 #(32) resultmux (ALUResult, Load_line, PCPlus4, PCTarget, ResultSrc, Result); //Changed ReadData to Load_line
   
   //new mux for jalr
    mux2 #(32) jalrmux(PCNextTemp, ALUResult, jalrsig, PCNext);
    mux2 #(32) storeInst(orig_WriteData, Write_line, (Instr[6:0] == 7'b0100011), WriteData);

endmodule // datapath

module adder (input  logic [31:0] a, b,
	      output logic [31:0] y);
   
   assign y = a + b;
   
endmodule

module extend (input  logic [31:7] instr,
	       input  logic [2:0]  immsrc, //Changed from 2 to 3 bits for U-type
	       output logic [31:0] immext);
   
   always_comb
     case(immsrc)
       // I−type
       3'b000:  immext = {{20{instr[31]}}, instr[31:20]};
       // S−type (stores)
       3'b001:  immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
       // B−type (branches)
       3'b010:  immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};       
       // J−type (jal)
       3'b011:  immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
       // U-type (lui, auipc)
       3'b100:  immext = {instr[31:12], 12'b0}; //TODO: Check?
      

       default: immext = 32'bx; // undefined
     endcase // case (immsrc)
   
endmodule // extend

module flopr #(parameter WIDTH = 8)
   (input  logic             clk, reset,
    input logic [WIDTH-1:0]  d,
    output logic [WIDTH-1:0] q);
   
   always_ff @(posedge clk, posedge reset)
     if (reset) q <= 0;
     else  q <= d;
   
endmodule // flopr

module flopenr #(parameter WIDTH = 8)
   (input  logic             clk, reset, en,
    input logic [WIDTH-1:0]  d,
    output logic [WIDTH-1:0] q);
   
   always_ff @(posedge clk, posedge reset)
     if (reset)  q <= 0;
     else if (en) q <= d;
   
endmodule // flopenr

module mux2 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1,
    input logic 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s ? d1 : d0;
   
endmodule // mux2

module mux3 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2,
    input logic [1:0] 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
   
endmodule // mux3

//define a new 4 input mux
module mux4 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2, d3, 
    input logic [1:0]         s,               
    output logic [WIDTH-1:0]  y);              
   
  assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0);
   
endmodule // mux4

module top (input  logic        clk, reset,
	    output logic [31:0] WriteData, DataAdr,
	    output logic 	MemWrite);
   
   logic [31:0] 		PC, Instr, ReadData;
   
   // instantiate processor and memories
   riscvsingle rv32single (clk, reset, PC, Instr, MemWrite, DataAdr,
			   WriteData, ReadData);
   imem imem (PC, Instr);
   dmem dmem (clk, MemWrite, DataAdr, WriteData, ReadData);
   
endmodule // top

module imem (input  logic [31:0] a,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[16384:0]; //Increase imem size
   
   assign rd = RAM[a[31:2]]; // word aligned
   
endmodule // imem

module dmem (input  logic        clk, we,
	     input  logic [31:0] a, wd,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[1028:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   always_ff @(posedge clk)
     if (we) RAM[a[31:2]] <= wd;
   
endmodule // dmem

module alu (input  logic [31:0] a, b, //------------------------------------
            input  logic [3:0] 	alucontrol, //change from 3 to 4 bits
            output logic [31:0] result, //calculation result

            output logic 	zero, //Output flags for branch calc. in controller
            output logic negative,
            output logic carry,
            output logic v);

   logic [31:0] 	       condinvb; 
   logic [32:0]          sum;      // extended 1 bit to have easy carry flag calc.
   logic 		       isAddSub;       // true when is add or subtract operation

   

   assign condinvb = alucontrol[0] ? ~b : b;
   assign sum = a + condinvb + alucontrol[0];
   assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                     ~alucontrol[1] & alucontrol[0];   

   always_comb
     case (alucontrol) //Changed alucontrol from 3 to 4 bits
       4'b0000:  result = sum[31:0];         // add
       4'b0001:  result = sum[31:0];         // subtract
       4'b0010:  result = a & b;       // and
       4'b0011:  result = a | b;       // or
       4'b0101:  result = sum[31] ^ v; // slt 

       4'b0110:  result = a ^ b;       // xor  

       4'b0111:  result = a << b[4:0];      //sll
       4'b1000:  result = a < b;       //sltu
       4'b1010:  result = $signed(a) >>> b[4:0];     //sra
       4'b1001:  result = a >> b[4:0];      //srl
       4'b1011:  result = b;           //lui




       default: result = 32'bx;
     endcase

   assign zero = (result == 32'b0); // zero result flag
   assign negative = result[31]; // negative result flag
   assign carry = (~alucontrol[1]) & sum[32]; // carry from result flag
   assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub; //overflow flag  

   
endmodule // alu

module regfile (input  logic        clk, 
		input  logic 	    we3, 
		input  logic [4:0]  a1, a2, a3, 
		input  logic [31:0] wd3, 
		output logic [31:0] rd1, rd2); //WriteData

   logic [31:0] 		    rf[31:0];

   // three ported register file
   // read two ports combinationally (A1/RD1, A2/RD2)
   // write third port on rising edge of clock (A3/WD3/WE3)
   // register 0 hardwired to 0

   always_ff @(posedge clk)
     if (we3) rf[a3] <= wd3;	

   assign rd1 = (a1 != 0) ? rf[a1] : 0;
   assign rd2 = (a2 != 0) ? rf[a2] : 0;
   
endmodule // regfile

