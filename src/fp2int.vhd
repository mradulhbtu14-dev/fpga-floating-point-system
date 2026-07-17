
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fp2int is
  Port ( 
  
  sign, mode : in std_logic;
         exp : in std_logic_vector (3 downto 0);
        frac : in std_logic_vector (7 downto 0);
        int8 : out std_logic_vector (7 downto 0)
  
  );
  
end fp2int;

architecture arch of fp2int is

begin

-- Inside process, we evaluate exp, normalize the fraction and then we cosider both signed and unsigned conversion while checking underflow and overflow conditions for signed mode

process (sign,exp,frac,mode)

variable          a_exp : signed (4 downto 0);
variable            mag : unsigned (7 downto 0);
variable          int_v : std_logic_vector (7 downto 0); 
variable G,R,S, roundup : std_logic;
variable           temp : unsigned (8 downto 0);

begin

a_exp := signed ('0'& exp) - to_signed (7,5);

case a_exp is 

       when "00001" =>
 
                      mag := "0000000" & unsigned(frac(7 downto 7));
                        G := frac(6);
                        R := frac(5);
                        S := frac(4) OR frac(3) OR frac(2) OR frac(1) OR frac(0);
                      
       when "00010" => 
       
                      mag := "000000"  & unsigned(frac(7 downto 6));
                        G := frac(5);
                        R := frac(4);
                        S := frac(3) OR frac(2) OR frac(1) OR frac(0);
                      
       when "00011" => 
        
                      mag := "00000"   & unsigned(frac(7 downto 5));
                        G := frac(4);
                        R := frac(3);
                        S := frac(2) OR frac(1) OR frac(0);
                      
       when "00100" => 
      
                      mag := "0000"    & unsigned(frac(7 downto 4));
                        G := frac(3);
                        R := frac(2);
                        S := frac(1) OR frac(0);
                      
       when "00101" => 
      
                      mag := "000"     & unsigned(frac(7 downto 3));
                        G := frac(2);
                        R := frac(1);
                        S := frac(0);
                      
       when "00110" => 
       
                      mag := "00"      & unsigned(frac(7 downto 2));
                        G := frac(1);
                        R := frac(0);
                        S := '0';
                      
       when "00111" => 
       
                      mag := "0"       & unsigned(frac(7 downto 1));
                        G := frac(0);
                        R := '0';
                        S := '0';
                      
       when "01000" =>
       
                      mag := unsigned (frac);
                        G := '0';   
                        R := '0';
                        S := '0';
                      
       when others => 
               
                      mag := (others => '0');
                        G := '0';   
                        R := '0';
                        S := '0'; 
 
  end case;
 
 --round up logic

roundup := G AND (R OR S OR mag(0));
 
 
     if roundup = '1' then  
      
        temp := unsigned("0" & mag) + to_unsigned(1,9);
        
    else   
        temp := unsigned("0" & mag);
        
    end if;

        mag := temp(7 downto 0);

--modes and overflow/underflow conditions

if sign = '0' then                     --we give the user the choice to whther convert the fp number to either signed or unsigned integer

  if mode = '0' and mag > 127 then     --we can convert to signed and unsigned both, we are choosing mode = '0' for signed mode and mode = '1' for unsigned mode
  
     int_v := "01111111";              --positive overflow for signed mode
     
  else 

     int_v := std_logic_vector (mag);  --unsigned mode
     
 end if;

else 

     if mag > 128 then
     
        int_v := "10000000";            --negative overflow for signed mode
        
     else 
     
        int_v := std_logic_vector (not(mag) + to_unsigned(1,8));
        
     end if;
     
    end if;
   
   int8 <= int_v;
   
  end process;

 end arch;

