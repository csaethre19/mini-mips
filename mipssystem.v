module mipssystem #(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8) 
		(
			input clk, input reset, 
			input  [(ADDR_WIDTH-1):0] switches,
			output [(DATA_WIDTH-1):0] LEDs
		);

wire [7:0] memdata;
wire memwrite;
wire [7:0] adr, writedata;

// Instantiating the external memory module and the cpu mips cpu module
// Upon first load the memdata outputted by exmem will have the 1st byte of the 1st instruction.
// The first four states correspond to the fetch states and this will load the 
// 32-bit instruction register with the four bytes of the instruction read from memory.

exmem   exm(
				.data(writedata), 
				.addr(adr), 
				.we(memwrite), 
				.clk(clk), 
				.switches(switches), 
				.LEDs(LEDs),
				.q(memdata)
			);

mipscpu cpu(
				.clk(clk), 
				.reset(reset), 
				.memdata(memdata), 
				.memwrite(memwrite), 
				.adr(adr), 
				.writedata(writedata)
			);


endmodule
