// all the datapath parts, including the register file, program
// counter, address registers, etc. 
module datapath #(parameter WIDTH = 8, REGBITS = 3)
                 (input              clk, reset, 
                  input  [WIDTH-1:0] memdata, // the byte of the instruction we are processing
                  input              alusrca, memtoreg, iord, pcen, regwrite, regdst,
                  input  [1:0]       pcsource, alusrcb, 
                  input  [3:0]       irwrite, 
                  input  [2:0]       alucont, 
                  output             zero, 
                  output [31:0]      instr, 
                  output [WIDTH-1:0] adr, writedata);

   // the size of the parameters must be changed to match the WIDTH parameter
   localparam CONST_ZERO = 8'b0;
   localparam CONST_ONE =  8'b1;

   wire [REGBITS-1:0] ra1, ra2, wa;
	// 8-bit signals
   wire [WIDTH-1:0]   pc, nextpc, md, rd1, rd2, wd, a, src1, src2, aluresult,
                          aluout, constx4;

   // shift left constant field by 2 - turns addreses
   // into word addresses
   assign constx4 = {instr[WIDTH-3:0],2'b00};

   // register file address fields
   assign ra1 = instr[REGBITS+20:21];
   assign ra2 = instr[REGBITS+15:16];
	
								 // Choosing which part of instruction will be our reg destination.
								 // regdst is either 0 or 1
								 // regdst = 1 --> R-type
								 // regdst = 0 --> lb/sb/addi (I-type)
   mux2       #(REGBITS) regmux(instr[REGBITS+15:16], instr[REGBITS+10:11], regdst, wa);


   // Load instruction into four 8-bit registers over 4 cycles.
	// iwrite is 4-bits, only has bits on when in one of the first 4 fetch states.
   flopenr     #(8)      ir0(clk, reset, irwrite[0], memdata[7:0], instr[7:0]);
   flopenr     #(8)      ir1(clk, reset, irwrite[1], memdata[7:0], instr[15:8]);
   flopenr     #(8)      ir2(clk, reset, irwrite[2], memdata[7:0], instr[23:16]);
   flopenr     #(8)      ir3(clk, reset, irwrite[3], memdata[7:0], instr[31:24]);
	// Once we get through first 4 states we will have our 32-bit instruction.

   // datapath registers and muxes
   flopenr    #(WIDTH)  pcreg(clk, reset, pcen, nextpc, pc);
   flopr      #(WIDTH)  mdr(clk, reset, memdata, md);
   flopr      #(WIDTH)  areg(clk, reset, rd1, a);	      // This is what gives us rega: rd1 is coming from the regfile below.
   flopr      #(WIDTH)  wrd(clk, reset, rd2, writedata); // This gives us writedata: rd2 is coming from the regfile below.
								
								// On posedge of clock if not a reset, aluout = aluresult.
   flopr      #(WIDTH)  res(clk, reset, aluresult, aluout);
	
								// Choosing between pc and aluout: if iord = 0 -> choose pc o/w choose aluout as output address.
								// (we only set iord to 1 when we do a memory access in the controller)
	mux2       #(WIDTH)  adrmux(pc, aluout, iord, adr);
	
								// if alusrca = 0 -> we choose the PC, if alusrca = 1 -> we choose the value in rega.
	mux2       #(WIDTH)  src1mux(pc, a, alusrca, src1); 
                        
								
								// alusrcb is a 2-bit signal selecting src2.
								// STATES THAT THE FOUR PARAMS CORRESPOND TO:
								// writedata -> RTYPE, BEQX
								// CONST_ONE -> First 4 Fetch States (incrementing PC by a constant 1)
								// instr[WIDTH-1:0] -> Lb/Sb/Addi - Selecting the lower 8 bits representing the immediate value
								// constx4 -> DECODE state
	mux4       #(WIDTH)  src2mux(writedata, CONST_ONE, instr[WIDTH-1:0], 
                                constx4, alusrcb, src2);
										  
								// PC selection:
								// nextpc gets updated based on pcsource signal.
								// nextpc ultimately becomes the addr that is outputted and passed 
								// to the exmem module to get the value in memory at that address.
								// pcsource is set in controller and is 00 for all of the states except for:
								// BEQEX -> 01
								// JEX -> 10
   mux4       #(WIDTH)  pcmux(aluresult, aluout, constx4, CONST_ZERO, pcsource, nextpc);
	
   mux2       #(WIDTH)  wdmux(aluout, md, memtoreg, wd);

   // instantiate the register file, ALU, and zerodetect on the ALU output
	// ra1 and ra2 are register addresses that come from the instruction
	// wa is the write address
	// wd is the contents that is to be written to that register address (wa)
   regfile    #(WIDTH,REGBITS) rf(clk, regwrite, ra1, ra2, wa, wd, rd1, rd2);
	
	// ALU takes the two source operands and the alucont signal and returns the aluresult which is the result of the operation performed.
   alu        #(WIDTH) alunit(src1, src2, alucont, aluresult); 
	
   zerodetect #(WIDTH) zd(aluresult, zero);
endmodule