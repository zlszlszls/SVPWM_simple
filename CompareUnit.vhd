-------------------------------------------------------------------------------
-- Title      : CompareUnit.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : CompareUnit.vhd
-- Author     : zls
-- Company    : BJTU
-- Created    : 2016-04-01
-- Last update: 2016-04-08
-- Platform   : Spartan 6 XC6SLX16
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: the compare unit for SVPWM module, without counter unit
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

entity CompareUnit is
  generic(
    COUNTER_WIDTH : integer := 16
    );
  port(
    clk            : in  std_logic;
    enable         : in  std_logic;     --active high 
    reset          : in  std_logic;     --active high  
    initial_in     : in  std_logic;     --the initial pwm
    CarrierWave_in : in  std_logic;     --carrier wave mode
    period_in      : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    CMPA_in        : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    CMPB_in        : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    deadband_in    : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    count          : out std_logic_vector(COUNTER_WIDTH-1 downto 0);
    zero           : out std_logic;
    pwm_top        : out std_logic;
    pwm_bottom     : out std_logic;
    debug1         : out std_logic
    );
end CompareUnit;

architecture Behavioral of CompareUnit is
  --signal declaration
  signal Q           : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  signal period      : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  signal CMPA        : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  signal CMPB        : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  signal deadband    : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  signal initial     : std_logic;
  signal CarrierWave : std_logic;
  signal up          : std_logic;

begin
  --process to load period and counter mode
  process(reset, clk)
  begin
    if(reset = '1' or enable = '0') then
      period      <= X"0000" after 1 ns;
      CMPA        <= X"0000" after 1 ns;
      CMPB        <= X"0000" after 1 ns;
      deadband    <= X"0000" after 1 ns;
      initial     <= '0';
      CarrierWave <= '1';  --1 is sawtooth carrier wave, 0 is triangle carrier
    --wave
    elsif rising_edge(clk) then
      -- only when the counter=0 load the new compare value
      if (Q = 0) then
        period      <= period_in      after 1 ns;  --sawtooth carrier wave:
                                        --period=Tpwm; triangle carrier
                                        --wave: period=(int)Tpwm/2
        CMPA        <= CMPA_in        after 1 ns;
        CMPB        <= CMPB_in        after 1 ns;  --only used in sawtooth carrier wave
        deadband    <= deadband_in    after 1 ns;
        initial     <= initial_in     after 1 ns;
        CarrierWave <= CarrierWave_in after 1 ns;
      end if;
    end if;
  end process;

  --process to count
  process(reset, clk)
  begin
    if (reset = '1' or enable = '0') then
      Q  <= (others => '0') after 1 ns;
      up <= '0'             after 1 ns;
    elsif (rising_edge(clk)) then
      if(CarrierWave = '1') then        -- sawtooth
        if(Q = period) then
          Q <= (others => '0') after 1 ns;
        else
          Q <= Q + 1 after 1 ns;
        end if;
      else                              --triangle
        if (up = '1') then
          if(Q = period) then
            up <= '0' after 1 ns;
          else
            Q <= Q + 1 after 1 ns;
          end if;
        else
          if(Q = 0) then
            up <= '1' after 1 ns;
          else
            Q <= Q - 1 after 1 ns;
          end if;
        end if;
      end if;
    end if;
  end process;

--process to compare for pwm_top
  process(reset, clk)
  begin
    if(reset = '1' or enable = '0') then
      pwm_top <= '0';  -- used to disable PWM module when fault occurs
    elsif rising_edge(clk) then
      if(CarrierWave = '1') then        --sawtooth
        if(initial = '1') then
          if(Q < (CMPA+deadband)) then
            pwm_top <= '1'after 1 ns;
          elsif(Q < CMPB) then
            pwm_top <= '0'after 1 ns;
          else
            pwm_top <= '1'after 1 ns;
          end if;
        else
          if(Q < CMPA) then
            pwm_top <= '0'after 1 ns;
          elsif(Q < (CMPB+deadband)) then
            pwm_top <= '1'after 1 ns;
          else
            pwm_top <= '0'after 1 ns;
          end if;
        end if;
      else                              --triangle
        if(initial = '1') then
          if(up = '1') then
            if(Q < (CMPA+deadband)) then
              pwm_top <= '1' after 1 ns;
            else
              pwm_top <= '0' after 1 ns;
            end if;
          else
            if(Q > CMPA+1) then
              pwm_top <= '0' after 1 ns;
            else
              pwm_top <= '1' after 1 ns;
            end if;
          end if;
        else
          if(up = '1') then
            if(Q < CMPA) then
              pwm_top <= '0' after 1 ns;
            else
              pwm_top <= '1' after 1 ns;
            end if;
          else
            if(Q > (CMPA-deadband+1)) then
              pwm_top <= '1' after 1 ns;
            else
              pwm_top <= '0' after 1 ns;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

--process to compare for pwm_bottom
  process(reset, clk)
  begin
    if(reset = '1' or enable = '0') then
      pwm_bottom <= '1';  -- used to disable PWM module when fault occurs
    elsif rising_edge(clk) then
      if(CarrierWave = '1') then        --sawtooth
        if(initial = '1') then
          if(Q < CMPA) then
            pwm_bottom <= '0'after 1 ns;
          elsif(Q < (CMPB+deadband)) then
            pwm_bottom <= '1'after 1 ns;
          else
            pwm_bottom <= '0'after 1 ns;
          end if;
        else
          if(Q < (CMPA+deadband)) then
            pwm_bottom <= '1'after 1 ns;
          elsif(Q < CMPB) then
            pwm_bottom <= '0'after 1 ns;
          else
            pwm_bottom <= '1'after 1 ns;
          end if;
        end if;
      else                              --triangle
        if(initial = '1') then
          if(up = '1') then
            if(Q < CMPA) then
              pwm_bottom <= '0' after 1 ns;
            else
              pwm_bottom <= '1' after 1 ns;
            end if;
          else
            if(Q > (CMPA-deadband+1)) then
              pwm_bottom <= '1' after 1 ns;
            else
              pwm_bottom <= '0' after 1 ns;
            end if;
          end if;
        else
          if(up = '1') then
            if(Q < (CMPA+deadband)) then
              pwm_bottom <= '1' after 1 ns;
            else
              pwm_bottom <= '0' after 1 ns;
            end if;
          else
            if(Q > CMPA+1) then
              pwm_bottom <= '0' after 1 ns;
            else
              pwm_bottom <= '1' after 1 ns;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  zero   <= '1' when (Q = 0) else '0';
  count  <= Q;
  debug1 <= up;
end Behavioral;

