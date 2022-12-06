module pc_counter(

	input [31:0] nextPc,
	input  clock,

	output reg [31:0] pc 
);

	initial
	begin
		pc = 100;
	end

	always @(posedge clock)
	begin
		pc <= nextPc; 
	end 
	
endmodule 
//_____________________________________
module inst_mem(

	input [31:0] pc,
	
	output reg [31:0] instOut
);
	
	reg [31:0] memory [0:63];


	initial 
	begin
		memory[25] = {6'b100011, 5'd1, 5'd2, 16'd0}; //100:lw $2, 00($1)
		memory[26] = {6'b100011, 5'd1, 5'd3, 16'd4};
		memory[27] = {6'b100011, 5'd1, 5'd4, 16'd8};
		memory[28] = {6'b100011, 5'd1, 5'd5, 16'd12};
		memory[29] = {6'b000000, 5'd2, 5'd10, 5'd6, 5'd0, 6'd100100};
		
	end
	
	
	always@(*)
	begin
		instOut <= memory[pc[7:2]];
	end
		
endmodule

//_______________________________________

module pc_adder(

	input [31:0] pc,
	
	output reg [31:0] nextPc
);
	
	


	always @(*)
	begin
		nextPc <= pc + 32'd4;
	end
		
endmodule
		
//_________________________________________

module ifid_reg(
	
	input [31:0] instOut,
	input clock,
	
	output reg [31:0] distOut
	
);


	always @(posedge clock)
	begin
		distOut <= instOut;
	end
	
endmodule

//__________________________________________
module control_unit(
	
	input [5:0] op,
	input [5:0] func,
	
	output reg wreg,
	output reg m2reg,
	output reg wmem,
	output reg [3:0] aluc,
	output reg aluimm,
	output reg regrt
);	


	
	always @(*)
	begin	
		wreg <=0;
		m2reg <=0;
		wmem <= 0;
		aluc <=4'b0000;
		aluimm <= 0;
		regrt <=0;
		case(op)
			6'b000000: //r-types
			begin
			     case(func)
					6'b100000: //add instruction
					begin
						aluc <= 4'b0010;
			     		wreg <=1;
			     	end  						
			      endcase			   
			 end
	      6'b100011: //lw
			begin
				aluc <= 4'b0010;
				wreg <= 1;
				m2reg <= 1;//set values for control sig for LW
				aluimm <=1;
				regrt <= 1;
			end
		endcase
	end
endmodule
//___________________________________________

module regrt(

	input [4:0] rt,
	input [4:0] rd,
	input regrt,
	
	output reg [4:0] destreg
);
	
	always @(*)
	begin
		if (regrt == 0)
		begin
			destreg <=rd;
		end
		else if (regrt == 1)
		begin
			destreg <= rt;
		end
	end
	
