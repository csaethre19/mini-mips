//-------------------------------------------------------
// mips.v
// Max Yi (byyi@hmc.edu) and David_Harris@hmc.edu 12/9/03
// Model of subset of MIPS processor described in Ch 1
//
// Modified by Erik Brunvand to have consistent 
// little endian byte ordering for reading and writing
// 
// Note that this uses Verilog 2001 syntax
//-------------------------------------------------------


// simplified MIPS processor
module mipscpu #(parameter WIDTH = 8, REGBITS = 3)
   (input clk,                  // 50MHz clock
    input reset,                // active-low reset
    input [7:0] memdata,        // data that is read from memory
    output memwrite,            // write-enable to memory
    output [7:0] adr,           // address to memory
    output [7:0] writedata      // write data to memory
    );
	 
   wire [31:0] instr;           // 32bit register for holding the instruction
   // Various control and status signals
   wire        zero, alusrca, memtoreg, iord, pcen, regwrite, regdst;
   wire [1:0]  aluop,pcsource,alusrcb; // parts of the instruction
   wire [3:0]  irwrite;                // which byte of instr are you writing? 
   wire [2:0]  alucont;                // ALU control

   // Instantiate the controller, alucontrol, and datapath modules
   controller  cont(clk, reset, instr[31:26], zero, memwrite, 
                    alusrca, memtoreg, iord, pcen, regwrite, regdst,
                    pcsource, alusrcb, aluop, irwrite);
						  
								 // instr[5:0] is funct part of 32-bit instruction output from the datapath
   alucontrol  ac(aluop, instr[5:0], alucont);
	
   datapath    #(WIDTH, REGBITS) 
               dp(clk, reset, memdata, alusrca, memtoreg, iord, pcen,
                  regwrite, regdst, pcsource, alusrcb, irwrite, alucont,
                  zero, instr, adr, writedata);
endmodule

