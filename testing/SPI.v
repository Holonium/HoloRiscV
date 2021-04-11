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

    always #100 clk = !clk;

    //Define instructions
    parameter WREN = 8'b00000110;
    parameter WRDI = 8'b00000100;
    parameter RDSR = 8'b00000101;
    parameter WRSR = 8'b00000001;
    parameter READ = 8'b00000011;
    parameter WRITE = 8'b00000010;

    //Define I/O
    reg SCK = 0;
    reg SI = 0;
    reg SO;
    reg nCS1 = 1;
    reg nCS2 = 1;
    reg nWP1 = 0;
    reg nWP2 = 0;
    reg nHOLD1;
    reg nHOLD2;

    //Define registers
    reg SPI_IN;
    reg SPI_OUT = 1'b0;
    reg [7:0] SPI_CMD = WRITE;
    reg [7:0] DOUT = 8'b10010101;

    //Define intermediates
    reg [23:0] SPI_ADDR = 9003910;
    reg [4:0] ADDR_BIT = 23;
    reg [31:0] CMD;
    reg [5:0] BIT = 0;
    reg [5:0] CYCLE = 0;
    reg [2:0] PHASE = 0;
    reg SCYCLE = 0;

    always @(posedge clk) begin
        case (CYCLE)
            0 : begin
                nCS1 <= 0;
                CYCLE <= 1;
            end
            1 : begin
                case (SCYCLE)
                    0 : begin
                        SCK <= !SCK;
                        SCYCLE <= 1;
                    end
                    1 : begin
                        SCK <= !SCK;
                        case (BIT)
                            0 : begin
                               SO <= SPI_CMD[7];
                               BIT <= 1; 
                            end
                            1 : begin
                                SO <= SPI_CMD[6];
                                BIT <= 2;
                            end
                            2 : begin
                                SO <= SPI_CMD[5];
                                BIT <= 3;
                            end
                            3 : begin
                                SO <= SPI_CMD[4];
                                BIT <= 4;
                            end
                            4 : begin
                                SO <= SPI_CMD[3];
                                BIT <= 5;
                            end
                            5 : begin
                                SO <= SPI_CMD[2];
                                BIT <= 6;
                            end
                            6 : begin
                                SO <= SPI_CMD[1];
                                BIT <= 7;
                            end
                            7 : begin
                                SO <= SPI_CMD[0];
                                BIT <= 0;
                                CYCLE <= 2;
                            end
                            default : begin
                            end
                        endcase
                        SCYCLE <= 0;
                    end
                endcase
            end
            2 : begin
                case (SPI_CMD)
                    WREN : begin
                        nCS1 <= 1;
                        CYCLE <= 0;
                    end
                    WRDI : begin
                        nCS1 <= 1;
                        CYCLE <= 0;
                    end
                    RDSR : begin
                        
                    end
                    WRSR : begin
                        
                    end
                    READ : begin
                        case (SCYCLE)
                            0 : begin
                                SCK <= !SCK;
                                SCYCLE <= 1;
                            end
                            1 : begin
                                SCK <= !SCK;
                                SI <= !SI;
                                case (PHASE)
                                    0 : begin
                                        case (BIT)
                                            0 : begin
                                                SO <= SPI_ADDR[23];
                                                BIT <= 1;
                                            end
                                            1 : begin
                                                SO <= SPI_ADDR[22];
                                                BIT <= 2;
                                            end
                                            2 : begin
                                                SO <= SPI_ADDR[21];
                                                BIT <= 3;
                                            end
                                            3 : begin
                                                SO <= SPI_ADDR[20];
                                                BIT <= 4;
                                            end
                                            4 : begin
                                                SO <= SPI_ADDR[19];
                                                BIT <= 5;
                                            end
                                            5 : begin
                                                SO <= SPI_ADDR[18];
                                                BIT <= 6;
                                            end
                                            6 : begin
                                                SO <= SPI_ADDR[17];
                                                BIT <= 7;
                                            end
                                            7 : begin
                                                SO <= SPI_ADDR[16];
                                                BIT <= 8;
                                            end
                                            8 : begin
                                                SO <= SPI_ADDR[15];
                                                BIT <= 9;
                                            end
                                            9 : begin
                                                SO <= SPI_ADDR[14];
                                                BIT <= 10;
                                            end
                                            10 : begin
                                                SO <= SPI_ADDR[13];
                                                BIT <= 11;
                                            end
                                            11 : begin
                                                SO <= SPI_ADDR[12];
                                                BIT <= 12;
                                            end
                                            12 : begin
                                                SO <= SPI_ADDR[11];
                                                BIT <= 13;
                                            end
                                            13 : begin
                                                SO <= SPI_ADDR[10];
                                                BIT <= 14;
                                            end
                                            14 : begin
                                                SO <= SPI_ADDR[9];
                                                BIT <= 15;
                                            end
                                            15 : begin
                                                SO <= SPI_ADDR[8];
                                                BIT <= 16;
                                            end
                                            16 : begin
                                                SO <= SPI_ADDR[7];
                                                BIT <= 17;
                                            end
                                            17 : begin
                                                SO <= SPI_ADDR[6];
                                                BIT <= 18;
                                            end
                                            18 : begin
                                                SO <= SPI_ADDR[5];
                                                BIT <= 19;
                                            end
                                            19 : begin
                                                SO <= SPI_ADDR[4];
                                                BIT <= 20;
                                            end
                                            20 : begin
                                                SO <= SPI_ADDR[3];
                                                BIT <= 21;
                                            end
                                            21 : begin
                                                SO <= SPI_ADDR[2];
                                                BIT <= 22;
                                            end
                                            22 : begin
                                                SO <= SPI_ADDR[1];
                                                BIT <= 23;
                                            end
                                            23 : begin
                                                SO <= SPI_ADDR[0];
                                                BIT <= 0;
                                                PHASE <= 1;
                                            end
                                            default : begin
                                            end
                                        endcase
                                    end
                                    1 : begin
                                        case (BIT)
                                            0 : begin
                                                CMD[31] <= SI;
                                                BIT <= 1;
                                            end
                                            1 : begin
                                                CMD[30] <= SI;
                                                BIT <= 2;
                                            end
                                            2 : begin
                                                CMD[29] <= SI;
                                                BIT <= 3;
                                            end
                                            3 : begin
                                                CMD[28] <= SI;
                                                BIT <= 4;
                                            end
                                            4 : begin
                                                CMD[27] <= SI;
                                                BIT <= 5;
                                            end
                                            5 : begin
                                                CMD[26] <= SI;
                                                BIT <= 6;
                                            end
                                            6 : begin
                                                CMD[25] <= SI;
                                                BIT <= 7;
                                            end
                                            7 : begin
                                                CMD[24] <= SI;
                                                BIT <= 8;
                                            end
                                            8 : begin
                                                CMD[23] <= SI;
                                                BIT <= 9;
                                            end
                                            9 : begin
                                                CMD[22] <= SI;
                                                BIT <= 10;
                                            end
                                            10 : begin
                                                CMD[21] <= SI;
                                                BIT <= 11;
                                            end
                                            11 : begin
                                                CMD[20] <= SI;
                                                BIT <= 12;
                                            end
                                            12 : begin
                                                CMD[19] <= SI;
                                                BIT <= 13;
                                            end
                                            13 : begin
                                                CMD[18] <= SI;
                                                BIT <= 14;
                                            end
                                            14 : begin
                                                CMD[17] <= SI;
                                                BIT <= 15;
                                            end
                                            15 : begin
                                                CMD[16] <= SI;
                                                BIT <= 16;
                                            end
                                            16 : begin
                                                CMD[15] <= SI;
                                                BIT <= 17;
                                            end
                                            17 : begin
                                                CMD[14] <= SI;
                                                BIT <= 18;
                                            end
                                            18 : begin
                                                CMD[13] <= SI;
                                                BIT <= 19;
                                            end
                                            19 : begin
                                                CMD[12] <= SI;
                                                BIT <= 20;
                                            end
                                            20 : begin
                                                CMD[11] <= SI;
                                                BIT <= 21;
                                            end
                                            21 : begin
                                                CMD[10] <= SI;
                                                BIT <= 22;
                                            end
                                            22 : begin
                                                CMD[9] <= SI;
                                                BIT <= 23;
                                            end
                                            23 : begin
                                                CMD[8] <= SI;
                                                BIT <= 24;
                                            end
                                            24 : begin
                                                CMD[7] <= SI;
                                                BIT <= 25;
                                            end
                                            25 : begin
                                                CMD[6] <= SI;
                                                BIT <= 26;
                                            end
                                            26 : begin
                                                CMD[5] <= SI;
                                                BIT <= 27;
                                            end
                                            27 : begin
                                                CMD[4] <= SI;
                                                BIT <= 28;
                                            end
                                            28 : begin
                                                CMD[3] <= SI;
                                                BIT <= 29;
                                            end
                                            29 : begin
                                                CMD[2] <= SI;
                                                BIT <= 30;
                                            end
                                            30 : begin
                                                CMD[1] <= SI;
                                                BIT <= 31;
                                            end
                                            31 : begin
                                                CMD[0] <= SI;
                                                BIT <= 0;
                                                PHASE <= 0;
                                                CYCLE <= 0;
                                            end
                                        endcase
                                    end
                                endcase
                                SCYCLE <= 0;
                            end
                        endcase
                    end
                    WRITE : begin
                        case (SCYCLE)
                            0 : begin
                                SCK <= !SCK;
                                SCYCLE <= 1;
                            end
                            1 : begin
                                SCK <= !SCK;
                                case (PHASE)
                                    0 : begin
                                        case (BIT)
                                            0 : begin
                                                SO <= SPI_ADDR[23];
                                                BIT <= 1;
                                            end
                                            1 : begin
                                                SO <= SPI_ADDR[22];
                                                BIT <= 2;
                                            end
                                            2 : begin
                                                SO <= SPI_ADDR[21];
                                                BIT <= 3;
                                            end
                                            3 : begin
                                                SO <= SPI_ADDR[20];
                                                BIT <= 4;
                                            end
                                            4 : begin
                                                SO <= SPI_ADDR[19];
                                                BIT <= 5;
                                            end
                                            5 : begin
                                                SO <= SPI_ADDR[18];
                                                BIT <= 6;
                                            end
                                            6 : begin
                                                SO <= SPI_ADDR[17];
                                                BIT <= 7;
                                            end
                                            7 : begin
                                                SO <= SPI_ADDR[16];
                                                BIT <= 8;
                                            end
                                            8 : begin
                                                SO <= SPI_ADDR[15];
                                                BIT <= 9;
                                            end
                                            9 : begin
                                                SO <= SPI_ADDR[14];
                                                BIT <= 10;
                                            end
                                            10 : begin
                                                SO <= SPI_ADDR[13];
                                                BIT <= 11;
                                            end
                                            11 : begin
                                                SO <= SPI_ADDR[12];
                                                BIT <= 12;
                                            end
                                            12 : begin
                                                SO <= SPI_ADDR[11];
                                                BIT <= 13;
                                            end
                                            13 : begin
                                                SO <= SPI_ADDR[10];
                                                BIT <= 14;
                                            end
                                            14 : begin
                                                SO <= SPI_ADDR[9];
                                                BIT <= 15;
                                            end
                                            15 : begin
                                                SO <= SPI_ADDR[8];
                                                BIT <= 16;
                                            end
                                            16 : begin
                                                SO <= SPI_ADDR[7];
                                                BIT <= 17;
                                            end
                                            17 : begin
                                                SO <= SPI_ADDR[6];
                                                BIT <= 18;
                                            end
                                            18 : begin
                                                SO <= SPI_ADDR[5];
                                                BIT <= 19;
                                            end
                                            19 : begin
                                                SO <= SPI_ADDR[4];
                                                BIT <= 20;
                                            end
                                            20 : begin
                                                SO <= SPI_ADDR[3];
                                                BIT <= 21;
                                            end
                                            21 : begin
                                                SO <= SPI_ADDR[2];
                                                BIT <= 22;
                                            end
                                            22 : begin
                                                SO <= SPI_ADDR[1];
                                                BIT <= 23;
                                            end
                                            23 : begin
                                                SO <= SPI_ADDR[0];
                                                BIT <= 0;
                                                PHASE <= 1;
                                            end
                                            default : begin
                                            end
                                        endcase
                                    end
                                    1 : begin
                                        case (BIT)
                                            0 : begin
                                                SO <= DOUT[7];
                                                BIT <= 1;
                                            end
                                            1 : begin
                                                SO <= DOUT[6];
                                                BIT <= 2;
                                            end
                                            2 : begin
                                                SO <= DOUT[5];
                                                BIT <= 3;
                                            end
                                            3 : begin
                                                SO <= DOUT[4];
                                                BIT <= 4;
                                            end
                                            4 : begin
                                                SO <= DOUT[3];
                                                BIT <= 5;
                                            end
                                            5 : begin
                                                SO <= DOUT[2];
                                                BIT <= 6;
                                            end
                                            6 : begin
                                                SO <= DOUT[1];
                                                BIT <= 7;
                                            end
                                            7 : begin
                                                SO <= DOUT[0];
                                                BIT <= 0;
                                                CYCLE <= 0;
                                            end
                                        endcase
                                    end
                                endcase
                                SCYCLE <= 0;
                            end
                        endcase
                    end
                    default : begin
                    end
                endcase
            end
        endcase
        /*case (SPI_CMD)
            WREN : begin

            end
            WRDI : begin
                
            end
            RDSR : begin
                
            end
            WRSR : begin
                
            end
            READ : begin
                
            end
            WRITE : begin
                
            end
            default : begin
                nWP1 <= 1;
            end
        endcase*/
    end
endmodule