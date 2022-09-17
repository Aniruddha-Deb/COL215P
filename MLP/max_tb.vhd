library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity max_tb is
end max_tb;

architecture max_tb_arc of max_tb is

    signal clk: std_logic := '0';
    signal din: std_logic_vector(15 downto 0) := x"00A0";
    signal dout: std_logic_vector(15 downto 0);
    signal en: std_logic := '1';
    signal rst: std_logic := '0';

begin

    max: entity work.max port map (
        clk => clk,
        din => din,
        dout => dout,
        en => en,
        rst => rst
    );

    clk <= not clk after 5 ns;

    test:process
    begin

        wait for 5 ns;

        din <= x"0100";

        wait for 10 ns;

        din <= x"0010";

        wait for 10 ns;

        din <= x"0A00";

        wait for 10 ns;

        en <= '0';
        din <= x"0B00";

        wait for 17 ns;

        rst <= '1';
    end process test;

end max_tb_arc;
