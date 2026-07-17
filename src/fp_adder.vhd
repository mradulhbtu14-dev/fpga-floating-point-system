
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity fp_adder is

  Port ( 
  
  sign1, sign2 : in std_logic;
    exp1, exp2 : in std_logic_vector(3 downto 0);
  frac1, frac2 : in std_logic_vector(7 downto 0);
      sign_out : out std_logic;
       exp_out : out std_logic_vector(3 downto 0);
      frac_out : out std_logic_vector(7 downto 0);
        fp_sum : out std_logic_vector(12 downto 0) 
  
  );
  
end fp_adder;

architecture arch of fp_adder is                                           --13 bit format --> 0 0101 10110000  (1-bit sign 4-bit exponent 8-bit significand)

-- suffix b,s,a,n for
-- big, small, aligned, normalized number

signal                       signb, signs : std_logic;
signal             expb, exps, expn, expr : unsigned(3 downto 0);
signal  fracb, fracs, fraca, fracn, fracr : unsigned(7 downto 0);
signal                           sum_norm : unsigned(10 downto 0);
signal                           exp_diff : unsigned(3 downto 0);
signal                                sum : unsigned(11 downto 0);          --one extra for carry
signal                              lead0 : unsigned(3 downto 0);
signal G,R,S,G_norm,R_norm,S_norm,roundup : std_logic;                       --extra bits for precision, guard, round and sticky bits according to the IEEE 754 standard and also roundup logic 
signal             zero_result,final_sign : std_logic;

begin

-- 1st stage : sort to find the larger number

process (sign1, sign2, exp1, exp2, frac1, frac2)

begin

if (exp1 & frac1) > (exp2 & frac2) then

   signb <= sign1;                                                          --the number which has the bigger exponent and significand is the bigger number
   signs <= sign2;
   expb <= unsigned (exp1);
   exps <= unsigned (exp2);
  fracb <= unsigned (frac1);
  fracs <= unsigned (frac2);
  
else

  signb <= sign2;
  signs <= sign1;
   expb <= unsigned (exp2);
   exps <= unsigned (exp1);
  fracb <= unsigned (frac2);
  fracs <= unsigned (frac1);
  
  end if;
end process;

-- 2nd stage : align smaller number

exp_diff <= expb - exps;

with exp_diff select

fraca <= 

  fracs                                   when "0000",                      --to align the smaller number with the bigger number, we shift the significand to the right according to the exponent difference
  "0"          & fracs (7 downto 1)       when "0001",
  "00"         & fracs (7 downto 2)       when "0010",
  "000"        & fracs (7 downto 3)       when "0011",
  "0000"       & fracs (7 downto 4)       when "0100",
  "00000"      & fracs (7 downto 5)       when "0101",
  "000000"     & fracs (7 downto 6)       when "0110",
  "0000000"    & fracs (7)                when "0111",
  "00000000"                              when others;
  
  
process(exp_diff, fracs)                                                  --accounting for the shifted out GRS bits

 begin
 
  case exp_diff is
  
              when "0000" =>
              
                   G <= '0';   
                   R <= '0';
                   S <= '0';
                   
              when "0001" =>
              
                   G <= fracs (0);
                   R <= '0';
                   S <= '0';
  
              when "0010" =>
              
                   G <= fracs(1);
                   R <= fracs(0);
                   S <= '0';
                   
              when "0011" =>
              
                   G <= fracs(2);
                   R <= fracs(1);
                   S <= fracs(0);
  
              when "0100" =>
  
                   G <= fracs(3);
                   R <= fracs(2);
                   S <= fracs(1) OR fracs(0);
  
              when "0101" =>
              
                   G <= fracs(4);
                   R <= fracs(3);
                   S <= fracs(2) OR fracs(1) OR fracs(0);
                   
              when "0110" =>
              
                   G <= fracs(5);
                   R <= fracs(4);
                   S <= fracs(3) OR fracs(2) OR fracs(1) OR fracs(0);
                   
              when "0111" =>
                  
                   G <= fracs(6);
                   R <= fracs(5);
                   S <= fracs(4) OR fracs(3) OR fracs(2) OR fracs(1) OR fracs(0);
                   
              when others =>
              
                   G <= fracs(7);
                   R <= fracs(6);
                   S <= fracs(5) OR fracs(4) OR fracs(3) OR fracs(2) OR fracs(1) OR fracs(0);
  
       end case;
       
      end process;

