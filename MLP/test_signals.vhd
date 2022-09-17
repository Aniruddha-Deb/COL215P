library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions


package test_signals is

    type bytearr is array(63 downto 0) of std_logic_vector(7 downto 0);

    signal test_bytearr : bytearr := (
        -- TODO 
    );

end package;
