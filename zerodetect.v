// detect all 0's on the ALU output. 
module zerodetect #(parameter WIDTH = 8)
                   (input [WIDTH-1:0] a, 
                    output            y);
   assign y = (a==0);
endmodule	