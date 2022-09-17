library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity ram is
    port (
        clk  : in std_logic;
        addr : in std_logic_vector(10 downto 0);
        din  : in std_logic_vector(7 downto 0);
        we   : in std_logic;
        re   : in std_logic;
        dout : out std_logic_vector(7 downto 0)
    );
end ram;

architecture ram_arc of ram is

    type ram_arr is array(2047 downto 0) of std_logic_vector(7 downto 0);
    signal ram_mem: ram_arr;

begin

    write: process(clk)
    begin
        if rising_edge(clk) and we = '1' then
            ram_arr(to_integer(unsigned(addr))) <= din;
        end if;
    end process write;

    dout <= ram_arr(to_integer(unsigned(addr))) when re = '1' else x"00";

end ram_arc;