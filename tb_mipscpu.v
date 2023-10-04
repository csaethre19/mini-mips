module tb_mipscpu;

// inputs
reg clk, reset, zero;
reg [5:0] op;
// input to alu
reg [2:0] alucont;
reg [7:0] a, b;


// outputs
wire memwrite, alusrca, memtoreg, iord, pcen, regwrite, regdst;
wire [1:0] pcsource, alusrcb, aluop;
wire [3:0] irwrite;
// output for alu
wire [7:0] result;


controller con(	
		.clk(clk), 
		.reset(reset), 
		.op(op), 
		.zero(zero), 
		.memwrite(memwrite), 
		.alusrca(alusrca),
		.memtoreg(memtoreg),
		.iord(iord),
		.pcen(pcen),
		.regwrite(regwrite),
		.regdst(regdst),
		.pcsource(pcsource),
		.alusrcb(alusrcb),
		.aluop(aluop),
		.irwrite(irwrite)
);

alu uut(.a(a), .b(b), .alucont(alucont), .result(result));

	initial 
	begin
		clk = 1'b0;
		// flip clock every 5 ps
		forever #5 clk=~clk;
	end
	
	initial begin
		reset = 1'b1; // reset active-low
		zero = 1'b0;
		op = 6'b001000; // op code for addi
		alucont =  3'b000;
		a = 1;
		b = 2;
		#20;
		$display("aluop from controller: %b", aluop);
		// alu test case
		alucont =  3'b010;
		#20;
		$display("ALU result: %d", result);

	end
	
	
endmodule

	