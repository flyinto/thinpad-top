module sram_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output reg [SRAM_ADDR_WIDTH-1:0] sram_addr,
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,
    output reg sram_ce_n,
    output reg sram_oe_n,
    output reg sram_we_n,
    output reg [SRAM_BYTES-1:0] sram_be_n
);

  // TODO: 实现 SRAM 控制�?
  typedef enum logic [2:0] {
    STATE_IDLE = 3'd0,
    STATE_READ = 3'd1,
    STATE_READ_2 = 3'd2,
    STATE_WRITE = 3'd3,
    STATE_WRITE_2 = 3'd4,
    STATE_WRITE_3 = 3'd5,
    STATE_DONE = 3'd6
  } state_t;
  
  state_t state;
  
  wire [31:0] sram_data_i_comb;
  reg [31:0] sram_data_o_comb;
  reg sram_data_t_comb;
    
  assign sram_data = sram_data_t_comb ? 32'bz : sram_data_o_comb;
  assign sram_data_i_comb = sram_data;
  
  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
        sram_ce_n <= 1'b1;
        sram_oe_n <= 1'b1;
        sram_we_n <= 1'b1;
    end else begin
        case (state)
            STATE_IDLE: begin
                sram_addr <= (wb_adr_i >> 2);
                sram_ce_n <= 1'b0;
                sram_we_n <= 1'b1;
                if (wb_stb_i && wb_cyc_i) begin
                    if (!wb_we_i) begin
                        sram_oe_n <= 1'b0;
                        sram_be_n <= 4'b0000;
                        sram_data_t_comb <= 1'b1;
                        state <= STATE_READ;
                    end else begin
                        sram_oe_n <= 1'b1;
                        sram_be_n <= ~wb_sel_i;
                        sram_data_t_comb <= 1'b0;
                        sram_data_o_comb <= wb_dat_i;
                        state <= STATE_WRITE;
                    end
                end
            end
            
            STATE_READ: begin
                wb_dat_o <= sram_data_i_comb;
                state <= STATE_READ_2;
            end
            
            STATE_READ_2: begin
                sram_ce_n <= 1'b1;
                sram_oe_n <= 1'b1;
                sram_we_n <= 1'b1;
                wb_ack_o <= 1'b1;
                state <= STATE_DONE;
            end
            
            STATE_WRITE: begin
                sram_we_n <= 1'b0;
                state <= STATE_WRITE_2;
            end
            
            STATE_WRITE_2: begin
                sram_we_n <= 1'b1;
                state <= STATE_WRITE_3;
            end
            
            STATE_WRITE_3: begin
                sram_ce_n <= 1'b1;
                sram_oe_n <= 1'b1;
                sram_we_n <= 1'b1;
                wb_ack_o <= 1'b1;
                state <= STATE_DONE;
            end
            
            STATE_DONE: begin
                wb_ack_o <= 1'b0;
                state <= STATE_IDLE;
            end
        endcase
    end
  end

endmodule
