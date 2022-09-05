library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity stopwatch is
    port (
    	start: in std_logic;
        clk: in std_logic;
        reset: in std_logic;
        stop: in std_logic;
        seg: out std_logic_vector(6 downto 0);
        dp: out std_logic;
        an: out std_logic_vector(3 downto 0)
    ) ;
end entity ; -- stopwatch

architecture arch of stopwatch is
  
    signal minute: std_logic_vector(3 downto 0) := x"0";
    signal sec_tens: std_logic_vector(3 downto 0) := x"0";
    signal sec_units: std_logic_vector(3 downto 0) := x"0";
    signal tenth: std_logic_vector(3 downto 0) := x"0";
    
    signal clk_ds: std_logic := '0';
    signal clk_ds_ctr: unsigned(15 downto 0) := x"0000";
    signal clk_ds_ctr_in: unsigned(15 downto 0) := x"0000";

    -- FSM
    -- Zero -> Running -> Paused 
    signal curr_state: state_t := ZERO;

    -- debounced signals
    signal db_start: std_logic;
    signal db_rst: std_logic;
    signal db_stop: std_logic;

begin
    led_driver: entity work.led_driver port map (clk, tenth, sec_units, sec_tens, minute, seg, dp, an);

    ctr_minute: entity work.digit_counter_new   generic map (10, 600000) port map (clk_ds, curr_state, minute);
    ctr_sec_tens: entity work.digit_counter_new generic map (6,  100000) port map (clk_ds, curr_state, sec_tens);
    ctr_sec_ones: entity work.digit_counter_new generic map (10, 10000) port map (clk_ds, curr_state, sec_units);
    ctr_tenth: entity work.digit_counter_new    generic map (10, 1000) port map (clk_ds, curr_state, tenth);
    
    debouncer_start: entity work.debouncer port map (clk, start, db_start);
    debouncer_rst: entity work.debouncer port map (clk, reset, db_rst);
    debouncer_stop: entity work.debouncer port map (clk, stop, db_stop);

    
    clk_ds_ctr_in <= x"0000" when clk_ds_ctr = 4999 else clk_ds_ctr + 1;
                    
    clk_ds_ctr <= clk_ds_ctr_in when rising_edge(clk);
    
    clk_ds <= not clk_ds when clk_ds_ctr = 0 and rising_edge(clk);

    update_state: process(clk)
    begin
        if (rising_edge(clk)) then
            if db_start = '1' then
                curr_state <= RUNNING;
            elsif db_stop = '1' then
                curr_state <= PAUSED;
            elsif db_rst = '1' then
                curr_state <= ZERO;
            end if;
        end if;
    end process update_state;

end architecture ;