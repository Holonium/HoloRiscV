`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/05/2021 03:41:41 PM
// Design Name: HoloRiscV
// Module Name: HoloRiscV
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

//Define stages
`define FETCH 3'b000
`define DECODE 3'b001
`define EXECUTE 3'b010
`define MEMORY 3'b011
`define WRITEBACK 3'b100

module HoloRiscV(
    input CLK100MHZ,
    input rst,
    input ja_miso,
    output ja_mosi,
    output ja_cs,
    output ja_sck,
    output ja_rst,
    output ja_wp,
    output ja_hld
    );
    
    parameter LOAD = 7'b0000011;
    
    // Configure Clocks
    wire core_clk_mmcm;
    wire spi_sck_mmcm;
    wire core_clk;
    wire spi_sck;
    wire mmcm_clkfb;
    wire locked;
    
    MMCME2_BASE #( .BANDWIDTH("OPTIMIZED"), .CLKFBOUT_MULT_F(10.000), .CLKIN1_PERIOD(10.000), .CLKOUT0_DIVIDE_F(10.000), .CLKOUT1_DIVIDE(10),
        .CLKOUT0_DUTY_CYCLE(0.5), .CLKOUT1_DUTY_CYCLE(0.5), .CLKOUT0_PHASE(0.000), .CLKOUT1_PHASE(0.000), .DIVCLK_DIVIDE(1), .REF_JITTER1(0.0))
    MMCME2_BASE_inst ( .CLKIN1(CLK100MHZ), .CLKOUT0(core_clk_mmcm), .CLKOUT1(spi_sck_mmcm), .CLKFBOUT(mmcm_clkfb), .LOCKED(locked), .PWRDWN(1'b0), .RST(1'b0),
        .CLKFBIN(mmcm_clkfb));
  
    BUFGCE core (.I(core_clk_mmcm), .O(core_clk), .CE(locked));
    BUFGCE spi (.I(spi_sck_mmcm), .O(spi_sck), .CE(locked));
    
    // SPI Commands
//    parameter init = 3'b000;
    
    reg [31:0] reg_file [0:31];
    
    wire dir = 1;
    wire [4:0] bits = 0;
    wire [31:0] spi_out_buff = 0;
//    reg [31:0] pc = 0;
//    wire [31:0] pc_temp;
    wire spi_init = 0;
    wire initialized;
    wire [31:0] spi_in_buff;
    
    reg fetch_active = 1;
    reg decode_active = 0;
    reg execute_active = 0;
    reg memory_active = 0;
    reg writeback_active = 0;
    wire fetch_done;
    wire decode_done;
    wire execute_done;
    wire memory_done;
        
    wire [31:0] cmd;
    wire [6:0] opcode;
    wire [2:0] type;
    wire [4:0] rd;
    wire [2:0] f3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] f7;
    wire [31:0] extended;
    wire [31:0] imm;
    
    wire [31:0] dest_ex;
    wire [31:0] dest_mem;
    reg [31:0] pc = 0;
    wire [31:0] pc_temp;
        
    /*module fetch(
    input clk,
    input active,
    //input miso,
    input [31:0] instr,
    output reg mosi = 1,
    output reg sck = 1,
    output reg cs = 1,
    output reg [31:0] cmd,
    output reg done = 0
    );*/
    
    wire fetch_mosi;
    wire fetch_sck;
    wire fetch_cs;
    wire mem_mosi;
    wire mem_sck;
    wire mem_cs;
    
    reg mosi;
    reg sck;
    reg cs;
    
    assign ja_mosi = mosi;
    assign ja_sck = sck;
    assign ja_cs = cs;
    
    fetch core_fetch (
        .clk(spi_ack),
        .active(fetch_active),
        .miso(ja_miso),
        .instr(pc),
        .mosi(fetch_mosi),
        .sck(fetch_sck),
        .cs(fetch_cs),
        .cmd(cmd),
        .done(fetch_done)
    );
    
    decode core_dec (
        .clk(core_clk), 
        .cmd(cmd), 
        .active(decode_active),
        .opcode(opcode),
        .type(type),
        .rd(rd), 
        .f3(f3), 
        .rs1(rs1), 
        .rs2(rs2), 
        .f7(f7), 
        .extended(extended), 
        .imm(imm),
        .done(decode_done)
    );
    
    execute core_ex (
        .clk(core_clk), 
        .active(execute_active), 
        .opcode(opcode), 
//        .type(type), 
//        .rd(rd), 
        .f3(f3), 
//        .rs1(rs1), 
//        .rs2(rs2), 
//        .f7(f7), 
        .extended(extended), 
        .src1(reg_file[rs1]), 
        .src2(reg_file[rs2]),
        .pc_in(pc), 
        .imm(imm),
//        .cmd(cmd),
        .cmd30(cmd[30]),
        .dest(dest_ex),
        .pc_out(pc_temp),
        .done(execute_done)
    );
    
    memory core_mem (
        .clk(spi_sck),
        .active(memory_active),
        .miso(ja_miso),
        .src1(reg_file[rs1]),
        .src2(reg_file[rs2]),
        .imm(imm),
        .f3(f3),
        .opcode(opcode),
        .pc(pc),
        .mosi(mem_mosi),
        .sck(mem_sck),
        .wp(ja_wp),
        .hold(ja_hld),
        .cs(mem_cs),
        .dest(dest_mem),
        .done(memory_done)
    );
    
    always @(posedge core_clk) begin
        if (fetch_active && fetch_done) begin
            fetch_active <= 0;
            decode_active <= 1;
        end
        if (decode_active && decode_done) begin
            decode_active <= 0;
            execute_active <= 1;
            reg_file[rs1] <= 5;
            reg_file[rs2] <= 9;
        end
        if (execute_active && execute_done) begin
            execute_active <= 0;
            memory_active <= 1;
//            writeback_active <= 1;
        end
        if (memory_active && memory_done) begin
            memory_active <= 0;
            writeback_active <= 1;
        end
        if (writeback_active) begin
            if (opcode == LOAD) reg_file[rd] <= dest_mem;
            else reg_file[rd] <= dest_ex;
            pc <= pc_temp + 4;
            writeback_active <= 0;
            fetch_active <= 1;
//            decode_active <= 1;
        end
        reg_file[0] <= 0;
        if (fetch_active && !memory_active) begin
            mosi <= fetch_mosi;
            cs <= fetch_cs;
            sck <= fetch_sck;
        end
        if (memory_active && !fetch_active) begin
            mosi <= mem_mosi;
            cs <= mem_cs;
            sck <= mem_sck;
        end
    end
endmodule
