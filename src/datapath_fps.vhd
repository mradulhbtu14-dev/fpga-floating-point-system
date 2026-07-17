
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath_fps is

  Port (
  
   clk,reset : in std_logic;
        mode : in std_logic;
   pop_data1 : in std_logic_vector (12 downto 0);
    
        a_en : in std_logic; 
        b_en : in std_logic;
      sum_en : in std_logic;
     comp_en : in std_logic;
      con_en : in std_logic;
  
       a_out : out std_logic_vector(12 downto 0);
       b_out : out std_logic_vector(12 downto 0);
     sum_out : out std_logic_vector(12 downto 0);
    comp_out : out std_logic_vector(1 downto 0);
     con_out : out std_logic_vector(7 downto 0)

   );

end datapath_fps;

architecture arch of datapath_fps is

signal           a_reg,b_reg : std_logic_vector(12 downto 0);
signal       sum_res,sum_reg : std_logic_vector(12 downto 0);
signal               con_reg : std_logic_vector(7 downto 0);
signal     comp_res,comp_reg : std_logic_vector(1 downto 0);
signal               con_res : std_logic_vector(7 downto 0);

begin

--adder instantiation

 fp_adder_unit : entity work.fp_adder
 
  port map (
  
             sign1 => a_reg(12),
              exp1 => a_reg(11 downto 8),
             frac1 => a_reg(7 downto 0),
             
             sign2 => b_reg(12),
             exp2  => b_reg(11 downto 8),
             frac2 => b_reg(7 downto 0),

          sign_out => open,
          exp_out  => open,
          frac_out => open,

          fp_sum   => sum_res
    
);
 
 --comparator instantiation
 
 comp_unit : entity work.fp_greater(rtl)

port map (

    sign1 => a_reg(12),
    exp1  => a_reg(11 downto 8),
    frac1 => a_reg(7 downto 0),

    sign2 => b_reg(12),
    exp2  => b_reg(11 downto 8),
    frac2 => b_reg(7 downto 0),

    gt => open,
    lt => open,
    eq => open,

    comp_res => comp_res
    
);
 
 --fp2int converter instantiation

fp2int_unit : entity work.fp2int(arch)

port map (

    sign => a_reg(12),
    exp  => a_reg(11 downto 8),
    frac => a_reg(7 downto 0),
    mode => mode,              -- from switch or fixed value
    int8 => con_res
    
);

--datapath register

 process(clk,reset)
 
  begin 
 
    if (reset = '1') then
    
        a_reg <= (others => '0');
        b_reg <= (others => '0');
      sum_reg <= (others => '0');
     comp_reg <= (others => '0');
      con_reg <= (others => '0');

 elsif (clk'event and clk = '1') then 
     
      if a_en = '1' then
      
          a_reg <= pop_data1; 
  
     end if;
     
      if b_en = '1' then
      
          b_reg <= pop_data1;
          
      end if;
      
    if sum_en = '1' then
      
        sum_reg <= sum_res;
      
    end if;
    
   if comp_en = '1' then
    
       comp_reg <= comp_res;
        
     end if;   
  
    if con_en = '1' then
  
        con_reg <= con_res;
        
      end if;  
    
    end if;
    
   end process; 
    
     a_out <= a_reg;
     b_out <= b_reg;
   sum_out <= sum_reg;
  comp_out <= comp_reg; 
   con_out <= con_reg; 

end arch;
