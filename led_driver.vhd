library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_driver is
    port (
        clk: in std_logic;
        dig_0: in std_logic_vector(3 downto 0);
        dig_1: in std_logic_vector(3 downto 0);
        dig_2: in std_logic_vector(3 downto 0);
        dig_3: in std_logic_vector(3 downto 0);
        seg: out std_logic_vector(6 downto 0);
        dp: out std_logic;
        an: out std_logic_vector(3 downto 0)
    );
end led_driver;

architecture led_driver_struct of led_driver is

    signal dig: std_logic_vector(3 downto 0) := "0000";
    signal curr_dig: unsigned(1 downto 0) := "00";
    signal clk_ctr: unsigned(12 downto 0) := (others=>'0');
    signal clk_scaled: std_logic := '1';

begin
    
    decoder: entity work.decoder port map (dig, seg);
    
    dig <= dig_0 when curr_dig = 0 else
           dig_1 when curr_dig = 1 else
           dig_2 when curr_dig = 2 else
           dig_3;
           
    an  <= "1110" when curr_dig = 0 else
           "1101" when curr_dig = 1 else
           "1011" when curr_dig = 2 else
           "0111";
           
    dp  <= '1' when ((curr_dig = 2) or (curr_dig = 0)) else '0';

    update_dig: process(clk_scaled)
    begin
        if rising_edge(clk_scaled) then
            curr_dig <= curr_dig + 1;
        end if;
    end process update_dig;
    
    scale_clk: process(clk, clk_ctr)
    begin
        if rising_edge(clk) then
            clk_ctr <= clk_ctr + 1;
            if clk_ctr = x"1fff" then
                clk_scaled <= not clk_scaled;
            end if;
        end if;
        
    end process scale_clk;
    
end led_driver_struct;