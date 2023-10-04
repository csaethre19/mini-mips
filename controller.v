// Controller is the main finite state machine that interprets 
// instructions and executes them. 
module controller(input            clk, reset, 
                  input      [5:0] op, 
                  input            zero, 
                  output reg       memwrite, alusrca, memtoreg, iord, 
                  output           pcen, 
                  output reg       regwrite, regdst, 
                  output reg [1:0] pcsource, alusrcb, aluop, 
                  output reg [3:0] irwrite);

	// Paramaters used for state names allows for easy 
	// changing of state encodings
	
	// Four states associated with fetching the instruction.
	// Each instruction is 32-bits and we load one byte at a time -> 4 x 8 = 32 bits
   parameter   FETCH1  =  4'b0000; // loading first byte of instruction
   parameter   FETCH2  =  4'b0010; // loading second byte of instruction
   parameter   FETCH3  =  4'b0011; // loading third byte of instruction
   parameter   FETCH4  =  4'b0100; // loading fourth byte of instruction
   parameter   DECODE  =  4'b0101; // decode the instruction
   parameter   MEMADR  =  4'b0110; // memory address computation state
   parameter   LBRD    =  4'b0111; // load-byte instruction state for reading
   parameter   LBWR    =  4'b1000; // load-byte instructino state for writing
   parameter   SBWR    =  4'b1001; // store-byte instruction state for writing
   parameter   RTYPEEX =  4'b1010; // execute r-type instruction state
   parameter   RTYPEWR =  4'b1011; // write what was executed r-type instruction state
   parameter   BEQEX   =  4'b1100; // branch if equal instruction state
   parameter   JEX     =  4'b1101; // jump instruction state
	parameter   ADDIEX  =  4'b0001; // ADDI execution instruction state
	parameter   ADDIWR  =  4'b1111; // ADDI write instruction state

	
	// parameters used for instruction types 
   parameter   LB      =  6'b100000;
   parameter   SB      =  6'b101000;
   parameter   RTYPE   =  6'b0;
   parameter   BEQ     =  6'b000100;
   parameter   J       =  6'b000010;
	parameter   AI      =  6'b001000; // Added parameter for ADDI instruction type

   reg [3:0] state, nextstate;       // state register and nextstate value
   reg       pcwrite, pcwritecond;   // Write to the PC? 

   // state register
   always @(posedge clk)
      if(~reset) state <= FETCH1;
      else state <= nextstate;

   // next state logic (Combinational) 
   always @(*)
      begin
         case(state)
            FETCH1:  nextstate <= FETCH2;
            FETCH2:  nextstate <= FETCH3;
            FETCH3:  nextstate <= FETCH4;
            FETCH4:  nextstate <= DECODE;
            DECODE:  case(op) // op is the top 6-bits of instruction and represents the type of instruction (L, R, I)
                        // Setting nextstate based on instruction type:
								LB:      nextstate <= MEMADR;
                        SB:      nextstate <= MEMADR;
                        RTYPE:   nextstate <= RTYPEEX;
                        BEQ:     nextstate <= BEQEX;
                        J:       nextstate <= JEX;
								AI:      nextstate <= ADDIEX;  // Added nextstate is ADDIEX when op == AI
                        default: nextstate <= FETCH1; //  should never happen
                     endcase
            MEMADR:  case(op)
                        LB:      nextstate <= LBRD;
                        SB:      nextstate <= SBWR;
                        default: nextstate <= FETCH1; // should never happen
                     endcase
            LBRD:    nextstate <= LBWR;
            LBWR:    nextstate <= FETCH1;
            SBWR:    nextstate <= FETCH1;
            RTYPEEX: nextstate <= RTYPEWR;
            RTYPEWR: nextstate <= FETCH1;
            BEQEX:   nextstate <= FETCH1;
            JEX:     nextstate <= FETCH1;
				ADDIEX:  nextstate <= ADDIWR; // When in ADDIEX state -> go to ADDWR next
				ADDIWR:  nextstate <= FETCH1;
            default: nextstate <= FETCH1; // should never happen
         endcase
      end

	// This combinational block generates the outputs from each state. 
   always @(*)
      begin
            // set all outputs to zero, then conditionally assert just the appropriate ones
            irwrite <= 4'b0000;
            pcwrite <= 0; pcwritecond <= 0;
            regwrite <= 0; regdst <= 0;
            memwrite <= 0;
            alusrca <= 0; alusrcb <= 2'b00; aluop <= 2'b00;
            pcsource <= 2'b00;
            iord <= 0; memtoreg <= 0;
				
            case(state)
               FETCH1: 
                  begin
                     irwrite <= 4'b0001; // change to reflect new memory ordering
                     alusrcb <= 2'b01;   // get the IR bits in the right spots
                     pcwrite <= 1;       // FETCH 2,3,4 also changed... 
                  end
               FETCH2: 
                  begin
                     irwrite <= 4'b0010;
                     alusrcb <= 2'b01;
                     pcwrite <= 1;
                  end
               FETCH3:
                  begin
                     irwrite <= 4'b0100;
                     alusrcb <= 2'b01;
                     pcwrite <= 1;
                  end
               FETCH4:
                  begin
                     irwrite <= 4'b1000;
                     alusrcb <= 2'b01;
                     pcwrite <= 1;
                  end
               DECODE: alusrcb <= 2'b11;
               MEMADR:
                  begin
                     alusrca <= 1;
                     alusrcb <= 2'b10;
                  end
               LBRD:
                  begin
                     iord    <= 1;
                  end
               LBWR:
                  begin
                     regwrite <= 1;
                     memtoreg <= 1;
                  end
               SBWR:
                  begin
                     memwrite <= 1;
                     iord     <= 1;
                  end
               RTYPEEX: 
                  begin
                     alusrca <= 1;
                     aluop   <= 2'b10;
                  end
               RTYPEWR:
                  begin
                     regdst   <= 1;
                     regwrite <= 1;
                  end
               BEQEX:
                  begin
                     alusrca     <= 1;
                     aluop       <= 2'b01;
                     pcwritecond <= 1;
                     pcsource    <= 2'b01;
                  end
               JEX:
                  begin
                     pcwrite  <= 1;
                     pcsource <= 2'b10;
                  end
					ADDIEX: // ALUSrcA should be enabled to select the first register contents over the PC
							  // ALUSrcB should be set to 10 to select the immediate value of the instruction 
						begin
							alusrca   <= 1;
							alusrcb   <= 2'b10;
						end
					ADDIWR:
						begin
							regwrite <= 1;
						end
         endcase
      end
   assign pcen = pcwrite | (pcwritecond & zero); // program counter enable
endmodule