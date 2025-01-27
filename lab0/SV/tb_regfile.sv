module stimulus ();

    logic clk;
    logic reset;
    logic we3;
    logic [4:0] ra1, ra2, wa3; // register addresses
    logic [31:0] wd3; // data that gets written
    logic [31:0] rd1, rd2;

    integer handle3;
    integer desc3;

   // Instantiate DUT
   regfile dut (clk, reset, we3, ra1, ra2, wa3, wd3, rd1, rd2);

   // Setup the clock to toggle every 1 time units 
   initial 
     begin	
	clk = 1'b1;
	forever #5 clk = ~clk;
     end

   initial
     begin
	// Gives output file name
	handle3 = $fopen("test.out");
	// Tells when to finish simulation
	#500 $finish;		
     end

   always 
     begin
	desc3 = handle3;
	#5 $fdisplay(desc3, "%b %b || %h %h", 
		     ra1, ra2, rd1, rd2);
     end   

    initial
        begin
        #0 ra1 = 5'b00000; ra2 = 5'b00000; wa3 = 5'b00000; wd3 = 32'b0; we3 = 0;

        //first test - write and read from register 1
        #10 we3 = 1; wa3 = 5'b00001; wd3 = 32'hABCD1234; // write values to register 1. can choose a different value to write, if wanted
        #10 we3 = 0; ra1 = 5'b00001; ra2 = 5'b00001; // read register 1. both read ports are reading from register 1

        //second test - write and read from register 2
        #10 we3 = 1; wa3 = 5'b00010; wd3 = 32'h1111AAAA; // write values to register 2. can choose a different value to write, if wanted
        #10 we3 = 0; ra1 = 5'b00010; ra2 = 5'b00010; // read register 2. both read ports are reading from register 2

        //third test - write to register 3 and read from different registers
        #10 we3 = 1; wa3 = 5'b00011; wd3 = 32'h11111111; // write values to register 3. can choose a different value to write, if wanted
        #10 we3 = 0; ra1 = 5'b00001; ra2 = 5'b00010; // read registers 1 and 2

        //fourth test - making sure register 0 is always reading 0
        #10 ra1 = 5'b00000; ra2 = 5'b00000;

        //fifth test - check the last register, register 31
        #10 we3 = 1; wa3 = 5'b11111; wd3 = 32'hAAAABBBB; // write values to register 31. can choose a different value to write, if wanted
        #10 we3 = 0; ra1 = 5'b11111; ra2 = 5'b00000; // read register 31 and register 0

        //sixth test - reset regfile and ensure all registers read 0
        #10 reset = 1'b1; // reset
        #10 reset = 1'b0; // stop reset
        #10 we3 = 0; ra1 = 5'b01010; // read register 10. Should be all zeroes

        #10 we3 = 1; wa3 = 5'b01010; wd3 = 32'h44445555; // write values to register 10. can choose a different value to write, if wanted
        #10 we3 = 0; ra1 = 5'b01010; // read register 10. 
        end  


endmodule
