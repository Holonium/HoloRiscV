/*

This version of the core is designed for implementation on a chip. Currently, only the RV32I ISA is being implemented.
The exception to this is the EBREAK, ECALL, and FENCE instructions.
The pipeline is composed of 5 stages, none of which currently run in parallel.

The code expects a 10 MHz clock input.

In this revision, the parallel flash has been changed in favor of SPI flash.

*/

`default_nettype none

module HoloRiscV (
	input clk,
	input rst,
	input SI,
	output reg SCK = 1,
	output reg SO,
	output reg nCS = 1,
	output reg nWP = 0,
	output reg nHOLD = 0
	);
	
	//Define stages
	parameter FETCH = 3'b000;
	parameter DECODE = 3'b001;
	parameter EXECUTE = 3'b010;
	parameter MEMORY = 3'b011;
	parameter WRITEBACK = 3'b100;

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

	//Define SPI instructions
    parameter WREN = 8'b00000110;
    parameter WRDI = 8'b00000100;
    parameter RDSR = 8'b00000101;
    parameter WRSR = 8'b00000001;
    parameter READ = 8'b00000011;
    parameter WRITE = 8'b00000010;

	//Define registers
	reg [31:0] CMD = 0;
	reg [31:0] REG_FILE [0:31];
	reg [31:0] PC = 0;

	//Define control registers
	reg [2:0] STAGE = 0;
	reg [3:0] CYCLE = 4'b0000;
	reg [3:0] SCYCLE = 4'b0000;
	reg SSTAGE = 0;
	reg [2:0] TYPE;

	integer i = 0;

	//Define intermediate registers
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
	reg [31:0] EXTENDED = 0;
	reg [31:0] SPI_IN = 0;
	reg [31:0] SPI_BUF;

	always @(posedge clk) begin
		REG_FILE[0] <= 0;
		//FETCH
		if (STAGE == FETCH) begin
			SPI_BUF <= {READ,PC[23:0]};
			if (i < 101) begin
				if (i == 0) begin
					nCS <= 0;
					i <= i + 1;
				end
				else if (i < 34) begin
					case (SSTAGE)
						0 : begin
							SO <= SPI_BUF[31];
							SSTAGE <= 1;
						end
						1 : begin
							i <= i + 1;
							SSTAGE <= 0;
							SPI_BUF <= SPI_BUF << 1;
						end
					endcase
				end
				else begin
					case (SSTAGE)
						0 : begin
							SPI_IN[0] <= SI;
							SSTAGE <= 1;
						end
						1 : begin
							i <= i + 1;
							SSTAGE <= 0;
							SPI_IN <= SPI_IN << 1;
						end
					endcase
					i <= i + 1;
				end
			end
			else begin
				nCS <= 1;
				CMD <= SPI_IN;
				STAGE <= DECODE;
				SSTAGE <= 0;
				i <= 0;
			end
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
							EXTENDED <= {{20{CMD[31]}},IMM[31:20]};
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
							EXTENDED <= {{20{CMD[31]}},IMM[31:20]};
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
						LUI : begin //FUNCTIONAL
							DEST <= {IMM[31:12],{12{1'b0}}};
							CYCLE <= 1;
						end
						AUIPC : begin //FUNCTIONAL
							DEST <= PC + {IMM[31:12],{12{1'b0}}};
							CYCLE <= 1;
						end
						JAL : begin //PROBLEM LOCATED
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
						JALR : begin //PROBLEM LOCATED
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
						BRANCH : begin //UNTESTED DUE TO HIGH CHANCE OF PROBLEMS
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
						ALUI : begin //FUNCTIONAL
							case (F3)
								ADDI : begin //FUNCTIONAL
									DEST <= SRC1 + EXTENDED;
									CYCLE <= 1;
								end
								SLTI : begin //FUNCTIONAL
									if ($signed(SRC1) < $signed(EXTENDED)) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								SLTIU : begin //FUNCTIONAL
									if (SRC1 < EXTENDED) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								XORI : begin //FUNCTIONAL
									//DEST <= SRC1 ^ {{20{IMM[11]}},IMM[11:0]};
									DEST <= SRC1 ^ EXTENDED;
									CYCLE <= 1;
								end
								ORI : begin //FUNCTIONAL
									//DEST <= SRC1 | {{20{IMM[11]}},IMM[11:0]};
									DEST <= SRC1 | EXTENDED;
									CYCLE <= 1;
								end
								ANDI : begin //FUNCTIONAL
									//DEST <= SRC1 & {{20{IMM[11]}},IMM[11:0]};
									DEST <= SRC1 ^ EXTENDED;
									CYCLE <= 1;
								end
								SLLI : begin //FUNCTIONAL
									DEST <= SRC1 << CMD[24:20];
									CYCLE <= 1;
								end
								SRI : begin //FUNCTIONAL
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
						ALU : begin //FUNCTIONAL
							case (F3)
								ADD : begin //FUNCTIONAL
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
								SLL : begin //FUNCTIONAL
									DEST <= SRC1 << SRC2[4:0];
									CYCLE <= 1;
								end
								SLT : begin //FUNCTIONAL
									if ($signed(SRC1) < $signed(SRC2)) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								SLTU : begin //FUNCTIONAL
									if (SRC1 < SRC2) begin
										DEST <= 1;
									end
									else begin
										DEST <= 0;
									end
									CYCLE <= 1;
								end
								XOR : begin //FUNCTIONAL
									DEST <= SRC1 ^ SRC2;
									CYCLE <= 1;
								end
								SR : begin //FUNCTIONAL
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
								OR : begin //FUNCTIONAL
									DEST <= SRC1 | SRC2;
									CYCLE <= 1;
								end
								AND : begin //FUNCTIONAL
									DEST <= SRC1 & SRC2;
									CYCLE <= 1;
								end
							endcase
						end
						LOAD : CYCLE <= 1;
						STORE : CYCLE <= 1;
						default : begin
							CYCLE <= 1;
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
		//WRITEBACK
		if (STAGE == WRITEBACK) begin
			case (CYCLE)
				0 : begin
					REG_FILE[RD] <= DEST;
					PC <= PC + 4;
					CYCLE <= 1;
				end
				1 : begin
					CYCLE <= 0;
					STAGE <= FETCH;
				end
				default : begin
				end
			endcase
		end
	end
	always @(negedge clk) begin
		SCK <= !SCK;
	end

endmodule
