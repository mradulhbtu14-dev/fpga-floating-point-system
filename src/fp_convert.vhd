
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fp_convert is

  Port ( 
  
      int8 : in std_logic_vector (7 downto 0);
  sign_out : out std_logic;
   exp_out : out std_logic_vector (3 downto 0);
  frac_out : out std_logic_vector (7 downto 0)
        
  );
  
end fp_convert;

architecture arch of fp_convert is

signal              sign : std_logic;
signal         exp,a_exp : std_logic_vector (3 downto 0);
signal              frac : std_logic_vector (7 downto 0); 
signal             lead0 : std_logic_vector (2 downto 0);
signal               mag : std_logic_vector (7 downto 0);

begin

-- Step 1 : sign extraction for fp

 process (int8)
 
  begin

   if (int8(7) = '1') then 
   
    sign <= '1';
    
   else
   
   sign <= '0';
    
  end if;
  
 end process;

--2's complement for negative input

mag <= std_logic_vector (unsigned (not int8) + 1)
        
       when int8(7) = '1' else int8;
            
-- Step 2 :  find exponent 

a_exp <= "1000" when (mag(7) = '1') else  --going for format (0.1xxxx * 2^e)
         "0111" when (mag(6) = '1') else
         "0110" when (mag(5) = '1') else
         "0101" when (mag(4) = '1') else
         "0100" when (mag(3) = '1') else
         "0011" when (mag(2) = '1') else
         "0010" when (mag(1) = '1') else
         "0001" when (mag(0) = '1') else
         "0000";


exp <= std_logic_vector (unsigned(a_exp) + to_unsigned(7,4)); --to adjust for bias we add 7

--Step 3 : normalize the significand

--counting leading zeros

lead0 <= "000" when (mag(7) = '1') else
         "001" when (mag(6) = '1') else
         "010" when (mag(5) = '1') else
         "011" when (mag(4) = '1') else
         "100" when (mag(3) = '1') else
         "101" when (mag(2) = '1') else
         "110" when (mag(1) = '1') else
         "111";
         
-- shift significand according to leading 0

with lead0 select 

  frac <= mag(7 downto 0)                when "000",
          mag(6 downto 0) & '0'          when "001",
          mag(5 downto 0) & "00"         when "010",
          mag(4 downto 0) & "000"        when "011",
          mag(3 downto 0) & "0000"       when "100",
          mag(2 downto 0) & "00000"      when "101",
          mag(1 downto 0) & "000000"     when "110",
          mag(0)          & "0000000"    when others;
          
 -- form output
 
 sign_out <= sign;
  exp_out <= exp;
 frac_out <= frac;
 
 end arch;
