-------------------------------------------------------------------------------
-- Title      : ClockDivider.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ClockDivider.vhd
-- Author     : zls
-- Company    : 
-- Created    : 2016-04-08
-- Last update: 2016-04-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: this is the clock divider for PWM module
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-04-08  1.0      zls     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ClockDivider is
  port(
    clk        : in  std_logic;
    reset      : in  std_logic;
    divisor_in : in  std_logic_vector(1 downto 0);
    clk_out    : out std_logic
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
  --signal declaration
  divisor : std_logic_vector(1 downto 0);
  --process to change the divisor
  process (clk, divisor_in)
    variable divisor_old, divisor_new :std_logic_vector(1 downto 0) :="00";
  begin
    if rising_edge(clk) then
      divisor_new := divisor_in;
      if (divisor_old /= divisor_new) then
        reset <= '1';
        
    end if;

  end process;
  begin

    --
    -- Divisor is <= 1
    --
    no_div : if C_DIVISOR <= 1 generate
    begin
      clk_out <= clk when reset = '0' else '0';
    end generate;

    --
    -- Divisor = 2
    --
    div_2 : if C_DIVISOR = 2 generate
      signal clk_out_i : std_logic := '0';
    begin
      process(clk, reset)
      begin
        if(reset = '1') then
          clk_out_i <= '0';
        elsif rising_edge(clk) then
          clk_out_i <= not clk_out_i;
        end if;
      end process;
      clk_out <= clk_out_i;
    end generate;

    --
    -- Divisor > 2 and odd
    --
    div_odd_gt2 : if C_DIVISOR > 2 and conv_std_logic_vector(C_DIVISOR, log2(C_DIVISOR))(0) = '1' generate
      signal count                        : std_logic_vector(log2(C_DIVISOR)-1 downto 0) := (others => '0');
      signal wave_50_A                    : std_logic                                    := '0';
      signal wave_50_B                    : std_logic                                    := '0';
      attribute clock_signal              : string;
      attribute clock_signal of wave_50_B : signal is "yes";
    begin

      process(clk, reset)
      begin
        if(reset = '1') then
          count     <= (others => '0');
          wave_50_A <= '0';
        elsif rising_edge(clk) then
          if(count < (C_DIVISOR-1)) then
            count <= count + 1;
            if(count < (C_DIVISOR/2)+1) then
              wave_50_A <= '1';
            else
              wave_50_A <= '0';
            end if;
          else
            count     <= (others => '0');
            wave_50_A <= '0';
          end if;
        end if;
      end process;


      process(clk, reset)
      begin
        if(reset = '1') then
          wave_50_B <= '0';
        elsif falling_edge(clk) then
          wave_50_B <= wave_50_A;
        end if;
      end process;
      clk_out <= wave_50_A and wave_50_B;
    end generate;

    --
    -- Divisor > 2 and even
    --
    div_th_2 : if C_DIVISOR > 2 and conv_std_logic_vector(C_DIVISOR, log2(C_DIVISOR))(0) = '0' generate
      signal count     : std_logic_vector(log2(C_DIVISOR)-1 downto 0) := (others => '0');
      signal clk_out_i : std_logic                                    := '0';
    begin
      process(clk, reset)
      begin
        if(reset = '1') then
          clk_out_i <= '0';
          count     <= (others => '0');
        elsif rising_edge(clk) then
          if(count < (C_DIVISOR-1)) then
            count <= count + 1;
            if(count < (C_DIVISOR/2)) then
              clk_out_i <= '1';
            else
              clk_out_i <= '0';
            end if;
          else
            count <= (others => '0');
          end if;
        end if;
      end process;
      clk_out <= clk_out_i;
    end generate;

  end Behavioral;
