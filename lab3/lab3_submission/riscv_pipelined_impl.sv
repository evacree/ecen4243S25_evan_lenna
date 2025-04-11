// riscvpipelined.sv

// RISC-V pipelined processor
// From Section 7.6 of Digital Design & Computer Architecture: RISC-V Edition
// 27 April 2020
// David_Harris@hmc.edu 
// Sarah.Harris@unlv.edu

// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)

// Pipelined implementation of RISC-V (RV32I)
// User-level Instruction Set Architecture V2.2 (May 7, 2017)
// Implements a subset of the base integer instructions:
//    lw, sw
//    add, sub, and, or, slt, 
//    addi, andi, ori, slti
//    beq
//    jal
// Exceptions, traps, and interrupts not implemented
// little-endian memory

// 31 32-bit registers x1-x31, x0 hardwired to 0
// R-Type instructions
//   add, sub, and, or, slt
//   INSTR rd, rs1, rs2
//   Instr[31:25] = funct7 (funct7b5 & opb5 = 1 for sub, 0 for others)
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// I-Type Instructions
//   lw, I-type ALU (addi, andi, ori, slti)
//   lw:         INSTR rd, imm(rs1)
//   I-type ALU: INSTR rd, rs1, imm (12-bit signed)
//   Instr[31:20] = imm[11:0]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// S-Type Instruction
//   sw rs2, imm(rs1) (store rs2 into address specified by rs1 + immm)
//   Instr[31:25] = imm[11:5] (offset[11:5])
//   Instr[24:20] = rs2 (src)
//   Instr[19:15] = rs1 (base)
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:0]  (offset[4:0])
//   Instr[6:0]   = opcode
// B-Type Instruction
//   beq rs1, rs2, imm (PCTarget = PC + (signed imm x 2))
//   Instr[31:25] = imm[12], imm[10:5]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:1], imm[11]
//   Instr[6:0]   = opcode
// J-Type Instruction
//   jal rd, imm  (signed imm is multiplied by 2 and added to PC, rd = PC+4)
//   Instr[31:12] = imm[20], imm[10:1], imm[11], imm[19:12]
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode

//   Instruction  opcode    funct3    funct7
//   add          0110011   000       0000000
//   sub          0110011   000       0100000
//   and          0110011   111       0000000
//   or           0110011   110       0000000
//   slt          0110011   010       0000000
//   addi         0010011   000       immediate
//   andi         0010011   111       immediate
//   ori          0010011   110       immediate
//   slti         0010011   010       immediate
//   beq          1100011   000       immediate
//   lw	          0000011   010       immediate
//   sw           0100011   010       immediate
//   jal          1101111   immediate immediate


//TODO: CHANGE jalrsig to auipcsig !!!!!!

