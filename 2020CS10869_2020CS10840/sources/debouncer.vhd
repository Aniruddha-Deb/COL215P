library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
    port (
        clk : in std_logic;
        in_sig  : in std_logic;
        out_sig : out std_logic
    );
end debouncer;

architecture debouncer_arc of debouncer is

    type state_t is (ZERO, UNSTABLE, STABLE);

    signal curr_state: state_t := ZERO;
    signal ctr: unsigned(31 downto 0);

begin

    out_sig <= '1' when curr_state = STABLE else '0';

    upd_state: process(clk)
    begin
        if (rising_edge(clk)) then
            if in_sig = '1' then
                if curr_state = ZERO then
                    curr_state <= UNSTABLE;
                elsif ctr >= 10000 then
                    curr_state <= STABLE;
                else
                    curr_state <= UNSTABLE;
                    ctr <= ctr + 1;
                end if;
            else
                curr_state <= ZERO;
                ctr <= (others => '0');
            end if;
        end if;
    end process upd_state;

end debouncer_arc;