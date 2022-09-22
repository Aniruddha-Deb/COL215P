library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- for type conversions

entity controller is
    port (
        clk : in std_logic;
        seg : out std_logic_vector(6 downto 0);
        an  : out std_logic;
        dp  : out std_logic
    );
end controller;

architecture controller_arc of controller is

    type state_t is (INIT, LAYER1, LAYER2, ARGMAX, DISP);
    type compute_t is (NONE, MULT, ACC, STORE);

    signal led_active: std_logic;
    signal led_A: std_logic_vector(3 downto 0);

    signal argmax_din   : signed(15 downto 0);
    signal argmax_en    : std_logic;
    signal argmax_first : std_logic;
    signal argmax_dout  : std_logic_vector(3 downto 0);

    signal ram_addr : std_logic_vector(10 downto 0);
    signal ram_din  : std_logic_vector(15 downto 0);
    signal ram_we   : std_logic;
    signal ram_re   : std_logic;
    signal ram_dout : std_logic_vector(15 downto 0);

    signal rom_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal rom_re   : std_logic;
    signal rom_dout : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal cmp_din1: std_logic_vector(15 downto 0);
    signal cmp_din2: std_logic_vector(15 downto 0);
    signal cmp_dout: std_logic_vector(15 downto 0);

    signal shift_en     : std_logic;
    signal shift_signed : std_logic := '1'; 
    signal shift_din    : std_logic_vector(15 downto 0);
    signal shift_dout   : std_logic_vector(15 downto 0);

    signal mac_first : std_logic;
    signal mac_din1  : signed(15 downto 0); -- input (widened from 8 bits to 16 bits)/activation( 16 bits)
    signal mac_din2  : signed(7 downto 0);  -- 8 bits (weight/bias)
    signal mac_dout  : signed(15 downto 0);

    -- controller internal signals
    signal r : unsigned(15 downto 0);
    signal c : unsigned(15 downto 0);
    signal r_lim : unsigned(15 downto 0);
    signal c_lim : unsigned(15 downto 0);

    signal rom_wt_base : unsigned(15 downto 0);
    signal rom_bias_base : unsigned(15 downto 0);
    signal ram_vec_base : unsigned(15 downto 0);

    signal curr_state: state_t := INIT;
    signal curr_compute_state: compute_t := NONE;

    signal ZERO : unsigned(15 downto 0) := x"0000";
    signal ONE  : unsigned(15 downto 0) := x"0001";

    signal L0_DIM : unsigned(15 downto 0) := to_unsigned(784,16);
    signal L1_DIM : unsigned(15 downto 0) := to_unsigned(64,16);
    signal L2_DIM : unsigned(15 downto 0) := to_unsigned(10,16);

    signal IMG_ROM_ADDR : unsigned(15 downto 0) := to_unsigned(0,16);
    signal W1_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(1024,16);
    signal B1_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(51200,16); -- 1024 + 784*64
    signal W2_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(51264,16); -- 1024 + 784*64 + 64
    signal B2_ROM_ADDR  : unsigned(15 downto 0) := to_unsigned(51904,16); -- 1024 + 784*64 + 64 + 64*10
    
    signal V0_RAM_ADDR : unsigned(15 downto 0) := to_unsigned(0,16);
    signal V1_RAM_ADDR : unsigned(15 downto 0) := to_unsigned(784,16);
    signal V2_RAM_ADDR : unsigned(15 downto 0) := to_unsigned(848,16);

begin

    -- TODO map signals to entities

    led_driver: entity work.led_driver port map (
        active => led_active;
        A => led_A;
        seg => seg;
        dp => dp;
        an => an
    );

    ram: entity work.ram port map (
        clk  => clk;
        addr => ram_addr;
        din  => ram_din;
        we   => ram_we;
        re   => ram_re;
        dout => ram_dout
    );

    rom: entity work.rom port map (
        clk  => clk;
        addr => rom_addr;
        re   => rom_re;
        dout => rom_dout
    );

    shifter: entity work.shifter port map (
        enable => shift_en;
        is_signed => shift_signed;
        data_in => shift_din;
        data_out => shift_dout
    );

    mac: entity work.mac port map (
        clk => clk;
        first => mac_first;
        din1 => mac_din1;
        din2 => mac_din2;
        dout => mac_dout
    );

    comparator: entity work.comparator port map (
        din1 => cmp_din1;
        din2 => cmp_din2;
        dout => cmp_dout
    );

    argmax: entity work.argmax port map (
        clk   => clk;
        din   => argmax_din;
        en    => argmax_en;
        first => argmax_first;
        dout  => argmax_dout
    );

    -- control logic here

    led_active <= ; -- TODO
    led_A <= ; -- TODO

    argmax_din <= ; -- TODO
    argmax_en <= ; -- TODO
    argmax_first <= ; -- TODO
    argmax_dout <= ; -- TODO

    ram_addr <= ; -- TODO
    ram_din <= ; -- TODO
    ram_we <= ; -- TODO
    ram_re <= ; -- TODO
    ram_dout <= ; -- TODO

    rom_addr <= ; -- TODO
    rom_re <= ; -- TODO
    rom_dout <= ; -- TODO

    cmp_din1 <= ; -- TODO
    cmp_din2 <= ; -- TODO
    cmp_dout <= ; -- TODO

    shift_en <= ; -- TODO
    shift_signed <= ; -- TODO
    shift_din <= ; -- TODO
    shift_dout <= ; -- TODO

    mac_first <= ; -- TODO
    mac_din1 <= ; -- TODO
    mac_din2 <= ; -- TODO
    mac_dout <= ; -- TODO

    upd_state : process(clk)
    begin
        if (curr_state = INIT) then
            if r = L0_DIM-1 then 
                curr_state <= LAYER1;
                r <= ZERO;
                c <= ZERO;
                r_lim <= L0_DIM;
                c_lim <= L1_DIM;
            end if;
        elsif (curr_state = LAYER1) then
            if curr_compute_state = NONE then
            elsif curr_compute_state = MULT then
            elsif curr_compute_state = ACC then
            else -- curr_compute_state = STORE
            end if;
        elsif (curr_state = LAYER2) then
            if curr_compute_state = NONE then
            elsif curr_compute_state = MULT then
            elsif curr_compute_state = ACC then
            else -- curr_compute_state = STORE
            end if;
        elsif curr_state = ARGMAX then
        else
            -- just display the result.
        end if;
    end process upd_state;

end controller_arc;
