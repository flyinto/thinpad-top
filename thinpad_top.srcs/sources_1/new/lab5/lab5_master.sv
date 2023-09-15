module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,

    // TODO: 添加�?要的控制信号，例如按键开关？
    input wire [ADDR_WIDTH-1:0] dip_sw,

    // wishbone master
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o
);

  // TODO: 实现实验 5 的内�?+串口 Master
  typedef enum logic [3:0] {
    READ_WAIT_ACTION = 4'd0,
    READ_WAIT_CHECK = 4'd1,
    READ_DATA_ACTION = 4'd2,
    READ_DATA_DONE = 4'd3,
    WRITE_SRAM_ACTION = 4'd4,
    WRITE_SRAM_DONE = 4'd5,
    WRITE_WAIT_ACTION = 4'd6,
    WRITE_WAIT_CHECK = 4'd7,
    WRITE_DATA_ACTION = 4'd8,
    WRITE_DATA_DONE = 4'd9
  } state_t;
  
  state_t state;
  
  logic [ADDR_WIDTH-1:0] sram_addr;
  logic [7:0] uart_data;
  
  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
        sram_addr <= dip_sw;
        state <= READ_WAIT_ACTION;
        wb_cyc_o <= 1'b1;
        wb_stb_o <= 1'b1;
        wb_adr_o <= 32'h10000005;
        wb_sel_o <= 4'b0010;
        wb_dat_o <= 32'b0;
        wb_we_o <= 1'b0;
    end else begin
        case (state)
            READ_WAIT_ACTION: begin
            //    if (wb_ack_i == 1'b1) begin
                    state <= READ_WAIT_CHECK;
            //    end
            end
            
            READ_WAIT_CHECK: begin
                if (wb_dat_i[8] == 1'b0) begin
                    state <= READ_WAIT_ACTION;
                    wb_adr_o <= 32'h10000005;
                    wb_sel_o <= 4'b0010;
                end else begin
                    state <= READ_DATA_ACTION;
                    wb_adr_o <= 32'h10000000;
                    wb_sel_o <= 4'b0001;
                end
            end
            
            READ_DATA_ACTION: begin
            //    if (wb_ack_i == 1'b1) begin
                    state <= READ_DATA_DONE;
                    uart_data <= wb_dat_i[7:0];
                 //   wb_cyc_o <= 1'b0;
                 //   wb_stb_o <= 1'b0;
            //    end
            end
            
            READ_DATA_DONE: begin
                state <= WRITE_SRAM_ACTION;
                wb_cyc_o <= 1'b1;
                wb_stb_o <= 1'b1;
                wb_dat_o <= {{24{1'bz}}, uart_data};
                wb_adr_o <= sram_addr;
                wb_sel_o <= 4'b0001;
                wb_we_o <= 1'b1;
            end
            
            WRITE_SRAM_ACTION: begin
                if (wb_ack_i == 1'b1) begin
                    state <= WRITE_SRAM_DONE;
                    sram_addr <= sram_addr + 32'd4;
                //    wb_cyc_o <= 1'b0;
                //    wb_stb_o <= 1'b0;
                    wb_we_o <= 1'b0;
                end
            end
            
            WRITE_SRAM_DONE: begin
                state <= WRITE_WAIT_ACTION;
                wb_cyc_o <= 1'b1;
                wb_stb_o <= 1'b1;
                wb_adr_o <= 32'h10000005;
                wb_sel_o <= 4'b0010;
            end
            
            WRITE_WAIT_ACTION: begin
            //    if (wb_ack_i == 1'b1) begin
                    state <= WRITE_WAIT_CHECK;
            //    end
            end
            
            WRITE_WAIT_CHECK: begin
                if (wb_dat_i[13] == 1'b0) begin
                    state <= WRITE_WAIT_ACTION;
                    wb_adr_o <= 32'h10000005;
                    wb_sel_o <= 4'b0010;
                end else begin
                    state <= WRITE_DATA_ACTION;
                    wb_adr_o <= 32'h10000000;
                    wb_sel_o <= 4'b0001;
                    wb_dat_o <= {{24{1'bz}}, uart_data};
                    wb_we_o <= 1'b1;
                end
            end
            
            WRITE_DATA_ACTION: begin
            //    if (wb_ack_i == 1'b1) begin
                    state <= WRITE_DATA_DONE;
                 //   wb_cyc_o <= 1'b0;
                 //   wb_stb_o <= 1'b0;
                    wb_we_o <= 1'b0;
            //    end
            end
            
            WRITE_DATA_DONE: begin
                state <= READ_WAIT_ACTION;
                wb_cyc_o <= 1'b1;
                wb_stb_o <= 1'b1;
                wb_adr_o <= 32'h10000004;
                wb_sel_o <= 4'b0010;
                wb_dat_o <= 32'b0;
                wb_we_o <= 1'b0;
            end
        endcase
    end
  end

endmodule
