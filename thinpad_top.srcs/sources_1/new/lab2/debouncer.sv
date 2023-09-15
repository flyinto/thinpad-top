`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/06 15:14:16
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input wire clk,
    input wire reset,
    input wire push,
    output wire debounced
);

reg last_push_1;
reg last_push_2;

always_ff @ (posedge clk or posedge reset) begin
    if (reset) begin
        last_push_1 <= 1'b0;
        last_push_2 <= 1'b0;
    end else begin
        last_push_1 <= push;
        last_push_2 <= last_push_1;
    end
end

assign debounced = last_push_1 && (!last_push_2);

endmodule
