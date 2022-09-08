library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity rom is
    generic (
        ADDR_WIDTH : integer := 10; 
        DATA_WIDTH : integer := 8; 
        ROM_SIZE : integer := 784; 
        IMAGE_FILE_NAME : string := "sample.mif"
    );
    port (
        clk  : in std_logic; -- keep for now, but unused 
        addr : in std_logic_vector(16 downto 0);
        re   : in std_logic;
        dout : out std_logic_vector(7 downto 0)
    );
end rom;

architecture rom_arc of rom is

    type rom_arr is array(0 TO ROM_SIZE) OF std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
    
    -- TODO init memory from mif file
    impure function init_mem(mif_file_name : in string) return mem_type is file mif_file : text open read_mode is mif_file_name;
        variable mif_line : line;
        variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
        variable temp_mem : rom_arr; 
    begin
        for i in rom_arr'range loop 
            readline(mif_file, mif_line); 
            read(mif_line, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        return temp_mem; 
    end function;

    signal rom_mem : rom_arr := init_mem(IMAGE_FILE_NAME);

begin

    dout <= rom_mem(to_integer(unsigned(addr))) when re = '1' else x"00";

end rom_arc;


...