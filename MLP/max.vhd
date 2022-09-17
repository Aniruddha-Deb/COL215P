library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity max is
    port (
        clk  : in std_logic;
        din  : in std_logic_vector(15 downto 0);
        en   : in std_logic;
        rst  : in std_logic;
        dout : out std_logic_vector(15 downto 0)
    );
end max;

architecture max_arc of max is

    signal max_elem_in: std_logic_vector(15 downto 0);
    signal max_elem_out: std_logic_vector(15 downto 0) := x"0000";

begin

    cmp : entity work.comparator port map (
        data_in1 => max_elem_out,
        data_in2 => din,
        data_out => max_elem_in
    );

    upd: process(clk, rst)
    begin
        if rst = '1' then
            max_elem_out <= x"0000";
        elsif rising_edge(clk) and en = '1' then
            max_elem_out <= max_elem_in;
        end if;
    end process upd;

    dout <= max_elem_out;

end max_arc;