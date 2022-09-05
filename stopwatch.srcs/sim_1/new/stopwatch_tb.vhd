----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.08.2022 15:57:11
-- Design Name: 
-- Module Name: stopwatch_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stopwatch_tb is
--  Port ( );
end stopwatch_tb;

architecture Behavioral of stopwatch_tb is

    signal start: std_logic := '0';
    signal clk: std_logic := '1';
    signal reset: std_logic := '0';
    signal stop: std_logic := '0';
    signal seg: std_logic_vector(6 downto 0) := "0000000";
    signal dp: std_logic := '0';
    signal an: std_logic_vector(3 downto 0) := "0000";
    signal ss_led: std_logic;
    signal db_ss_led: std_logic;
    
begin
    stopwatch: entity work.stopwatch port map (start, clk, reset, stop, seg, dp, an, ss_led, db_ss_led);
    
    clk <= not clk after 5 us;
    
    start <= '1' after 20 ms, '0' after 220 ms, '1' after 5000 ms, '0' after 5200 ms;
    
    reset <= '1' after 4000 ms, '0' after 4500 ms;

end Behavioral;
