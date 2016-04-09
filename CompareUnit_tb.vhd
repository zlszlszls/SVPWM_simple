-------------------------------------------------------------------------------
-- Title      : CounterUnit_tb.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : CounterUnit_tb.vhd
-- Author     : zls
-- Company    : BJTU
-- Created    : 2016-04-01
-- Last update: 2016-04-08
-- Platform   : Spartan 6 XC6SLX16
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: the testbench for CounterUnit
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-04-01  1.0      zls     Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CompareUnit_tb is
end CompareUnit_tb;

architecture behavior of CompareUnit_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component CompareUnit
    generic(
      COUNTER_WIDTH : integer := 16
      );
    port(
      clk            : in  std_logic;
      enable         : in  std_logic;   --active high 
      reset          : in  std_logic;   --active high  
      initial_in     : in  std_logic;   --the initial pwm
      CarrierWave_in : in  std_logic;   --carrier wave mode
      period_in      : in  std_logic_vector(15 downto 0);
      CMPA_in        : in  std_logic_vector(15 downto 0);
      CMPB_in        : in  std_logic_vector(15 downto 0);
      deadband_in    : in  std_logic_vector(15 downto 0);
      count          : out std_logic_vector(15 downto 0);
      zero           : out std_logic;
      pwm_top        : out std_logic;
      pwm_bottom     : out std_logic;
      debug1         : out std_logic
      );
  end component;

  --Inputs
  signal clk            : std_logic := '0';
  signal enable         : std_logic := '0';
  signal reset          : std_logic := '1';
  signal initial_in     : std_logic := '0';
  signal CarrierWave_in : std_logic := '1';
  signal period_in      : std_logic_vector(15 downto 0);
  signal CMPA_in        : std_logic_vector(15 downto 0);
  signal CMPB_in        : std_logic_vector(15 downto 0);
  signal deadband_in    : std_logic_vector(15 downto 0);

  --Outputs
  signal count        : std_logic_vector(15 downto 0);
  signal zero         : std_logic;
  signal pwm_top      : std_logic;
  signal debug1       : std_logic;
  
  -- Clock period definitions
  constant clk_period : time := 20 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : CompareUnit port map (
    clk            => clk,
    enable         => enable,
    reset          => reset,
    initial_in     => initial_in,
    CarrierWave_in => CarrierWave_in,
    period_in      => period_in,
    CMPA_in        => CMPA_in,
    CMPB_in        => CMPB_in,
    deadband_in    => deadband_in,
    count          => count,
    zero           => zero,
    pwm_top        => pwm_top,
    pwm_bottom     => pwm_bottom,
    debug1         => debug1
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
    enable         <= '1';
    initial_in     <= '0';
    CarrierWave_in <= '1';
    period_in      <= X"0060";
    CMPA_in        <= X"001A";
    CMPB_in        <= X"004A";
    deadband_in    <= X"0004";
    --wait for 3000 ns;
    --initial_in     <= '1';
    --CarrierWave_in <= '1';
    --period_in      <= X"0030";
    --CMPA_in        <= X"0010";
    --CMPB_in        <= X"0040";
    --deadband_in    <= X"0004";

    -- insert stimulus here 

    wait;
  end process;
end behavior;

