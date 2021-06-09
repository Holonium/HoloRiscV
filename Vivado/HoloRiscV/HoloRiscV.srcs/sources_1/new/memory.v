`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/05/2021 03:41:41 PM
// Design Name: HoloRiscV
// Module Name: memory
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

module memory (
    input clk,
    input active,
    input miso,
    input [23:0] src1,
    input [23:0] src2,
    input [23:0] imm,
    input [2:0] f3,
    input [6:0] opcode,
//    input [31:0] pc,
    output reg mosi = 1,
    output reg sck = 1,
    output reg wp = 1,
    output reg hold = 1,
    output reg cs = 1,
    output reg [31:0] dest,
    output reg done = 0
    );
    
    //Define opcodes
	parameter LOAD = 7'b0000011;
	parameter STORE = 7'b0100011;
	
	//Define load operations
	parameter LB = 3'b000;
	parameter LH = 3'b001;
	parameter LW = 3'b010;
	parameter LBU = 3'b100;
	parameter LHU = 3'b101;
	
	//Define store operations
	parameter SB = 3'b000;
	parameter SH = 3'b001;
	parameter SW = 3'b010;
	
	reg [3:0] cycle = 0;
	reg [3:0] scycle = 0;
	reg count = 0;
	reg [3:0] byte_shift = 0;
    reg [7:0] bout = 8'h06;	
    reg [23:0] addr;
    reg [31:0] spi_buff_out = 0;
    reg [6:0] shift = 0;
    reg [31:0] spi_buff_in = 0;
    
	always @(posedge clk) begin
	   if (active) begin
	       case (opcode)
	           LOAD : begin
	               case (cycle)
	                   0 : begin
	                       addr <= src1[23:0] + {{12{imm[11]}},imm[11:0]};
	                       cycle <= 1;
	                   end
	                   1 : begin
	                       spi_buff_out <= {8'h03,addr};
	                       cycle <= 2;
	                   end
	                   2 : begin
	                       cs <= 0;
	                       mosi <= spi_buff_out[31];
	                       cycle <= 3;
	                   end
	                   3 : begin
	                       if (shift > 0) begin
	                           sck <= 0;
	                           mosi <= spi_buff_out[31];
	                       end
	                       cycle <= 4;
	                   end
	                   4 : begin
	                       sck <= 1;
	                       cycle <= 3;
	                       if (shift < 32) begin
	                           if (shift > 0) begin
	                               spi_buff_out <= spi_buff_out << 1;
	                           end
	                       end
	                       else begin
	                           shift <= 0;
	                           cycle <= 5;
	                           spi_buff_out <= 0;
	                       end
	                       shift <= shift + 1;
	                   end
	                   5 : begin
	                       case (f3)
	                           LB : begin
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
	                                       if (shift < 8) begin
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
	                                       cycle <= 6;
	                                       spi_buff_in <= {{24{spi_buff_in[7]}},spi_buff_in[7:0]};
	                                   end
	                               endcase
	                           end
	                           LH : begin
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
	                                       if (shift < 16) begin
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
	                                       cycle <= 6;
	                                       spi_buff_in <= {{16{spi_buff_in[15]}},spi_buff_in[15:0]};
	                                   end
	                               endcase
	                           end
	                           LW : begin
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
	                                       cycle <= 6;
	                                   end
	                               endcase
	                           end
	                           LBU : begin
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
	                                       if (shift < 8) begin
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
	                                       cycle <= 6;
	                                       spi_buff_in <= {{24{1'b0}},spi_buff_in[7:0]};
	                                   end
	                               endcase
	                           end
	                           LHU : begin
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
	                                       if (shift < 8) begin
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
	                                       cycle <= 6;
	                                       spi_buff_in <= {{16{1'b0}},spi_buff_in[15:0]};
	                                   end
	                               endcase
	                           end
	                           default : begin
	                               cycle <= 0;
	                               scycle <= 0;
	                               cs <= 1;
	                               done <= 1;
	                           end
	                       endcase
	                   end
	                   default : begin
	                       dest <= spi_buff_in;
	                       cycle <= 0;
	                       done <= 1;
	                   end
	               endcase
	           end
	           STORE : begin
	               case (cycle)
	                   0 : begin
	                       cs <= 0;
	                       cycle <= 1;
	                       mosi <= bout[7];
	                   end
	                   1 : begin
	                       if (byte_shift > 0) begin
	                           sck <= 0;
	                           mosi <= bout[7];
	                       end
	                       cycle <= 2;
	                   end
	                   2 : begin
	                       cycle <= 1;
	                       sck <= 1;
	                       if (byte_shift < 8) begin
	                           if (byte_shift > 0) begin
	                               bout <= bout << 1;
	                           end
	                       end
	                       else begin
	                           cycle <= 3;
	                           byte_shift <= 0;
	                       end
	                       byte_shift <= byte_shift + 1;
	                   end
	                   3 : begin
	                       cs <= 1;
	                       cycle <= 4;
	                       mosi <= 1;
	                   end
	                   4 : begin
	                       addr <= src1[23:0] + {{12{imm[11]}},imm[11:0]};
	                       cycle <= 5;
	                   end
	                   5 : begin
	                       spi_buff_out <= {8'h02,addr};
	                       cycle <= 6;
	                   end
	                   6 : begin
	                       cs <= 0;
	                       mosi <= spi_buff_out[31];
	                       cycle <= 7;
	                   end
	                   7 : begin
	                       if (shift > 0) begin
	                           sck <= 0;
	                           mosi <= spi_buff_out[31];
	                       end
	                       cycle <= 8;
	                   end
	                   8 : begin
	                       sck <= 1;
	                       cycle <= 7;
	                       if (shift < 32) begin
	                           if (shift > 0) begin
	                               spi_buff_out <= spi_buff_out << 1;
	                           end
	                       end
	                       else begin
	                           shift <= 0;
	                           cycle <= 9;
	                           spi_buff_out <= src2;
	                       end
	                       shift <= shift + 1;
	                   end
	                   9 : begin
	                       case (f3)
	                           SB : begin
	                               case (scycle)
	                                   0 : begin
	                                       mosi <= spi_buff_out[7];
	                                       scycle <= 1;
	                                   end
	                                   1 : begin
                	                       if (shift > 0) begin
	                                           sck <= 0;
	                                           mosi <= spi_buff_out[7];
                	                       end
	                                       scycle <= 2;
	                                   end
                	                   2 : begin
	                                       scycle <= 1;
                	                       sck <= 1;
	                                       if (shift < 8) begin
	                                           if (shift > 0) begin
	                                               spi_buff_out <= spi_buff_out << 1;
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
	                                       cycle <= 10;
	                                       mosi <= 1;
	                                   end
	                               endcase
	                           end
	                           SH : begin
	                               case (scycle)
	                                   0 : begin
	                                       mosi <= spi_buff_out[15];
	                                       scycle <= 1;
	                                   end
	                                   1 : begin
                	                       if (shift > 0) begin
	                                           sck <= 0;
	                                           mosi <= spi_buff_out[7];
                	                       end
	                                       scycle <= 2;
	                                   end
                	                   2 : begin
	                                       scycle <= 1;
                	                       sck <= 1;
	                                       if (shift < 16) begin
	                                           if (shift > 0) begin
	                                               spi_buff_out <= spi_buff_out << 1;
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
	                                       cycle <= 10;
	                                       mosi <= 1;
	                                   end
	                               endcase
	                           end
	                           SW : begin
	                               case (scycle)
	                                   0 : begin
	                                       mosi <= spi_buff_out[15];
	                                       scycle <= 1;
	                                   end
	                                   1 : begin
                	                       if (shift > 0) begin
	                                           sck <= 0;
	                                           mosi <= spi_buff_out[7];
                	                       end
	                                       scycle <= 2;
	                                   end
                	                   2 : begin
	                                       scycle <= 1;
                	                       sck <= 1;
	                                       if (shift < 32) begin
	                                           if (shift > 0) begin
	                                               spi_buff_out <= spi_buff_out << 1;
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
	                                       cycle <= 10;
	                                       mosi <= 1;
	                                   end
	                               endcase
	                           end
	                           default : begin
	                               cycle <= 0;
	                               scycle <= 0;
	                               cs <= 1;
	                               done <= 1;
	                           end
	                       endcase
	                   end
	                   default : begin
	                       cycle <= 0;
	                       done <= 1;
	                       sck <= 1;
	                   end
	               endcase
	           end
	           default : done <= 1;
	       endcase
	   end
	   else if (!active) done <= 0;
	end
endmodule