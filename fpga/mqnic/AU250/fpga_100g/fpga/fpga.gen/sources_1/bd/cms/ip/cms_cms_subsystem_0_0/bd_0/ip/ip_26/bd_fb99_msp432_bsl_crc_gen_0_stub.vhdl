-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
-- Date        : Wed Jul 12 20:20:01 2023
-- Host        : desktop02 running 64-bit Ubuntu 18.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/ubuntu/git_repos/corundum/fpga/mqnic/AU250/fpga_100g/fpga/fpga.gen/sources_1/bd/cms/ip/cms_cms_subsystem_0_0/bd_0/ip/ip_26/bd_fb99_msp432_bsl_crc_gen_0_stub.vhdl
-- Design      : bd_fb99_msp432_bsl_crc_gen_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcu250-figd2104-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bd_fb99_msp432_bsl_crc_gen_0 is
  Port ( 
    clk : in STD_LOGIC;
    reset_n : in STD_LOGIC;
    s0_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s0_axis_tready : out STD_LOGIC;
    s0_axis_tvalid : in STD_LOGIC;
    s0_axis_tlast : in STD_LOGIC;
    m0_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m0_axis_tready : in STD_LOGIC;
    m0_axis_tvalid : out STD_LOGIC;
    m0_axis_tlast : out STD_LOGIC
  );

end bd_fb99_msp432_bsl_crc_gen_0;

architecture stub of bd_fb99_msp432_bsl_crc_gen_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,reset_n,s0_axis_tdata[31:0],s0_axis_tready,s0_axis_tvalid,s0_axis_tlast,m0_axis_tdata[31:0],m0_axis_tready,m0_axis_tvalid,m0_axis_tlast";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "shell_utils_msp432_bsl_crc_gen_v1_0_0,Vivado 2022.2";
begin
end;
