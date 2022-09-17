library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- 16 x 8 multiplier
-- 16 bit adder
entity mac is
    port (
        clk : in std_logic;
        first : in std_logic;
        din1 : in unsigned(15 downto 0); -- input(shifted from 8 bits to 16 bits)/activation( 16 bits)
        din2 : in unsigned(7 downto 0);  -- 8 bits (weight/bias)
        dout : out unsigned(15 downto 0)
    );
end mac;

architecture mac_arc of mac is

    signal acc_reg_din: unsigned(15 downto 0);
    signal dout_ret: unsigned(15 downto 0) := x"0000";

    signal mult_out: unsigned(23 downto 0);  -- 24 bit output that needs truncation
    --signal mult_out_mod: unsigned(23 downto 0);   -- 24 bit output that needs truncation 

begin

    acc_reg : entity work.reg port map (
        clk  => clk, 
        din  => acc_reg_din, 
        dout => dout_ret );

    -- NOTE this is NOT a modulo n counter... What do we do with overflows?
    mult_out <= (din1*din2)(15 downto 0) + dout_ret when first = '0' else (din1*din2)(15 downto 0);
    --mult_out_mod <= mult_out mod 256;

    -- TODO fix the bit widths here!
    acc_reg_din <= mult_out;

    dout <= dout_ret;

end mac_arc;