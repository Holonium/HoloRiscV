`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/12/2021 02:16:08 PM
// Design Name: HoloRiscV
// Module Name: execute
// Project Name: HoloRiscV
// Target Devices: xc7a35ticsg324-1L
// Tool Versions: Vivado 2020.2
// Description: This is the execute stage of the HoloRiscV core.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.0.1 - File Created
// Revision 1.0.0 - Began rebuild
// Additional Comments: This is not the final code, rather it is a checkpoint.
// 
//////////////////////////////////////////////////////////////////////////////////


module execute (
    input clk,
    input active,
    input [6:0] opcode,
    input [2:0] f3,
    input [31:0] extended,
    input [31:0] src1,
    input [31:0] src2,
    input [31:0] pc_in,
    input [31:0] imm,
    input [6:0] f7,
    output reg [31:0] dest,
    output reg [31:0] pc_out,
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
    
    // Define ALUI Operations
	parameter ADDI = 3'b000;
	parameter SLTI = 3'b010;
	parameter SLTIU = 3'b011;
	parameter XORI = 3'b100;
	parameter ORI = 3'b110;
	parameter ANDI = 3'b111;
	parameter SLLI = 3'b001;
	parameter SRI = 3'b101;
	
	// Define ALU Operations
	parameter ADD = 3'b000;
	parameter SLL = 3'b001;
	parameter SLT = 3'b010;
	parameter SLTU = 3'b011;
	parameter XOR = 3'b100;
	parameter SR = 3'b101;
	parameter OR = 3'b110;
	parameter AND = 3'b111;

	// Define Branches
	parameter BEQ = 3'b000;
	parameter BNE = 3'b001;
	parameter BLT = 3'b100;
	parameter BGE = 3'b101;
	parameter BLTU = 3'b110;
	parameter BGEU = 3'b111;

	// Define Load Operations
	parameter LB = 3'b000;
	parameter LH = 3'b001;
	parameter LW = 3'b010;
	parameter LBU = 3'b100;
	parameter LHU = 3'b101;
	
	// Define Store Operations
	parameter SB = 3'b000;
	parameter SH = 3'b001;
	parameter SW = 3'b010;

    reg cycle = 0;
    reg [1:0] scycle = 0;
    reg [31:0] pc_temp = 0;

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
                                    pc_temp <= pc_in + $signed({{12{imm[20]}},imm[20:1]});
                                    scycle <= 1;
                                end
                                1 : begin
                                    dest <= pc_temp + 4;
                                    cycle <= 1;
                                    scycle <= 0;
                                end
                            endcase
                        end
                        JALR : begin
                            case (scycle)
                                0 : begin
                                    pc_temp <= src1 + $signed({{20{imm[11]}},imm[11:0]});
                                    scycle <= 1;
                                end
                                1 : begin
                                    pc_temp[0] <= 1'b0;
                                    scycle <= 2;
                                end
                                2 : begin
                                    pc_temp <= pc_temp + 4;
                                    cycle <= 1;
                                    scycle <= 0;
                                end
                            endcase
                        end
                        BRANCH : begin
                            case (f3)
                                BEQ : begin
                                    
                                end
                                BNE : begin
                                    
                                end
                                BLT : begin
                                    
                                end
                                BGE : begin
                                    
                                end
                                BLTU : begin
                                    
                                end
                                BGEU : begin
                                    
                                end
                                default : ;
                            endcase
                            cycle <= 1;
                        end
                        ALUI : begin
                            case (f3)
                                ADDI : dest <= src1 + extended;
                                SLTI : begin
                                    if ($signed(src1) < $signed(extended)) dest <= 1;
                                    else dest <= 0;
                                end
                                SLTIU : begin
                                    if (src1 < extended) dest <= 1;
                                    else dest <= 0;
                                end
                                XORI : dest <= src1 ^ extended;
                                ORI : dest <= src1 | extended;
                                ANDI : dest <= src1 & extended;
                                SLLI : dest <= src1 << imm[4:0];
                                SRI : begin
                                    case (f7)
                                        7'b0000000 : dest <= src1 >> imm[4:0];
                                        7'b0100000 : dest <= $signed(src1) >>> imm[4:0];
                                        default : ;
                                    endcase
                                end
                            endcase
                            cycle <= 1;
                        end
                        ALU : begin
                            case (f3)
                                ADD : begin
                                    case (f7)
                                        7'b0000000 : dest <= src1 + src2;
                                        7'b0100000 : dest <= src1 - src2;
                                        default : ;
                                    endcase
                                end
                                SLL : dest <= src1 << src2[4:0];
                                SLT : begin
                                    if ($signed(src1) < $signed(src2)) dest <= 1;
                                    else dest <= 0;
                                end
                                SLTU : begin
                                    if (src1 < src2) dest <= 1;
                                    else dest <= 0;
                                end
                                XOR : dest <= src1 ^ src2;
                                SR : begin
                                    case (f7)
                                        7'b0000000 : dest <= src1 >> src2[4:0];
                                        7'b0100000 : dest <= $signed(src1) >>> src2[4:0];
                                        default : ;
                                    endcase
                                end
                                OR : dest <= src1 | src2;
                                AND : dest <= src1 & src2;
                            endcase
                            cycle <= 1;
                        end
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
                end
            endcase
        end
        else if (!active) done <= 0;
    end
endmodule