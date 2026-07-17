
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_fp2int is
--  Port ( );
end tb_fp2int;

architecture arch of tb_fp2int is

signal sign,mode : std_logic;
signal       exp : std_logic_vector(3 downto 0);
signal      frac : std_logic_vector(7 downto 0);
signal      int8 : std_logic_vector(7 downto 0);

begin

fp2int_unit : entity work.fp2int

port map (

          sign => sign,
          mode => mode,
           exp => exp,
          frac => frac,
          int8 => int8
          
        );
        
process 

 begin
 
--**********
--initial input
--**********

sign <= '0';
 exp <= (others => '0');
frac <= (others => '0');           
mode <= '0';  --signed mode initially

wait for 20ns;

--*************
--case1 
--*************

--(+6)

mode <= '0';
sign <= '0';   
 exp <= "1010";
frac <= "11000000"; 

wait for 20ns;

assert int8 = "00000110"
report "Case1 : +6 fp to int failed"
severity error;

--*************
--case2 
--*************

--(-5)

mode <= '0';
sign <= '1';
 exp <= "1010";
frac <= "10100000"; 

wait for 20ns;

assert int8 = "11111011"
report "Case2 : -5 fp to int failed"
severity error;

--*************
--case3 
--*************

--(+200)
--signed overflow (mode = '0')

mode <= '0';
sign <= '0';
 exp <= "1111";
frac <= "11001000"; 

wait for 20ns;

assert int8 = "01111111"
report "Case3 : positive signed overflow test failed"
severity error;

--*************
--case4 
--*************

--(+250)
--unsigned overflow (mode = '1')

mode <= '1';
sign <= '0';
 exp <= "1111";
frac <= "11111010"; 

wait for 20ns;

assert int8 = "11111010"
report "Case4 : unsigned conversion test failed"
severity error;

--*************
--case5 
--*************

--(+5.75 ~ +6)
--GRS round up logic

mode <= '0';
sign <= '0';
 exp <= "1010";
frac <= "10111000"; 

wait for 20ns;

assert int8 = "00000110"
report "Case5 : GRS roundup test failed"
severity error;

--*************
--case6 
--*************

--(-200)
--signed negative overflow

mode <= '0';
sign <= '1';
 exp <= "1111";
frac <= "11001000"; 

wait for 20ns;

assert int8 = "10000000"
report "Case6 : negative signed underflow test failed"
severity error;

report "All fp2int test cases passed";

wait;

end process;

end arch;
