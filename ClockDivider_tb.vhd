-------------------------------------------------------------------------------
-- Title      : ClockDivider.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ClockDivider_tb.vhd
-- Author     : zls
-- Company    : 
-- Created    : 2016-04-08
-- Last update: 2016-04-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: this is a clock divider for PWM module testbench
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-04-08  1.0      zls     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ClockDivider_tb_vhd is
end ClockDivider_tb_vhd;

architecture behavior of ClockDivider_tb_vhd is

  -- Component Declaration for the Unit Under Test (UUT)
  component clockdivider
    generic(
      C_DIVISOR : integer := 5
      );
    port(
      clk     : in  std_logic;
      reset   : in  std_logic;
      clk_out : out std_logic
      );
  end component;

  --Inputs
  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';

  --Outputs
  signal clk_out : std_logic;

  -- Clock process definitions
  constant clk_period : time := 20 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : CompareUnit port map (
    clk     => clk,
    reset   => reset,
    clk_out => clk_out
    );
  
  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  stimulus : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;
    reset          <= '0';
    -- insert stimulus here 

    wait;
  end process;
end behavior;
