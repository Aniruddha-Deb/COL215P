library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;



entity shifter_tb is
-- empty
end entity ; -- shifter_tb

architecture arch of shifter_tb is

component shifter is 
	port(
		enable: in std_logic;
		is_signed: in std_logic;
		data_in : in std_logic_vector(15 downto 0);
		data_out: out std_logic_vector(15 downto 0)
		);
end component;


signal tb_enable: std_logic:= '1';

signal tb_is_signed: std_logic:= '1';

signal tb_data_in : std_logic_vector(15 downto 0):= x"0000";

signal tb_data_out : std_logic_vector(15 downto 0);

begin

	DUT: shifter port map (tb_enable, tb_is_signed, tb_data_in, tb_data_out);

	process
	begin

		tb_enable <= '1';
		tb_is_signed <= '1';
		tb_data_in <= x"10AB";
		wait for 1 ns;


		tb_enable <= '1';
		tb_is_signed <= '0';
		tb_data_in <= x"10AB";
		wait for 1 ns;


		tb_enable <= '1';
		tb_is_signed <= '1';
		tb_data_in <= x"F0AB";
		wait for 1 ns;


		tb_enable <= '1';
		tb_is_signed <= '0';
		tb_data_in <= x"F0AB";
		wait for 1 ns;

		tb_enable <= '0';
		tb_is_signed <= '0';
		tb_data_in <= x"F0AB";
		wait for 1 ns;

		tb_enable <= '0';
		tb_is_signed <= '1';
		tb_data_in <= x"F0AB";
		wait for 1 ns;


		assert False report "Test done" severity note;

	end process;

end architecture ; -- arch

