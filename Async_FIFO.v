// ------------------------------------------------------------------
// Description : 
// Function    :  This is an Top Module 
//                Here all the interconnections between different 
//                modules are manages
// ------------------------------------------------------------------
 
`timescale 1ns / 1ps

module Async_FIFO #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 4
)(
    input                  wclk,
    input                  wrst_n,
    input                  winc,
    input [DATA_WIDTH-1:0] wdata,
    output                 wfull,
    
    input                  rclk,
    input                  rrst_n,
    input                  rinc,
    output[DATA_WIDTH-1:0] rdata,
    output                 rempty            
);
  
    // FIFO MEMORY INSTANTIATION    
    wire wclk_en;
    wire rclk_en;
    
    wire [ADDR_WIDTH-1:0] waddr;
    wire [ADDR_WIDTH-1:0] raddr;
    
    assign wclk_en = (winc && !wfull);
    assign rclk_en = (rinc && !rempty);


    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) FIFO (
        .wclk    (wclk),
        .wclk_en (wclk_en),
        .wdata   (wdata),
        .waddr   (waddr),
        
        .rclk    (rclk),
        .rclk_en (rclk_en),
        .raddr   (raddr),
        .rdata   (rdata)
    );
    
    
    // Write side & Read side Brain instantiation
    wire [ADDR_WIDTH:0] wq2_rgray;
    wire [ADDR_WIDTH:0] rq2_wgray;
    
    wire [ADDR_WIDTH:0] wgray;
    wire [ADDR_WIDTH:0] rgray;
    
    
    wr_brain #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) WRITE (
        .wclk      (wclk),
        .wrst_n    (wrst_n),
        .winc      (winc),
        .wq2_rgray (wq2_rgray),
        .waddr     (waddr),
        .wgray     (wgray),
        .wfull     (wfull)
    );  
    
    rd_brain #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) READ (
        .rclk      (rclk),
        .rrst_n    (rrst_n),
        .rinc      (rinc),
        .rq2_wgray (rq2_wgray),
        .raddr     (raddr),
        .rgray     (rgray),
        .rempty    (rempty)
    ); 
    
    
    // 2 Flop synchronizer instantiation for Read & Write pointer    
    sync_pointer #(
        .PTR_WIDTH(ADDR_WIDTH + 1)
    ) WR_PTR (
        .clk       (rclk),
        .rst_n     (rrst_n),
        .async_ptr (wgray),
        .sync_ptr  (rq2_wgray)
    );
    
    sync_pointer #(
        .PTR_WIDTH(ADDR_WIDTH + 1)
    ) RD_PTR (
        .clk       (wclk),
        .rst_n     (wrst_n),
        .async_ptr (rgray),
        .sync_ptr  (wq2_rgray)
    );
    

endmodule
