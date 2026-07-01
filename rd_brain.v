// --------------------------------------------------------------------
// Description : 
// function    : This module is an brain of read clk side 
//               it would decide fifo empty or not , counter increment,
//               binary to gray conversion 
// --------------------------------------------------------------------


`timescale 1ns / 1ps

module rd_brain #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  rclk,
    input  wire                  rrst_n,
    input  wire                  rinc,
    input  wire [ADDR_WIDTH:0]   rq2_wgray,

    output wire [ADDR_WIDTH-1:0] raddr,
    output reg  [ADDR_WIDTH:0]   rgray,
    output reg                   rempty
);

    // Internal binary write pointer
    reg  [ADDR_WIDTH:0] rbin;

    wire [ADDR_WIDTH:0] rbin_next;
    wire [ADDR_WIDTH:0] rgray_next;
    wire                rempty_next;

    assign raddr = rbin[ADDR_WIDTH-1:0];
    

    // Increment only when write request comes and FIFO is not full
    assign rbin_next = rbin + (rinc && !rempty);

    // Binary to Gray conversion
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;

    // Full detection using synchronized read Gray pointer
    assign rempty_next = (rgray_next == rq2_wgray);

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin   <= 0;
            rgray  <= 0;
            rempty <= 1;
        end
        else begin
            rbin   <= rbin_next;
            rgray  <= rgray_next;
            rempty <= rempty_next;
        end
    end

endmodule


// NOTE : we have considered two MSB bits of the pointer to check instead
//        of just MSB bit because we are checking using gray pointer not 
//        the binary pointer.