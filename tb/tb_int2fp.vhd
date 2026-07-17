
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_int2fp is
--  Port ( );
end tb_int2fp;

architecture arch of tb_int2fp is

signal     int8 : std_logic_vector(7 downto 0);
signal sign_out : std_logic;
signal  exp_out : std_logic_vector(3 downto 0);
signal frac_out : std_logic_vector(7 downto 0);

begin

int2fp_unit : entity work.fp_convert

port map (

          int8 => int8,
      sign_out => sign_out,
       exp_out => exp_out,
      frac_out => frac_out
      
      );

process

 begin
   
--**********
--initial input
--**********

int8 <= (others => '0');      

wait for 20ns;

--*************
--case1 
--*************
--(+9) to fp

int8 <= "00001001";

wait for 20ns;

assert (sign_out = '0' and exp_out = "1011" and frac_out = "10010000")
report "Case1 +9 int2fp failed"
severity error;

--*************
--case2 
--*************
--(-7) to fp

int8 <= "11111001";

wait for 20ns;

assert (sign_out = '1' and exp_out = "1010" and frac_out = "11100000")
report "Case2 -7 int2fp failed"
severity error;

--*************
--case3 
--*************
--(+32) to fp

int8 <= "00100000";

wait for 20ns;

assert (sign_out = '0' and exp_out = "1101" and frac_out = "10000000")
report "Case3 +32 int2fp failed"
severity error;

--*************
--case4 
--*************
--(+64) to fp

int8 <= "01000000";

wait for 20ns;

assert (sign_out = '0' and exp_out = "1110" and frac_out = "10000000")
report "Case4 +64 int2fp failed"
severity error;

--*************
--case5 
--*************
--(+127) to fp

int8 <= "01111111";

wait for 20ns;

assert (sign_out = '0' and exp_out = "1111" and frac_out = "11111111")
report "Case5 +127 int2fp failed"
severity error;

--*************
--case6
--*************
--(-128) to fp

int8 <= "10000000";

wait for 20ns;

assert (sign_out = '1' and exp_out = "1111" and frac_out = "10000000")
report "Case6 -128 int2fp failed"
severity error;

report "All int2fp test cases passed";

wait;

end process;

end arch;
