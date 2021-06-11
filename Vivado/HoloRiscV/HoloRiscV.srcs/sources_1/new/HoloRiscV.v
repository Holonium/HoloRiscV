`timescale 1ns / 1ps
//`default_nettype none
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
    output ja_hld,
    output uart_rxd_out
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
	
    // Configure Clocks
    wire core_clk_mmcm;
    wire spi_sck_mmcm;
    wire uart_clk_mmcm;
    wire core_clk;
    wire spi_sck;
    wire mmcm_clkfb;
    wire locked;
    wire uart_clk;
    
    MMCME2_BASE #( .BANDWIDTH("OPTIMIZED"), .CLKFBOUT_MULT_F(10.000), .CLKIN1_PERIOD(10.000), .CLKOUT0_DIVIDE_F(100.000), .CLKOUT1_DIVIDE(10),
        .CLKOUT0_DUTY_CYCLE(0.5), .CLKOUT1_DUTY_CYCLE(0.5), .CLKOUT0_PHASE(0.000), .CLKOUT1_PHASE(0.000), .CLKOUT2_DIVIDE(100), .DIVCLK_DIVIDE(1), .REF_JITTER1(0.0))
    MMCME2_BASE_inst ( .CLKIN1(CLK100MHZ), .CLKOUT0(core_clk_mmcm), .CLKOUT1(spi_sck_mmcm), .CLKOUT2(uart_clk_mmcm), .CLKFBOUT(mmcm_clkfb), .LOCKED(locked), .PWRDWN(1'b0), .RST(1'b0),
        .CLKFBIN(mmcm_clkfb));
  
    BUFGCE core (.I(core_clk_mmcm), .O(core_clk), .CE(locked));
//    BUFGCE spi (.I(spi_sck_mmcm), .O(spi_sck), .CE(locked));
    BUFGCE uart_clock (.I(uart_clk_mmcm), .O(uart_clk), .CE(locked));
        
        
    reg [7:0] mem_file [0:511];
    reg [31:0] reg_file [0:31];
    
    initial begin
        $readmemh("ext.mem",mem_file);
    end
    
    reg init = 0;
    
    reg fetch_active = 0;
    reg decode_active = 0;
    reg execute_active = 0;
    reg memory_active = 0;
    reg writeback_active = 0;
    reg dump_active = 0;
    reg uart_active = 0;
    wire fetch_done;
    wire decode_done;
    wire execute_done;
    wire memory_done;
    wire incr;
    
    reg [14:0] addr = 0;
    wire [14:0] addr_mem = 0;
    wire [14:0] addr_out = 0;
    
    reg [31:0] mem_in = 0;
    wire [31:0] mem_out;
    
    reg [31:0] cmd;
    wire [6:0] opcode;
    wire [2:0] format;
    wire [4:0] rd;
    wire [2:0] f3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] f7;
    wire [31:0] extended;
    wire [31:0] imm;
    
    reg [31:0] mem_src1;
    reg [31:0] mem_src2;
    
    wire [31:0] dest_ex;
    reg [31:0] dest_mem;
    reg [31:0] mem_temp;
    reg [31:0] pc = 0;
    wire [31:0] pc_temp;
    
    /*assign ja_hld = 1;
    assign ja_wp = 1;
    assign ja_rst = 1;*/
    
    wire fetch_mosi;
    wire fetch_sck;
    wire fetch_cs;
    wire mem_mosi;
    wire mem_sck;
    wire mem_cs;
    
    reg mosi;
    reg sck;
    reg cs;
    
    reg [1:0] cycle = 0;
    reg dinit;
    
    assign ja_sck = uart_clk;
    
    wire uart_tx;
    //reg tx = 0;
