library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity max is
    port (
        clk  : in std_logic;
        din  : in std_logic_vector(7 downto 0);
        en   : in std_logic;
        rst  : in std_logic;
        dout : out std_logic_vector(7 downto 0)
    );
end max;

architecture max_arc of max is
begin

end max_arc;