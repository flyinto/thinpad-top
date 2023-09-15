`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/08 20:48:55
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [3:0] op,
    output reg [15:0] y
);

  logic [3:0] shift_b;
  
  always_comb begin
    shift_b = b[3:0];
    case (op)
        4'b0001: begin
            y = a + b;
        end
        4'b0010: begin
            y = a - b;
        end
        4'b0011: begin
            y = a & b;
        end
        4'b0100: begin
            y = a | b;
        end
        4'b0101: begin
            y = a ^ b;
        end
        4'b0110: begin
            y = ~ a;
        end
        4'b0111: begin
            y = a << shift_b;
        end
        4'b1000: begin
            y = a >> shift_b;
        end
        4'b1001: begin
            y = signed'(a) >>> shift_b;
        end
        4'b1010: begin
            y = (a << shift_b) | (a >> (4'd15 - shift_b + 4'd1));
        end
        default: begin
            y = 16'd0;
        end
    endcase
  end
  
endmodule
