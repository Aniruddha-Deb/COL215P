library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    generic (
        size : integer := 8
    );
    port (
        clk  : in std_logic;
        din  : in unsigned(size-1 downto 0);
        dout : out unsigned(size-1 downto 0) := (others => '0')
    );
end reg;

architecture reg_arc of reg is
begin

    dout <= din when rising_edge(clk);

end reg_arc;