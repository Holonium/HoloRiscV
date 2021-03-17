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
	reg [3:0] PC = 0;

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
					INSTR_ADDR <= PC;
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
					INSTR_ADDR <= PC;
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
						end
						I : begin
							SRC1 <= REG_FILE[RS1];
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
			
		end
	end
endmodule
