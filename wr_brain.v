// --------------------------------------------------------------------
// Description : 
// function    : This module is an brain of write clk side 
//               it would decide fifo full or not , counter increment,
//               binary to gray conversion 
// --------------------------------------------------------------------


`timescale 1ns / 1ps

module wr_brain #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wclk,
    input  wire                  wrst_n,
    input  wire                  winc,
    input  wire [ADDR_WIDTH:0]   wq2_rgray,

    output wire [ADDR_WIDTH-1:0] waddr,
    output reg  [ADDR_WIDTH:0]   wgray,
    output reg                   wfull
);

    // Internal binary write pointer
    reg  [ADDR_WIDTH:0] wbin;

    wire [ADDR_WIDTH:0] wbin_next;
    wire [ADDR_WIDTH:0] wgray_next;
    wire                wfull_next;

    assign waddr = wbin[ADDR_WIDTH-1:0];
    

    // Increment only when write request comes and FIFO is not full
    assign wbin_next = wbin + (winc && !wfull);

    // Binary to Gray conversion
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;

    // Full detection using synchronized read Gray pointer
    assign wfull_next = (wgray_next == {~wq2_rgray[ADDR_WIDTH:ADDR_WIDTH-1],
                                         wq2_rgray[ADDR_WIDTH-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin  <= 0;
            wgray <= 0;
            wfull <= 0;
        end
        else begin
            wbin  <= wbin_next;
            wgray <= wgray_next;
            wfull <= wfull_next;
        end
    end

endmodule


// NOTE : we have considered two MSB bits of the pointer to check instead
//        of just MSB bit because we are checking using gray pointer not 
//        the binary pointer.