/*module testbench();

   logic        clk;
   logic        reset;

   logic [31:0] WriteData, DataAdr;
   logic        MemWrite;

   // instantiate device to be tested
   top dut(clk, reset, WriteData, DataAdr, MemWrite);

   initial
     begin
	string memfilename;
        // memfilename = {"../riscvtest/riscvtest.memfile"};  // ? 
        // memfilename = {"../testing/add.memfile"};    // working
        // memfilename = {"../testing/addi.memfile"};   // working
        // memfilename = {"../testing/and.memfile"};    // working
        // memfilename = {"../testing/andi.memfile"};   // working
        // memfilename = {"../testing/auipc.memfile"};  // working
        // memfilename = {"../testing/beq.memfile"};    // working
        // memfilename = {"../testing/bge.memfile"};    // working
        // memfilename = {"../testing/bgeu.memfile"};   // working
        // memfilename = {"../testing/blt.memfile"};    // working
        // memfilename = {"../testing/bltu.memfile"};   // working
        // memfilename = {"../testing/bne.memfile"};    // working
        // memfilename = {"../testing/jal.memfile"};    // working
        // memfilename = {"../testing/jalr.memfile"};   // working
        // memfilename = {"../testing/ori.memfile"};    // working
        // memfilename = {"../testing/or.memfile"};     // working
        // memfilename = {"../testing/slli.memfile"};   // working
        // memfilename = {"../testing/slt.memfile"};    // working
        // memfilename = {"../testing/slti.memfile"};   // working
        // memfilename = {"../testing/sltiu.memfile"};  // working
        // memfilename = {"../testing/sltu.memfile"};   // working
        // memfilename = {"../testing/sra.memfile"};    // working
        // memfilename = {"../testing/srai.memfile"};   // working
        // memfilename = {"../testing/srl.memfile"};    // working
        // memfilename = {"../testing/srli.memfile"};   // working
        // memfilename = {"../testing/sub.memfile"};    // working
        // memfilename = {"../testing/xor.memfile"};    // working
        // memfilename = {"../testing/xori.memfile"};   // working
        // memfilename = {"../testing/sw.memfile"};     // working
        // memfilename = {"../testing/sh.memfile"};     // working
        // memfilename = {"../testing/sb.memfile"};     // working
        // memfilename = {"../testing/lhu.memfile"};    // working
        // memfilename = {"../testing/lw.memfile"};     // working
        // memfilename = {"../testing/lh.memfile"};     // working
        // memfilename = {"../testing/lbu.memfile"};    // working
	$readmemh(memfilename, dut.imem.RAM);
  $readmemh(memfilename, dut.dmem.RAM); //added 'read dmem' for tests
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

   // check results -- needed only for riscv_test

  //  always @(negedge clk)
  //    begin
	// if(MemWrite) begin
  //          if(DataAdr === 100 & WriteData === 25) begin
  //             $display("Simulation succeeded");
  //             $stop;
  //          end else if (DataAdr !== 96) begin
  //             $display("Simulation failed");
  //             $stop;
  //          end
	// end
  //    end
endmodule

module top(input  logic        clk, reset, 
           output logic [31:0] WriteDataM, DataAdrM, 
           output logic        MemWriteM);

   logic [31:0] 	       PCF, InstrF, ReadDataM;
   
   // instantiate processor and memories
   riscv rv32pipe (clk, reset, PCF, InstrF, MemWriteM, DataAdrM, 
		   WriteDataM, ReadDataM);
   imem imem (PCF, InstrF);
   dmem dmem (clk, MemWriteM, DataAdrM, WriteDataM, ReadDataM);
   
endmodule*/

module riscv(input  logic        clk, reset,
             output logic [31:0] PCF,
             input logic [31:0]  InstrF,
             output logic 	 MemWriteM,
             output logic [31:0] ALUResultM, WriteDataM,
             input logic [31:0]  ReadDataM,
             output logic    MemStrobe,
             input logic     PCReady
             );

   logic [6:0] 			 opD;
   logic [2:0] 			 funct3D;
   logic 			 funct7b5D;
   logic [2:0] 			 ImmSrcD; //2 to 3 bits
   logic 			 ZeroE, NegE, CarrE, OverflowE;
   logic [1:0] PCSrcE;  //expanded for jalr
   logic [3:0] 			 ALUControlE; //3 to 4 bits
   logic 			 ALUSrcE;
   logic 			 ResultSrcEb0;
   logic 			 RegWriteM;
   logic [1:0] 			 ResultSrcM; // TODO: change to ResultSrcM?
   logic 			 RegWriteW;

   logic [1:0] 			 ForwardAE, ForwardBE;
   logic 			 StallF, StallD, FlushD, FlushE;

   logic [4:0] 			 Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
   logic       auipcSrcD; //for auipc instruction
   
   controller c(clk, reset,
		opD, funct3D, funct7b5D, ImmSrcD,
		FlushE, ZeroE, NegE, CarrE, OverflowE, PCSrcE, ALUControlE, ALUSrcE, ResultSrcEb0,
		MemWriteM, RegWriteM, 
		RegWriteW, ResultSrcM, auipcSrcD);

   datapath dp(clk, reset,
               StallF, PCF, InstrF,
	       opD, funct3D, funct7b5D, StallD, FlushD, ImmSrcD,
	       FlushE, ForwardAE, ForwardBE, PCSrcE, ALUControlE, ALUSrcE, ZeroE, NegE, CarrE, OverflowE,
               MemWriteM, WriteDataM, ALUResultM, ReadDataM, RegWriteM, //added RegWriteM to datapath
               RegWriteW, ResultSrcM,
               Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW, auipcSrcD, MemStrobe, PCReady);

   hazard  hu(Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
              PCSrcE[0], ResultSrcEb0, RegWriteM, RegWriteW, //PCSrcE[0] since PCSrcE is now 2 bits wide
              ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE);			 
