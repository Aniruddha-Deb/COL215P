library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity argmax_tb is
end argmax_tb;

architecture argmax_tb_arc of argmax_tb is

    signal clk: std_logic := '0';
    signal din: signed(15 downto 0);
    signal dout: std_logic_vector(3 downto 0);
    signal en: std_logic := '1';
    signal first: std_logic := '1';

begin

    argmax: entity work.argmax port map (
        clk => clk,
        din => din,
        dout => dout,
        en => en,
        first => first
    );

    clk <= not clk after 5 ns;

    test:process
    begin
        din <= x"00A0";

        wait for 5 ns;

        din <= x"0100";
        first <= '0';

        wait for 10 ns;

        din <= x"0010";

        wait for 10 ns;

        din <= x"0A00";

        wait for 10 ns;

        en <= '0';
        din <= x"0B00";
    end process test;

end argmax_tb_arc;