endmodule
//___________________________________________
module register_file(
	
	input [4:0] rs,
	input [4:0] rt,
	input [4:0] wdestreg, 
	input [31:0] wbdata,
	input wwreg,
	input clk,
	
	output reg [31:0] qa,
	output reg [31:0] qb
);
	

	
	reg [31:0] register [0:31];


    integer i;
    
    initial
    begin
        for(i=0; i<32; i=i+1)
        begin
        register[i] = 32'b0;
        end
    end
    
    
	
	
	always @(*) 
	begin
		qa = register[rs];
		qb = register[rt];
		if (clk == 0 && wwreg == 1'b1)
		begin
			register[wdestreg] <=wbdata;
		end
	end
	
endmodule
//___________________________________________

module immediate_extender(

	input [15:0] imm,
	
	output reg [31:0] imm32

);

	always@(*)
	begin
		 imm32 <= {{16{imm[15]}},imm};
	end
endmodule
//____________________________________________

module idexe_reg(

	input clock,
	input wreg,
	input m2reg,
	input wmem,
	input [3:0] aluc,
	input aluimm,
	input [5:0] destReg,
	input [31:0]qa,    
	input [31:0] qb,    
	input [31:0] imm32,    
	
	
	output reg ewreg,
	output reg em2reg,
	output reg ewmem,
	output reg [3:0] ealuc,   
	output reg ealuimm,
	output reg [4:0]edestReg, 
	output reg [31:0] eqa,
	output reg [31:0]eqb,
	output reg [31:0]eimm32
		

);
	
	always @(posedge clock)
	begin
		ewreg <= wreg;
		em2reg <= m2reg;
		ewmem <= wmem;
		ealuc <= aluc;
		ealuimm <= aluimm;
		edestReg <= destReg; 
		eqa <= qa;   
		eqb <= qb;   
		eimm32 <=imm32;
	end
endmodule
//____________________________________________
module alu_mux(

	input[31:0] eqb,
	input [31:0] eimm32,
	input ealuimm,

	output reg [31:0] b

);
	
	always@(*)
	begin
		case(ealuimm)
			0:  b <= eqb;
			1'b1: b <= eimm32;
		endcase
	end
endmodule
//_______________________________________________
module alu(

	input [31:0] eqa,
	input [31:0] b,
	input [3:0] ealuc,

	output reg [31:0] r

);		
	always@(*) begin
		case(ealuc)
			4'b0000: r<= eqa & b;
			4'b0001: r<= eqa | b;
			4'b0010: r<= eqa + b;
			4'b0110: r<= eqa - b;
			4'b0111: r<= eqa < b? 1:0;
			4'b1100: r<= ~(eqa | b);
		endcase
	end
endmodule
//__________________________________________________
module exemem(

	input ewreg,
	input em2reg,
	input ewmem,
	input [4:0] edestreg,
	input [31:0] r,
	input [31:0] eqb,
	input clock,
	
	output reg mwreg,
	output reg mm2reg,
	output reg mwmem,
	output reg [4:0] mdestreg,
	output reg [31:0] mr,
	output reg [31:0] mqb

);

	always@(posedge clock)
	begin
		mwreg<=ewreg;
		mm2reg<=em2reg;
		mwmem<=ewmem;
		mdestreg<=edestreg;
		mr<=r;
		mqb <=eqb;
	end
endmodule
//___________________________________________________
module data_memory(

	input [31:0] mr,
	input [31:0] mqb,
	input mwmem,
	input clock,
	
	output reg [31:0] mdo

);
	reg [31:0] data_mem [0:63];
		initial 
		begin
			data_mem[0] <= 32'hA00000AA;
			data_mem[1] <= 32'h10000011;
			data_mem[2] <= 32'h20000022;
			data_mem[3] <= 32'h30000033;
			data_mem[4] <= 32'h40000044;
			data_mem[5] <= 32'h50000055;
			data_mem[6] <= 32'h60000066;
			data_mem[7] <= 32'h70000077;
			data_mem[8] <= 32'h80000088;
			data_mem[9] <= 32'h90000099;
		end
		
		
		always@(*) 
		begin
			mdo = data_mem[mr[7:2]];
			if(clock == 0 && mwmem ==1'b1)
			begin
				 data_mem[mr[7:2]] = mqb;	
			end
		end	
endmodule
//_____________________________________________
module memwb(

	input mwreg,
	input mm2reg,
	input [4:0] mdestreg,
	input [31:0] mr,
	input [31:0] mdo,
	input clock,
	
	output reg wwreg,
	output reg wm2reg,
	output reg [4:0] wdestreg,
	output reg [31:0] wr,
	output reg [31:0] wdo
);

	always@(posedge clock)
	begin
		wwreg<=mwreg;
		wm2reg<=mm2reg;
		wdestreg<=mdestreg;
		wr<=mr;
		wdo<=mdo;
	end
endmodule
//______________________________________

module wbmux(

	input [31:0] wr,
	input [31:0] wdo,
	input wm2reg,
	
	output reg [31:0] wbdata

);

	always@(*)
	begin
		case(wm2reg)
		1'b0: wbdata <= wr;
		1'b1: wbdata <= wdo;
		endcase
	end
endmodule

//______________________________________


module labv(

	input clock,
	
	output wire [31:0] pc,
	output wire [31:0] dinstOut,
	output wire ewreg,
   output wire em2reg,
   output wire ewmem,
	output wire [3:0] ealuc,
   output wire ealuimm,
	output wire [4:0]edestReg,
   output wire [31:0] eqa,
	output wire [31:0]eqb,
	output wire [31:0]eimm32,
	output wire mwreg,
	output wire mm2reg,
	output wire mwmem,
	output wire [4:0] mdestreg,
	output wire [31:0] mr,
	output wire [31:0] mqb,
	output wire wwreg,
	output wire wm2reg,
	output wire [4:0] wdestreg, 
	output wire [31:0] wr,
	output wire [31:0] wdo

	
 
); 
	
	wire [31:0] const;
	wire [5:0] op = dinstOut[31:26];
	wire [5:0] func = dinstOut[5:0];
	wire [4:0]rt = dinstOut[20:16];
	wire [4:0] rd = dinstOut[15:11];
	wire [4:0] rs = dinstOut[25:21];
	wire [15:0] imm = dinstOut[15:0];
	wire [31:0] nextPc;
	wire [31:0] instOut;
	wire wreg;
	wire m2reg;
	wire wmem;
	wire [3:0] aluc;
	wire aluimm;
	wire regrt;
	wire [4:0] destReg;
	wire [31:0] qa;
	wire [31:0] qb; 
	wire [31:0] b;
	wire [31:0] r;
	wire [31:0] mdo;
	wire [31:0] wbdata;
	wire [31:0] imm32;

	pc_adder adder(pc,nextPc);
	
	pc_counter pcCounter(nextPc,clock, pc);
	
	inst_mem instMem(pc,instOut);
	
	ifid_reg ifid(instOut,clock,dinstOut);
	
	control_unit controlUnit(op, func, wreg, m2reg, wmem, aluc, aluimm,regrt);
	
	regrt reg_rt(rt, rd,regrt, destReg);
	
	register_file reg_file(rs, rt, wdestreg, wbdata, wwreg, clock, qa, qb);
	
	immediate_extender immediateExtender(imm,imm32);
	
	idexe_reg idexe(clock, wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
	
	alu_mux aluMux(eqb, eimm32, ealuimm, b);
	
	alu ALU(eqa, b, ealuc, r);  
	
	exemem EXEMEM(ewreg, em2reg, ewmem, edestReg, r, eqb, clock, mwreg, mm2reg, mwmem, mdestreg, mr, mqb);
	
	data_memory dataMem(mr, mqb, mwmem, clock, mdo);
	
	memwb MEMWB(mwreg, mm2reg, mdestreg, mr, mdo, clock, wwreg, wm2reg, wdestreg, wr, wdo);
	
	wbmux wbMux(wr, wdo, wm2reg, wbdata);

endmodule 