
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_fps is

  Port ( 
  
         clk, reset : in std_logic;
        m_next,push : in std_logic;
           stack_op : out std_logic_vector(1 downto 0);
           disp_sel : out std_logic_vector(2 downto 0);

            a_en,b_en : out std_logic;
sum_en,comp_en,con_en : out std_logic;
            intcon_en : out std_logic

  );
  
end FSM_fps;

architecture arch of FSM_fps is

type state_type is (
                                   --we fill up the stack 
                     load_stack,
                                    --adder substates
                     add_pop_a,                    
                     add_disp_a,                    
                     add_disp_b,                    
                     add_disp_res,
                                    --comparator substates
                     comp_pop_a,
                     comp_disp_a,
                     comp_disp_b,
                     comp_disp_res,
                                    --fp2int converter substates
                     fpcon_pop_a,
                     fpcon_disp_a,
                     fpcon_disp_res,
                                    --int2fp converter substates
                     intcon_cap,
                     intcon_disp
   
                     );

signal state_reg,state_next : state_type;
signal            case_next : unsigned(2 downto 0);   --we need a case counter because we can only demonstrate one operation for each of our component in one go
signal             case_reg : unsigned(2 downto 0);   
       

begin

-- state register

process(clk, reset)

begin

    if reset = '1' then
    
        state_reg <= load_stack;
         case_reg <= (others => '0');

    elsif (clk'event and clk = '1') then
    
        state_reg <= state_next;
         case_reg <= case_next;
        
    end if;
    
end process;

--next state output logic

process (state_reg,m_next,push,case_reg)

begin

  state_next <= state_reg;
   case_next <= case_reg;   
    disp_sel <= "000";      --display nothing
    stack_op <= "11";       --stack does nothing     
        a_en <= '0';
        b_en <= '0';
      sum_en <= '0';
     comp_en <= '0';
      con_en <= '0';
   intcon_en <= '0';
     
case state_reg is

when load_stack =>
 
                   if push = '1' then
                   
                      stack_op <= "00";             --push, the fsm tells the stack to start push mode where we push all 16 vlaues in the stack

                   end if;
                 
                   if m_next = '1' then
                   
                      state_next <= add_pop_a;
                       case_next <= (others => '0'); --before we start popping we need to make sure that we start from case 0
                      
                  else 
                  
                      state_next <= load_stack;

                   end if;

when add_pop_a =>

                                                      --pop a and load into a_reg
                    a_en <= '1';
                  stack_op <= "10";
             
                state_next <= add_disp_a;             --we do not wait for m_next to move on to the next state, add_pop_a should only be one clock cycle state where we pop and store a in one clock cycle and move on, otherwise it might pop again in the next clock cycle

             
when add_disp_a =>

                   disp_sel <= "001";                 --display a_reg
                   
                 if m_next = '1' then
                 
                     b_en <= '1';
                   stack_op <= "10";

                 state_next <= add_disp_b;

                end if;

when add_disp_b =>

                   disp_sel <= "010";                 --display b_reg

                  if m_next = '1' then
                  
                     sum_en <= '1';
                      
                   state_next <= add_disp_res;
                   
                 end if;
                 
when add_disp_res =>

                   disp_sel <= "011";                 --display adder result
                   
                   if m_next = '1' then
                   
                     state_next <= comp_pop_a;

                 end if;

when comp_pop_a =>

                                                      --pop a and load into a_reg
               a_en <= '1';
             stack_op <= "10";
                
           state_next <= comp_disp_a;
           
when comp_disp_a =>
 
                    disp_sel <= "001";                --display a_reg
                   
                 if m_next = '1' then
                 
                     b_en <= '1';
                   stack_op <= "10";

                 state_next <= comp_disp_b;

                end if;

when comp_disp_b =>

                     disp_sel <= "010";               --display b_reg

                  if m_next = '1' then
                  
                     comp_en <= '1';
                      
                   state_next <= comp_disp_res;
                   
                 end if;

when comp_disp_res =>

                     disp_sel <= "100";               --display comp result
                     
                   if m_next = '1' then
                   
                   state_next <= fpcon_pop_a;
                      
                  end if;  
                      
when fpcon_pop_a =>
                                                      --pop a and load into a_reg
                     a_en <= '1';
                   stack_op <= "10";
                
                 state_next <= fpcon_disp_a;

when fpcon_disp_a => 

                     disp_sel <= "001";               --display a_reg
                     
                   if m_next = '1' then
                  
                     con_en <= '1';
                      
                   state_next <= fpcon_disp_res;
                   
                 end if;

when fpcon_disp_res =>

                     disp_sel <= "101";
                     
                  if m_next = '1' then
                  
                   state_next <= intcon_cap;
                    
                end if;    
                    
when intcon_cap =>               

                     intcon_en <= '1';
                  
                      state_next <= intcon_disp;

when intcon_disp =>

                   disp_sel <= "110";
                   
                 if m_next = '1' then

                   if case_reg < 5 then
                   
                  case_next <= case_reg + 1;        --when we are done with one case set, we go back to add_pop_a and counter increases until 5 (we use 6 cases (0-5) for our demo demonstration) and then we go back to loading the stack again

                 state_next <= add_pop_a;

                  else 
                  
                 state_next <= load_stack;

                 end if;

                end if;

when others =>

                 state_next <= load_stack;


    end case;
              
  end process;

end arch;
