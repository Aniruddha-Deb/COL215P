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

    type state_t is (INIT, LAYER1, LAYER2, ARGMAX, DISP); -- which part of the process we are currently in
    type compute_t is (NONE, MULT, ACC, STORE);  -- compute state

    signal led_active: std_logic;               -- led is active or not
    signal led_A: std_logic_vector(3 downto 0); -- the actual digit to display in the led

    signal argmax_din   : signed(15 downto 0);          -- the data fed into arg_max (will be sequentially feeding the values corresponding to the 10 output)
    signal argmax_en    : std_logic;                    -- enable the argmax
    signal argmax_first : std_logic;                    -- first input to argmax
    signal argmax_dout  : std_logic_vector(3 downto 0); -- output from argmax

    signal ram_addr : std_logic_vector(10 downto 0);
    signal ram_din  : std_logic_vector(15 downto 0);
    signal ram_we   : std_logic;
    signal ram_re   : std_logic;
    signal ram_dout : std_logic_vector(15 downto 0);

    signal rom_addr : std_logic_vector(15 downto 0);
    signal rom_re   : std_logic;
    signal rom_dout : std_logic_vector(8 downto 0);

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
    signal r_lim : unsigned(15 downto 0);
    signal c_lim : unsigned(15 downto 0);

    signal rom_wt_base : unsigned(15 downto 0);     -- pointer to starting address in rom for reading weights
    signal rom_bias_base : unsigned(15 downto 0);   -- pointer to starting address in rom for reading bias
    signal ram_vec_base : unsigned(15 downto 0);    -- pointer to starting address in ram for reading input

    signal curr_state: state_t := INIT;
    signal curr_compute_state: compute_t := NONE;

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

    signal V0_RAM_ADDR : unsigned(15 downto 0) := to_unsigned(0,16);
    signal V1_RAM_ADDR : unsigned(15 downto 0) := to_unsigned(784,16);
    signal V2_RAM_ADDR : unsigned(15 downto 0) := to_unsigned(848,16);

    signal ram_read_pos : unsigned(15 downto 0) := x"0000";
    signal ram_load_pos : unsigned(15 downto 0) := x"0000";

    signal ram_l1_output_pos : unsigned(15 downto 0) := x"0000";
    signal ram_l2_output_pos : unsigned(15 downto 0) := x"0000";

    signal rom_read_pos   : unsigned(15 downto 0) := x"0000";
    signal rom_weight_pos : unsigned(15 downto 0) := x"0000";

    signal mac_first_flag_l1 : std_logic := '0';
    signal mac_first_flag_l2 : std_logic := '0';
    signal argmax_first_flag : std_logic := '0';