//    assign uart_rxd_out = tx;
    /*assign ja_mosi = mosi;
    assign ja_sck = sck;
    assign ja_cs = cs;*/
    
    /*module ram(
    input clk,
    input we,
    input [9:0] addr,
    input [31:0] din,
    output reg [31:0] dout
    );*/
    
    reg we = 0;
    
    assign addr_mem[14:0] = dump_active ? addr_out[14:0] : addr[14:0];
    
    ram memory (
        .clk(core_clk),
        .we(we),
        .addr(addr_mem[14:0]),
        .din(mem_in),
        .dout(mem_out)
    );
    
    /*fetch core_fetch (
        .clk(spi_sck),
        .active(fetch_active),
        .miso(ja_miso),
        .instr(pc[23:0]),
        .mosi(fetch_mosi),
        .sck(fetch_sck),
        .cs(fetch_cs),
        .cmd(cmd),
        .done(fetch_done)
    );*/
    
    decode core_dec (
        .clk(core_clk), 
        .cmd(cmd), 
        .active(decode_active),
        .opcode(opcode),
        .format(format),
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
        .f3(f3), 
        .extended(extended), 
        .src1(reg_file[rs1]), 
        .src2(reg_file[rs2]),
        .pc_in(pc), 
        .imm(imm),
        .f7(f7),
        .dest(dest_ex),
        .pc_out(pc_temp),
        .done(execute_done)
    );
    
    /*memory core_mem (
        .clk(spi_sck),
        .active(memory_active),
        .miso(ja_miso),
        .src1(mem_src1[23:0]),
        .src2(mem_src2[23:0]),
        .imm(imm[23:0]),
        .f3(f3),
        .opcode(opcode),
        .mosi(mem_mosi),
        .sck(mem_sck),
        .cs(mem_cs),
        .dest(dest_mem),
        .done(memory_done)
    );*/
    
    uart dump (
        .clk(uart_clk),
        .din(mem_out),
        .active(dump_active),
        .next(incr),
        .tx(uart_rxd_out),
        .addr_out(addr_out[14:0])
        );
        
    //assign uart_rxd_out = uart_active ? 1'b1 : uart_tx;
        
    always @(posedge core_clk) begin
        /*if (fetch_active && fetch_done) begin
            fetch_active <= 0;
            decode_active <= 1;
        end*/
        if (fetch_active) begin
            //cmd <= {mem_file[pc[5:0]+3],mem_file[pc[8:0]+2],mem_file[pc[8:0]+1],mem_file[pc[8:0]]};
            if (cycle == 0) begin
                addr <= pc[14:0];
                cycle <= 1;
            end
            else begin
                cmd <= mem_out;
                fetch_active <= 0;
                decode_active <= 1;
                cycle <= 0;
            end
            /*fetch_active <= 0;
            decode_active <= 1;*/
        end
        if (decode_active && decode_done) begin
            decode_active <= 0;
            execute_active <= 1;
        end
        if (execute_active && execute_done) begin
            execute_active <= 0;
            memory_active <= 1;
