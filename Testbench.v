// ------------------------------------------------------
// Description :
// This is an testbench module to test Asynchronus FIFO
// ------------------------------------------------------

`timescale 1ns / 1ps

module Testbench();

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;
    localparam DEPTH      = (1 << ADDR_WIDTH);

    reg rclk;
    reg wclk;
    
    reg rrst_n;
    reg wrst_n;
    
    reg rinc;
    reg winc;
    
    reg  [DATA_WIDTH-1:0] wdata;
    wire [DATA_WIDTH-1:0] rdata;
    
    wire wfull;
    wire rempty;
    
    // Asynchronus FIFO module Instantiation
    Async_FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .rclk   (rclk),
        .rrst_n (rrst_n),
        .rinc   (rinc),
        .rdata  (rdata),
        .rempty (rempty),
        
        .wclk   (wclk),
        .wrst_n (wrst_n),
        .winc   (winc),
        .wdata  (wdata),
        .wfull  (wfull)
    );
    
    
    // Read and Write Clock Generation
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end
    
    initial begin
        rclk = 0;
        forever #7 rclk = ~rclk;
    end
    
     

    // Write task
    task write_fifo;
        input [DATA_WIDTH-1:0] data_in;
        begin
            @(negedge wclk);
            if (!wfull) begin
                winc  = 1'b1;
                wdata = data_in;
            end
            else begin
                winc  = 1'b0;
                $display("[%0t] WRITE BLOCKED: FIFO FULL", $time);
            end

            @(negedge wclk);
            winc = 1'b0;
        end
    endtask

    // Read task for synchronous read FIFO
    integer i;
    integer error_count;
    
    task read_fifo;
        input [DATA_WIDTH-1:0] expected_data;
        begin
            // Wait until FIFO is not empty
            wait (!rempty);

            @(negedge rclk);
            rinc = 1'b1;

            // Data updates on read clock edge
            @(posedge rclk);
            #1;

            if (rdata !== expected_data) begin
                $display("[%0t] ERROR: Expected = %0h, Got = %0h",
                          $time, expected_data, rdata);
                error_count = error_count + 1;
            end
            else begin
                $display("[%0t] PASS: Read Data = %0h", $time, rdata);
            end

            @(negedge rclk);
            rinc = 1'b0;
        end
    endtask
    
    
        initial begin
        wrst_n = 1'b0;
        rrst_n = 1'b0;
        winc   = 1'b0;
        rinc   = 1'b0;
        wdata  = {DATA_WIDTH{1'b0}};
        error_count = 0;

        // Reset
        #30;
        wrst_n = 1'b1;
        rrst_n = 1'b1;

        #40;


        // TEST 1: Reset Check
        $display("TEST 1: Reset Check");

        if (rempty !== 1'b1) begin
            $display("[%0t] ERROR: FIFO should be empty after reset", $time);
            error_count = error_count + 1;
        end
        else begin
            $display("[%0t] PASS: FIFO empty after reset", $time);
        end

        if (wfull !== 1'b0) begin
            $display("[%0t] ERROR: FIFO should not be full after reset", $time);
            error_count = error_count + 1;
        end
        else begin
            $display("[%0t] PASS: FIFO not full after reset", $time);
        end

        
        // TEST 2: Write 4 values and read them back
        $display("TEST 2: Write 4 values and read them back");

        write_fifo(8'hA1);
        write_fifo(8'hB2);
        write_fifo(8'hC3);
        write_fifo(8'hD4);

        // Wait for write Gray pointer to synchronize into read domain
        repeat (5) @(posedge rclk);

        read_fifo(8'hA1);
        read_fifo(8'hB2);
        read_fifo(8'hC3);
        read_fifo(8'hD4);

        repeat (5) @(posedge rclk);

        if (rempty !== 1'b1) begin
            $display("[%0t] ERROR: FIFO should be empty after reading all 4 values", $time);
            error_count = error_count + 1;
        end
        else begin
            $display("[%0t] PASS: FIFO empty after reading all 4 values", $time);
        end

        
        // TEST 3: Fill FIFO and check full flag
        $display("TEST 3: Fill FIFO and check full flag");

        for (i = 0; i < DEPTH; i = i + 1) begin
            write_fifo(i + 8'h10);
        end

        repeat (4) @(posedge wclk);

        if (wfull !== 1'b1) begin
            $display("[%0t] ERROR: FIFO should be full", $time);
            error_count = error_count + 1;
        end
        else begin
            $display("[%0t] PASS: FIFO full detected", $time);
        end

        // Try one extra write
        write_fifo(8'hFF);

  
        // TEST 4: Drain FIFO and check empty flag
        $display("TEST 4: Drain FIFO and check empty flag");

        // Wait for write pointer to synchronize into read domain
        repeat (5) @(posedge rclk);

        for (i = 0; i < DEPTH; i = i + 1) begin
            read_fifo(i + 8'h10);
        end

        repeat (5) @(posedge rclk);

        if (rempty !== 1'b1) begin
            $display("[%0t] ERROR: FIFO should be empty after draining", $time);
            error_count = error_count + 1;
        end
        else begin
            $display("[%0t] PASS: FIFO empty detected after draining", $time);
        end

        // Try one extra read
        @(negedge rclk);
        if (rempty) begin
            rinc = 1'b1;
            $display("[%0t] READ ATTEMPTED BUT FIFO EMPTY", $time);
        end

        @(negedge rclk);
        rinc = 1'b0;


        #100;
        $finish;
    end

    

endmodule















































