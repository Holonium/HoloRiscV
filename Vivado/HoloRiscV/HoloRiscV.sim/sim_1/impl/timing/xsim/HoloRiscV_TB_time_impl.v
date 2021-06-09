// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Mon Jun  7 12:22:31 2021
// Host        : DarkstarXII running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               C:/Users/Holonium/Documents/HoloRiscV/Vivado/HoloRiscV/HoloRiscV.sim/sim_1/impl/timing/xsim/HoloRiscV_TB_time_impl.v
// Design      : HoloRiscV
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a35ticsg324-1L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "cfa05eed" *) (* init = "3'b000" *) 
(* NotValidForBitStream *)
module HoloRiscV
   (CLK100MHZ,
    rst,
    ja_miso,
    ja_mosi,
    ja_cs,
    ja_sck,
    ja_rst,
    ja_wp,
    ja_hld);
  input CLK100MHZ;
  input rst;
  input ja_miso;
  output ja_mosi;
  output ja_cs;
  output ja_sck;
  output ja_rst;
  output ja_wp;
  output ja_hld;

  wire CLK100MHZ;
  wire CLK100MHZ_IBUF;
  wire ja_cs;
  wire ja_cs_OBUF;
  wire ja_hld;
  wire ja_mosi;
  wire ja_mosi_OBUF;
  wire ja_rst;
  wire ja_sck;
  wire ja_sck_OBUF;
  wire ja_wp;
  wire locked;
  wire mmcm_clkfb;
  wire spi_sck;
  wire spi_sck_mmcm;
  wire NLW_MMCME2_BASE_inst_CLKFBOUTB_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKFBSTOPPED_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKINSTOPPED_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT0_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT0B_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT1B_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT2_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT2B_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT3_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT3B_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT4_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT5_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_CLKOUT6_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_DRDY_UNCONNECTED;
  wire NLW_MMCME2_BASE_inst_PSDONE_UNCONNECTED;
  wire [15:0]NLW_MMCME2_BASE_inst_DO_UNCONNECTED;

initial begin
 $sdf_annotate("HoloRiscV_TB_time_impl.sdf",,,,"tool_control");
