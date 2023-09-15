`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/09 15:51:16
// Design Name: 
// Module Name: regFiles
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


module regFiles(
    input wire clk,
    
    input wire [4:0] raddr_a,
    input wire [4:0] raddr_b,
    output reg [15:0] rdata_a,
    output reg [15:0] rdata_b,
    
    input wire [4:0] waddr,
    input wire [15:0] wdata,
    input wire we
    );
    
  reg [15:0] regs [1:31];
  
  always_comb begin
    if (raddr_a == 5'b00000) begin
      rdata_a = 16'b0;
    end else begin
      rdata_a = regs[raddr_a];
    end
  end
  
  always_comb begin
    if (raddr_b == 5'b00000) begin
      rdata_b = 16'b0;
    end else begin
      rdata_b = regs[raddr_b];
    end
  end
  
  always_ff @ (posedge clk) begin
    if ((we == 1'b1) && (waddr != 5'b00000)) begin
      regs[waddr] <= wdata;
    end
  end
  
endmodule
