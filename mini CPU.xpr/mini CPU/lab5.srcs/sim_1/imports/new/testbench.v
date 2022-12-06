`timescale 1ns/1ps 

module testbenchv(
);

	reg clock; 
	
	 wire [31:0] pc;
	 wire [31:0] dinstOut;
	 wire ewreg;
    wire em2reg;
    wire ewmem;
	 wire [3:0] ealuc;
    wire ealuimm;
	 wire [4:0]edestReg;
    wire [31:0] eqa;
	 wire [31:0]eqb;
	 wire [31:0]eimm32;
	 wire mwreg;
	 wire mm2reg;
	 wire mwmem;
	 wire [4:0] mdestreg;
	 wire [31:0] mr;
	 wire [31:0] mqb;
	 wire wwreg;
	 wire wm2reg;
	 wire [4:0] wdestreg; 
	 wire [31:0] wr;
	 wire [31:0] wdo;




	labv labv_testbench(clock, pc, dinstOut, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg,
	eqa, eqb, eimm32, mwreg, mm2reg, mwmem, mdestreg, mr, mqb, wwreg, wm2reg, wdestreg, wr, wdo);
		initial begin
			clock = 0;
		end
			
		always begin
		#5 clock = ~clock;
		
	end
endmodule