-- 3rd stage : add/subtract

sum <= ('0' & fracb & "000") + ('0' & fraca & G & R & S) when signb=signs else                 --now this is a 12 bit addition (1 zero at the beginning for carry, 8 bit fraction and 3 bit GRS)
       ('0' & fracb & "000") - ('0' & fraca & G & R & S);                          

-- 4th stage : normalize
-- count leading 0s

lead0 <= "0000" when (sum (10) = '1') else   
         "0001" when (sum (9) = '1')  else   
         "0010" when (sum (8) = '1')  else   
         "0011" when (sum (7) = '1')  else   
         "0100" when (sum (6) = '1')  else   
         "0101" when (sum (5) = '1')  else   
         "0110" when (sum (4) = '1')  else                          
         "0111" when (sum (3) = '1')  else
         "1000" when (sum (2) = '1')  else
         "1001" when (sum (1) = '1')  else
         "1111";
         
         
 -- shift significand according to leading 0
 
 with lead0 select 

sum_norm <= 

  sum(10 downto 0)                       when "0000",  
  sum(9 downto 0) & "0"                  when "0001",  
  sum(8 downto 0) & "00"                 when "0010",  
  sum(7 downto 0) & "000"                when "0011",  
  sum(6 downto 0) & "0000"               when "0100",  
  sum(5 downto 0) & "00000"              when "0101",  
  sum(4 downto 0) & "000000"             when "0110",  
  sum(3 downto 0) & "0000000"            when "0111",
  sum(2 downto 0) & "00000000"           when "1000",
  sum(1 downto 0) & "000000000"          when "1001",
  sum(0)          & "0000000000"         when others;
  
  
--normalize with special conditions

process(sum, sum_norm, expb, lead0)

begin

  if sum(11) = '1' then                      --sum(11) is the 12th bit for our sum which is 12 bit now including the 3 bit GRS and the extra carry MSB, if high means we have a carry
    
    if expb = "1111" then

        expn   <= "1111";                    
        fracn  <= (others => '1');
        G_norm <= '0';
        R_norm <= '0';
        S_norm <= '0';

    else

        expn   <= expb + 1;                  --the carry is transferred to the exp unless it is already overflowing
        fracn  <= sum(11 downto 4);          --we ignore the lsb
        G_norm <= sum(3);                    --these GRS bits are different from the earlier GRS bits because addition and subtraction will change them
        R_norm <= sum(2);
        S_norm <= sum(1) OR sum(0);

    
    end if;
  elsif (lead0 > expb) then                 --if the no. of leading zeros are more than the exponent of the bigger number, then the number is smaller than the smallest standard normalized number, so it must be converted to zero.

      expn <= (others => '0');
     fracn <= (others => '0');
    G_norm <= '0';
    R_norm <= '0';
    S_norm <= '0';
         
  else
  
      expn <= expb - lead0;
     fracn <= sum_norm(10 downto 3);
    G_norm <= sum_norm(2);
    R_norm <= sum_norm(1);
    S_norm <= sum_norm(0);
     
  end if;
  
end process;

--round up logic

roundup <= G_norm AND (R_norm OR S_norm OR fracn(0));

process(fracn, expn, roundup)

    variable temp : unsigned(8 downto 0);
    
begin

    if roundup = '1' then  
      
        temp := ('0' & fracn) + 1;
        
    else   
        temp := ('0' & fracn);
        
    end if;

  if temp(8) = '1' then          --rounding caused carry: 11111111 + 1 = 1_00000000
    
    if expn = "1111" then
    
        expr  <= "1111";
        fracr <= (others => '1');  --if after rounding up, the exp saturates, then the fraction saturates as well
        
    else
    
        expr  <= expn + 1;
        fracr <= temp(8 downto 1);
        
    end if;
        
  else
     
            expr  <= expn;
            fracr <= temp(7 downto 0);
        
    end if;
    
end process;

-- form output

zero_result <= '1' when (expr = "0000" and fracr = "00000000") else '0';

final_sign <= '0' when zero_result = '1' else signb;

sign_out <= final_sign;
exp_out  <= std_logic_vector(expr);
frac_out <= std_logic_vector(fracr);

fp_sum <= final_sign & std_logic_vector(expr) & std_logic_vector(fracr);

end arch;
