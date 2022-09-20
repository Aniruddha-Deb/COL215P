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

    signal led_active: std_logic;

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

begin

    -- TODO map signals to entities

    led_driver: entity work.led_driver port map (clk, seg, an, dp);

end controller_arc;