endmodule


module controller(input  logic		 clk, reset,  ///DONE(?????)
                  // Decode stage control signals
                  input logic [6:0]  opD,
                  input logic [2:0]  funct3D,
                  input logic 	     funct7b5D,
                  output logic [2:0] ImmSrcD, //2 to 3 bits
                  // Execute stage control signals
                  input logic 	     FlushE, 
                  input logic 	     ZeroE, NegE, CarrE, OverflowE, //ADDED 
                  output logic [1:0] PCSrcE, // for datapath and Hazard Unit -- expanded to 2 bits for jalr
                  output logic [3:0] ALUControlE, //3 to 4 bits
                  output logic 	     ALUSrcE,
                  output logic 	     ResultSrcEb0, // for Hazard Unit
                  // Memory stage control signals
                  output logic 	     MemWriteM,
                  output logic 	     RegWriteM, // for Hazard Unit				  
                  // Writeback stage control signals
                  output logic 	     RegWriteW, // for datapath and Hazard Unit
                  output logic [1:0] ResultSrcM, //TODO: change to ResultSrcM?
                  output logic       auipcSrcD); //ADDED

   // pipelined control signals
   logic 			     RegWriteD, RegWriteE;
   logic [1:0] 			     ResultSrcD, ResultSrcE;
   logic 			     MemWriteD, MemWriteE;
   logic 			     JumpD, JumpE;
   logic 			     BranchD, BranchE;
   logic [1:0] 			     ALUOpD;
   logic [3:0] 			     ALUControlD; //3 to 4 bits 
   logic 			     ALUSrcD;
   logic           Branch_condition;
   logic [2:0]     funct3E; //ADDED
   logic           PCSrc_0, PCSrc_1; //ADDED - for concatenating into PCSrcE value for jalr
   logic [6:0]     opE; //ADDED - for jalr condition testing
   
  //TODO: change jalrsigD/E if not needed?

   // Decode stage logic
   maindec md(opD, ResultSrcD, MemWriteD, BranchD,
              ALUSrcD, RegWriteD, JumpD, ImmSrcD, ALUOpD, auipcSrcD);
   aludec  ad(opD[5], funct3D, funct7b5D, ALUOpD, ALUControlD);

      // Execute stage pipeline control register and logic
   floprc #(21) controlregE(clk, reset, FlushE,
                            {RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD, ALUControlD, ALUSrcD, funct3D, opD}, //TODO: jalrsigD/E not needed?
                            {RegWriteE, ResultSrcE, MemWriteE, JumpE, BranchE, ALUControlE, ALUSrcE, funct3E, opE});

   always_comb begin // Branch condition (pass or fail) calculation
    case(funct3E) //for branch instructions
      3'b000: Branch_condition = (ZeroE); // beq
      3'b001: Branch_condition = (~ZeroE); // bne
      3'b100: Branch_condition = (NegE ^ OverflowE); // blt
      3'b101: Branch_condition = (~(NegE ^ OverflowE)); // bge
      3'b110: Branch_condition = (~CarrE); // bltu
      3'b111: Branch_condition = (CarrE); // bgeu
      default: Branch_condition = 1'b0;
    endcase

    case(opE) //for jalr condition 
      7'b1100111: PCSrc_1 = 1'b1; //if instruction is jalr, take proper PC source
      default: PCSrc_1 = 1'b0;
    endcase

   end //end conditions
   
   assign PCSrc_0 = (BranchE & Branch_condition) | JumpE; //normal PCSrcE condition test
   assign PCSrcE = {PCSrc_1, PCSrc_0}; //concatenating bits for PCSrcE w/ jalr functionality
   assign ResultSrcEb0 = ResultSrcE[0];
   
   // Memory stage pipeline control register
   flopr #(4) controlregM(clk, reset,
                          {RegWriteE, ResultSrcE, MemWriteE},
                          {RegWriteM, ResultSrcM, MemWriteM});
   
   // Writeback stage pipeline control register
  //  flopr #(3) controlregW(clk, reset,
  //                         {RegWriteM, ResultSrcM}, 
  //                         {RegWriteW, ResultSrcW});     
  flopr #(1) controlregW(clk, reset,
                          {RegWriteM},
                          {RegWriteW});    
endmodule


