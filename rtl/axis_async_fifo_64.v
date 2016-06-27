/*

Copyright (c) 2014-2016 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4-Stream asynchronous FIFO (64 bit datapath)
 */
module axis_async_fifo_64 #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(
    /*
     * Common asynchronous reset
     */
    input  wire                   async_rst,

    /*
     * AXI input
     */
    input  wire                   input_clk,
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_axis_tkeep,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,
    
    /*
     * AXI output
     */
    input  wire                   output_clk,
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_axis_tkeep,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser
);

reg [ADDR_WIDTH:0] wr_ptr_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [ADDR_WIDTH:0] wr_ptr_gray_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_gray_next;
reg [ADDR_WIDTH:0] rd_ptr_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [ADDR_WIDTH:0] rd_ptr_gray_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_gray_next;

reg [ADDR_WIDTH:0] wr_ptr_gray_sync1_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_gray_sync2_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync2_reg = {ADDR_WIDTH+1{1'b0}};

reg input_rst_sync1_reg = 1'b1;
reg input_rst_sync2_reg = 1'b1;
reg input_rst_sync3_reg = 1'b1;
reg output_rst_sync1_reg = 1'b1;
reg output_rst_sync2_reg = 1'b1;
reg output_rst_sync3_reg = 1'b1;

reg [DATA_WIDTH+KEEP_WIDTH+2-1:0] mem[(2**ADDR_WIDTH)-1:0];
reg [DATA_WIDTH+KEEP_WIDTH+2-1:0] mem_read_data_reg = {DATA_WIDTH+2{1'b0}};
wire [DATA_WIDTH+KEEP_WIDTH+2-1:0] mem_write_data;

reg output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;

// full when first TWO MSBs do NOT match, but rest matches
// (gray code equivalent of first MSB different but rest same)
wire full = ((wr_ptr_gray_reg[ADDR_WIDTH] != rd_ptr_gray_sync2_reg[ADDR_WIDTH]) &&
             (wr_ptr_gray_reg[ADDR_WIDTH-1] != rd_ptr_gray_sync2_reg[ADDR_WIDTH-1]) &&
             (wr_ptr_gray_reg[ADDR_WIDTH-2:0] == rd_ptr_gray_sync2_reg[ADDR_WIDTH-2:0]));
// empty when pointers match exactly
wire empty = rd_ptr_gray_reg == wr_ptr_gray_sync2_reg;

// control signals
reg write;
reg read;

assign input_axis_tready = ~full & ~input_rst_sync3_reg;

assign output_axis_tvalid = output_axis_tvalid_reg;

assign mem_write_data = {input_axis_tlast, input_axis_tuser, input_axis_tkeep, input_axis_tdata};
assign {output_axis_tlast, output_axis_tuser, output_axis_tkeep, output_axis_tdata} = mem_read_data_reg;

// reset synchronization
always @(posedge input_clk or posedge async_rst) begin
    if (async_rst) begin
        input_rst_sync1_reg <= 1'b1;
        input_rst_sync2_reg <= 1'b1;
        input_rst_sync3_reg <= 1'b1;
    end else begin
        input_rst_sync1_reg <= 1'b0;
        input_rst_sync2_reg <= input_rst_sync1_reg | output_rst_sync1_reg;
        input_rst_sync3_reg <= input_rst_sync2_reg;
    end
end

always @(posedge output_clk or posedge async_rst) begin
    if (async_rst) begin
        output_rst_sync1_reg <= 1'b1;
        output_rst_sync2_reg <= 1'b1;
        output_rst_sync3_reg <= 1'b1;
    end else begin
        output_rst_sync1_reg <= 1'b0;
        output_rst_sync2_reg <= output_rst_sync1_reg;
        output_rst_sync3_reg <= output_rst_sync2_reg;
    end
end

// Write logic
always @* begin
    write = 1'b0;

    wr_ptr_next = wr_ptr_reg;
    wr_ptr_gray_next = wr_ptr_gray_reg;

    if (input_axis_tvalid) begin
        // input data valid
        if (~full) begin
            // not full, perform write
            write = 1'b1;
            wr_ptr_next = wr_ptr_reg + 1;
            wr_ptr_gray_next = wr_ptr_next ^ (wr_ptr_next >> 1);
        end
    end
end

always @(posedge input_clk) begin
    if (input_rst_sync3_reg) begin
        wr_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_reg <= wr_ptr_next;
        wr_ptr_gray_reg <= wr_ptr_gray_next;
    end

    if (write) begin
        mem[wr_ptr_reg[ADDR_WIDTH-1:0]] <= mem_write_data;
    end
end

// pointer synchronization
always @(posedge input_clk) begin
    if (input_rst_sync3_reg) begin
        rd_ptr_gray_sync1_reg <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_sync2_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        rd_ptr_gray_sync1_reg <= rd_ptr_gray_reg;
        rd_ptr_gray_sync2_reg <= rd_ptr_gray_sync1_reg;
    end
end

always @(posedge output_clk) begin
    if (output_rst_sync3_reg) begin
        wr_ptr_gray_sync1_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_sync2_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_gray_sync1_reg <= wr_ptr_gray_reg;
        wr_ptr_gray_sync2_reg <= wr_ptr_gray_sync1_reg;
    end
end

// Read logic
always @* begin
    read = 1'b0;

    rd_ptr_next = rd_ptr_reg;
    rd_ptr_gray_next = rd_ptr_gray_reg;

    output_axis_tvalid_next = output_axis_tvalid_reg;

    if (output_axis_tready | ~output_axis_tvalid) begin
        // output data not valid OR currently being transferred
        if (~empty) begin
            // not empty, perform read
            read = 1'b1;
            output_axis_tvalid_next = 1'b1;
            rd_ptr_next = rd_ptr_reg + 1;
            rd_ptr_gray_next = rd_ptr_next ^ (rd_ptr_next >> 1);
        end else begin
            output_axis_tvalid_next = 1'b0;
        end
    end
end

always @(posedge output_clk) begin
    if (output_rst_sync3_reg) begin
        rd_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_reg <= {ADDR_WIDTH+1{1'b0}};
        output_axis_tvalid_reg <= 1'b0;
    end else begin
        rd_ptr_reg <= rd_ptr_next;
        rd_ptr_gray_reg <= rd_ptr_gray_next;
        output_axis_tvalid_reg <= output_axis_tvalid_next;
    end

    if (read) begin
        mem_read_data_reg <= mem[rd_ptr_reg[ADDR_WIDTH-1:0]];
    end
end

endmodule
