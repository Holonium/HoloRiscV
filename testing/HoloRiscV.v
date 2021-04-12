/*

This version of the core will use a 32 bit bus for address and 8 bit bus for data, along with separate instruction and data memories. It will implement the RV32I architecture.

NOTE: This version is not meant for implementation. It is the active development version meant to be run in a testbench.

*/

`timescale 1ns/100ps
`default_nettype none

module HoloRiscV (

	);
	
	reg [7:0] instr_mem [0:3];
	reg [7:0] prog_mem [0:15];
	//reg [31:0] reg_init [0:31];

	initial begin
		$dumpfile("HoloRiscV.vcd");
		$dumpvars(0,HoloRiscV);
		$readmemb("instr.mem",instr_mem);
		$readmemb("prog.mem",prog_mem);
		//$readmemb("reg.mem",REG_FILE);
		#1000 $finish;
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
	reg [1:0] INSTR_ADDR;
	reg [7:0] INSTR_DATA;
	reg INSTR_OE = 1;
	
	//Program memory I/O
	reg [31:0] DATA_ADDR;
	reg [7:0] DATA_OUT;
	reg [7:0] DATA_IN;
	reg DATA_OE = 0;
	reg DATA_WE = 0;

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
	reg [31:0] EXTENDED = 0;

	reg [7:0] INSTR = 0;

	always @(posedge clk) begin
		REG_FILE[0] <= 0;
		//FETCH
		if (STAGE == FETCH) begin
			
		end
		//DECODE
		if (STAGE == DECODE) begin
			
		end
		//EXECUTE
		if (STAGE == EXECUTE) begin
			
		end
		//MEMORY
		if (STAGE == MEMORY) begin //BROKEN
			
		end
		//WRITEBACK
		if (STAGE == WRITEBACK) begin //FUNCTIONAL
			
		end
	end
endmodule
