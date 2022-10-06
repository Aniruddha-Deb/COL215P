library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mac_tb is
end mac_tb;

architecture mac_tb_arc of mac_tb is

    signal clk: std_logic := '0';
    signal first : std_logic := '0';
    signal din1 : signed(15 downto 0);
    signal din2 : signed(7 downto 0);
    signal dout : signed(15 downto 0);

    type unsigned_arr is array(63 downto 0) of unsigned(16 downto 0);

begin

    mac: entity work.mac port map (clk, first, din1, din2, dout);

    clk <= not clk after 5 ns;

    test: process
    begin

        -- check:
        -- 1. Base case
        -- 2. Overflow

        wait for 1 ns;

        din1 <= x"0004";
        din2 <= x"08";

        wait for 10 ns;

        assert dout = x"0020" report "ERROR: unable to Multiply";
        din1 <= dout;
        din2 <= x"08";

        wait for 10 ns;
        assert dout = x"0120"  report "ERROR: unable to Accumulate";
        din1 <= x"FFFF";
        din2 <= x"10";

        wait for 10 ns;
        assert dout = x"0110"  report "ERROR: unable to Accumulate negatives";
        first <= '1';
        din1 <= x"FFFE";
        din2 <= x"11";

        wait for 10 ns;
        assert dout = x"FFDE"  report "ERROR: unable to reset when first high";

    end process test;

end mac_tb_arc;