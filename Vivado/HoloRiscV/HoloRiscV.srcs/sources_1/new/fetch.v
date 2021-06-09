`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/06/2021 09:33:04 AM
// Design Name: HoloRiscV
// Module Name: fetch
// Project Name: HoloRiscV
// Target Devices: xc7a35ticsg324-1L
// Tool Versions: Vivado 2020.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fetch(
    input clk,
    input active,
    input miso,
    input [31:0] instr,
    output reg mosi = 1,
    output reg sck = 1,
    output reg cs = 1,
    output reg [31:0] cmd,
    output reg done = 0
    );
    
    reg [2:0] cycle = 0;
    reg [2:0] scycle = 0;
    reg [6:0] shift = 0;
    
    reg [31:0] spi_buff_out;
    reg [31:0] spi_buff_in;
    
    always @(posedge clk) begin
        if (active) begin
            case (cycle)
                0 : begin
                    spi_buff_out <= {8'h03,instr[23:0]};
                    cycle <= 1;
                end
                1 : begin
                    cs <= 0;
                    mosi <= spi_buff_out[31];
                    cycle <= 2;
                end
                2 : begin
                    if (shift > 0) begin
	                   sck <= 0;
	                   mosi <= spi_buff_out[31];
	                end
	                cycle <= 3;
                end
                3 : begin
                    sck <= 1;
	                cycle <= 2;
	                if (shift < 32) begin
	                   if (shift > 0) begin
	                       spi_buff_out <= spi_buff_out << 1;
	                   end
	                end
	                else begin
	                   shift <= 0;
	                   cycle <= 4;
	                   spi_buff_out <= 0;
	                end
	                shift <= shift + 1;
                end
                4 : begin
                    case (scycle)
                        0 : begin
                            spi_buff_in[0] <= miso;
                            scycle <= 1;
                        end
                        1 : begin
                            if (shift > 0) begin
                                sck <= 1;
                                spi_buff_in[0] <= miso;
                            end
                            scycle <= 2;
                        end
                        2 : begin
                            scycle <= 1;
                            sck <= 0;
                            if (shift < 32) begin
                                if (shift > 0) begin
                                    spi_buff_in <= spi_buff_in << 1;
                                end
                            end
                            else begin
                                scycle <= 3;
                                shift <= 0;
                            end
                            shift <= shift + 1;
                        end
                        default : begin
                            cs <= 1;
                            scycle <= 0;
                            cycle <= 5;
                        end
                    endcase
                end
                default : begin
                    done <= 1;
                    cmd <= spi_buff_in;
                end
            endcase
        end
        else if (!active) done <= 0;
    end
endmodule
