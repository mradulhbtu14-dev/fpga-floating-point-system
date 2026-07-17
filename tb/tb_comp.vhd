
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_comp is
--  Port ( );
end tb_comp;

architecture arch of tb_comp is

signal sign1,sign2 : std_logic;
signal   exp1,exp2 : std_logic_vector(3 downto 0);
signal frac1,frac2 : std_logic_vector(7 downto 0);
signal    gt,lt,eq : std_logic;
signal    comp_res : std_logic_vector (1 downto 0);

begin

comp_unit : entity work.fp_greater

port map (

           sign1 => sign1,
           sign2 => sign2,
            exp1 => exp1,
            exp2 => exp2,
           frac1 => frac1,
           frac2 => frac2,
              gt => gt,
              lt => lt,
              eq => eq,
        comp_res => comp_res
           
           );
 
process

 begin
 
--**********
--initial input
--**********

sign1 <= '0';
sign2 <= '0';
exp1 <= (others => '0');
exp2 <= (others => '0');
frac1 <= (others => '0');
frac2 <= (others => '0');

    wait for 20ns;

--*************
--case1 
--*************
--(+7)>(+2)

sign1 <= '0';
 exp1 <= "1010";
frac1 <= "11100000";

sign2 <= '0';
 exp2 <= "1001";
frac2 <= "10000000";

    wait for 20ns;

assert (comp_res = "01" and gt = '1' and lt = '0' and eq = '0')
report "Case1 : gt test failed"
severity error;

--*************
--case2 
--*************

sign1 <= '0';
 exp1 <= "1001";
frac1 <= "10000000";

sign2 <= '0';
 exp2 <= "1010";
frac2 <= "11000000";

    wait for 20ns;

assert (comp_res = "10" and gt = '0' and lt = '1' and eq = '0')
report "Case2 : lt test failed"
severity error;

--*************
--case3 
--*************

sign1 <= '0';
 exp1 <= "1001";
frac1 <= "10000000";

sign2 <= '0';
 exp2 <= "1001";
frac2 <= "10000000";

    wait for 20ns;

assert (comp_res = "00" and gt = '0' and lt = '0' and eq = '1')
report "Case3 : eq test failed"
severity error;

report "All comp test cases passed";

wait;

end process;

end arch;
