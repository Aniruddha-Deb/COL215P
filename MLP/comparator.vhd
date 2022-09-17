library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;




entity comparator is
  port (
	data_in1: in std_logic_vector(15 downto 0);
	data_in2: in std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(15 downto 0)
  ) ;
end entity ; -- comparator

architecture arch of comparator is



begin

	data_out<= data_in1 when signed(data_in1) > signed(data_in2) else data_in2;

end architecture ; -- arch