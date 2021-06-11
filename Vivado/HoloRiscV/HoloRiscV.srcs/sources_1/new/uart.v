`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2021 02:13:11 PM
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define DIV 87

module uart(
    input clk,
    input [31:0] din,
    input active,
    output reg next = 0,
    output reg tx = 1,
    output reg [14:0] addr_out
    );
    
    reg [31:0] data_buffer;
    
    reg [51:0] send;
    reg [2:0] cycle = 0;
    reg [7:0] pause = 0;
    reg [6:0] bit = 0;
    reg shift = 0;
    reg init = 0;
    
    reg align = 0;
    
    reg [14:0] addr = 0;
    
    always @(posedge clk) begin
        case (cycle)
            0 : begin
                if (!init) begin
                    addr_out <= addr;
                    init <= 1;
                end
                else begin
                    data_buffer <= din;
                    cycle <= 1;
                end
            end
            1 : begin
                if (active && !next) begin
                    send <= {4'hf,data_buffer[31:24],1'b0,4'hf,data_buffer[23:16],1'b0,4'hf,data_buffer[15:8],1'b0,4'hf,data_buffer[7:0],1'b0};
                    cycle <= 2;
                end
            end
            2 : begin
                if (bit < 52) begin
                    if (pause < 87) begin
                        tx <= send[0];
                        pause <= pause + 1;
                    end
                    else begin
                        send <= send >> 1;
                        bit <= bit + 1;
                        pause <= 0;
                    end
                end
                else begin
                    addr <= addr + 1;
                    cycle <= 3;
                    bit <= 0;
                    pause <= 0;
                end
            end
            3 : begin
                addr_out <= addr;
                cycle <= 4;
            end
            4 : begin
                cycle <= 0;
            end
        endcase
    end
endmodule
