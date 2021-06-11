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
    output reg tx = 1
    );
    
    reg [43:0] send;
    reg [1:0] cycle = 0;
    reg [7:0] pause = 0;
    reg [6:0] bit = 0;
    
    always @(posedge clk) begin
        case (cycle)
            0 : begin
                if (active && !next) begin
                    send <= {1'b1,1'b0,din[31:24],1'b0,1'b1,1'b0,din[23:16],1'b0,1'b1,1'b0,din[15:8],1'b0,1'b1,1'b0,din[7:0],1'b0};
                    cycle <= 1;
                end
            end
            1 : begin
                if (bit < 44 && !next) begin
                    if (pause < 87) begin
                        tx <= send[0];
                        pause <= pause + 1;
                    end
                    else begin
                        send <= send >> 1;
                        pause <= 0;
                        bit <= bit + 1;
                    end
                end
                else begin
                    next <= 1;
                    if (!active && next) begin
                        cycle <= 0;
                        bit <= 0;
                        next <= 0;
                    end
                end
            end
        endcase
    end
endmodule
