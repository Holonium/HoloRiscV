`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/12/2021 02:16:08 PM
// Design Name: HoloRiscV
// Module Name: ram
// Project Name: HoloRiscV
// Target Devices: xc7a35ticsg324-1L
// Tool Versions: Vivado 2020.2
// Description: This is the ram module of the HoloRiscV core. It instantiates BRAM
// 
// Dependencies: ram.mem
// 
// Revision:
// Revision 0.0.1 - File Created
// Revision 1.0.0 - Began rebuild
// Additional Comments: This is not the final code, rather it is a checkpoint.
// 
//////////////////////////////////////////////////////////////////////////////////


module ram (
    input clk,
    input we,
    input [14:0] addr,
    input [31:0] din,
    output reg [31:0] dout
    );
    
    reg [31:0] mem [1024:0];

    initial begin
        $readmemh("ram.mem",mem);
    end
    
    always @(posedge clk) begin
        if (we) mem[addr[9:0]] <= din;
        dout <= mem[addr[9:0]];
    end
endmodule