/*

This code is designed to work out an implementation of SPI for the core to access external memory.

NOTE: This code is designed for the M95M01. A 10 MHz clock is expected.

*/

`timescale 1ns/1ns
`default_nettype none

module SPI (
    
    );

    initial begin
        $dumpfile("SPI.vcd");
        $dumpvars(0,SPI);
        #100000 $finish;
    end

    reg clk = 0;

    always #50 clk = !clk;

    //Define instructions
    parameter WREN = 8'b00000110;
    parameter WRDI = 8'b00000100;
    parameter RDSR = 8'b00000101;
    parameter WRSR = 8'b00000001;
    parameter READ = 8'b00000011;
    parameter WRITE = 8'b00000010;

    //Define I/O
    reg SCK = 1;
    reg SI;
    reg SO = 0;
    reg nCS = 1;
    reg nWP = 0;
    reg nHOLD;

    //Define registers
    reg [7:0] SPI_CMD = READ;
    reg [39:0] SPI_BUF = {READ,24'b011010010001001001,8'b1111111};
    reg [31:0] SPI_IN = 0;

    //Define intermediates
    integer i = 0;
    //integer k = 0;
    reg STAGE = 0;

    always @(posedge clk) begin
        case (SPI_CMD)
            WREN : begin
                if (i < 9) begin
                    if (i == 0) begin
                        nCS <= 0;
                        i <= i + 1;
                    end
                    else begin
                        case (STAGE)
                            0 : begin
                                SO <= SPI_BUF[15];
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_BUF <= SPI_BUF << 1;
                            end
                        endcase
                    end
                end
                else begin
                    nCS <= 1;
                end
            end
            WRDI : begin
                if (i < 9) begin
                    if (i == 0) begin
                        nCS <= 0;
                        i <= i + 1;
                    end
                    else begin
                        case (STAGE)
                            0 : begin
                                SO <= SPI_BUF[15];
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_BUF <= SPI_BUF << 1;
                            end
                        endcase
                    end
                end
                else begin
                    nCS <= 1;
                end
            end
            RDSR : begin
                if (i < 24) begin
                    if (i == 0) begin
                        nCS <= 0;
                        i <= i + 1;
                    end
                    else if (i < 9) begin
                        case (STAGE)
                            0 : begin
                                SO <= SPI_BUF[15];
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_BUF <= SPI_BUF << 1;
                            end
                        endcase
                    end
                    else begin
                        case (STAGE)
                            0 : begin
                                SPI_IN[0] <= SI;
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_IN <= SPI_IN << 1;
                            end
                        endcase
                        i <= i + 1;
                    end
                end
                else begin
                    nCS <= 1;
                end
            end
            WRSR : begin
                if (i < 17) begin
                    if (i == 0) begin
                        nCS <= 0;
                        i <= i + 1;
                    end
                    else begin
                        case (STAGE)
                            0 : begin
                                SO <= SPI_BUF[15];
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_BUF <= SPI_BUF << 1;
                            end
                        endcase
                    end
                end
                else begin
                    nCS <= 1;
                end
            end
            READ : begin
                if (i < 101) begin
                    if (i == 0) begin
                        nCS <= 0;
                        i <= i + 1;
                    end
                    else if (i < 34) begin
                        case (STAGE)
                            0 : begin
                                SO <= SPI_BUF[39];
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_BUF <= SPI_BUF << 1;
                            end
                        endcase
                    end
                    else begin
                        case (STAGE)
                            0 : begin
                                SPI_IN[0] <= SI;
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_IN <= SPI_IN << 1;
                            end
                        endcase
                        i <= i + 1;
                    end
                end
                else begin
                    nCS <= 1;
                end
            end
            WRITE : begin
                if (i < 41) begin
                    if (i == 0) begin
                        nCS <= 0;
                        i <= i + 1;
                    end
                    else begin
                        case (STAGE)
                            0 : begin
                                SO <= SPI_BUF[39];
                                STAGE <= 1;
                            end
                            1 : begin
                                i <= i + 1;
                                STAGE <= 0;
                                SPI_BUF <= SPI_BUF << 1;
                            end
                        endcase
                    end
                end
                else begin
                    nCS <= 1;
                end
            end
            default : begin
            end
        endcase
        /*if (k < 9) begin
            if (k == 0) begin
                nCS <= 0;
                k <= k + 1;
            end
            else begin
                case (STAGE)
                    0 : begin
                        SO <= SPI_CMD[7];
                        STAGE <= 1;
                    end
                    1 : begin
                        k <= k + 1; 
                        STAGE <= 0;
                        SPI_CMD <= SPI_CMD << 1;
                    end
                endcase
            end
        end
        else begin
            nCS <= 1;
        end*/
    end
    always @(negedge clk) begin
        SCK <= !SCK;
    end
endmodule