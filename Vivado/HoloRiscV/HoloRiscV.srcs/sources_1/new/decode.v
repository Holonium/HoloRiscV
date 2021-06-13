`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/12/2021 02:16:08 PM
// Design Name: HoloRiscV
// Module Name: decode
// Project Name: HoloRiscV
// Target Devices: xc7a35ticsg324-1L
// Tool Versions: Vivado 2020.2
// Description: This is the decode stage of the HoloRiscV core.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.0.1 - File Created
// Revision 1.0.0 - Began rebuild
// Additional Comments: This is not the final code, rather it is a checkpoint.
// 
//////////////////////////////////////////////////////////////////////////////////


module decode (
    input clk,
    input [31:0] cmd,
    input active,
    output reg [6:0] opcode,
    output reg [4:0] rd,
    output reg [2:0] f3,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [6:0] f7,
    output reg [31:0] imm,
    output reg [31:0] extended,
    output reg done = 0
    );

    // Define Opcodes
	parameter LUI = 7'b0110111;
	parameter AUIPC = 7'b0010111;
	parameter JAL = 7'b1101111;
	parameter JALR = 7'b1100111;
	parameter BRANCH = 7'b1100011;
	parameter LOAD = 7'b0000011;
	parameter STORE = 7'b0100011;
	parameter ALUI = 7'b0010011;
	parameter ALU = 7'b0110011;

	// Define Instruction Formats
	parameter R = 3'b001;
	parameter I = 3'b010;
	parameter S = 3'b011;
	parameter B = 3'b100;
	parameter U = 3'b101;
	parameter J = 3'b110;

    // Define Control Registers
    reg [1:0] cycle = 0;
    reg [2:0] format = 0;

    always @(posedge clk) begin
        if (active) begin
            case (cycle)
                0 : begin
                    case (cmd[6:0])
                        LUI : format <= U;
                        AUIPC : format <= U;
						JAL : format <= J;
						JALR : format <= I;
						BRANCH : format <= B;
						LOAD : format <= I;
						STORE : format <= S;
						ALUI : begin
							case (cmd[14:12])
								3'b001 : format <= R;
								3'b101 : format <= R;
								default : format <= I;
							endcase
						end
						ALU : format <= R;
						default : ;
                    endcase
                    opcode <= cmd[6:0];
                    cycle <= 1;
                end
                1 : begin
                    case (format)
						R : begin //R
							f7 <= cmd[31:25];
							rs2 <= cmd[24:20];
							rs1 <= cmd[19:15];
							f3 <= cmd[14:12];
							rd <= cmd[11:7];
						end
						I : begin //I
							imm[11:0] <= cmd[31:20];
							rs1 <= cmd[19:15];
							f3 <= cmd[14:12];
							rd <= cmd[11:7];
							extended <= {{20{cmd[31]}},imm[11:0]};
						end
						S : begin //S
							imm[11:0] <= {cmd[31:25],cmd[11:7]};
							rs2 <= cmd[24:20];
							rs1 <= cmd[19:15];
							f3 <= cmd[14:12];
							extended <= {{20{cmd[31]}},imm[11:0]};
						end
						B : begin //B
							imm[11:0] <= {cmd[31],cmd[7],cmd[30:25],cmd[11:8]};
							rs2 <= cmd[24:20];
							rs1 <= cmd[19:15];
							f3 <= cmd[14:12];
							extended <= {{20{cmd[31]}},imm[11:0]};
						end
						U : begin //U
							imm[31:12] <= cmd[31:12];
							rd <= cmd[11:7];
							extended <= {{12{cmd[31]}},imm[31:12]};
						end
						J : begin //J
							imm[20:1] <= {cmd[31],cmd[19:12],cmd[20],cmd[30:21]};
							rd <= cmd[11:7];
							extended <= {{12{cmd[31]}},imm[20:1]};
						end
						default : ;
					endcase
					cycle <= 2;
                end
                2 : begin
                    cycle <= 0;
                    done <= 1;
                end
            endcase
        end
        else if (!active) done <= 0;
    end
endmodule