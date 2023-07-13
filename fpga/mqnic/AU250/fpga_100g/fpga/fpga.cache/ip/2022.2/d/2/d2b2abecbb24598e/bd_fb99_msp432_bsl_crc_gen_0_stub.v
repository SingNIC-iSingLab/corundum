// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
// Date        : Wed Jul 12 20:19:59 2023
// Host        : desktop02 running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_fb99_msp432_bsl_crc_gen_0_stub.v
// Design      : bd_fb99_msp432_bsl_crc_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcu250-figd2104-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "shell_utils_msp432_bsl_crc_gen_v1_0_0,Vivado 2022.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, reset_n, s0_axis_tdata, s0_axis_tready, 
  s0_axis_tvalid, s0_axis_tlast, m0_axis_tdata, m0_axis_tready, m0_axis_tvalid, 
  m0_axis_tlast)
/* synthesis syn_black_box black_box_pad_pin="clk,reset_n,s0_axis_tdata[31:0],s0_axis_tready,s0_axis_tvalid,s0_axis_tlast,m0_axis_tdata[31:0],m0_axis_tready,m0_axis_tvalid,m0_axis_tlast" */;
  input clk;
  input reset_n;
  input [31:0]s0_axis_tdata;
  output s0_axis_tready;
  input s0_axis_tvalid;
  input s0_axis_tlast;
  output [31:0]m0_axis_tdata;
  input m0_axis_tready;
  output m0_axis_tvalid;
  output m0_axis_tlast;
endmodule
