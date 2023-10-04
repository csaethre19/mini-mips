module mux4 #(parameter WIDTH = 8)
             (input      [WIDTH-1:0] d0, d1, d2, d3,
              input      [1:0]       s, 
              output reg [WIDTH-1:0] y);

   always @(*)
      case(s)
         2'b00: y <= d0; // For src2 mux: used for RTYPE and BEQ states output logic           (ALUSRCb=00)
         2'b01: y <= d1; // For src2 mux: First four FETCH states (PC)                         (ALUSRCb=01)
         2'b10: y <= d2; // For src2 mux: used for lb/sb/addi - selecting the immediate value  (ALUSRCb=10)
         2'b11: y <= d3; // For src2 mux: used for DECODE state output logic                   (ALUSRCb=11)
      endcase
endmodule
