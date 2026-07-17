library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Stack is

generic (

          B : natural := 13;           --2^W by B registers, 16 registers each 13 bit wide in our case
          W : natural := 5             --32 stack for our fsm demonstration, we'll be using 30 values
          
        ); 

  Port (
  
         clk, reset : in std_logic;
           stack_op : in std_logic_vector (1 downto 0);
          push_data : in std_logic_vector (B-1 downto 0);
        empty, full : out std_logic;
          pop_data1 : out std_logic_vector (B-1 downto 0);
          pop_data2 : out std_logic_vector (B-1 downto 0)
             
   );
  
end Stack;

architecture arch of Stack is

type reg_file_type is array (2**W - 1 downto 0) of std_logic_vector (B-1 downto 0);

signal                                                   array_reg : reg_file_type;
signal s_ptr_reg, s_ptr_next, s_ptr_succ, s_ptr_prev1, s_ptr_prev2 : std_logic_vector (W downto 0);
signal                  full_reg, empty_reg, full_next, empty_next : std_logic;
signal                                                     push_en : std_logic;

begin

--=============================
--register file
--=============================
                      
      process (clk, reset)
      
      begin
      
           if (reset = '1') then
           
              array_reg <= (others => (others => '0'));
              
           elsif (clk'event and clk = '1') then
           
             if push_en = '1' then
           
              array_reg (to_integer (unsigned (s_ptr_reg(W-1 downto 0)))) <= push_data;
                              
           end if;
           
          end if;
          
         end process; 
         
  
-- write enabled only when stack is not full
      
    push_en <= '1' when (stack_op = "00" and full_reg = '0') else '0';   
      
--================================
--stack control logic
--================================
                      
--register for stack pointer
                      
       process (clk, reset)
       
       begin
       
        if (reset = '1') then
        
           s_ptr_reg <= (others => '0');   
            full_reg <= '0';
           empty_reg <= '1';
           
     elsif (clk'event and clk = '1') then
     
           s_ptr_reg <= s_ptr_next;          -- at the clock edge, the pointer makes a decision, either stay, increment or decrement by 1, only two choices
            full_reg <= full_next;
           empty_reg <= empty_next;
           
         end if;
         
        end process;
        
                     --successive pointer values
                     
                     s_ptr_succ <= std_logic_vector (unsigned (s_ptr_reg) + 1);       
                    s_ptr_prev1 <= std_logic_vector (unsigned (s_ptr_reg) - 1);  --first pop, top value       
                    s_ptr_prev2 <= std_logic_vector (unsigned (s_ptr_reg) - 2);  --second pop, second values from the top
                    
                     
   process (s_ptr_reg, s_ptr_succ, s_ptr_prev1, s_ptr_prev2, stack_op, empty_reg, full_reg)
   
   begin
   
               s_ptr_next <= s_ptr_reg;                                   -- pointer stays
                full_next <= full_reg;
               empty_next <= empty_reg;                   
                     
         case stack_op is
         
         --stack_op <= "00"; --push all values
         --stack_op <= "01"; --pop2
         --stack_op <= "10"; --pop1
         --stack_op <= "11"; --nothing
                      
                      --our fsm decides whether it wants one or more pops, it depends on the state, like adder needs two pops whereas converter only needs one
                      
                       when "00" => --push all values
                       
                                   if (full_reg /= '1') then
                                   
                                      s_ptr_next <= s_ptr_succ;
                                      empty_next <= '0';
                                      
                                   if (unsigned(s_ptr_succ) = 2**W) then     --
                                   
                                      full_next <= '1';
                                      
                                end if;
                                
                              end if; 
                       
                       when "01" => --pop2
                                            
                                        if unsigned(s_ptr_reg) >= 2 then

                                                    s_ptr_next <= s_ptr_prev2;
                                                    full_next  <= '0';

                                        if unsigned(s_ptr_reg) = 2 then
            
                                                    empty_next <= '1';
         
                                         end if;

                                       end if;         
                                            
                      when "10" => --pop1
                      
                                      if unsigned(s_ptr_reg) >= 1 then
                                      
                                         s_ptr_next <= s_ptr_prev1;
                                          full_next <= '0';
                               
                                      if unsigned(s_ptr_reg) = 1 then
                                          
                                          empty_next <= '1';
                                   
                                      end if;

                                     end if; 
                                            

             
                       when "11" => -- no operation
                       
                                   null;
                                   
                     when others =>
                                   
                                   null;
                                   
                    end case;
                    
                   end process;
          
 -- read port 
                                                                                     --s_ptr_prev needs to be converted into integer form so that we can pop data from a memory location like array_reg(0), array_reg(1) and so on. <s_ptr_prev here is next memory loaction that will be popped (Last-in-first-out)>
    pop_data1 <= array_reg (to_integer (unsigned (s_ptr_prev1(W-1 downto 0))));      
    pop_data2 <= array_reg (to_integer (unsigned (s_ptr_prev2(W-1 downto 0)))); 
          
    full  <= full_reg;
    empty <= empty_reg;
                   
 end arch;   
