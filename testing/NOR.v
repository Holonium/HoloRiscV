/*

This code is designed for the design and testing of the interface for the flash memory.

It is designed to work with parallel NOR flash.

*/

`timescale 1ns/1ns
`default_nettype none

module NOR (

    );
    
    reg clk = 0;

    reg RDY_BSY; //Input
	reg nMEMRST = 0; //Output
	reg nBYTE = 0; //Output
	reg nCE = 1; //Output
	reg nWE; //Output
	reg nOE; //Output
	reg [26:0] ADDR; //Output
	reg [7:0] DATA; //Inout

    initial begin
        $dumpfile("NOR.vcd");
        $dumpvars(0,NOR);
        #500000 $finish;
    end
    
    always #10 clk = !clk;

    integer i = 0;
    reg [2:0] MEM_INIT = 0;

    always @(posedge clk) begin
        if (MEM_INIT == 0) begin
            if (i < 15000) begin
                i <= i + 1;
            end
            if (i == 15000) begin
                MEM_INIT <= 1;
                nMEMRST <= 1;
                i <= 0;
            end
        end
        else if (MEM_INIT == 1) begin
            if (i < 2) begin
                i <= i + 1;
            end
            if (i == 2) begin
                MEM_INIT <= 2;
                nCE <= 0;
                i <= 0;
            end
        end
        else if (MEM_INIT == 2) begin
            
        end
    end

endmodule