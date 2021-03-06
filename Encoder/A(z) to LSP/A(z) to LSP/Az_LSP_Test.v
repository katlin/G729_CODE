`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:26:34 10/28/2010
// Module Name:    Az_LSP_Test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Az_toLSP_FSM
// Dependencies: 	 L_mac.v, L_msu.v,L_shl,L_sub,add,mult,norm_s
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Az_LSP_Test_v;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;	
	reg lspMuxSel;
	reg [11:0] testReadRequested;
	//mux1 regs
	reg [11:0] testWriteRequested;
	//mux2 regs
	reg [31:0] testLspOut;
	//mux3regs
	reg testLspWrite;
	
	//Outputs
   wire [31:0] lspIn;
	
	//working regs
	reg [15:0] aSubI_in [0:9999];
	reg [15:0] lspOutMem [0:9999];
	
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("lsp_az_lsp_in.out", aSubI_in);
		$readmemh("lsp_az_lsp_out.out", lspOutMem);
	end							 
	
	// Instantiate the Unit Under Test (UUT)	
   Az_LSP_Top uut(
						.clk(clk),
						.reset(reset),
						.start(start),
						.lspMuxSel(lspMuxSel),
						.testReadRequested(testReadRequested),
						.testWriteRequested(testWriteRequested),
						.testLspOut(testLspOut),
						.testLspWrite(testLspWrite),
						.done(done),
						.lspIn(lspIn)
						);
	initial begin
		// Initialize Input
		#100;
		clk = 0;
		reset = 0;
		start = 0;
		testReadRequested = 0;	
		testWriteRequested = 0;	
	   testLspWrite = 0;
		lspMuxSel = 0;
		testLspOut = 0;
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		// Wait 100 ns for global reset to finish
		
		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
		@(posedge clk);
		@(posedge clk) #5;
		
		for(j=0;j<120;j=j+1)
		begin
		
		@(posedge clk);
		@(posedge clk) #5;
		//writing the previous modules to memory
			lspMuxSel = 0;					
			for(i=0;i<11;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				lspMuxSel = 1;
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;					//Added Delay BY PARKER
				testWriteRequested = {A_T_HIGH[10:4],i[3:0]};
				testLspOut = aSubI_in[j*11+i];
				testLspWrite = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			lspMuxSel = 0;
			 
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			// Add stimulus here		
		
			wait(done);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			lspMuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadRequested = {LSP_NEW[10:4],i[3:0]};
					@(posedge clk);
					@(posedge clk) #5;
					if (lspIn != lspOutMem[10*j+i])
						$display($time, " ERROR: lsp[%d] = %x, expected = %x", 10*j+i, lspIn, lspOutMem[10*j+i]);
					else if (lspIn == lspOutMem[10*j+i])
						$display($time, " CORRECT:  lsp[%d] = %x", 10*j+i, lspIn);
					@(posedge clk) #5;	
			end
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule


