library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity digit_counter_new is
    generic (
        modulo: integer;
        scale: integer 
    );
    port (
        clk : in std_logic;
        state: in state_t;
        s : out std_logic_vector(3 downto 0)
    );
end digit_counter_new;

architecture beh of digit_counter_new is

    signal s_in: unsigned(3 downto 0) := (others => '0');
    signal s_out: unsigned(3 downto 0) := (others => '0');
    signal ctr_in: unsigned(31 downto 0) := (others => '0');
    signal ctr_out: unsigned(31 downto 0) := (others => '0');

begin

    s <= std_logic_vector(s_out);
    
    s_in <= x"0" when state = RUNNING and s_out = modulo-1 and ctr_out = scale-1 else 
            s_out + 1 when state = RUNNING and ctr_out = scale-1 else
            x"0" when state = ZERO else 
            s_out;
    
    ctr_in <= x"00000000" when state = RUNNING and ctr_out = scale-1 else
              ctr_out + 1 when state = RUNNING else
              x"00000000" when state = ZERO else 
              ctr_out;
    
    update_out:process(clk)
    begin 
        if(rising_edge(clk)) then 
            s_out <= s_in;
            ctr_out <= ctr_in;
        end if;
    end process update_out;
end architecture ; -- beh