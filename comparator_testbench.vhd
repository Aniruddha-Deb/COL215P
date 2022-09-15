library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;




entity comparator_testbench is
--empty
end entity ; -- comparator_testbench

architecture arch of comparator_testbench is

component comparator is 
	port(
		data_in1: in std_logic_vector(15 downto 0);
		data_in2: in std_logic_vector(15 downto 0);
		data_out: out std_logic_vector(15 downto 0)
	);


end component;

signal tb_data_in1: std_logic_vector(15 downto 0);
signal tb_data_in2: std_logic_vector(15 downto 0);
signal tb_data_out: std_logic_vector(15 downto 0);


begin

	DUT: comparator port map (tb_data_in1, tb_data_in2, tb_data_out);
	process
	begin

	tb_data_in1 <= x"0000";
	tb_data_in2 <= x"1000";
	wait for 1 ns;

	tb_data_in1 <= x"0000";
	tb_data_in2 <= x"0030";
	wait for 1 ns;


	tb_data_in1 <= x"1000";
	tb_data_in2 <= x"0130";
	wait for 1 ns;



	end process;

end architecture ; -- arch