module load(

  input logic        RegWrite, ALUSrc,
  input logic [1:0]  ResultSrc,
  input logic [2:0]  funct3,
  input logic [31:0] dataAdr,
  input logic [31:0] ReadData,

  output logic [31:0] Data

);

  always_comb begin
    if (RegWrite & ALUSrc & ResultSrc[0] & (~ResultSrc[1])) begin
      case (funct3) //looking at funct3 for different load instructions
      3'b000: 
        case (dataAdr[1:0])  
          2'b00:   Data = {{24{ReadData[7]}},ReadData[7:0]}; //sign extended
          2'b01:   Data = {{24{ReadData[15]}},ReadData[15:8]};
          2'b10:   Data = {{24{ReadData[23]}},ReadData[23:16]};
          2'b11:   Data = {{24{ReadData[31]}},ReadData[31:24]};
        endcase //lb

      3'b001:
        case (dataAdr[1:0])  
          2'b00:   Data = {{16{ReadData[15]}},ReadData[15:0]};
          2'b10:   Data = {{16{ReadData[31]}},ReadData[31:16]};
        endcase //lh  

      3'b010:
        Data = ReadData[31:0];  //lw

      3'b100:
        case (dataAdr[1:0])  
          2'b00:   Data = {{24'b0},ReadData[7:0]}; //zero extended
          2'b01:   Data = {{24'b0},ReadData[15:8]};
          2'b10:   Data = {{24'b0},ReadData[23:16]};
          2'b11:   Data = {{24'b0},ReadData[31:24]};
        endcase //lbu

      3'b101:
        case (dataAdr[1:0])  
          2'b00:   Data = {{16'b0}, ReadData[15:0]};
          2'b10:   Data = {{16'b0},ReadData[31:16]};
        endcase //lhu  

      default:
        Data = ReadData;
      endcase
    end //end if
    else begin
      Data = ReadData;
    end //end else
  end //end always_comb

endmodule //end load()


module store(

  input logic memWrite,
  input logic [2:0] funct3,
  input logic [31:0] dataAdr, ReadData, rd2,

  output logic [31:0] WriteDataOut

);

  always_comb begin
    if (memWrite)begin
      case(funct3)
        3'b000:    
        case (dataAdr[1:0])  
          2'b00:   WriteDataOut =  {{ReadData[31:8]}, rd2[7:0]};
          2'b01:   WriteDataOut = {{ReadData[31:16], rd2[7:0], ReadData[7:0]}};
          2'b10:   WriteDataOut = {ReadData[31:24], rd2[7:0], ReadData[15:0]};
          2'b11:   WriteDataOut = {rd2[7:0], ReadData[23:0]};
        endcase //sb

        3'b001:        
        case (dataAdr[1:0])  
          2'b00:   WriteDataOut =  {ReadData[31:16], rd2[15:0]};
          2'b10:   WriteDataOut = {rd2[15:0], ReadData[15:0]};
        endcase //sh      

        3'b010:
          WriteDataOut = rd2; //sw

        default:
          WriteDataOut = rd2;
      endcase
    end //end if
    else begin
      WriteDataOut = rd2;
    end //end else
  end //end always_comb

endmodule //end store()


module maindec (input  logic [6:0] op, //DONE
		output logic [1:0] ResultSrc,
		output logic 	   MemWrite,
		output logic 	   Branch, ALUSrc, 
		output logic 	   RegWrite, Jump,
		output logic [2:0] ImmSrc, //change from 2 to 3 bits
		output logic [1:0] ALUOp,
    output logic auipcSrc); //pass through new jalrsig control signal     TODO: PASS AROUND
   
   logic [12:0] 		   controls;
   
   assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
	   ResultSrc, Branch, ALUOp, Jump, auipcSrc} = controls;  //pass through new jalrsig control signal
   
   always_comb
     case(op)
       // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_auipcSrc TODO: Modify?
       7'b0000011: controls = 13'b1_000_1_0_01_0_00_0_0; // lw
       7'b0100011: controls = 13'b0_001_1_1_00_0_00_0_0; // sw
       7'b0110011: controls = 13'b1_xxx_0_0_00_0_10_0_0; // R-type
       7'b1100011: controls = 13'b0_010_0_0_00_1_01_0_0; // beq
       7'b0010011: controls = 13'b1_000_1_0_00_0_10_0_0; // I-type ALU
       7'b1101111: controls = 13'b1_011_0_0_10_0_00_1_0; // jal
       7'b0110111: controls = 13'b1_100_1_0_11_0_1x_0_0; //lui
       7'b1100111: controls = 13'b1_000_1_0_10_0_00_1_0; //jalr
       7'b0010111: controls = 13'b1_100_1_0_00_0_00_0_1; //auipc
       7'b0000000: controls = 13'b0_000_0_0_00_0_00_0_0; // need valid values at reset

       default: controls = 13'bx_xxx_x_x_xx_x_xx_x_x; // ???

     endcase // case (op)
   
