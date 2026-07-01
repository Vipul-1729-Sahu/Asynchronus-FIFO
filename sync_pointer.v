// ------------------------------------------------------------------
// Description  :
// module name  : sync_pointer
// function     : It's used to synchronize the pointer 
//                while sending write pointer to read clk domain and
//                while sending read pointer to write clk domain
// pointer type : Gray pointer is used to send across clk domains 
//                for better data coherency
// ------------------------------------------------------------------

`timescale 1ns / 1ps

module sync_pointer #(
    parameter PTR_WIDTH = 5
)(
    input                      clk,
    input                      rst_n,
    input      [PTR_WIDTH-1:0] async_ptr,
    output reg [PTR_WIDTH-1:0] sync_ptr
);

    reg [PTR_WIDTH-1:0] ptr_temp;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ptr_temp <= 0;
            sync_ptr <= 0;
        end
        else begin
            ptr_temp <= async_ptr;
            sync_ptr <= ptr_temp;
        end
    end
    
endmodule
