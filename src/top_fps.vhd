
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_fps is

  Port ( 
  
        CLK100MHZ : in std_logic;
   btnl,btnr,btnu : in std_logic;                                        --m_next,mode,push
               SW : in std_logic_vector(15 downto 0);                    --mode,8 bit int input,13 bit input
              LED : out std_logic_vector(15 downto 0);                   --all results
             sseg : out std_logic_vector(7 downto 0);
               AN : out std_logic_vector(7 downto 0)
  
  );

end top_fps;

architecture arch of top_fps is

signal                 disp_sel : std_logic_vector(2 downto 0); 
signal    intcon_reg,intcon_res : std_logic_vector(12 downto 0);
signal        comp_out,stack_op : std_logic_vector(1 downto 0);
signal     reset_btn,empty,full : std_logic;
signal                pop_data1 : std_logic_vector(12 downto 0);
signal         a_en,b_en,sum_en : std_logic;
signal comp_en,con_en,intcon_en : std_logic;
signal      a_out,b_out,sum_out : std_logic_vector(12 downto 0);
signal                  con_out : std_logic_vector(7 downto 0);
signal  db_btnl,db_btnr,db_btnu : std_logic;
signal      hex3,hex2,hex1,hex0 : std_logic_vector(4 downto 0);
signal                 sign_out : std_logic;
signal                  exp_out : std_logic_vector(3 downto 0);
signal                 frac_out : std_logic_vector(7 downto 0);
signal                 LED_disp : std_logic_vector(15 downto 0);

begin

process (CLK100MHZ,reset_btn)

 begin
 
  if reset_btn = '1' then
  
       intcon_reg <= (others => '0');
  
  elsif (CLK100MHZ'event and CLK100MHZ = '1') then
  
     if intcon_en = '1' then
     
       intcon_reg <= intcon_res;
        
  end if;

 end if;
 
end process;
     
 -- stack instantiation
 
 stack_unit : entity work.Stack
 
  port map (
  
        clk => CLK100MHZ,
      reset => reset_btn,
   stack_op => stack_op,
  push_data => SW(12 downto 0),
  pop_data1 => pop_data1,
  pop_data2 => open,
      empty => empty,
       full => full
  
  );
  
 -- FSM intantiation
 
 fsm_unit : entity work.FSM_fps
 
 port map (
 
       clk => CLK100MHZ,
     reset => reset_btn,
    m_next => db_btnl,
      push => db_btnr,
  stack_op => stack_op,
  disp_sel => disp_sel,
      a_en => a_en,
      b_en => b_en,
    sum_en => sum_en,
   comp_en => comp_en,
    con_en => con_en,
 intcon_en => intcon_en
 
 );
 
 -- datapath instantiation
 
 data_unit : entity work.datapath_fps
 
 port map(
 
        clk => CLK100MHZ,
      reset => reset_btn,
       mode => SW(15),
  pop_data1 => pop_data1,
  
       a_en => a_en,
       b_en => b_en,
     sum_en => sum_en,
    comp_en => comp_en,
     con_en => con_en, 

      a_out => a_out,
      b_out => b_out, 
    sum_out => sum_out,
   comp_out => comp_out,
    con_out => con_out
    
    );
  
  --btnl m_next
  --btnu reset
  --btnr push
  
  
 -- debounce instantiation for btnl
 
  debounce_unit0 : entity work.debounce
  
  port map (
  
      clk => CLK100MHZ,
    reset => '0',
       sw => btnl,
 db_level => open,
  db_tick => db_btnl 
      
 );     
  
  -- debounce instantiation for btnr
 
  debounce_unit1 : entity work.debounce
  
  port map (
  
      clk => CLK100MHZ,
    reset => '0',
       sw => btnr,
 db_level => open,
  db_tick => db_btnr 
      
 );     
   
 -- debounce instantiation for btnu
 
debounce_unit2 : entity work.debounce
  
  port map (
  
      clk => CLK100MHZ,
    reset => '0',
       sw => btnu,
 db_level => reset_btn,
  db_tick => open 
      
 );     
    
    
-- disp_with_hex instantiation

disp_unit : entity work.disp_with_hex

port map (

       clk => CLK100MHZ,
     reset => reset_btn,
      hex3 => hex3,
      hex2 => hex2,
      hex1 => hex1,
      hex0 => hex0,
     dp_in => "1111",
        an => AN(7 downto 0),
      sseg => sseg
        
  );
  
  
  process(disp_sel,a_out,b_out,sum_out,comp_out,con_out)
  
   begin
   
        hex3 <= "11111";
        hex2 <= "11111";
        hex1 <= "11111";
        hex0 <= "11111";
    LED_disp <= (others => '0');  
        
    case disp_sel is
    
     when "001" => --display a_reg
     
               LED_disp <=  "000" & a_out(12 downto 0);
                   hex3 <= "0000" & a_out(12);
                   hex2 <= '0'    & a_out(11 downto 8);
                   hex1 <= '0'    & a_out(7 downto 4);
                   hex0 <= '0'    & a_out(3 downto 0);
                   
     when "010" => --display b_reg
     
               LED_disp <=  "000" & b_out(12 downto 0);     
                   hex3 <= "0000" & b_out(12);
                   hex2 <= '0'    & b_out(11 downto 8);
                   hex1 <= '0'    & b_out(7 downto 4);
                   hex0 <= '0'    & b_out(3 downto 0);
                   
     when "011" => --display sum_reg
     
               LED_disp <=  "000" & sum_out(12 downto 0);
                   hex3 <= "0000" & sum_out(12);
                   hex2 <= '0'    & sum_out(11 downto 8);
                   hex1 <= '0'    & sum_out(7 downto 4);   
                   hex0 <= '0'    & sum_out(3 downto 0);
                   
     when "100" => --display comp_res
     
                LED_disp <= "00000000000000" & comp_out;
     
                 if comp_out = "01" then --gt
       
                    hex3 <= "11111";
                    hex2 <= "11111";
                    hex1 <= "10000";
                    hex0 <= "10001";
                    
              elsif comp_out = "10" then --lt
              
                    hex3 <= "11111";
                    hex2 <= "11111";
                    hex1 <= "10010";
                    hex0 <= "10001";
                    
                end if;
  
     when "101" =>  --display con_res
     
                LED_disp <= "00000000" & con_out (7 downto 0);
                    hex3 <= "11111";
                    hex2 <= "11111";
                    hex1 <= '0'    & con_out(7 downto 4);
                    hex0 <= '0'    & con_out(3 downto 0);
                    
     when "110" =>  --display intcon_res
     
                LED_disp <=  "000" & intcon_reg(12 downto 0);     
                    hex3 <= "0000" & intcon_reg(12);
                    hex2 <= '0'    & intcon_reg(11 downto 8);
                    hex1 <= '0'    & intcon_reg(7 downto 4);
                    hex0 <= '0'    & intcon_reg(3 downto 0);
                    
     when others =>
     
                LED_disp <= (others => '0');
                    hex3 <= "11111";
                    hex2 <= "11111";
                    hex1 <= "11111";
                    hex0 <= "11111";
                    
       end case;             
                    
    end process;              

--int2fp instantiation

  int2fp_unit : entity work.fp_convert
  
   port map (
   
             int8 => SW(7 downto 0),
         sign_out => sign_out,
          exp_out => exp_out,
         frac_out => frac_out
         
        ); 
           
 intcon_res <= sign_out & exp_out & frac_out;          

LED <= LED_disp;

end arch;