endmodule // maindec

module aludec (input  logic       opb5,  //----------------------------- DONE
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
       default: case(funct3) // R–type or I–type ALU
		  3'b000: if (RtypeSub)
		    ALUControl = 4'b0001; // sub
		  else
		    ALUControl = 4'b0000; // add, addi
		  3'b010: ALUControl = 4'b0101; // slt, slti
		  3'b110: ALUControl = 4'b0011; // or, ori
		  3'b111: ALUControl = 4'b0010; // and, andi

      3'b100: ALUControl = 4'b0100; // xor, xori
      3'b001: ALUControl = 4'b1000; //sll, slli
      3'b011: ALUControl = 4'b1001; //sltu, sltiu
      
      3'b101: if (funct7b5) 
        ALUControl = 4'b0110; //sra, srai
      else
        ALUControl = 4'b0111; //srl, srli

		  default: ALUControl = 4'bxxxx; // ???
		endcase // case (funct3)       
     endcase // case (ALUOp)
   
endmodule // aludec

module datapath(input logic clk, reset,
                // Fetch stage signals
                input logic 	    StallF,
                output logic [31:0] PCF,
                input logic [31:0]  InstrF,
                // Decode stage signals
                output logic [6:0]  opD,
                output logic [2:0]  funct3D, 
                output logic 	    funct7b5D,
                input logic 	    StallD, FlushD,
                input logic [2:0]   ImmSrcD, // 2 to 3 bits
                // Execute stage signals
                input logic 	    FlushE,
                input logic [1:0]   ForwardAE, ForwardBE,
                input logic [1:0]	  PCSrcE,  //1 to 2 bits
                input logic [3:0]   ALUControlE, //change from 3 to 4 bits
                input logic 	    ALUSrcE,
                output logic 	    ZeroE, NegE, CarrE, OverflowE, //added flags
                // Memory stage signals
                input logic 	    MemWriteM, 
                output logic [31:0] StoreOutM, ALUResultM,
                input logic [31:0]  ReadDataM,
                input logic       RegWriteM,
                // Writeback stage signals
                input logic 	    RegWriteW, 
                input logic [1:0]   ResultSrcM, //TODO: to ResultSrcM from W?
                // Hazard Unit signals 
                output logic [4:0]  Rs1D, Rs2D, Rs1E, Rs2E,
                output logic [4:0]  RdE, RdM, RdW,
                input logic        auipcSrcD,
                output logic       MemStrobeM,
                input logic        PCReady);

   // Fetch stage signals
   logic [31:0] 		    PCNextF, PCPlus4F;
   // Decode stage signals
   logic [31:0] 		    InstrD;
   logic [31:0] 		    PCD, PCPlus4D;
   logic [31:0] 		    RD1D, RD2D;
   logic [31:0] 		    ImmExtD;
   logic [4:0] 			    RdD;
   logic                MemStrobeD;
   // Execute stage signals
   logic [31:0] 		    RD1E, RD2E;
   logic [31:0] 		    PCE, ImmExtE;
   logic [31:0] 		    SrcAE, SrcBE;
   logic [31:0] 		    ALUResultE;
   logic [31:0] 		    WriteDataE;
   logic [31:0] 		    PCPlus4E;
   logic [31:0] 		    PCTargetE;
   logic                MemStrobeE;
   // Memory stage signals
   logic [31:0] 		    PCPlus4M;
   //MemStrobeM output

   // Writeback stage signals
   logic [31:0] 		    ALUResultW;
   logic [31:0] 		    ReadDataW;
   logic [31:0] 		    PCPlus4W;
   logic [31:0] 		    ResultW;

   //ADDED:
   logic [31:0]         ImmExtM,ImmExtW;
   logic [31:0]         jalrTarget;
   logic [31:0]          RD1D0, RD2M;
   logic [2:0]          funct3E, funct3M, funct3W;
   logic [31:0]         DataM, DataW;
   logic [31:0]         WriteDataM;
   logic [1:0]          ResultSrcW;

   //end writeback signals


   // Fetch stage pipeline register and logic

   assign jalrTarget = SrcAE + ImmExtE; //jalr jump target calculation

   mux3    #(32) pcmux(PCPlus4F, PCTargetE, jalrTarget, PCSrcE, PCNextF); //added jalr instruction support
   flopenr #(32) pcreg(clk, reset, ~StallF | PCReady, PCNextF, PCF);
   adder         pcadd(PCF, 32'h4, PCPlus4F);

   // Decode stage pipeline register and logic

   flopenrc #(96) regD(clk, reset, FlushD, ~StallD, 
                       {InstrF, PCF, PCPlus4F},
                       {InstrD, PCD, PCPlus4D});
   assign opD       = InstrD[6:0];
   assign funct3D   = InstrD[14:12];
   assign funct7b5D = InstrD[30];
   assign Rs1D      = InstrD[19:15];
   assign Rs2D      = InstrD[24:20];
   assign RdD       = InstrD[11:7];

   assign MemStrobeD = ((opD == 7'b0000011) | (opD == 7'b0100011)) ? 1 : 0;
   
   mux2 #(32) srcamux(RD1D, PCD, auipcSrcD, RD1D0); //added support for auipc instruction
   regfile        rf(clk, RegWriteW, Rs1D, Rs2D, RdW, ResultW, RD1D, RD2D);
   extend         ext(InstrD[31:7], ImmSrcD, ImmExtD);
   
   // Execute stage pipeline register and logic
   floprc #(179) regE(clk, reset, FlushE, 
                      {RD1D0, RD2D, PCD, Rs1D, Rs2D, RdD, ImmExtD, PCPlus4D, funct3D, MemStrobeD}, 
                      {RD1E, RD2E, PCE, Rs1E, Rs2E, RdE, ImmExtE, PCPlus4E, funct3E, MemStrobeE});
   
   mux3   #(32)  faemux(RD1E, ResultW, ALUResultM, ForwardAE, SrcAE);
   mux3   #(32)  fbemux(RD2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
   mux2   #(32)  srcbmux(WriteDataE, ImmExtE, ALUSrcE, SrcBE);

   

   alu           alu(SrcAE, SrcBE, ALUControlE, ALUResultE, ZeroE, NegE, CarrE, OverflowE);
   adder         branchadd(ImmExtE, PCE, PCTargetE);

   // Memory stage pipeline register
   flopr  #(138) regM(clk, reset, 
                      {ALUResultE, RdE, PCPlus4E, ImmExtE, ALUSrcE, funct3E, WriteDataE, MemStrobeE},
                      {ALUResultM, RdM, PCPlus4M, ImmExtM, ALUSrcM, funct3M, WriteDataM, MemStrobeM});
   
   // Writeback stage pipeline register and logic
   flopr  #(139) regW(clk, reset, 
                      {ALUResultM, DataM, RdM, PCPlus4M, ImmExtM, ALUSrcM, funct3M, ResultSrcM},
                      {ALUResultW, DataW, RdW, PCPlus4W, ImmExtW, ALUSrcW, funct3W, ResultSrcW});

   mux4   #(32)  resultmux(ALUResultW, DataW, PCPlus4W, ImmExtW, ResultSrcW, ResultW); 	

   //REMOVED old jalr mux

   load load(RegWriteM, ALUSrcM, ResultSrcM, funct3M, ALUResultM, ReadDataM, DataM); //ADDED for load instrs.
   store store(MemWriteM, funct3M, ALUResultM, DataM, WriteDataM, StoreOutM); //ADDED for store instrs.


