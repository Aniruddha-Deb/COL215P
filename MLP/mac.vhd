library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 16 x 8 multiplier
-- 16 bit adder
entity mac is
    port (
        clk : in std_logic;
        first : in std_logic;
        din1 : in signed(15 downto 0); -- input (widened from 8 bits to 16 bits)/activation( 16 bits)
        din2 : in signed(7 downto 0);  -- 8 bits (weight/bias)
        dout : out signed(15 downto 0)
    );
end mac;

architecture mac_arc of mac is

    signal dout_ret: signed(15 downto 0) := x"0000";

    signal w_en: std_logic := '1';

    signal mac_out: signed(15 downto 0);
    signal mult: signed(23 downto 0); -- 24 bit output that needs truncation

begin

    acc_reg : entity work.reg port map (
        clk  => clk, 
        write_enable => w_en,
        din  => mac_out, 
        dout => dout_ret
    );

    w_en <= '1';

    mult <= din1*din2;
    mac_out <= mult(15 downto 0) + dout_ret when first = '0' else mult(15 downto 0);

    dout <= dout_ret;

end mac_arc;