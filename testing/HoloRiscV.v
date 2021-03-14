/*

This version of the core will use a 32 bit bus for address and 8 bit bus for data, along with separate instruction and data memories. It will implement the RV32I architecture.

NOTE: This version is not meant for implementation. It is the active development version meant to be run in a testbench.

*/

`timescale 1ns/1ps
`default_nettype none

module HoloRiscV (

	);
	
	initial begin
		$dumpfile("HoloRiscV.vcd");
		$dumpvars(0,HoloRiscV);
		#1000 $finish;
	end
	reg clk = 0;
	
	always #10 clk = !clk;
	
	//Define formats
	parameter R = 3'b001;
	parameter I = 3'b010;
	parameter S = 3'b011;
	parameter B = 3'b100;
	parameter U = 3'b101;
	parameter J = 3'b110;
	
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
	
	//Define branches
	parameter BEQ = 3'b000;
	parameter BNE = 3'b001;
	parameter BLT = 3'b100;
	parameter BGE = 3'b101;
	parameter BLTU = 3'b110;
	parameter BGEU = 3'b111;
	
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
	
	//Define stages
	parameter FETCH = 3'b000;
	parameter DECODE = 3'b001;
	parameter EXECUTE = 3'b010;
	parameter MEMORY = 3'b011;
	parameter WRITEBACK = 3'b100;
	
	//Declare memory buses
	reg [7:0] INSTR_IN;
	reg [7:0] DATA_IN;
	reg [7:0] DATA_OUT;
	reg [31:0] INSTR_ADDR;
	reg [31:0] DATA_ADDR;
	
	//Declare misc I/O
	reg INSTR_OE = 1;
	reg INSTR_CE = 1;
	reg DATA_OE = 1;
	reg DATA_WE = 0;
	reg DATA_CE = 1;
	
	//Declare system registers
	reg [31:0] REG_FILE [31:0];
	reg [31:0] PC = 0;
	
	//Declare control registers
	reg [2:0] STAGE = 0;
	reg [3:0] CYCLE = 0;
	reg [3:0] SCYCLE = 0;
	
	//Declare intermediate registers
	reg [31:0] CMD = {7'b1,5'b0,5'b0,LB,5'b01101,LOAD};
	reg [2:0] TYPE;
	reg [4:0] RD = 0;
	reg [2:0] F3 = 0;
	reg [4:0] RS1 = 0;
	reg [4:0] RS2 = 0;
	reg [6:0] F7 = 0;
	reg [31:0] IMM = 0;
	reg [31:0] TMP = 0;
	
	always @(posedge clk) begin
		REG_FILE[0] <= 32'b0;
		//FETCH
		if (STAGE == FETCH) begin
			case (CYCLE)
				0 : begin
					INSTR_ADDR <= PC;
					CYCLE <= 1;
				end
				1 : begin
					//CMD[7:0] <= INSTR_IN;
					CYCLE <= 2;
					INSTR_ADDR <= INSTR_ADDR + 1;
				end
				2 : begin
					//CMD[15:8] <= INSTR_IN;
					CYCLE <= 3;
					INSTR_ADDR <= INSTR_ADDR + 1;
				end
				3 : begin
					//CMD[23:16] <= INSTR_IN;
					CYCLE <= 4;
					INSTR_ADDR <= INSTR_ADDR + 1;
				end
				4 : begin
					//CMD[31:24] <= INSTR_IN;
					CYCLE <= 0;
					STAGE <= DECODE;
					INSTR_ADDR <= PC;
				end
			endcase
		end
		//DECODE
		if (STAGE == DECODE) begin
			case (CYCLE)
				0 : begin
					case (CMD[6:0])
						LUI : begin
							TYPE <= U;
						end
						AUIPC : begin
							TYPE <= U;
						end
						JAL : begin
							TYPE <= J;
						end
						JALR : begin
							TYPE <= I;
						end
						BRANCH : begin
							TYPE <= B;
						end
						LOAD : begin
							TYPE <= I;
						end
						STORE : begin
							TYPE <= S;
						end
						ALUI : begin
							case (CMD[14:12])
								3'b001 : TYPE <= R;
								3'b101 : TYPE <= R;
								default : TYPE <= I;
							endcase
						end
						ALU : begin
							TYPE <= R;
						end
						default : begin
						end
					endcase
					CYCLE <= 1;
				end
				1 : begin
					case (TYPE)
						R : begin //R
							F7 <= CMD[31:25];
							RS2 <= CMD[24:20];
							RS1 <= CMD[19:15];
							F3 <= CMD[14:12];
							RD <= CMD[11:7];
						end
						I : begin //I
							IMM[11:0] <= CMD[31:20];
							RS1 <= CMD[19:15];
							F3 <= CMD[14:12];
							RD <= CMD[11:7];
						end
						S : begin //S
							IMM[11:0] <= {CMD[31:25],CMD[11:7]};
							RS2 <= CMD[24:20];
							RS1 <= CMD[19:15];
							F3 <= CMD[14:12];
						end
						B : begin //B
							IMM[11:0] <= {CMD[31],CMD[7],CMD[30:25],CMD[11:8]};
							RS2 <= CMD[24:20];
							RS1 <= CMD[19:15];
							F3 <= CMD[14:12];
						end
						U : begin //U
							IMM[31:12] <= CMD[31:12];
							RD <= CMD[11:7];
						end
						J : begin //J
							IMM[20:1] <= {CMD[31],CMD[19:12],CMD[20],CMD[30:21]};
							RD <= CMD[11:7];
						end
						default : begin
						end
					endcase
					CYCLE <= 0;
					STAGE <= EXECUTE;
				end
			endcase
		end
		//EXECUTE
		if (STAGE == EXECUTE) begin
			case (CMD[6:0])
				LUI : REG_FILE[RD] <= {IMM[31:12],12'b0};
				AUIPC : REG_FILE[RD] <= PC + {IMM[31:12],12'b0};
				JAL : begin
					if (CYCLE == 0) begin
						PC <= PC + {{12{IMM[20]}},IMM[20:1]};
						REG_FILE[RD] <= PC + 4;
						CYCLE <= 1;
					end
					else begin
						TMP <= REG_FILE[RD];
						STAGE <= MEMORY;
						CYCLE <= 0;
					end
				end
				JALR : begin
					if (CYCLE == 0)begin
						PC <= REG_FILE[RS1] + {{20{IMM[11]}},IMM[11:0]};
						PC[0] <= 1'b0;
						CYCLE <= 1;
					end
					else if (CYCLE == 1) begin
						REG_FILE[RD] <= PC + 4;
						CYCLE <= 2;
					end
					else begin
						TMP <= REG_FILE[RD];
						STAGE <= MEMORY;
						CYCLE <= 0;
					end
				end
				BRANCH : begin
					case (F3)
						BEQ : begin
							if (REG_FILE[RS1] == REG_FILE[RS2]) begin
								PC <= PC + {{20{IMM[12]}},IMM[12:1]};
								STAGE <= MEMORY;
							end
						end
						BNE : begin
							if (REG_FILE[RS1] != REG_FILE[RS2]) begin
								PC <= PC + {{20{IMM[12]}},IMM[12:1]};
								STAGE <= MEMORY;
							end
						end
						BLT : begin
							if ($signed(REG_FILE[RS1]) < $signed(REG_FILE[RS2])) begin
								PC <= PC + {{20{IMM[12]}},IMM[12:1]};
								STAGE <= MEMORY;
							end
						end
						BGE : begin
							if ($signed(REG_FILE[RS1]) >= $signed(REG_FILE[RS2])) begin
								PC <= PC + {{20{IMM[12]}},IMM[12:1]};
								STAGE <= MEMORY;
							end
						end
						BLTU : begin
							if (REG_FILE[RS1] < REG_FILE[RS2]) begin
								PC <= PC + {{20{IMM[12]}},IMM[12:1]};
								STAGE <= MEMORY;
							end
						end
						BGEU : begin
							if (REG_FILE[RS1] >= REG_FILE[RS2]) begin
								PC <= PC + {{20{IMM[12]}},IMM[12:1]};
								STAGE <= MEMORY;
							end
						end
						default : begin
							STAGE <= MEMORY;
						end
					endcase
				end
				LOAD : begin
					case (CYCLE)
						0 : begin
							DATA_ADDR <= REG_FILE[RS1] + {{20{IMM[11]}},IMM[11:0]};
							CYCLE <= 1;
						end
						1 : begin
							case (F3)
								LB : begin
									case (SCYCLE)
										0 : begin
											REG_FILE[RD] <= {{24{DATA_IN[7]}},DATA_IN};
											SCYCLE <= 1;
										end
										1 : begin
											DATA_ADDR <= 0;
											SCYCLE <= 0;
											STAGE <= MEMORY;
											CYCLE <= 0;
										end
									endcase
								end
								LH : begin
									case (SCYCLE)
										0 : begin
											TMP[7:0] <= DATA_IN;
											SCYCLE <= 1;
										end
										1 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 2;
										end
										2 : begin
											REG_FILE[RD] <= {{16{DATA_IN[7]}},DATA_IN,TMP[7:0]};
											SCYCLE <= 3;
										end
										3 : begin
											STAGE <= MEMORY;
											DATA_ADDR <= 0;
											SCYCLE <= 0;
											CYCLE <= 0;
										end
										default : begin
										end
									endcase
								end
								LW : begin
									case (SCYCLE)
										0 : begin
											TMP[7:0] <= DATA_IN;
											SCYCLE <= 1;
										end
										1 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 2;
										end
										2 : begin
											TMP[15:8] <= DATA_IN;
											SCYCLE <= 3;
										end
										3 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 4;
										end
										4 : begin
											TMP[23:16] <= DATA_IN;
											SCYCLE <= 5;
										end
										5 : begin
											REG_FILE[RD] <= {DATA_IN,TMP[23:0]};
											SCYCLE <= 6;
										end
										6 : begin
											STAGE <= MEMORY;
											DATA_ADDR <= 0;
											SCYCLE <= 0;
											CYCLE <= 0;
										end
									endcase
								end
								LBU : begin
									case (SCYCLE)
										0 : begin
											REG_FILE[RD] <= {24'b0,DATA_IN};
											SCYCLE <= 1;
										end
										1 : begin
											STAGE <= MEMORY;
											DATA_ADDR <= 0;
											SCYCLE <= 0;
											CYCLE <= 0;
										end
										default : begin
										end
									endcase
								end
								LHU : begin
									case (SCYCLE)
										0 : begin
											TMP[7:0] <= DATA_IN;
											SCYCLE <= 1;
										end
										1 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 2;
										end
										2 : begin
											REG_FILE[RD] <= {16'b0,DATA_IN,TMP[7:0]};
											SCYCLE <= 3;
										end
										3 : begin
											STAGE <= MEMORY;
											DATA_ADDR <= 0;
											SCYCLE <= 0;
											CYCLE <= 0;
										end
									endcase
								end
								default : begin
								end
							endcase
						end
					endcase
				end
				STORE : begin
					case (CYCLE)
						0 : begin
							DATA_ADDR <= REG_FILE[RS1] + {{20{IMM[11]}},IMM[11:0]};
							TMP <= REG_FILE[RS2];
							DATA_WE <= 1;
							CYCLE <= 1;
						end
						1 : begin
							case (F3)
								SB : begin
									case (SCYCLE)
										0 : begin
											DATA_OUT <= TMP[7:0];
											SCYCLE <= 1;
										end
										1: begin
											DATA_OUT <= 0;
											STAGE <= MEMORY;
											SCYCLE <= 0;
											CYCLE <= 0;
											DATA_ADDR <= 0;
											DATA_WE <= 0;
										end
										default : begin
										end
									endcase
								end
								SH : begin
									case (SCYCLE)
										0 : begin
											DATA_OUT <= TMP[7:0];
											SCYCLE <= 1;
										end
										1 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 2;
										end
										2 : begin
											DATA_OUT <= TMP[15:8];
											SCYCLE <= 3;
										end
										3 : begin
											DATA_OUT <= 0;
											STAGE <= MEMORY;
											SCYCLE <= 0;
											CYCLE <= 0;
											DATA_ADDR <= 0;
											DATA_WE <= 0;
										end
										default : begin
										end
									endcase
								end
								SW : begin
									case (SCYCLE)
										0 : begin
											DATA_OUT <= TMP[7:0];
											SCYCLE <= 1;
										end
										1 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 2;
										end
										2 : begin
											DATA_OUT <= TMP[15:8];
											SCYCLE <= 3;
										end
										3 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 4;
										end
										4 : begin
											DATA_OUT <= TMP[23:16];
											SCYCLE <= 5;
										end
										5 : begin
											DATA_ADDR <= DATA_ADDR + 1;
											SCYCLE <= 6;
										end
										6 : begin
											DATA_OUT <= TMP[31:24];
											SCYCLE <= 7;
										end
										7 : begin
											DATA_OUT <= 0;
											STAGE <= MEMORY;
											SCYCLE <= 0;
											CYCLE <= 0;
											DATA_ADDR <= 0;
											DATA_WE <= 0;
										end
										default : begin
										end
									endcase
								end
								default : begin
								end
							endcase
						end
					endcase
				end
				ALUI : begin
					case (F3)
						ADDI : begin
							case (CYCLE)
								0 : begin
									REG_FILE[RD] <= REG_FILE[RS1] + {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
							endcase
						end
						SLTI : begin
							case (CYCLE)
								0 : begin
									if ($signed(REG_FILE[RS1]) < $signed({{20{IMM[11]}},IMM[11:0]})) begin
										REG_FILE[RD] <= 1;
									end
									else begin
										REG_FILE[RD] <= 0;
									end
									CYCLE <= 1;
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
								default : begin
								end
							endcase
						end
						SLTIU : begin
							case (CYCLE)
								0 : begin
									if (REG_FILE[RS1] < {{20{IMM[11]}},IMM[11:0]}) begin
										REG_FILE[RD] <= 1;
									end
									else begin
										REG_FILE[RD] <= 0;
									end
									CYCLE <= 1;
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
								default : begin
								end
							endcase
						end
						XORI : begin
							case (CYCLE)
								0 : begin
									REG_FILE[RD] <= REG_FILE[RS1] ^ {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
							endcase
						end
						ORI : begin
							case (CYCLE)
								0 : begin
									REG_FILE[RD] <= REG_FILE[RS1] | {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
							endcase
						end
						ANDI : begin
							case (CYCLE)
								0 : begin
									REG_FILE[RD] <= REG_FILE[RS1] & {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
							endcase
						end
						SLLI : begin
							case (CYCLE)
								0 : begin
									REG_FILE[RD] <= REG_FILE[RS1] << IMM[4:0];
									CYCLE <= 1;
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
							endcase
						end
						SRI : begin
							case (CYCLE)
								0: begin
									case (CMD[30])
										0 : begin
											REG_FILE[RD] <= REG_FILE[RS1] >> IMM[4:0];
											CYCLE <= 1;
										end
										1 : begin
											REG_FILE[RD] <= REG_FILE[RS1] >>> IMM[4:0];
											CYCLE <= 1;
										end
									endcase
								end
								1 : begin
									STAGE <= MEMORY;
									CYCLE <= 0;
								end
							endcase
						end
					endcase
				end
				ALU : begin
					case (CYCLE)
						0 : begin
							case (F3)
								ADD : begin
									case (CMD[30])
										0 : begin
											REG_FILE[RD] <= REG_FILE[RS1] + REG_FILE[RS2];
											CYCLE <= 1;
										end
										1 : begin
											REG_FILE[RD] <= REG_FILE[RS1] - REG_FILE[RS2];
											CYCLE <= 1;
										end
										default : begin
										end
									endcase
								end
								SLL : begin
									case (SCYCLE)
										0 : begin
											TMP <= REG_FILE[RS2];
											SCYCLE <= 1;
										end
										1: begin
											REG_FILE[RD] <= REG_FILE[RS1] << TMP[4:0];
											SCYCLE <= 0;
											CYCLE <= 1;
										end
										default : begin
										end
									endcase
								end
								SLT : begin
									if ($signed(REG_FILE[RS1]) < $signed(REG_FILE[RS2])) begin
										REG_FILE[RD] <= 1;
										CYCLE <= 1;
									end
									else begin
										REG_FILE[RD] <= 0;
										CYCLE <= 1;
									end
								end
								SLTU : begin
									if (REG_FILE[RS1] < REG_FILE[RS2]) begin
										REG_FILE[RD] <= 1;
										CYCLE <= 1;
									end
									else begin
										REG_FILE[RD] <= 0;
										CYCLE <= 1;
									end
								end
								XOR : begin
									REG_FILE[RD] <= REG_FILE[RS1] ^ REG_FILE[RS2];
									CYCLE <= 1;
								end
								SR : begin
									case (SCYCLE)
										0 : begin
											TMP <= REG_FILE[RS2];
											SCYCLE <= 1;
										end
										1 : begin
											case (CMD[30])
												0 : begin
													REG_FILE[RD] <= REG_FILE[RS1] >> TMP[4:0];
													SCYCLE <= 0;
													CYCLE <= 1;
												end
												1 : begin
													REG_FILE[RD] <= REG_FILE[RS1] >>> TMP[4:0];
													SCYCLE <= 0;
													CYCLE <= 1;
												end
												default : begin
												end
											endcase
										end
										default : begin
										end
									endcase
								end
								OR : begin
									REG_FILE[RD] <= REG_FILE[RS1] | REG_FILE[RS2];
									CYCLE <= 1;
								end
								AND : begin
									REG_FILE[RD] <= REG_FILE[RS1] & REG_FILE[RS2];
									CYCLE <= 1;
								end
							endcase
						end
						1 : begin
							STAGE <= MEMORY;
							CYCLE <= 0;
						end
					endcase
				end
				default : begin
				end
			endcase
		end
	end
endmodule
