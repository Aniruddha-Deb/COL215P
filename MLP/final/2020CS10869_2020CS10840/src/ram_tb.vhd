library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity ram_tb is
end ram_tb;

architecture ram_tb_arc of ram_tb is

    signal clk  : std_logic := '0';
    signal addr : std_logic_vector(10 downto 0);
    signal din  : std_logic_vector(15 downto 0);
    signal we   : std_logic;
    signal re   : std_logic := '0';
    signal dout : std_logic_vector(15 downto 0);

begin

    ram : entity work.ram port map (
        clk  => clk,
        addr => addr,
        din  => din,
        we   => we,
        re   => re,
        dout => dout
    );

    clk <= not clk after 5 ns;

    test: process
    begin
        addr <= "00000110101";
        din <= x"BCAE";
        we <= '1';

        wait for 5 ns;

        addr <= "00000110110";
        din <= x"EF1B";
        we <= '1';

        wait for 10 ns;

        addr <= "00000110111";
        din <= x"12E8";
        we <= '1';

        wait for 10 ns;

        addr <= "00000110101";
        re <= '1';
        we <= '0';

        wait for 10 ns;
        assert dout = x"BCAE" report "Error: data mismatch";

        addr <= "00000110110";
        wait for 10 ns;
        assert dout = x"EF1B" report "Error: data mismatch";

        addr <= "00000110111";
        wait for 10 ns;
        assert dout = x"12E8" report "Error: data mismatch";

    end process test;


end ram_tb_arc;
