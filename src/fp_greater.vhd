
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fp_greater is

  Port ( 
  
sign1, sign2 : in std_logic;
  exp1, exp2 : in std_logic_vector (3 downto 0);
frac1, frac2 : in std_logic_vector (7 downto 0);
    gt,lt,eq : out std_logic;
    comp_res : out std_logic_vector (1 downto 0)
  
  );
end fp_greater;

architecture rtl of fp_greater is

signal mag1, mag2 : unsigned (11 downto 0);  --exp(4) and frac(8)

begin

-- combine exponent and fraction (magnitude)

mag1 <= unsigned(exp1 & frac1);
mag2 <= unsigned(exp2 & frac2);

process (sign1, sign2, mag1, mag2)

begin

gt <= '0';
lt <= '0';
eq <= '0';

-- case 1 : both signs and magnitudes are equal

if (sign1 = sign2) and  (mag1 = mag2) then

eq <= '1';
comp_res <= "00";

-- case 2 : different signs

elsif (sign1 = '0') and (sign2 = '1') then

      gt <= '1';
comp_res <= "01";

elsif (sign1 = '1') and (sign2 = '0') then

      lt <= '1';
comp_res <= "10";

-- case 3 : both positive

elsif (sign1 = '0') and (sign2 = '0') then

  if (mag1 > mag2) then

       gt <= '1';
 comp_res <= "01";
     
  else
  
      lt <= '1';
comp_res <= "10";
     
  end if;
  
-- case 4 : both negative

elsif (sign1 = '1') and (sign2 = '1') then

  if (mag1 > mag2) then
  
      lt <= '1';
comp_res <= "10";
     
  else
  
      gt <= '1';
comp_res <= "01";
     
   end if;
  
  end if;
 
 end process;

end rtl;