endmodule

// Hazard Unit: forward, stall, and flush
module hazard(input  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
              input logic 	 PCSrcE, ResultSrcEb0, 
              input logic 	 RegWriteM, RegWriteW,
              output logic [1:0] ForwardAE, ForwardBE,
              output logic 	 StallF, StallD, FlushD, FlushE);

   logic 			 lwStallD;
   
   // forwarding logic
   always_comb begin
      ForwardAE = 2'b00;
      ForwardBE = 2'b00;
      if (Rs1E != 5'b0)
	if      ((Rs1E == RdM) & RegWriteM) ForwardAE = 2'b10;
	else if ((Rs1E == RdW) & RegWriteW) ForwardAE = 2'b01;
      
      if (Rs2E != 5'b0)
	if      ((Rs2E == RdM) & RegWriteM) ForwardBE = 2'b10;
	else if ((Rs2E == RdW) & RegWriteW) ForwardBE = 2'b01;
   end
   
   // stalls and flushes
   assign lwStallD = ResultSrcEb0 & ((Rs1D == RdE) | (Rs2D == RdE));  
   assign StallD = lwStallD;
   assign StallF = lwStallD;
   assign FlushD = PCSrcE;
   assign FlushE = lwStallD | PCSrcE;
endmodule

module regfile(input  logic        clk, 
               input logic 	   we3, 
               input logic [ 4:0]  a1, a2, a3, 
               input logic [31:0]  wd3, 
               output logic [31:0] rd1, rd2);

   logic [31:0] 		   rf[31:0];

   // three ported register file
   // read two ports combinationally (A1/RD1, A2/RD2)
   // write third port on rising edge of clock (A3/WD3/WE3)
   // write occurs on falling edge of clock
   // register 0 hardwired to 0

   always_ff @(negedge clk)
     if (we3) rf[a3] <= wd3;	

   assign rd1 = (a1 != 0) ? rf[a1] : 0;
   assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(input  [31:0] a, b,
             output [31:0] y);

   assign y = a + b;
endmodule

module extend (input  logic [31:7] instr,   ///DONE
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
       3'b100:  immext = {instr[31:12], 12'b0};
      

       default: immext = 32'bx; // undefined
     endcase // case (immsrc)
   
endmodule // extend

module flopr #(parameter WIDTH = 8)
   (input  logic             clk, reset,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset) q <= 0;
     else       q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
   (input  logic             clk, reset, en,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset)   q <= 0;
     else if (en) q <= d;
endmodule

module flopenrc #(parameter WIDTH = 8)
   (input  logic             clk, reset, clear, en,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset)   q <= 0;
     else if (en) 
       if (clear) q <= 0;
       else       q <= d;
endmodule

module floprc #(parameter WIDTH = 8)
   (input  logic clk,
    input logic 	     reset,
    input logic 	     clear,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset) q <= 0;
     else       
       if (clear) q <= 0;
       else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, 
    input logic 	     s, 
    output logic [WIDTH-1:0] y);

   assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2,
    input logic [1:0] 	     s, 
    output logic [WIDTH-1:0] y);

   assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module mux4 #(parameter WIDTH = 8) //ADDED
   (input  logic [WIDTH-1:0] d0, d1, d2, d3, 
    input logic [1:0]         s,               
    output logic [WIDTH-1:0]  y);              
   
  assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0);
   
