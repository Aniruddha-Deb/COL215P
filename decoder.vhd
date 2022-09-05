library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port (
        A: in std_logic_vector(3 downto 0);
        seg: out std_logic_vector(6 downto 0)
    );
end decoder;

architecture decoder_bvr of decoder is
begin
    
    seg(0) <= (A(0) and (not A(1)) and (not A(2)) and (not A(3))) or (A(2) and (not A(1)) and (not A(0)) and (not A(3)));
    seg(1) <= (A(0) and A(2) and (not A(1)) and (not A(3))) or (A(1) and A(2) and (not A(0)) and (not A(3)));
    seg(2) <= (A(1) and (not A(0)) and (not A(2)) and (not A(3)));
    seg(3) <= (A(0) and (not A(1)) and (not A(2)) and (not A(3))) or (A(2) and (not A(0)) and (not A(1)) and (not A(3))) or (A(0) and A(1) and A(2) and (not A(3)));
    seg(4) <= (A(0) and (not A(3))) or (A(2) and (not A(1)) and (not A(3))) or (A(0) and (not A(1)) and (not A(2)));
    seg(5) <= (A(0) and (not A(2)) and (not A(3))) or (A(0) and A(1) and (not A(3))) or (A(1) and (not A(3)) and (not A(2)));
    seg(6) <= (A(0) and A(1) and A(2) and (not A(3))) or ((not A(1)) and (not A(2)) and (not A(3)));

end decoder_bvr;