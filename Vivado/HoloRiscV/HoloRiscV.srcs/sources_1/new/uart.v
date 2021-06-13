`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/12/2021 02:16:08 PM
// Design Name: HoloRiscV
// Module Name: uart
// Project Name: HoloRiscV
// Target Devices: xc7a35ticsg324-1L
// Tool Versions: Vivado 2020.2
// Description: This is a debugging module for the HoloRiscV core. Its purpose is
// to dump the contents of the BRAM over UART to be read from a serial terminal.
//  
// Dependencies: 
// 
// Revision:
// Revision 0.0.1 - File Created
// Revision 1.0.0 - Began rebuild
// Additional Comments: This is not the final code, rather it is a checkpoint.
// 
//////////////////////////////////////////////////////////////////////////////////

`define DIV 87

module uart (
    input clk,
    input [31:0] din,
    input active,
    output reg tx = 1,
    output reg [14:0] addr = 0
    );

    reg [31:0] data_buffer = 0;

    reg [51:0] send = 0;
    reg [1:0] cycle = 0;
    reg [5:0] bbit = 0;
    reg [6:0] pause = 0;
    
    always @(posedge clk) begin
        if (active) begin
            case (cycle)
                0 : begin
                    data_buffer <= din;
                    cycle <= 1;
                end
                1 : begin
                    send <= {4'hf,data_buffer[31:24],1'b0,4'hf,data_buffer[23:16],1'b0,4'hf,data_buffer[15:8],1'b0,4'hf,data_buffer[7:0],1'b0};
                    cycle <= 2;
                end
                2 : begin
                    if (bbit < 52) begin
                        if (pause < `DIV) begin
                            tx <= send[0];
                            pause <= pause + 1;
                        end
                        else if (pause == `DIV) begin
                            send <= send >> 1;
                            bbit <= bbit + 1;
                            pause <= 0;
                        end
                    end
                    else if (bbit == 52) begin
                        addr <= addr + 1;
                        cycle <= 3;
                        bbit <= 0;
                        pause <= 0;
                    end
                end
                3 : begin
                    cycle <= 0;
                end
            endcase
        end
    end
endmodule