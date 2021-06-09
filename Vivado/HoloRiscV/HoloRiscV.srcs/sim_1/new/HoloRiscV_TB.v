`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2021 10:41:37 AM
// Design Name: HoloRiscV
// Module Name: HoloRiscV_TB
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

//`include "../../sources_1/new/HoloRiscV.v"

module HoloRiscV_TB(
    output ja_mosi,
    output ja_cs,
    output ja_sck,
    output ja_rst,
    output ja_wp,
    output ja_hld
    );
    
    reg CLK100MHZ = 0;
    always #10 CLK100MHZ <= !CLK100MHZ;
    
    reg rst = 0;
    reg ja_miso = 1;
    
    HoloRiscV tb (CLK100MHZ, rst, ja_miso, ja_mosi, ja_cs, ja_sck, ja_rst, ja_wp, ja_hld);
    
endmodule
