library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity reg is
    generic (
        size : integer := 16
    );
    port (
        write_enable: in std_logic;
        clk  : in std_logic;
        din  : in signed(size-1 downto 0);
        dout : out signed(size-1 downto 0) := (others => '0')
    );
end reg;

architecture reg_arc of reg is
begin

    dout <= din when (rising_edge(clk) and write_enable = '1');

end reg_arc;