//            reg_file[1] <= {16{2'b01}};
            mem_src1 <= reg_file[rs1];
            mem_src2 <= reg_file[rs2];
            addr <= mem_src1[31:0] + $signed({{10{imm[11]}},imm[11:0]});
        end
       /*if (memory_active && memory_done) begin
            memory_active <= 0;
            writeback_active <= 1;
        end*/
        if (memory_active) begin
            case (opcode)
                LOAD : begin
                    case (f3)
                        LB : begin
                            dest_mem <= {{24{mem_out[7]}},mem_out[7:0]};
                            writeback_active <= 1;
                            memory_active <= 0;
                        end
                        LH : begin
                            dest_mem <= {{16{mem_out[15]}},mem_out[15:0]};
                            writeback_active <= 1;
                            memory_active <= 0;
                        end
                        LW : begin
                            dest_mem <= mem_out;
                            writeback_active <= 1;
                            memory_active <= 0;
                        end
                        LBU : begin
                            dest_mem <= {{24{1'b0}},mem_out[7:0]};
                            writeback_active <= 1;
                            memory_active <= 0;
                        end
                        LHU : begin
                            dest_mem <= {{16{1'b0}},mem_out[15:0]};
                            writeback_active <= 1;
                            memory_active <= 0;
                        end
                        default : begin
                            writeback_active <= 1;
                            memory_active <= 0;
                        end
                    endcase
                end
                STORE : begin
                    case (f3)
                        SB : begin
                             case (cycle)
                                0 : begin
                                    mem_temp <= mem_out;
                                    cycle <= 1;
                                end
                                1 : begin
                                    mem_in <= {mem_temp[31:8],mem_src2[7:0]};
                                    cycle <= 2;
                                end
                                2 : begin
                                    we <= 1;
                                    cycle <= 3;
                                end
                                3 : begin
                                    we <= 0;
                                    cycle <= 0;
                                    mem_temp <= 0;
                                    mem_in <= 0;
                                    writeback_active <= 1;
                                    memory_active <= 0;
                                end
                             endcase
                        end
                        SH : begin
                            case (cycle)
                                0 : begin
                                    mem_temp <= mem_out;
                                    cycle <= 1;
                                end
                                1 : begin
                                    mem_in <= {mem_temp[31:16],mem_src2[15:0]};
                                    cycle <= 2;
                                end
                                2 : begin
                                    we <= 1;
                                    cycle <= 3;
                                end
                                3 : begin
                                    we <= 0;
                                    cycle <= 0;
                                    mem_temp <= 0;
                                    mem_in <= 0;
                                    writeback_active <= 1;
                                    memory_active <= 0;
                                end
                             endcase
                        end
                        SW : begin
                            case (cycle)
                                0 : begin
                                    mem_temp <= mem_out;
                                    cycle <= 1;
                                end
                                1 : begin
                                    mem_in <= mem_src2;
                                    cycle <= 2;
                                end
                                2 : begin
                                    we <= 1;
                                    cycle <= 3;
                                end
                                3 : begin
                                    we <= 0;
                                    cycle <= 0;
                                    mem_temp <= 0;
                                    mem_in <= 0;
                                    writeback_active <= 1;
                                    memory_active <= 0;
                                end
                             endcase
                        end
                        default : begin
                            writeback_active <= 1;
                            memory_active <= 0;
                        end
                    endcase
                end
                default : begin
                    writeback_active <= 1;
                    memory_active <= 0;
                end
            endcase
        end
        if (writeback_active) begin
            if (opcode == LOAD) reg_file[rd] <= dest_mem;
            else reg_file[rd] <= dest_ex;
//            tx <= !tx;
            if (pc == 16) begin
                addr <= 0;
                dump_active <= 1;
                writeback_active <= 0;
                fetch_active <= 0;
            end
            else if (pc < 16) begin
                pc <= pc_temp + 4;
                writeback_active <= 0;
                fetch_active <= 1;
            end
        end
        if (dump_active) begin
            case (cycle)
                0 : begin
                    if (!dinit) begin
                        fetch_active <= 0;
                        decode_active <= 0;
                        execute_active <= 0;
                        memory_active <= 0;
                        writeback_active <= 0;
//                        addr <= 0;
                        cycle <= 1;
                    end
                end
                1 : begin
                    if (addr_out[0] == 1) addr[0] <= 1; 
//                    uart_active <= 1;
//                    cycle <= 3;
                    if (addr_out == 3) dump_active <= 0;
                end
                2 : begin
//                    cycle <= 1;
                end
                3 : begin
//                    if (incr && addr_out < 3) begin
//                        addr <= addr + 1;
//                        uart_active <= 0;
//                        cycle <= 2;
//                    end
//                    else begin
//                        uart_active <= 1;
//                    end
                end
            endcase
        end
        reg_file[0] <= 0;
        /*if (fetch_active && !memory_active) begin
            mosi <= fetch_mosi;
            cs <= fetch_cs;
            sck <= fetch_sck;
        end
        if (memory_active && !fetch_active) begin
            mosi <= mem_mosi;
            cs <= mem_cs;
            sck <= mem_sck;
        end*/
        if (!init) begin
            reg_file[1] <= 0;
            reg_file[2] <= 0;
            reg_file[3] <= 0;
            reg_file[4] <= 0;
            reg_file[5] <= 0;
            reg_file[6] <= 0;
            reg_file[7] <= 0;
            reg_file[8] <= 0;
            reg_file[9] <= 0;
            reg_file[10] <= 0;
            reg_file[11] <= 0;
            reg_file[12] <= 0;
            reg_file[13] <= 0;
            reg_file[14] <= 0;
            reg_file[15] <= 0;
            reg_file[16] <= 0;
            reg_file[17] <= 0;
            reg_file[18] <= 0;
            reg_file[19] <= 0;
            reg_file[20] <= 0;
            reg_file[21] <= 0;
            reg_file[22] <= 0;
            reg_file[23] <= 0;
            reg_file[24] <= 0;
            reg_file[25] <= 0;
            reg_file[26] <= 0;
            reg_file[27] <= 0;
            reg_file[28] <= 0;
            reg_file[29] <= 0;
            reg_file[30] <= 0;
            reg_file[31] <= 0;
            dinit <= 0;
            init <= 1;
            fetch_active <= 1;
        end
        if (!rst) begin
            init <= 0;
        end
    end
endmodule
