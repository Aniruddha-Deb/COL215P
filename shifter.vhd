entity shifter is
  port (
	enable: in std_logic;
	is_signed: in std_logic; 
	data_in: in std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(15 downto 0)
  ) ;
end entity ; -- shifter

architecture arch of shifter is



begin


data_out <= ("11111" & data_in(15 downto 5)) when (enable = '1' and data_in(15) = '1' and is_signed = '1') 
			("00000" & data_in(15 downto 5)) when (enable = '1') else
			x"00000"


end architecture ; -- arch