endmodule // mux4

/*module imem (input  logic [31:0] a,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[16384:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   
endmodule // imem

module dmem (input  logic        clk, we,
	     input  logic [31:0] a, wd,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[16384:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   always_ff @(posedge clk)
     if (we) RAM[a[31:2]] <= wd;
   
endmodule // dmem*/

module alu (input  logic [31:0] a, b, //------------------------------------  DONE
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
       4'b0000:  result = sum;          // add
       4'b0001:  result = sum;          // subtract
       4'b0010:  result = a & b;        // and
       4'b0011:  result = a | b;        // or
       4'b0100:  result = a ^ condinvb; //xor  
       4'b0101:  result = sum[31] ^ v;  // slt
       4'b0110:  result = $signed(a) >>> b[4:0]; //sra srai
       4'b0111:  result = a >> b[4:0];  //srl srli
       4'b1000:  result = a << b[4:0];  //sll slli
       4'b1001:  result = $unsigned(a) < $unsigned(b);  //sltu sltiu

       default: result = 32'bx;
     endcase

   assign zero = (result == 32'b0); // zero result flag
   assign negative = result[31]; // negative result flag
   assign carry = (~alucontrol[1]) & sum[32]; // carry from result flag
   assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub; //overflow flag  

   
endmodule // alu

