`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/06 14:58:27
// Design Name: 
// Module Name: counter
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


module counter(
    input wire clk,
    input wire reset,
    input wire trigger,
    output reg [3:0] count
);

always_ff @ (posedge clk or posedge reset) begin
    if (reset) begin
        count <= 4'b0;
    end else begin
        if (trigger && (count != 4'd15)) begin
            count <= count + 4'b1;
        end
    end
end

endmodule
