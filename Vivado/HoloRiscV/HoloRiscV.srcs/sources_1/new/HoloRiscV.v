`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Holonium
// 
// Create Date: 06/12/2021 02:16:08 PM
// Design Name: HoloRiscV
// Module Name: HoloRiscV
// Project Name: HoloRiscV
// Target Devices: xc7a35ticsg324-1L
// Tool Versions: Vivado 2020.2
// Description: This is the core module of the HoloRiscV core.
// 
// Dependencies: decode.v, execute.v, ram.v, uart.v
// 
// Revision:
// Revision 0.0.1 - File Created
// Revision 1.0.0 - Began rebuild
// Additional Comments: This is not the final code, rather it is a checkpoint.
// 
//////////////////////////////////////////////////////////////////////////////////

`define END 16
`define END_DUMP 256

module HoloRiscV (
    input CLK100MHZ,
    input rst,
    output uart_rxd_out
    );

    parameter LOAD = 7'b0000011;
    parameter STORE = 7'b0100011;

    parameter LB = 3'b000;
	parameter LH = 3'b001;
	parameter LW = 3'b010;
	parameter LBU = 3'b100;
	parameter LHU = 3'b101;

    parameter SB = 3'b000;
	parameter SH = 3'b001;
	parameter SW = 3'b010;

    // Define Clocks
    wire core_clk_mmcm;
    wire spi_sck_mmcm;
    wire uart_clk_mmcm;
    wire core_clk;
    wire spi_sck;
    wire uart_clk;

    // Define MMCM controls
    wire mmcm_clkfb;
    wire locked;

    // Instantiate MMCM
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT_F(10.000),
        .CLKIN1_PERIOD(10.000),
        .CLKOUT0_DIVIDE_F(100.000),
        .CLKOUT1_DIVIDE(10),
        .CLKOUT2_DIVIDE(100),
        .REF_JITTER1(0.0)
    ) MMCM_MASTER (
        .CLKIN1(CLK100MHZ),
        .CLKFBIN(mmcm_clkfb),
        .CLKOUT0(core_clk_mmcm),
        .CLKOUT1(spi_sck_mmcm),
        .CLKOUT2(uart_clk_mmcm),
        .CLKFBOUT(mmcm_clkfb),
        .LOCKED(locked),
        .PWRDWN(1'b0),
        .RST(!rst)
    );

    // Instantiate Clock Buffers
    BUFGCE core (
        .I(core_clk_mmcm),
        .O(core_clk),
        .CE(locked)
    );
    /*BUFGCE spi (
        .I(spi_sck_mmcm),
        .O(spi_sck),
        .CE(locked)
    );*/
    BUFGCE uart_clock (
        .I(uart_clk_mmcm),
        .O(uart_clk),
        .CE(locked)
    );

    // Define Module Controls
    reg fetch_active = 0;
    reg decode_active = 0;
    reg execute_active = 0;
    reg memory_active = 0;
    reg writeback_active = 0;
    reg dump_active = 0;
    wire decode_done;
    wire execute_done;
    
    // Define Module Signals
    wire [14:0] addr_mem;
    reg we = 0;
    reg [31:0] mem_in = 0;
    wire [31:0] mem_out;
    reg [31:0] cmd = 0;
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] f3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] f7;
    wire [31:0] imm;
    wire [31:0] extended;
    wire [31:0] dest_ex;
    wire [31:0] pc_temp;
    wire [14:0] addr_out;

    // Define Core Signals
    reg init = 0;
    reg dinit = 0;
    reg [1:0] cycle = 0;
    reg [31:0] dest_mem = 0;
    reg [31:0] pc = 0;
    reg [31:0] reg_file [0:31];
    reg [14:0] addr = 0;
    reg [31:0] mem_src1 = 0;
    reg [31:0] mem_src2 = 0;

    assign addr_mem[14:0] = dump_active ? addr_out[14:0] : addr[14:0];

    // Instantiate Modules
    ram core_ram (
        .clk(core_clk),
        .we(we),
        .addr(addr_mem[14:0]),
        .din(mem_in),
        .dout(mem_out)
    );

    decode core_dec (
        .clk(core_clk),
        .cmd(cmd),
        .active(decode_active),
        .opcode(opcode),
        .rd(rd),
        .f3(f3),
        .rs1(rs1),
        .rs2(rs2),
        .f7(f7),
        .imm(imm),
        .extended(extended),
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
    
    uart core_dump (
        .clk(uart_clk),
        .din(mem_out),
        .active(dump_active),
        .tx(uart_rxd_out),
        .addr(addr_out)
    );

    always @(posedge core_clk) begin
        if (locked && rst) begin
            if (fetch_active) begin
                if (cycle == 0) begin
                    addr <= pc[14:0] >> 2;
                    cycle <= 1;
                end
                else if (cycle == 1) begin
                    cmd <= mem_out;
                    fetch_active <= 0;
                    decode_active <= 1;
                    cycle <= 0;
                end
            end
            else if (decode_active && decode_done) begin
                decode_active <= 0;
                execute_active <= 1;
            end
            else if (execute_active && execute_done) begin
                mem_src1 <= reg_file[rs1];
                mem_src2 <= reg_file[rs2];
                addr <= mem_src1[14:0] + $signed({{3{imm[11]}},imm[11:0]});
                execute_active <= 0;
                memory_active <= 1;
            end
            else if (memory_active) begin
                case (opcode)
                    LOAD : begin
                        case (f3)
                            LB : begin
                                dest_mem <= {{24{mem_out[7]}},mem_out[7:0]};
                                memory_active <= 0;
                                writeback_active <= 1;
                            end
                            LH : begin
                                dest_mem <= {{16{mem_out[7]}},mem_out[15:0]};
                                memory_active <= 0;
                                writeback_active <= 1; 
                            end
                            LW : begin
                                dest_mem <= mem_out;
                                memory_active <= 0;
                                writeback_active <= 1;
                            end
                            LBU : begin
                                dest_mem <= {{24{1'b0}},mem_out[7:0]};
                                memory_active <= 0;
                                writeback_active <= 1;
                            end
                            LHU : begin
                                dest_mem <= {{16{1'b0}},mem_out[15:0]};
                                memory_active <= 0;
                                writeback_active <= 1;
                            end
                        endcase
                    end
                    STORE : begin
                        case (cycle)
                            0 : begin
                                case (f3)
                                    SB : begin
                                        mem_in <= {mem_out[31:8],mem_src2[7:0]};
                                        cycle <= 1;
                                    end
                                    SH : begin
                                        mem_in <= {mem_out[31:16],mem_src2[15:0]};
                                        cycle <= 1;
                                    end
                                    SW : begin
                                        mem_in <= mem_src2;
                                        cycle <= 1;
                                    end
                                endcase
                            end
                            1 : begin
                                we <= 1;
                                cycle <= 2;
                            end
                            2 : begin
                                cycle <= 3;
                            end
                            3 : begin
                                we <= 0;
                                cycle <= 0;
                                mem_in <= 0;
                                memory_active <= 0;
                                writeback_active <= 1;
                            end
                        endcase
                    end
                    default : begin
                        memory_active <= 0;
                        writeback_active <= 1;
                    end
                endcase
            end
            else if (writeback_active) begin
                if (opcode == LOAD) reg_file[rd] <= dest_mem;
                else reg_file[rd] <= dest_ex;
                if (pc == `END) begin
                    addr <= 0;
                    dump_active <= 1;
                    writeback_active <= 0;
                    fetch_active <= 0;
                end
                else if (pc < `END) begin
                    pc <= pc_temp + 4;
                    writeback_active <= 0;
                    fetch_active <= 1;
                end
            end
            else if (dump_active) begin
                if (!dinit) begin
                    fetch_active <= 0;
                    decode_active <= 0;
                    execute_active <= 0;
                    memory_active <= 0;
                    writeback_active <= 0;
                    dinit <= 1;
                end
                else begin
                    case (cycle)
                        0 : begin
                            if (addr_out == `END_DUMP) cycle <= 1;
                        end
                        1 : begin
                            
                        end
                    endcase
                end
            end
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
                pc <= 0;
            end
            reg_file[0] <= 0;
        end
        if (!rst) init <= 0;
    end
endmodule