library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity register_tb is
-- empty
end entity ; -- register_tb




architecture arch of register_tb is

component reg is
    generic (
        size : integer := 16
    );
    port (
    	write_enable: in std_logic;
        clk  : in std_logic;
        din  : in signed(size-1 downto 0);
        dout : out signed(size-1 downto 0) := (others => '0')
    );
end component;

signal write_enable  : std_logic := '1';
signal clk           : std_logic := '0';
signal din           : signed(15 downto 0) := x"0000";
signal dout          : signed(15 downto 0) := x"0000"; 

begin
	DUT: reg port map (write_enable, clk, din, dout);

	process
	begin

	clk <= '1';
	din <= x"AAAF";
	write_enable<= '1';

	wait for 1 ns;
	assert dout <= x"AAAF" report "Error";

	clk <= '0';
	wait for 1 ns;

	clk <= '1';
	din <= x"1AAF";
	write_enable<= '0';


	wait for 1 ns;
	assert dout <= x"AAAF" report "Error";


	clk <= '0';
	wait for 1 ns;


	clk <= '1';
	din <= x"1AAF";
	write_enable<= '1';


	wait for 1 ns;
	assert dout <= x"1AAF" report "Error";


	clk <= '0';
	wait for 1 ns;



	end process;

end architecture ; -- arch