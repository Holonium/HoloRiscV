`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/05/2021 03:41:41 PM
// Design Name: HoloRiscV
// Module Name: execute
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

module execute (
    input clk,
    input active,
    input [6:0] opcode,
    input [2:0] type,
    input [4:0] rd,
    input [2:0] f3,
    input [4:0] rs1,
    input [4:0] rs2,
    input [6:0] f7,
    input [31:0] extended,
    input [31:0] src1,
    input [31:0] src2,
    input [31:0] pc_in,
    input [31:0] imm,
    input [31:0] cmd,
    output reg [31:0] dest,
    output reg [31:0] pc_out,
    output reg done = 0
    );
    
    //Define opcodes
	parameter LUI = 7'b0110111;
	parameter AUIPC = 7'b0010111;
	parameter JAL = 7'b1101111;
	parameter JALR = 7'b1100111;
	parameter BRANCH = 7'b1100011;
	parameter LOAD = 7'b0000011;
	parameter STORE = 7'b0100011;
	parameter ALUI = 7'b0010011;
	parameter ALU = 7'b0110011;
    
    //Define ALUI operations
	parameter ADDI = 3'b000;
	parameter SLTI = 3'b010;
	parameter SLTIU = 3'b011;
	parameter XORI = 3'b100;
	parameter ORI = 3'b110;
	parameter ANDI = 3'b111;
	parameter SLLI = 3'b001;
	parameter SRI = 3'b101;
	
	//Define ALU operations
	parameter ADD = 3'b000;
	parameter SLL = 3'b001;
	parameter SLT = 3'b010;
	parameter SLTU = 3'b011;
	parameter XOR = 3'b100;
	parameter SR = 3'b101;
	parameter OR = 3'b110;
	parameter AND = 3'b111;

	//Define branches
	parameter BEQ = 3'b000;
	parameter BNE = 3'b001;
	parameter BLT = 3'b100;
	parameter BGE = 3'b101;
	parameter BLTU = 3'b110;
	parameter BGEU = 3'b111;

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
    
	//Define instruction formats
	parameter R = 3'b001;
	parameter I = 3'b010;
	parameter S = 3'b011;
	parameter B = 3'b100;
	parameter U = 3'b101;
	parameter J = 3'b110;
    
    reg cycle = 0;
    reg [1:0] scycle = 0;
    reg [31:0] pc_temp;
    
    always @(posedge clk) begin
        if (active) begin
            case (cycle)
                0 : begin
                    case (opcode)
                        LUI : begin
                            dest <= {imm[31:12],{12{1'b0}}};
                            cycle <= 1;
                        end
                        AUIPC : begin
                            dest <= pc_in + {imm[31:12],{12{1'b0}}};
                            cycle <= 1;
                        end
                        JAL : begin
                            case (scycle)
                                0 : begin
                                    pc_temp <= pc_in + {{12{imm[20]}},imm[20:1]};
                                    scycle <= 1;
                                end
                                1 : begin
                                    dest <= pc_temp + 4;
                                    cycle <= 1;
                                    scycle <= 0;
                                end
                                default : ;
                            endcase
                        end
                        JALR : begin
                            case (scycle)
                                0 : begin
                                    pc_temp <= src1 + {{20{imm[11]}},imm[11:0]};
                                    scycle <= 1;
                                end
                                1 : begin
                                    pc_temp[0] <= 1'b0;
                                    scycle <= 2;
                                end
                                2 : begin
                                    pc_temp <= pc_temp + 4;
                                    scycle <= 0;
                                    cycle <= 1;
                                end
                                default : ;
                            endcase
                        end
                        BRANCH : begin
                            case (f3)
                                BEQ : begin
                                    if (src1 == src2) begin
                                        pc_temp <= pc_in + {{20{imm[12]}},imm[12:1]};
                                    end
                                end
                                BNE : begin
                                    if (src1 != src2) begin
                                        pc_temp <= pc_in + {{20{imm[12]}},imm[12:1]};
                                    end
                                end
                                BLT : begin
                                    if ($signed(src1) < $signed(src2)) begin
                                        pc_temp <= pc_in + {{20{imm[12]}},imm[12:1]};
                                    end
                                end
                                BGE : begin
                                    if ($signed(src1) >= $signed(src2)) begin
                                        pc_temp <= pc_in + {{20{imm[12]}},imm[12:1]};
                                    end
                                end
                                BLTU : begin
                                    if (src1 < src2) begin
                                        pc_temp <= pc_in + {{20{imm[12]}},imm[12:1]};
                                    end
                                end
                                BGEU : begin
                                    if (src1 >= src2) begin
                                        pc_out <= pc_temp + {{20{imm[12]}},imm[12:1]};
                                    end
                                end
                                default : ;
                            endcase
                            cycle <= 1;
                        end
                        ALUI : begin
                            case (f3)
                                ADDI : begin
                                    dest <= src1 + extended;
                                    cycle <= 1;
                                end
                                SLTI : begin
                                    if ($signed(src1) < $signed(extended)) dest <= 1;
                                    else dest <= 0;
                                    cycle <= 1;
                                end
                                SLTIU : begin
                                    if (src1 < extended) dest <= 1;
                                    else dest <= 0;
                                    cycle <= 1;
                                end
                                XORI : begin
                                    dest <= src1 ^ extended;
                                end
                                ORI : begin
                                    dest <= src1 | extended;
                                    cycle <= 1;
                                end
                                ANDI : begin
                                    dest <= src1 & extended;
                                    cycle <= 1;
                                end
                                SLLI : begin
                                    dest <= src1 << cmd[24:20];
                                    cycle <= 1;
                                end
                                SRI : begin
                                    case (cmd[30])
                                        0 : dest <= src1 >> cmd[24:20];
                                        1 : dest <= $signed(src1) >>> cmd[24:20];
                                    endcase
                                    cycle <= 1;
                                end
                            endcase
                        end
                        ALU : begin
                            case (f3)
                                ADD : begin
                                    case (cmd[30])
                                        0 : dest <= src1 + src2;
                                        1 : dest <= src1 - src2;
                                    endcase
                                    cycle <= 1;
                                end
                                SLL : begin
                                    dest <= src1 << src2[4:0];
                                    cycle <= 1;
                                end
                                SLT : begin
                                    if ($signed(src1) < $signed(src2)) dest <= 1;
                                    else dest <= 0;
                                    cycle <= 1;
                                end
                                SLTU : begin
                                    if (src1 < src2) dest <= 1;
                                    else dest <= 0;
                                    cycle <= 1;
                                end
                                XOR : begin
                                    dest <= src1 ^ src2;
                                    cycle <= 1;
                                end
                                SR : begin
                                    case (cmd[30])
                                        0 : dest <= src1 >> src2[4:0];
                                        1 : dest <= $signed(src1) >>> src2[4:0];
                                    endcase
                                    cycle <= 1;
                                end
                                OR : begin
                                    dest <= src1 | src2;
                                    cycle <= 1;
                                end
                                AND : begin
                                    dest <= src1 & src2;
                                    cycle <= 1;
                                end
                            endcase
                        end
                        LOAD : cycle <= 1;
                        STORE : cycle <= 1;
                        default : cycle <= 1;
                    endcase
                end
                1 : begin
                    cycle <= 0;
                    scycle <= 0;
                    case (opcode)
                        JAL : pc_out <= pc_temp;
                        JALR : pc_out <= pc_temp;
                        BRANCH : pc_out <= pc_temp;
                        default : pc_out <= pc_in;
                    endcase
                    done <= 1;
                end
            endcase
        end
        else if (!active) done <= 0;
    end
endmodule