library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rom is
    generic (
        ADDR_WIDTH : integer := 16; 
        DATA_WIDTH : integer := 8; 
        ROM_SIZE : integer := 65535; 
        IMAGE_FILE_NAME  : string := "imgdata_digit7.mif";
        WEIGHT_FILE_NAME : string := "weights_bias.mif"
    );
    port (
        clk  : in std_logic; -- keep for now, but unused 
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        re   : in std_logic;
        dout : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end rom;

architecture rom_arc of rom is

    type rom_arr is array(ROM_SIZE downto 0) OF std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
    type image_arr is array(783 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type wt_arr is array(50889 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

    -- TODO init memory from mif file
    impure function read_rom(img_file_name : in string; wt_file_name : in string) return rom_arr is 
        file img_file : text open read_mode is img_file_name;
        file wt_file : text open read_mode is wt_file_name;
        variable mif_line : line;
        variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
        variable temp_mem : rom_arr := (others => x"00");
    begin
        for i in 0 to 783 loop 
            readline(img_file, mif_line); 
            read(mif_line, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        for i in 1024 to 51913 loop 
            readline(wt_file, mif_line); 
            read(mif_line, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        return temp_mem;
    end function;

    signal rom_mem : rom_arr := read_rom("imgdata_digit7.mif", "weights_bias.mif");
    

begin

    dout <= rom_mem(to_integer(unsigned(addr))) when re = '1' else x"00";

end rom_arc;