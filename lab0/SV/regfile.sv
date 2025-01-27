module regfile (input logic         clk, //INPUT: clock
      input logic reset, //INPUT (for TB): reset, which sets registers to 0
		input logic 	    we3, //write enable signal
		input logic [4:0]   ra1, ra2, wa3, //2 source register #s, 1 destination register #
		input logic [31:0]  wd3, //data port for writes

		output logic [31:0] rd1, rd2); //OUTPUT: 2 register values for each of the read ports
   
   logic [31:0] 		    rf[31:0];
   
   // three ported register file
   // read two ports combinationally
   // write third port on rising edge of clock
   // register 0 hardwired to 0

  /* always_ff @(posedge clk) begin
      if (we3) begin

         rf[wa3] <= wd3;

      end
   end
   
   assign rd1 = rf[ra1];
   assign rd2 = rf[ra2];

   */ //old code, ignore

   always_ff @(posedge clk)
      if (we3) rf [wa3] <= wd3;

      else if (reset) begin
         for (int i=0; i < 32; i++) begin
            rf[i] <=32'b0;
         end
      end      // for test bench to allow resets, not sure if this is correct. Had online help

   assign rd1 = (ra1 == 5'b00000) ? 32'b0 : rf[ra1];
   assign rd2 = (ra2 == 5'b00000) ? 32'b0 : rf[ra2];
     
endmodule // regfile
