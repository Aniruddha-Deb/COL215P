library ieee;
use ieee.std_logic_1164.all;

entity debouncer_tb is 
end debouncer_tb;

architecture debouncer_tb_bvr of debouncer_tb is

    signal switch: std_logic := '0';
    signal clk: std_logic := '0';
    signal debounced: std_logic;
    

begin

    debouncer: entity work.debouncer port map (clk, switch, debounced);

    clk <= not clk after 5 ns;

    switch <= '0' after 510 us,
            '1' after 546 us,
            '0' after 560 us,
            '1' after 586 us,
            '0' after 587 us,
            '1' after 597 us,
            '0' after 1314 us,
            '1' after 1377 us,
            '0' after 1398 us,
            '1' after 1455 us,
            '0' after 1470 us,
            '1' after 1492 us;
            
end debouncer_tb_bvr;