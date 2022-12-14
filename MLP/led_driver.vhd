library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity led_driver is
    port (
        active : in std_logic;
        A: in std_logic_vector(3 downto 0);
        seg: out std_logic_vector(6 downto 0);
        dp: out std_logic;
        an: out std_logic
    );
end led_driver;

architecture led_driver_arc of led_driver is

begin

    seg(0) <= '1' when (active = '0') else (A(0) and (not A(1)) and (not A(2)) and (not A(3))) or (A(2) and (not A(1)) and (not A(0)) and (not A(3)));
    seg(1) <= '1' when (active = '0') else (A(0) and A(2) and (not A(1)) and (not A(3))) or (A(1) and A(2) and (not A(0)) and (not A(3)));
    seg(2) <= '1' when (active = '0') else (A(1) and (not A(0)) and (not A(2)) and (not A(3)));
    seg(3) <= '1' when (active = '0') else (A(0) and (not A(1)) and (not A(2)) and (not A(3))) or (A(2) and (not A(0)) and (not A(1)) and (not A(3))) or (A(0) and A(1) and A(2) and (not A(3)));
    seg(4) <= '1' when (active = '0') else (A(0) and (not A(3))) or (A(2) and (not A(1)) and (not A(3))) or (A(0) and (not A(1)) and (not A(2)));
    seg(5) <= '1' when (active = '0') else (A(0) and (not A(2)) and (not A(3))) or (A(0) and A(1) and (not A(3))) or (A(1) and (not A(3)) and (not A(2)));
    seg(6) <= '0' when (active = '0') else (A(0) and A(1) and A(2) and (not A(3))) or ((not A(1)) and (not A(2)) and (not A(3)));

    dp <= '1';
    an <= '1'; -- keep it perpetually on

end led_driver_arc;
