// Quartus Prime Verilog Template
// Single port RAM with single read/write address 
/*
	Upon first run the exmem module will load the .dat file into ram.
	One byte of the instruction will be loaded into an address, starting with the lower addresses.
	When the controller is in the first four fetch states the addr coming into this module
	will correspond to getting the next byte of the instruction out of memory. 
*/

module exmem #(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8)
        (
				input  [(DATA_WIDTH-1):0] data,
				input  [(ADDR_WIDTH-1):0] addr,
				input                     we, clk,
				input  [(ADDR_WIDTH-1):0] switches,
				output reg [(DATA_WIDTH-1):0] LEDs,
				output [(DATA_WIDTH-1):0] q
        );
	
	
	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Variable to hold the read address
	reg [ADDR_WIDTH-1:0] addr_reg;
	
	// Variable to hold IO 
	wire IO;
	

        // The $readmemb function allows you to load the
        // RAM with data on initialization to the FPGA
	initial begin
	$display("Loading memory");
	$readmemb("C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/assembly_code/fib-converted.dat", ram);
	$display("done loading");

	end

	always @ (negedge clk)
	begin
		// Write data
		if (we) begin
			if (IO) begin
				LEDs <= data;
				//leds_temp <= data;
			end
			else begin
				ram[addr] <= data;
			end
		end
		
      // Read data
		addr_reg <= addr;
	end
	

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign q = IO ? switches : ram[addr_reg];
	
	// if top two bits of addr is 2'b11 then we are in I/O space
	assign IO = (addr[(ADDR_WIDTH-1) : (ADDR_WIDTH-2)] == 2'b11);

	
endmodule // exmem