begin

    -- TODO map signals to entities

    led_driver: entity work.led_driver port map (
        active => led_active,
        A => led_A,
        seg => seg,
        dp => dp,
        an => an
    );

    ram: entity work.ram port map (
        clk  => clk,
        addr => ram_addr,
        din  => ram_din,
        we   => ram_we,
        re   => ram_re,
        dout => ram_dout
    );

    rom: entity work.rom port map (
        clk  => clk,
        addr => rom_addr,
        re   => rom_re,
        dout => rom_dout
    );

    shifter: entity work.shifter port map (
        enable => shift_en,
        is_signed => shift_signed,
        data_in => shift_din,
        data_out => shift_dout
    );

    mac: entity work.mac port map (
        clk => clk,
        first => mac_first,
        din1 => mac_din1,
        din2 => mac_din2,
        dout => mac_dout
    );

    comparator: entity work.comparator port map (
        din1 => cmp_din1,
        din2 => cmp_din2,
        dout => cmp_dout
    );

    argmax: entity work.argmax port map (
        clk   => clk,
        din   => argmax_din,
        en    => argmax_en,
        first => argmax_first,
        dout  => argmax_dout
    );

    -- control logic here

    led_active <= '1' when curr_state = DISP else
                  '0' ; -- TODO
    led_A <= argmax_dout when curr_state = DISP else
             "0000"; -- TODO

    argmax_din    <= signed(ram_dout) when curr_state = ARGMAX else x"0000"; -- need to change ram address appropriately
    argmax_en     <= '1' when curr_state = ARGMAX else
                     '0'; -- TODO
    argmax_first  <= ; -- i think we need to adjust this while changing the state, for example if we are changing state from layer-2 to argmax, we would set this to zero, at the next clock cycle if we are already at argmax, we would set it to '0'
    argmax_dout   <= ; -- why do we need to do anything here, assuming correctness of argmax

    ram_addr      <= std_logic_vector(V0_RAM_ADDR + ram_load_pos) when curr_state = INIT else   -- in the initial state we would be reading from ram and storing the input image starting from V0_BASE_ADDR

                     std_logic_vector(V0_RAM_ADDR + ram_read_pos) when curr_state = LAYER1 and curr_compute_state = MULT else -- reading the input image for multiplication (NOTE - MAINTAIN RAM READ POS 1 BEHIND THE CORRESPONDING ROW AND COLUMN IN ROM)
                     x"0000"                    when curr_state = LAYER1 and curr_compute_state = ACC else  -- no need to read anything from RAM when computing output of accumulator
                     std_logic_vector(V1_RAM_ADDR + ram_l1_output_pos) when curr_state = LAYER1 and curr_compute_state = STORE else -- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     std_logic_vector(V1_RAM_ADDR + ram_read_pos) when curr_state = LAYER2 and curr_compute_state = MULT else -- reading the intermediate result of first layer for multiplication (NOTE - MAINTAIN RAM READ POS 1 BEHIND THE CORRESPONDING ROW AND COLUMN IN ROM)
                     x"0000"                    when curr_state = LAYER2 and curr_compute_state = ACC else  -- no need to read anything from RAM when computing output of accumulator
                     std_logic_vector(V2_RAM_ADDR + ram_l2_output_pos) when curr_state = LAYER2 and curr_compute_state = STORE else -- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     std_logic_vector(V2_RAM_ADDR + ram_read_pos) when curr_state = ARGMAX else

                     x"0000" when curr_state = DISP;

    ram_din       <= std_logic_vector(x"00" & rom_dout) when curr_state = INIT else -- unsigned extension of 8 bit input read from ROM to RAM

                     x"0000" when curr_state = LAYER1 and curr_compute_state = MULT else  -- reading the input, so no need to store anything
                     x"0000" when curr_state = LAYER1 and curr_compute_state = ACC else -- nothing required
                     cmp_dout when curr_state = LAYER1 and curr_compute_state = STORE else -- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     x"0000" when curr_state = LAYER2 and curr_compute_state = MULT else  -- reading the input, so no need to store anything
                     x"0000" when curr_state = LAYER2 and curr_compute_state = ACC else  -- nothing required
                     cmp_dout when curr_state = LAYER2 and curr_compute_state = STORE else -- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     x"0000" when curr_state = ARGMAX else

                     x"0000" when curr_state = DISP;

    ram_we        <= '1' when curr_state = INIT else              -- in the initial state of loading we would be writing to RAM

                     '0' when curr_state = LAYER1 and curr_compute_state = MULT else -- reading input for first layer multiplication
                     '0' when curr_state = LAYER1 and curr_compute_state = ACC else -- no need to do anything
                     '1' when curr_state = LAYER1 and curr_compute_state = STORE else -- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     '0' when curr_state = LAYER2 and curr_compute_state = MULT else -- reading input for first layer multiplication
                     '0' when curr_state = LAYER2 and curr_compute_state = ACC  else -- no need to do anything
                     '1' when curr_state = LAYER2 and curr_compute_state = STORE else-- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     '0' when curr_state = ARGMAX else

                     '0' when curr_state = DISP;

    ram_re        <= '0' when curr_state = INIT else               -- in the initial state we won't be reading anything from the RAM (can we improve this)

                     '1' when curr_state = LAYER1 and curr_compute_state = MULT else
                     '0' when curr_state = LAYER1 and curr_compute_state = ACC  else -- no need to do anything
                     '0' when curr_state = LAYER1 and curr_compute_state = STORE  else -- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     '1' when curr_state = LAYER2 and curr_compute_state = MULT else
                     '0' when curr_state = LAYER2 and curr_compute_state = ACC else  -- no need to do anything
                     '0' when curr_state = LAYER2 and curr_compute_state = STORE else -- storing the computed result (one element of the resultant matrix, after row column multiplication, bias addition, shifting and application of relu)

                     '1' when curr_state = ARGMAX  else

                     '0' when curr_state = DISP;

    ram_dout      <= -- why do we need to assign value to this

    rom_addr <= std_logic_vector(IMG_ROM_ADDR + r) when curr_state = INIT else

                std_logic_vector(W1_ROM_ADDR + c*L0_DIM + r) when curr_state = LAYER1 and curr_compute_state = MULT else
                std_logic_vector(B1_ROM_ADDR + c) when curr_state = LAYER1 and curr_compute_state = ACC else  -- reading bias from ROM
                x"0000" when curr_state = LAYER1 and curr_compute_state = STORE else -- no need to do anything to ROM at this point

                std_logic_vector(W2_ROM_ADDR + c*L1_DIM + r) when curr_state = LAYER2 and curr_compute_state = MULT else
                std_logic_vector(B2_ROM_ADDR + c) when curr_state = LAYER2 and curr_compute_state = ACC else -- reading bias from ROM
                x"0000" when curr_state = LAYER2 and curr_compute_state = STORE else -- no need to do anything to ROM at this point

                x"0000" when curr_state = ARGMAX else

                x"0000" when curr_state = DISP;


    rom_re <= '1' when curr_state = INIT else  -- TODO

              '1' when curr_state = LAYER1 and curr_compute_state = MULT else  -- reading weights from ROM
              '1' when curr_state = LAYER1 and curr_compute_state = ACC else   -- reading bias from ROM
              '0' when curr_state = LAYER1 and curr_compute_state = STORE else -- no need to do anything to ROM at this point in time

              '1' when curr_state = LAYER2 and curr_compute_state = MULT else -- reading weights from ROM
              '1' when curr_state = LAYER2 and curr_compute_state = ACC else  -- reading bias from ROM
              '0' when curr_state = LAYER2 and curr_compute_state = STORE else-- no need to do anything to ROM at this point in time

              '0' when curr_state = ARGMAX else

              '0' when curr_state = DISP;

    rom_dout <= ; -- why do we need to do anything here

    cmp_din1 <= x"0000" when curr_state = INIT else  -- TODO

                x"0000" when curr_state = LAYER1 and curr_compute_state = MULT else
                x"0000" when curr_state = LAYER1 and curr_compute_state = ACC  else -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                x"0000" when curr_state = LAYER1 and curr_compute_state = STORE else -- at this point we need to use comparator to do relu (by comparison of accumulated output with 0)

                x"0000" when curr_state = LAYER2 and curr_compute_state = MULT else
                x"0000" when curr_state = LAYER2 and curr_compute_state = ACC  else -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                x"0000" when curr_state = LAYER2 and curr_compute_state = STORE else -- at this point we need to use comparator to do relu (by comparison of accumulated output with 0)

                x"0000" when curr_state = ARGMAX else

                x"0000" when curr_state = DISP;

    cmp_din2 <= x"0000" when curr_state = INIT else  -- TODO

                x"0000" when curr_state = LAYER1 and curr_compute_state = MULT else
                x"0000" when curr_state = LAYER1 and curr_compute_state = ACC else -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                shift_dout when curr_state = LAYER1 and curr_compute_state = STORE else -- at this point we need to use comparator to do relu (by comparison of accumulated output with 0)

                x"0000" when curr_state = LAYER2 and curr_compute_state = MULT else
                x"0000" when curr_state = LAYER2 and curr_compute_state = ACC else  -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                shift_dout when curr_state = LAYER2 and curr_compute_state = STORE else -- at this point we need to use comparator to do relu (by comparison of accumulated output with 0)

                x"0000" when curr_state = ARGMAX else

                x"0000" when curr_state = DISP;

    cmp_dout <= -- why do we need to do anything at this point
    --cmp_dout <= x"0000" when curr_state = INIT else  -- TODO
    --         <= x"0000" when curr_state = LAYER1 and curr_compute_state = MULT
    --         <= x"0000" when curr_state = LAYER1 and curr_compute_state = ACC  -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output

    -- shifter will be required only in compute_state STORE
    shift_en <= '0' when curr_state = INIT else  -- TODO

                '0' when curr_state = LAYER1 and curr_compute_state = MULT else
                '0' when curr_state = LAYER1 and curr_compute_state = ACC else -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                '1' when curr_state = LAYER1 and curr_compute_state = STORE else -- at this point we need to use comparator to do relu (by comparison of accumulated output with 0)

                '0' when curr_state = LAYER1 and curr_compute_state = MULT else
                '0' when curr_state = LAYER1 and curr_compute_state = ACC else -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                '1' when curr_state = LAYER1 and curr_compute_state = STORE else -- at this point we need to use comparator to do relu (by comparison of accumulated output with 0)

                '0' when curr_state = ARGMAX else

                '0' when curr_state = DISP;

    shift_signed <= '1'; -- this should always be 1

    shift_din <= x"0000" when curr_state = INIT else  -- TODO

                 x"0000" when curr_state = LAYER1 and curr_compute_state = MULT else
                 x"0000" when curr_state = LAYER1 and curr_compute_state = ACC else -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                 std_logic_vector(mac_dout) when curr_state = LAYER1 and curr_compute_state = STORE else -- at this point we need to shift the output from mac (which includes the bias added) by 32 bits

                 x"0000" when curr_state = LAYER2 and curr_compute_state = MULT else
                 x"0000" when curr_state = LAYER2 and curr_compute_state = ACC else  -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output
                 std_logic_vector(mac_dout) when curr_state = LAYER2 and curr_compute_state = STORE else -- at this point we need to shift the output from mac (which includes the bias added) by 32 bits

                 x"0000" when curr_state = ARGMAX else

                 x"0000" when curr_state = DISP;

    shift_dout <= -- why do we need to do anything here
    --shift_dout <= x"0000" when curr_state = INIT else  -- TODO
    --         <= x"0000" when curr_state = LAYER1 and curr_compute_state = MULT
    --         <= x"0000" when curr_state = LAYER1 and curr_compute_state = ACC  -- in this state also the output from mac would not be correct for comparison, as the mac would take once clock cycle to output the accumulated(one with bias) output

    mac_first <= ; -- needs to be maintained during FSM transition
    mac_din1 <= signed(ram_dout) when curr_state = LAYER1 and curr_compute_state = MULT else  -- input matrix
                x"0001" when curr_state = LAYER1 and curr_compute_state = ACC else
                x"0000" when curr_state = LAYER1 and curr_compute_state = STORE else -- MAC needs to be reset at this point, but this will be done by setting first at apt time

                signed(ram_dout) when curr_state = LAYER2 and curr_compute_state = MULT else  -- input matrix
                x"0001" when curr_state = LAYER2 and curr_compute_state = ACC else
                x"0000" when curr_state = LAYER2 and curr_compute_state = STORE else -- MAC needs to be reset at this point, but this will be done by setting first at apt time

                x"0000" when curr_state = ARGMAX else

                x"0000" when curr_state = DISP;

    mac_din2 <= signed(rom_dout) when curr_state = LAYER1 and curr_compute_state = MULT else  -- weight from rom
                signed(rom_dout) when curr_state = LAYER1 and curr_compute_state = ACC else   -- bias from ROM
                x"0000" when curr_state = LAYER1 and curr_compute_state = STORE else -- MAC needs to be reset at this point, but this will be done by setting first at apt time

                signed(rom_dout) when curr_state = LAYER2 and curr_compute_state = MULT else  -- weight from rom
                signed(rom_dout) when curr_state = LAYER2 and curr_compute_state = ACC else   -- bias from ROM
                x"0000" when curr_state = LAYER2 and curr_compute_state = STORE else -- MAC needs to be reset at this point, but this will be done by setting first at apt time

                x"0000" when curr_state = ARGMAX else

                x"0000" when curr_state = DISP;

    mac_dout <= ;  -- why do we need to do anything


    --r <= r + 1 when curr_state = LAYER1 and curr_compute_state = MULT else

    --c <= c + 1 when curr_state = LAYER1 and curr_compute_state

    upd_state : process(clk)
    begin
        --if (curr_state = INIT) then
        --    if r = L0_DIM-1 then
        --        curr_compute_state <= LAYER1;
        --        r <= ZERO;
        --        c <= ZERO;
        --        r_lim <= L0_DIM;
        --        c_lim <= L1_DIM;
        --    end if;
        --elsif (curr_state = LAYER1) then
        --    if curr_compute_state = NONE then
        --    elsif curr_compute_state = MULT then
        --    elsif curr_compute_state = ACC then
        --    else -- curr_compute_state = STORE
        --    end if;
        --elsif (curr_state = LAYER2) then
        --    if curr_compute_state = NONE then
        --    elsif curr_compute_state = MULT then
        --    elsif curr_compute_state = ACC then
        --    else -- curr_compute_state = STORE
        --    end if;
        --elsif curr_state = ARGMAX then
        --else
        --    -- just display the result.
        --end if;

        if (curr_state = INIT) then
            if r = L0_DIM-1 then
                curr_state <= LAYER1;
                curr_compute_state <= MULT;

                c <= ZERO;
                r <= ZERO;
                r_lim <= L0_DIM;
                c_lim <= L1_DIM;

                ram_load_pos <= 0;
                ram_read_pos <= 0;

                mac_first <= '0';
                mac_first_flag_l1 <= '0';
                mac_first_flag_l2 <= '0';

            else
                r <= r + 1;         -- c will be used to move over the image (stored in column major format)
                ram_load_pos <= ram_load_pos + 1; -- ram_load_pos will be used to store the input image read from rom ( ram_read_pos should be 1 clock cycle behind in intialization)
            end if;
        elsif (curr_state = LAYER1) then
            if curr_compute_state = NONE then  -- when can such thing happen ?
            elsif curr_compute_state = MULT then

                if r = L0_DIM - 1 then
                    curr_compute_state <= ACC;
                end if;

                if mac_first_flag_l1 = '0' then
                    mac_first <= '1';
                    mac_first_flag_l1 <= '1';
                else
                    mac_first <= '0';
                end if;
                --end if;

                ram_read_pos <= ram_read_pos + 1;
                r <= r + 1;
            elsif curr_compute_state = ACC then
                curr_compute_state <= STORE;
                c <= c + 1;
                --ram_l1_output_pos <=
            elsif curr_compute_state = STORE then
                ram_l1_output_pos <= ram_l1_output_pos + 1;
                if c = c_lim then
                    -- shift to layer 2
                    curr_state <= LAYER2;
                    curr_compute_state <= MULT;

                    ram_read_pos <= x"0000";
                    c <= x"0000";
                    r <= x"0000";

                    mac_first <= '0';

                else
                    -- multiply leftover columns
                    curr_state <= LAYER1;
                    curr_compute_state <= MULT;

                    mac_first_flag_l1 <= '0';

                    ram_read_pos <= x"0000";
                    r <= x"0000";
                    -- c would already be incremented when we transition to state STORE (around line 414)

                end if;
            --elsif curr_compute_state = ACC then
            else -- curr_compute_state = STORE
            end if;
        elsif (curr_state = LAYER2) then
            if curr_compute_state = NONE then  -- when can such thing happen ?
            elsif curr_compute_state = MULT then

                if r = L0_DIM - 1 then
                    curr_compute_state <= ACC;
                end if;

                if mac_first_flag_l2 = '0' then
                    mac_first <= '1';
                    mac_first_flag_l2 <= '1';
                else
                    mac_first <= '0';
                end if;
                --end if;

                ram_read_pos <= ram_read_pos + 1;

                r <= r + 1;

            elsif curr_compute_state = ACC then
                curr_compute_state <= STORE;
                c <= c + 1;
                --ram_l1_output_pos <=
            elsif curr_compute_state = STORE then
                ram_l2_output_pos <= ram_l2_output_pos + 1;
                if c = c_lim then
                    -- go to state ARGMAX
                    curr_state <= ARGMAX;
                    curr_compute_state <= NONE;
                    argmax_first_flag <= '0';

                    ram_read_pos <= x"0000";

                    -- they won't be needed anymore
                    c <= x"0000";
                    r <= x"0000";


                else
                    -- multiply leftover columns
                    curr_state <= LAYER2;
                    curr_compute_state <= MULT;

                    mac_first_flag_l2 <= '0';

                    ram_read_pos <= x"0000";
                    r <= x"0000";
                    -- c would already be incremented when we transition to state STORE (around line 414)

                end if;
            --elsif curr_compute_state = ACC then
            --else -- curr_compute_state = STORE
            end if;
        elsif curr_state = ARGMAX then
            if ram_read_pos = L2_DIM then 
                curr_state <= DISP;
                led_active <= '1';
                led_A <= argmax_dout;
            else
                ram_read_pos <= ram_read_pos + 1;
            end if;
        else -- curr_state is display
            led_active <= '1'
            led_A <= argmax_dout;
            -- just display the result.
        end if;


    end process upd_state;

end controller_arc;
