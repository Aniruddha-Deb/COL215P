library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity controller is
    port (
        clk : in std_logic;
        seg : out std_logic_vector(6 downto 0); -- output from controller will be given to led driver
        an  : out std_logic;
        dp  : out std_logic
    );
end controller;

architecture controller_arc of controller is

    type state_t is (INIT, LOAD, LAYER1, LAYER2, ARGMAX, DISP); -- which part of the process we are currently in
    type compute_t is (NONE, MULT, ACC, STORE);  -- compute state

    signal led_active: std_logic;               -- led is active or not
    signal led_A: std_logic_vector(3 downto 0); -- the actual digit to display in the led

    signal argmax_din   : signed(15 downto 0);          -- the data fed into arg_max (will be sequentially feeding the values corresponding to the 10 output)
    signal argmax_en    : std_logic;                    -- enable the argmax
    signal argmax_first : std_logic;                    -- first input to argmax
    signal argmax_dout  : std_logic_vector(3 downto 0); -- output from argmax

    signal ram_addr : unsigned(10 downto 0) := "00000000000";
    signal ram_din  : std_logic_vector(15 downto 0);
    signal ram_we   : std_logic := '1';
    signal ram_re   : std_logic;
    signal ram_dout : std_logic_vector(15 downto 0);

    signal rom_addr : unsigned(15 downto 0) := x"0000";
    signal rom_re   : std_logic := '1';
    signal rom_dout : std_logic_vector(7 downto 0);

    signal cmp_din1: std_logic_vector(15 downto 0);     -- signals to comparator
    signal cmp_din2: std_logic_vector(15 downto 0);
    signal cmp_dout: std_logic_vector(15 downto 0);

    signal shift_en     : std_logic;                    -- signals to shifter
    signal shift_signed : std_logic := '1';             -- we would be doing signed shift in general
    signal shift_din    : std_logic_vector(15 downto 0);
    signal shift_dout   : std_logic_vector(15 downto 0);

    signal mac_first : std_logic;
    signal mac_din1  : signed(15 downto 0); -- input (widened from 8 bits to 16 bits)/activation( 16 bits)
    signal mac_din2  : signed(7 downto 0);  -- 8 bits (weight/bias)
    signal mac_dout  : signed(15 downto 0);

    -- controller internal signals
    signal r : unsigned(15 downto 0);       -- current row of matrix
    signal c : unsigned(15 downto 0);       -- current col of matrix
    signal v : unsigned(10 downto 0);
    signal r_lim : unsigned(15 downto 0);
    signal c_lim : unsigned(15 downto 0);

    signal rom_wt_base : unsigned(15 downto 0);     -- pointer to starting address in rom for reading weights
    signal rom_bias_base : unsigned(15 downto 0);   -- pointer to starting address in rom for reading bias
    signal ram_vec_base : unsigned(10 downto 0);    -- pointer to starting address in ram for reading input
    signal ram_write_base : unsigned(10 downto 0);  -- pointer to starting address in ram for writing output

    signal curr_state: state_t := INIT;
    signal curr_compute_state: compute_t := MULT;

    signal ZERO : unsigned(15 downto 0) := x"0000";
    signal ONE  : unsigned(15 downto 0) := x"0001";

    signal L0_DIM : unsigned(15 downto 0) := to_unsigned(784,16);   -- layer 0 dimensions (dimensions of the input layer)
    signal L1_DIM : unsigned(15 downto 0) := to_unsigned(64,16);
    signal L2_DIM : unsigned(15 downto 0) := to_unsigned(10,16);

    signal IMG_ROM_ADDR : unsigned(15 downto 0) := to_unsigned(0,16);     -- used for initially loading the image
    signal W1_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(1024,16);
    signal B1_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(51200,16); -- 1024 + 784*64
    signal W2_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(51264,16); -- 1024 + 784*64 + 64
    signal B2_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(51904,16); -- 1024 + 784*64 + 64 + 64*10

    signal V0_RAM_ADDR : unsigned(10 downto 0) := to_unsigned(0,11);
    signal V1_RAM_ADDR : unsigned(10 downto 0) := to_unsigned(784,11);
    signal V2_RAM_ADDR : unsigned(10 downto 0) := to_unsigned(848,11);

