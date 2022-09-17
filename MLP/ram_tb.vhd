library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use work.test_signals.all;

entity ram_tb is
end ram_tb;

architecture ram_tb_arc of ram_tb is

    signal clk  : in std_logic := '1';
    signal addr : in std_logic_vector(10 downto 0);
    signal din  : in std_logic_vector(7 downto 0);
    signal we   : in std_logic;
    signal re   : in std_logic;
    signal dout : out std_logic_vector(7 downto 0);

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


end ram_tb_arc;
