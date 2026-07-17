
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_fp_adder is
--  Port ( );
end tb_fp_adder;

architecture arch of tb_fp_adder is

constant T : time := 20ns;

signal sign1,sign2 : std_logic;
signal   exp1,exp2 : std_logic_vector(3 downto 0);
signal frac1,frac2 : std_logic_vector(7 downto 0);
signal    sign_out : std_logic;
signal     exp_out : std_logic_vector(3 downto 0);
signal    frac_out : std_logic_vector(7 downto 0);
signal      fp_sum : std_logic_vector(12 downto 0); 

begin

--****************
--instantiation
--***************

fp_adder_unit : entity work.fp_adder(arch)

port map(

          sign1 => sign1,
          sign2 => sign2,
           exp1 => exp1,
           exp2 => exp2,
          frac1 => frac1,
          frac2 => frac2,
       sign_out => sign_out,
        exp_out => exp_out,
       frac_out => frac_out,
         fp_sum => fp_sum
         
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
--case1 fp number
--*************

--(+5) + (+3) = (+8)

sign1 <= '0';
 exp1 <= "1010";
frac1 <= "10100000";

sign2 <= '0';
 exp2 <= "1010";
frac2 <= "01100000";

    wait for 20ns;

assert fp_sum = "0101110000000"
report "Case1 : (+5)+(+3)=(+8) failed"
severity error;

--*************
--case2 fp number
--*************

--(+7) + (-3) = (+4)

sign1 <= '0';
 exp1 <= "1010";
frac1 <= "11100000";

sign2 <= '1';
 exp2 <= "1010";
frac2 <= "01100000";

    wait for 20ns;

assert fp_sum = "0101010000000"
report "Case2 : (+7)+(-3)=(+4) failed"
severity error;

--*************
--case3 fp number
--*************

--positive overflow
--(+240) + (+240)

sign1 <= '0';
 exp1 <= "1111";
frac1 <= "11110000";

sign2 <= '0';
 exp2 <= "1111";
frac2 <= "11110000";

    wait for 20ns;

assert fp_sum = "0111111111111"  --exp and frac both saturate
report "Case3 : positive overflow failed"
severity error;

--*************
--case4 fp number
--*************

--near cancellation case
--(+2) + (-1.98) = (0.02 ~ 0)

sign1 <= '0';
 exp1 <= "0001";
frac1 <= "10000000";

sign2 <= '1';
 exp2 <= "0001";
frac2 <= "01111111";

    wait for 20ns;

assert fp_sum = "0000000000000"
report "Case4 : near cancellation failed"
severity error;

--*************
--case5 fp number
--*************

--round up test

sign1 <= '0';
 exp1 <= "1010";
frac1 <= "10000000";

sign2 <= '0';
 exp2 <= "0110";
frac2 <= "10011000";

    wait for 20ns;

assert fp_sum = "0101010001010"
report "Case 5 GRS test failed"
severity error;

--*************
--case6 fp number
--*************

--cancellation case
--(+2) + (-2) = 0

sign1 <= '0';
 exp1 <= "0001";
frac1 <= "10000000";

sign2 <= '1';
 exp2 <= "0001";
frac2 <= "10000000";

    wait for 20ns;

assert fp_sum = "0000000000000"
report "Case 6 cancellation test failed"
severity error;

report "All FP adder test cases passed";

wait;

end process;

end arch;
