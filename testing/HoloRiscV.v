/*

This version of the core will use a 32 bit bus for address and 8 bit bus for data, along with separate instruction and data memories. It will implement the RV32I architecture.

NOTE: This version is not meant for implementation. It is the active development version meant to be run in a testbench.

*/

`timescale 1ns/100ps
`default_nettype none

module HoloRiscV (

	);
	
	reg [7:0] instr_mem [0:15];
	//reg [7:0] prog_mem [0:15];

	initial begin
		$dumpfile("HoloRiscV.vcd");
		$dumpvars(0,HoloRiscV);
		$readmemb("instr.mem",instr_mem);
		//$readmemb("prog.mem",prog_mem);
		#5000 $finish;
	end

	reg clk = 0;

	always #10 clk = !clk;

	//Define stages
	parameter FETCH = 3'b000;
	parameter DECODE = 3'b001;
	parameter EXECUTE = 3'b010;
	parameter MEMORY = 3'b011;
	parameter WRITEBACK = 3'b100;

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

	//Define instruction formats
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

	//Instruction memory I/O
	reg [3:0] INSTR_ADDR;
	reg [7:0] INSTR_DATA;
	reg INSTR_OE = 1;
	
	//Registers
	reg [31:0] CMD = 0;
	reg [31:0] REG_FILE [0:31];
	reg [31:0] PC = 0;

	//Control registers
	reg [2:0] STAGE = 0;
	reg [3:0] CYCLE = 4'b0000;
	reg [3:0] SCYCLE = 4'b0000;
	reg [2:0] TYPE;

	//Intermediate registers
	reg [4:0] RD = 0;
	reg [2:0] F3 = 0;
	reg [4:0] RS1 = 0;
	reg [4:0] RS2 = 0;
	reg [6:0] F7 = 0;
	reg [31:0] IMM = 0;
	reg [31:0] TMP = 0;
	reg [31:0] SRC1 = 0;
	reg [31:0] SRC2 = 0;
	reg [31:0] DEST = 0;

	always @(posedge clk) begin
		REG_FILE[0] <= 32'b0;
		//FETCH
		if (STAGE == FETCH) begin
			case (CYCLE)
				0 : begin
					INSTR_ADDR <= PC[3:0];
					CYCLE <= 1;
				end
				1 : begin
					CMD[7:0] <= instr_mem[INSTR_ADDR];
					CYCLE <= 2;
				end
				2 : begin
					INSTR_ADDR <= INSTR_ADDR + 1;
					CYCLE <= 3;
				end
				3 : begin
					CMD[15:8] <= instr_mem[INSTR_ADDR];
					CYCLE <= 4;
				end
				4 : begin
					INSTR_ADDR <= INSTR_ADDR + 1;
					CYCLE <= 5;
				end
				5 : begin
					CMD[23:16] <= instr_mem[INSTR_ADDR];
					CYCLE <= 6;
				end
				6 : begin
					INSTR_ADDR <= INSTR_ADDR + 1;
					CYCLE <= 7;
				end
				7 : begin
					CMD[31:24] <= instr_mem[INSTR_ADDR];
					CYCLE <= 8;
				end
				8 : begin
					CYCLE <= 0;
					STAGE <= DECODE;
					INSTR_ADDR <= PC[3:0];
				end
				default : begin
				end
			endcase
		end
		//DECODE
		if (STAGE == DECODE) begin
			case (CYCLE)
				0 : begin
					case (CMD[6:0])
						LUI : TYPE <= U;
						AUIPC : TYPE <= U;
						JAL : TYPE <= J;
						JALR : TYPE <= I;
						BRANCH : TYPE <= B;
						LOAD : TYPE <= I;
						STORE : TYPE <= S;
						ALUI : begin
							case (CMD[14:12])
								3'b001 : TYPE <= R;
								3'b101 : TYPE <= R;
								default : TYPE <= I;
							endcase
						end
						ALU : TYPE <= R;
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
					CYCLE <= 2;
				end
				2 : begin
					case (TYPE)
						R : begin
							SRC2 <= REG_FILE[RS2];
							SRC1 <= REG_FILE[RS1];
							//SRC1 <= {1'b1,31'b110000000};
							//SRC2 <= 32'b1110010;
						end
						I : begin
							SRC1 <= REG_FILE[RS1];
							//SRC1 <= {1'b0,7'b1,24'b0};
							//SRC1 <= {22'b111111111,10'b1111100};
						end
						S : begin
							SRC2 <= REG_FILE[RS2];
							SRC1 <= REG_FILE[RS1];
						end
						B : begin
							SRC2 <= REG_FILE[RS2];
							SRC1 <= REG_FILE[RS1];
						end
						default : begin
						end
					endcase
					CYCLE <= 3;
				end
				3 : begin
					CYCLE <= 0;
					STAGE <= EXECUTE;
					//STAGE <= FETCH;
					//PC <= PC + 4;
				end
			endcase
		end
		//EXECUTE
		if (STAGE == EXECUTE) begin
			case (CYCLE)
				0 : begin
					case (CMD[6:0])
						LUI : begin
							DEST <= {IMM[31:12],12'b0};
							CYCLE <= 1;
						end
						AUIPC : begin
							DEST <= PC + {IMM[31:12],12'b0};
							CYCLE <= 1;
						end
						JAL : begin
							case (SCYCLE)
								0: begin
									PC <= PC + {{12{IMM[20]}},IMM[20:1]};
									SCYCLE <= 1;
								end
								1 : begin
									DEST <= PC + 4;
									CYCLE <= 1;
									SCYCLE <= 0;
								end
								default : begin
								end
							endcase	
						end
						JALR : begin
							case (SCYCLE)
								0 : begin
									PC <= SRC1 + {{20{IMM[11]}},IMM[11:0]};
									SCYCLE <= 1;
								end
								1 : begin
									PC[0] <= 1'b0;
									SCYCLE <= 2;
								end
								2 : begin
									PC <= PC + 4;
									SCYCLE <= 3;
									CYCLE <= 1;
								end
								3 : begin
									//STAGE <= MEMORY;
									SCYCLE <= 0;
									CYCLE <= 1;
								end
								default : begin
								end
							endcase
						end
						BRANCH : begin
							case (F3)
								BEQ : begin
									if (SRC1 == SRC2) begin
										PC <= PC + {{20{IMM[12]}},IMM[12:1]};
									end
								end
								BNE : begin
									if (SRC1 != SRC2) begin
										PC <= PC + {{20{IMM[12]}},IMM[12:1]};
									end
								end
								BLT : begin
									if ($signed(SRC1) < $signed(SRC2)) begin
										PC <= PC + {{20{IMM[12]}},IMM[12:1]};
									end
								end
								BGE : begin
									if ($signed(SRC1) >= $signed(SRC2)) begin
										PC <= PC + {{20{IMM[12]}},IMM[12:1]};
									end
								end
								BLTU : begin
									if (SRC1 < SRC2) begin
										PC <= PC + {{20{IMM[12]}},IMM[12:1]};
									end
								end
								BGEU : begin
									if (SRC1 >= SRC2) begin
										PC <= PC + {{20{IMM[12]}},IMM[12:1]};
									end
								end
								default : begin
								end
							endcase
							CYCLE <= 1;
						end
						ALUI : begin
							case (F3)
								ADDI : begin
									DEST <= SRC1 + {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								SLTI : begin
									if ($signed(SRC1) < $signed({{20{IMM[11]}},IMM[11:0]})) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								SLTIU : begin
									if (SRC1 < {{20{IMM[11]}},IMM[11:0]}) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								XORI : begin
									DEST <= SRC1 ^ {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								ORI : begin
									DEST <= SRC1 | {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								ANDI : begin
									DEST <= SRC1 & {{20{IMM[11]}},IMM[11:0]};
									CYCLE <= 1;
								end
								SLLI : begin
									DEST <= SRC1 << CMD[24:20];
									CYCLE <= 1;
								end
								SRI : begin
									case (CMD[30])
										0 : begin
											DEST <= SRC1 >> CMD[24:20];
										end
										1 : begin
											DEST <= $signed(SRC1) >>> CMD[24:20];
										end
									endcase
									CYCLE <= 1;
								end
							endcase
						end
						ALU : begin
							case (F3)
								ADD : begin
									case (CMD[30])
										0 : begin
											DEST <= SRC1 + SRC2;
										end
										1 : begin
											DEST <= SRC1 - SRC2;
										end
									endcase
									CYCLE <= 1;
								end
								SLL : begin
									DEST <= SRC1 << SRC2[4:0];
									CYCLE <= 1;
								end
								SLT : begin
									if ($signed(SRC1) < $signed(SRC2)) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								SLTU : begin
									if (SRC1 < SRC2) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								XOR : begin
									DEST <= SRC1 ^ SRC2;
									CYCLE <= 1;
								end
								SR : begin
									case (CMD[30])
										0 : begin
											DEST <= SRC1 >> SRC2[4:0];
										end
										1 : begin
											DEST <= $signed(SRC1) >>> SRC2[4:0];
										end
									endcase
									CYCLE <= 1;
								end
								OR : begin
									DEST <= SRC1 | SRC2;
									CYCLE <= 1;
								end
								AND : begin
									DEST <= SRC1 & SRC2;
									CYCLE <= 1;
								end
							endcase
						end
						LOAD : CYCLE <= 1;
						STORE : CYCLE <= 1;
						default : begin
						end
					endcase
				end
				1 : begin
					STAGE <= MEMORY;
					CYCLE <= 0;
					SCYCLE <= 0;
				end
			endcase
		end
		//MEMORY
		if (STAGE == MEMORY) begin
			
		end
	end
endmodule
