// ----------------------------------------------------
// Description : 
// Module Name : fifo_mem
// function    : It's an main fifo memory module
// ----------------------------------------------------
`timescale 1ns / 1ps

module fifo_mem #( 
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    // write ports
    input                       wclk,
    input                       wclk_en,
    input  [DATA_WIDTH-1:0]     wdata,
    input  [ADDR_WIDTH-1:0]     waddr,
    
    // read ports
    input                       rclk,
    input                       rclk_en,
    input      [ADDR_WIDTH-1:0] raddr,
    output reg [DATA_WIDTH-1:0] rdata
);

     // DEPTH = 2^ADDR_WIDTH
     localparam DEPTH = (1 << ADDR_WIDTH);
     
     
     // internal memory
     reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
     
     
     // write 
     always @(posedge wclk) begin
        if (wclk_en)
            mem[waddr] <= wdata;
     end
     
     // read
     always @(posedge rclk) begin
        if (rclk_en)
            rdata <= mem[raddr];
     end

endmodule