begin

    ent_led_driver: entity work.led_driver port map (
        active => led_active,
        A => led_A,
        seg => seg,
        dp => dp,
        an => an
    );

    ent_ram: entity work.ram port map (
        clk  => clk,
        addr => ram_addr,
        din  => ram_din,
        we   => ram_we,
        re   => ram_re,
        dout => ram_dout
    );

    ent_rom: entity work.rom port map (
        clk  => clk,
        addr => rom_addr,
        re   => rom_re,
        dout => rom_dout
    );

    ent_shifter: entity work.shifter port map (
        enable => shift_en,
        is_signed => shift_signed,
        data_in => shift_din,
        data_out => shift_dout
    );

    ent_mac: entity work.mac port map (
        clk => clk,
        first => mac_first,
        din1 => mac_din1,
        din2 => mac_din2,
        dout => mac_dout
    );

    ent_comparator: entity work.comparator port map (
        data_in1 => cmp_din1,
        data_in2 => cmp_din2,
        data_out => cmp_dout
    );

    ent_argmax: entity work.argmax port map (
        clk   => clk,
        din   => argmax_din,
        en    => argmax_en,
        first => argmax_first,
        dout  => argmax_dout
    );

    -- control logic here

    led_active <= '1' when curr_state = DISP else '0';
    led_A <= argmax_dout;

    argmax_din    <= signed(ram_dout);

    ram_din       <= std_logic_vector(x"00" & rom_dout) when curr_state = INIT else 
                     -- unsigned extension of 8 bit input read from ROM to RAM
                     cmp_dout;

    cmp_din1 <= x"0000";
                -- ZERO when curr_state = LAYER2 and curr_compute_state = STORE else 
                -- change to deactivate ReLU while storing outputs for the last layer
                -- this can happen because all inferences may be negative, in which 
                -- case we'll have to pick the least negative inference to proceed 

    cmp_din2 <= shift_dout;
                
    shift_en <= '1' when curr_state = LAYER1 and curr_compute_state = STORE else 
                '1' when curr_state = LAYER2 and curr_compute_state = STORE else 
                '0';

    shift_signed <= '1'; -- change for unsigned shifts (which we probably won't need)

    shift_din <= std_logic_vector(mac_dout);
                 
    mac_din1 <= signed(ram_dout) when curr_state = LAYER1 and curr_compute_state = MULT else  
                x"0001" when curr_state = LAYER1 and curr_compute_state = ACC else
                signed(ram_dout) when curr_state = LAYER2 and curr_compute_state = MULT else  
                x"0001" when curr_state = LAYER2 and curr_compute_state = ACC else
                x"0000" ;

    mac_din2 <= signed(rom_dout);

    upd_state : process(clk)
    begin
        if rising_edge(clk) then
            if curr_state = INIT then
                curr_state <= LOAD;
                rom_addr <= rom_addr + 1;
            elsif curr_state = LOAD then
                if ram_addr = L0_DIM(10 downto 0)-1 then
                    -- transition out
                    curr_state <= LAYER1;
                    r <= ONE;
                    c <= ZERO;
                    v <= ZERO(10 downto 0);

                    r_lim <= L0_DIM;
                    c_lim <= L1_DIM;
                    rom_wt_base <= W1_ROM_ADDR;
                    rom_bias_base <= B1_ROM_ADDR;
                    ram_vec_base <= V0_RAM_ADDR;
                    ram_write_base <= V1_RAM_ADDR;

                    rom_addr <= W1_ROM_ADDR;
                else
                    ram_we <= '1';
                    ram_addr <= ram_addr + 1;
                    rom_addr <= rom_addr + 1;
                end if;

            elsif curr_state = LAYER1 then

                if curr_compute_state = MULT then
                    if v = ZERO(10 downto 0) then
                        ram_we <= '0';
                        ram_re <= '1';
                        ram_addr <= ram_vec_base;
                        mac_first <= '1';
                    else
                        mac_first <= '0';
                    end if;

                    if v = r_lim(10 downto 0) then
                        curr_compute_state <= ACC;
                    else
                        v <= v+1;
                        ram_addr <= ram_vec_base + v;
                        if r = r_lim then
                            rom_addr <= rom_bias_base + c;
                        else
                            r <= r+1;
                            rom_addr <= rom_wt_base + r;
                        end if;
                    end if;

                elsif curr_compute_state = ACC then
                    shift_en <= '1';
                    ram_we <= '1';
                    ram_re <= '0';
                    curr_compute_state <= STORE;
                    ram_addr <= ram_write_base + c(10 downto 0);
                else
                    -- transition to next mult state
                    r <= ONE;
                    v <= ZERO(10 downto 0);
                    ram_we <= '0';
                    ram_re <= '1';

                    if (c = c_lim-1) then
                        c <= ZERO;
                        -- state transtion
                        rom_wt_base <= W2_ROM_ADDR;
                        rom_bias_base <= B2_ROM_ADDR;
                        ram_vec_base <= V1_RAM_ADDR;
                        ram_write_base <= V2_RAM_ADDR;
                        r_lim <= L1_DIM;
                        c_lim <= L2_DIM;
                        curr_state <= LAYER2;

                        rom_addr <= W2_ROM_ADDR;
                    else
                        c <= c+1;
                        rom_wt_base <= rom_wt_base + r_lim;
                        rom_addr <= rom_wt_base + r_lim;
                    end if;

                    curr_compute_state <= MULT;
                end if;

            elsif curr_state = LAYER2 then

                if curr_compute_state = MULT then
                    if v = ZERO(10 downto 0) then
                        ram_we <= '0';
                        ram_re <= '1';
                        ram_addr <= ram_vec_base;
                        mac_first <= '1';
                    else
                        mac_first <= '0';
                    end if;

                    if v = r_lim(10 downto 0) then
                        curr_compute_state <= ACC;
                    else
                        v <= v+1;
                        ram_addr <= ram_vec_base + v;
                        if r = r_lim then
                            rom_addr <= rom_bias_base + c;
                        else
                            r <= r+1;
                            rom_addr <= rom_wt_base + r;
                        end if;
                    end if;

                elsif curr_compute_state = ACC then
                    shift_en <= '1';
                    ram_we <= '1';
                    ram_re <= '0';
                    curr_compute_state <= STORE;
                    ram_addr <= ram_write_base + c(10 downto 0);
                else
                    -- transition to next mult state
                    r <= ONE;
                    ram_we <= '0';
                    ram_re <= '1';

                    if (c = c_lim-1) then
                        c <= ZERO;
                        -- state transtion
                        v <= ONE(10 downto 0);
                        ram_vec_base <= V2_RAM_ADDR;
                        r_lim <= L2_DIM;
                        curr_state <= ARGMAX;
                        argmax_en <= '1';
                        ram_addr <= V2_RAM_ADDR;
                        argmax_first <= '1';
                    else
                        v <= ZERO(10 downto 0);
                        c <= c+1;
                        rom_wt_base <= rom_wt_base + r_lim;
                        rom_addr <= rom_wt_base + r_lim;
                    end if;

                    curr_compute_state <= MULT;
                end if;

            elsif curr_state = ARGMAX then
                argmax_en <= '1';
                argmax_first <= '0';

                if v = 10 then
                    curr_state <= DISP;
                    argmax_en <= '0';
                else
                    v <= v+1;
                end if;
                ram_addr <= ram_vec_base + v;
            else
                -- DISP
                -- do nothing in this state.
            end if;
        end if;
    end process upd_state;

end controller_arc;
