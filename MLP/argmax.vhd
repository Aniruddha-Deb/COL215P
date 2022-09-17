library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity argmax is
    port (
        clk  : in std_logic;
        din  : in signed(15 downto 0);
        en   : in std_logic;
        first: in std_logic;
        dout : out std_logic_vector(3 downto 0)
    );
end argmax;

architecture argmax_arc of argmax is

    signal max: signed(15 downto 0) := x"8000";
    signal ctr: unsigned(3 downto 0) := x"0";

begin

    upd: process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                if first = '1' then
                    ctr <= x"0";
                    max <= din;
                    dout <= x"0";
                else
                    ctr <= ctr + 1;
                    if (din > max) then
                        max <= din;
                        dout <= std_logic_vector(ctr + 1);
                    end if;
                end if;
            end if;
        end if;
    end process upd;

end argmax_arc;