end
  IBUF CLK100MHZ_IBUF_inst
       (.I(CLK100MHZ),
        .O(CLK100MHZ_IBUF));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* OPT_MODIFIED = "SWEEP BUFG_OPT" *) 
  (* XILINX_LEGACY_PRIM = "MMCME2_BASE" *) 
  MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT_F(10.000000),
    .CLKFBOUT_PHASE(0.000000),
    .CLKFBOUT_USE_FINE_PS("FALSE"),
    .CLKIN1_PERIOD(10.000000),
    .CLKIN2_PERIOD(10.000000),
    .CLKOUT0_DIVIDE_F(10.000000),
    .CLKOUT0_DUTY_CYCLE(0.500000),
    .CLKOUT0_PHASE(0.000000),
    .CLKOUT0_USE_FINE_PS("FALSE"),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT1_DUTY_CYCLE(0.500000),
    .CLKOUT1_PHASE(0.000000),
    .CLKOUT1_USE_FINE_PS("FALSE"),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.500000),
    .CLKOUT2_PHASE(0.000000),
    .CLKOUT2_USE_FINE_PS("FALSE"),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.500000),
    .CLKOUT3_PHASE(0.000000),
    .CLKOUT3_USE_FINE_PS("FALSE"),
    .CLKOUT4_CASCADE("FALSE"),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.500000),
    .CLKOUT4_PHASE(0.000000),
    .CLKOUT4_USE_FINE_PS("FALSE"),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.500000),
    .CLKOUT5_PHASE(0.000000),
    .CLKOUT5_USE_FINE_PS("FALSE"),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.500000),
    .CLKOUT6_PHASE(0.000000),
    .CLKOUT6_USE_FINE_PS("FALSE"),
    .COMPENSATION("INTERNAL"),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.000000),
    .REF_JITTER2(0.010000),
    .SS_EN("FALSE"),
    .SS_MODE("CENTER_HIGH"),
    .SS_MOD_PERIOD(10000),
    .STARTUP_WAIT("FALSE")) 
    MMCME2_BASE_inst
       (.CLKFBIN(mmcm_clkfb),
        .CLKFBOUT(mmcm_clkfb),
        .CLKFBOUTB(NLW_MMCME2_BASE_inst_CLKFBOUTB_UNCONNECTED),
        .CLKFBSTOPPED(NLW_MMCME2_BASE_inst_CLKFBSTOPPED_UNCONNECTED),
        .CLKIN1(CLK100MHZ_IBUF),
        .CLKIN2(1'b0),
        .CLKINSEL(1'b1),
        .CLKINSTOPPED(NLW_MMCME2_BASE_inst_CLKINSTOPPED_UNCONNECTED),
        .CLKOUT0(NLW_MMCME2_BASE_inst_CLKOUT0_UNCONNECTED),
        .CLKOUT0B(NLW_MMCME2_BASE_inst_CLKOUT0B_UNCONNECTED),
        .CLKOUT1(spi_sck_mmcm),
        .CLKOUT1B(NLW_MMCME2_BASE_inst_CLKOUT1B_UNCONNECTED),
        .CLKOUT2(NLW_MMCME2_BASE_inst_CLKOUT2_UNCONNECTED),
        .CLKOUT2B(NLW_MMCME2_BASE_inst_CLKOUT2B_UNCONNECTED),
        .CLKOUT3(NLW_MMCME2_BASE_inst_CLKOUT3_UNCONNECTED),
        .CLKOUT3B(NLW_MMCME2_BASE_inst_CLKOUT3B_UNCONNECTED),
        .CLKOUT4(NLW_MMCME2_BASE_inst_CLKOUT4_UNCONNECTED),
        .CLKOUT5(NLW_MMCME2_BASE_inst_CLKOUT5_UNCONNECTED),
        .CLKOUT6(NLW_MMCME2_BASE_inst_CLKOUT6_UNCONNECTED),
        .DADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DCLK(1'b0),
        .DEN(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DO(NLW_MMCME2_BASE_inst_DO_UNCONNECTED[15:0]),
        .DRDY(NLW_MMCME2_BASE_inst_DRDY_UNCONNECTED),
        .DWE(1'b0),
        .LOCKED(locked),
        .PSCLK(1'b0),
        .PSDONE(NLW_MMCME2_BASE_inst_PSDONE_UNCONNECTED),
        .PSEN(1'b0),
        .PSINCDEC(1'b0),
        .PWRDWN(1'b0),
        .RST(1'b0));
  OBUF ja_cs_OBUF_inst
       (.I(ja_cs_OBUF),
        .O(ja_cs));
  OBUFT ja_hld_OBUF_inst
       (.I(1'b0),
        .O(ja_hld),
        .T(1'b1));
  OBUF ja_mosi_OBUF_inst
       (.I(ja_mosi_OBUF),
        .O(ja_mosi));
  OBUFT ja_rst_OBUF_inst
       (.I(1'b0),
        .O(ja_rst),
        .T(1'b1));
  OBUF ja_sck_OBUF_inst
       (.I(ja_sck_OBUF),
        .O(ja_sck));
  OBUFT ja_wp_OBUF_inst
       (.I(1'b0),
        .O(ja_wp),
        .T(1'b1));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* OPT_MODIFIED = "BUFG_OPT" *) 
  (* XILINX_LEGACY_PRIM = "BUFGCE" *) 
  (* XILINX_TRANSFORM_PINMAP = "CE:CE0 I:I0" *) 
  BUFGCTRL #(
    .CE_TYPE_CE0("SYNC"),
    .CE_TYPE_CE1("SYNC"),
    .INIT_OUT(0),
    .PRESELECT_I0("TRUE"),
    .PRESELECT_I1("FALSE"),
    .SIM_DEVICE("7SERIES"),
    .STARTUP_SYNC("FALSE")) 
    spi
       (.CE0(locked),
        .CE1(1'b0),
        .I0(spi_sck_mmcm),
        .I1(1'b1),
        .IGNORE0(1'b0),
        .IGNORE1(1'b1),
        .O(spi_sck),
        .S0(1'b1),
        .S1(1'b0));
  fetch spi_comm
       (.clk_out(ja_sck_OBUF),
        .cs(ja_cs_OBUF),
        .mosi(ja_mosi_OBUF),
        .spi_sck(spi_sck));
endmodule

module fetch
   (mosi,
    cs,
    clk_out,
    spi_sck);
  output mosi;
  output cs;
  output clk_out;
  input spi_sck;

  wire CYCLE;
  wire \FSM_onehot_CYCLE[1]_i_1_n_0 ;
  wire \FSM_onehot_CYCLE[3]_i_1_n_0 ;
  wire \FSM_onehot_CYCLE[9]_i_2_n_0 ;
  wire \FSM_onehot_CYCLE[9]_i_3_n_0 ;
  wire \FSM_onehot_CYCLE_reg_n_0_[0] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[1] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[2] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[3] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[4] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[5] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[6] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[7] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[8] ;
  wire \FSM_onehot_CYCLE_reg_n_0_[9] ;
  wire bout;
  wire \bout[1]_i_1_n_0 ;
  wire \bout[1]_i_2_n_0 ;
  wire \bout[7]_i_1_n_0 ;
  wire byte_shift;
  wire \byte_shift[0]_i_1_n_0 ;
  wire \byte_shift[1]_i_1_n_0 ;
  wire \byte_shift[2]_i_1_n_0 ;
  wire \byte_shift[3]_i_2_n_0 ;
  wire \byte_shift_reg_n_0_[0] ;
  wire \byte_shift_reg_n_0_[1] ;
  wire \byte_shift_reg_n_0_[2] ;
  wire \byte_shift_reg_n_0_[3] ;
  wire clk_out;
  wire clk_out_i_1_n_0;
  wire clk_out_i_2_n_0;
  wire cs;
  wire cs_i_1_n_0;
  wire [7:2]in5;
  wire mosi;
  wire mosi_i_1_n_0;
  wire mosi_i_2_n_0;
  wire p_0_in;
  wire spi_sck;

  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'hFF54)) 
    \FSM_onehot_CYCLE[1]_i_1 
       (.I0(\byte_shift_reg_n_0_[3] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[0] ),
        .O(\FSM_onehot_CYCLE[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_onehot_CYCLE[3]_i_1 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I1(\byte_shift_reg_n_0_[3] ),
        .O(\FSM_onehot_CYCLE[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \FSM_onehot_CYCLE[9]_i_1 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[0] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[4] ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I4(\FSM_onehot_CYCLE[9]_i_3_n_0 ),
        .I5(\FSM_onehot_CYCLE_reg_n_0_[5] ),
        .O(CYCLE));
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_onehot_CYCLE[9]_i_2 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I1(\byte_shift_reg_n_0_[3] ),
        .O(\FSM_onehot_CYCLE[9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \FSM_onehot_CYCLE[9]_i_3 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[7] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[1] ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[6] ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[9] ),
        .I4(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .O(\FSM_onehot_CYCLE[9]_i_3_n_0 ));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b1)) 
    \FSM_onehot_CYCLE_reg[0] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(1'b0),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[0] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[1] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE[1]_i_1_n_0 ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[1] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[2] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE_reg_n_0_[1] ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[3] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE[3]_i_1_n_0 ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[4] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[4] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[5] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE_reg_n_0_[4] ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[5] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[6] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE_reg_n_0_[5] ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[6] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[7] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE_reg_n_0_[6] ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[7] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[8] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE_reg_n_0_[7] ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "iSTATE:00000001000,iSTATE0:00000010000,iSTATE1:00000000100,iSTATE2:10000000000,iSTATE3:00000000010,iSTATE4:00000000001,iSTATE5:00010000000,iSTATE6:01000000000,iSTATE7:00100000000,iSTATE8:00001000000,iSTATE9:00000100000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_CYCLE_reg[9] 
       (.C(spi_sck),
        .CE(CYCLE),
        .D(\FSM_onehot_CYCLE[9]_i_2_n_0 ),
        .Q(\FSM_onehot_CYCLE_reg_n_0_[9] ),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFDFDFDFFF0F0F0F0)) 
    \bout[1]_i_1 
       (.I0(\bout[1]_i_2_n_0 ),
        .I1(\byte_shift_reg_n_0_[3] ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[4] ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I4(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I5(in5[2]),
        .O(\bout[1]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \bout[1]_i_2 
       (.I0(\byte_shift_reg_n_0_[0] ),
        .I1(\byte_shift_reg_n_0_[3] ),
        .I2(\byte_shift_reg_n_0_[2] ),
        .I3(\byte_shift_reg_n_0_[1] ),
        .O(\bout[1]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \bout[7]_i_1 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[4] ),
        .I1(clk_out_i_2_n_0),
        .O(\bout[7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFF00FEFFFF0000)) 
    \bout[7]_i_2 
       (.I0(\byte_shift_reg_n_0_[1] ),
        .I1(\byte_shift_reg_n_0_[2] ),
        .I2(\byte_shift_reg_n_0_[0] ),
        .I3(\byte_shift_reg_n_0_[3] ),
        .I4(\FSM_onehot_CYCLE_reg_n_0_[4] ),
        .I5(clk_out_i_2_n_0),
        .O(bout));
  FDRE #(
    .INIT(1'b1)) 
    \bout_reg[1] 
       (.C(spi_sck),
        .CE(1'b1),
        .D(\bout[1]_i_1_n_0 ),
        .Q(in5[2]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \bout_reg[2] 
       (.C(spi_sck),
        .CE(bout),
        .D(in5[2]),
        .Q(in5[3]),
        .R(\bout[7]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \bout_reg[3] 
       (.C(spi_sck),
        .CE(bout),
        .D(in5[3]),
        .Q(in5[4]),
        .R(\bout[7]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \bout_reg[4] 
       (.C(spi_sck),
        .CE(bout),
        .D(in5[4]),
        .Q(in5[5]),
        .R(\bout[7]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \bout_reg[5] 
       (.C(spi_sck),
        .CE(bout),
        .D(in5[5]),
        .Q(in5[6]),
        .R(\bout[7]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \bout_reg[6] 
       (.C(spi_sck),
        .CE(bout),
        .D(in5[6]),
        .Q(in5[7]),
        .R(\bout[7]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \bout_reg[7] 
       (.C(spi_sck),
        .CE(bout),
        .D(in5[7]),
        .Q(p_0_in),
        .R(\bout[7]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h0E)) 
    \byte_shift[0]_i_1 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I2(\byte_shift_reg_n_0_[0] ),
        .O(\byte_shift[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h0EE0)) 
    \byte_shift[1]_i_1 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I2(\byte_shift_reg_n_0_[0] ),
        .I3(\byte_shift_reg_n_0_[1] ),
        .O(\byte_shift[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h0EEEE000)) 
    \byte_shift[2]_i_1 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I2(\byte_shift_reg_n_0_[0] ),
        .I3(\byte_shift_reg_n_0_[1] ),
        .I4(\byte_shift_reg_n_0_[2] ),
        .O(\byte_shift[2]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'hFE)) 
    \byte_shift[3]_i_1 
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .O(byte_shift));
  LUT6 #(
    .INIT(64'h7F7F7F0080808000)) 
    \byte_shift[3]_i_2 
       (.I0(\byte_shift_reg_n_0_[2] ),
        .I1(\byte_shift_reg_n_0_[0] ),
        .I2(\byte_shift_reg_n_0_[1] ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I4(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I5(\byte_shift_reg_n_0_[3] ),
        .O(\byte_shift[3]_i_2_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \byte_shift_reg[0] 
       (.C(spi_sck),
        .CE(byte_shift),
        .D(\byte_shift[0]_i_1_n_0 ),
        .Q(\byte_shift_reg_n_0_[0] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \byte_shift_reg[1] 
       (.C(spi_sck),
        .CE(byte_shift),
        .D(\byte_shift[1]_i_1_n_0 ),
        .Q(\byte_shift_reg_n_0_[1] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \byte_shift_reg[2] 
       (.C(spi_sck),
        .CE(byte_shift),
        .D(\byte_shift[2]_i_1_n_0 ),
        .Q(\byte_shift_reg_n_0_[2] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \byte_shift_reg[3] 
       (.C(spi_sck),
        .CE(byte_shift),
        .D(\byte_shift[3]_i_2_n_0 ),
        .Q(\byte_shift_reg_n_0_[3] ),
        .R(1'b0));
  LUT5 #(
    .INIT(32'hFFFFFFA8)) 
    clk_out_i_1
       (.I0(\bout[1]_i_2_n_0 ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[7] ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[1] ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .I4(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .O(clk_out_i_1_n_0));
  LUT2 #(
    .INIT(4'hE)) 
    clk_out_i_2
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[2] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[8] ),
        .O(clk_out_i_2_n_0));
  FDRE #(
    .INIT(1'b1)) 
    clk_out_reg
       (.C(spi_sck),
        .CE(clk_out_i_1_n_0),
        .D(clk_out_i_2_n_0),
        .Q(clk_out),
        .R(1'b0));
  LUT3 #(
    .INIT(8'hFE)) 
    cs_i_1
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[0] ),
        .I1(\FSM_onehot_CYCLE_reg_n_0_[6] ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .O(cs_i_1_n_0));
  FDRE #(
    .INIT(1'b1)) 
    cs_reg
       (.C(spi_sck),
        .CE(cs_i_1_n_0),
        .D(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .Q(cs),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFAFAFAFAFAFAFAEA)) 
    mosi_i_1
       (.I0(\FSM_onehot_CYCLE_reg_n_0_[0] ),
        .I1(\bout[1]_i_2_n_0 ),
        .I2(\FSM_onehot_CYCLE[9]_i_3_n_0 ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .I4(\FSM_onehot_CYCLE_reg_n_0_[9] ),
        .I5(\FSM_onehot_CYCLE_reg_n_0_[6] ),
        .O(mosi_i_1_n_0));
  LUT5 #(
    .INIT(32'hFCFCFCA8)) 
    mosi_i_2
       (.I0(p_0_in),
        .I1(\FSM_onehot_CYCLE[9]_i_3_n_0 ),
        .I2(\FSM_onehot_CYCLE_reg_n_0_[0] ),
        .I3(\FSM_onehot_CYCLE_reg_n_0_[9] ),
        .I4(\FSM_onehot_CYCLE_reg_n_0_[3] ),
        .O(mosi_i_2_n_0));
  FDRE #(
    .INIT(1'b1)) 
    mosi_reg
       (.C(spi_sck),
        .CE(mosi_i_1_n_0),
        .D(mosi_i_2_n_0),
        .Q(mosi),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
