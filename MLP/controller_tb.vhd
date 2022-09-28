library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity controller_tb is
end controller_tb;

architecture controller_tb_arc of controller_tb is

    signal clk : std_logic := '0';
    signal seg : std_logic_vector(6 downto 0);
    signal an  : std_logic;
    signal dp  : std_logic;

begin

    controller: entity work.controller port map (
        clk => clk,
        seg => seg,
        an => an,
        dp => dp
    );


    clk <= not clk after 5 ns;

end controller_tb_arc;
