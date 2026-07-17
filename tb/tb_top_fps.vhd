
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top_fps is
--  Port ( );
end tb_top_fps;

architecture arch of tb_top_fps is

constant T : time := 20ns;

signal CLK100MHZ,btnl,btnr,btnu : std_logic;
signal                       SW : std_logic_vector(15 downto 0);
signal                      LED : std_logic_vector(15 downto 0);
signal                     sseg : std_logic_vector(7 downto 0);
signal                       AN : std_logic_vector(7 downto 0);

begin

top_unit : entity work.top_fps

port map (

      CLK100MHZ => CLK100MHZ,
           btnl => btnl,
           btnr => btnr,
           btnu => btnu,
             SW => SW,
            LED => LED,
           sseg => sseg,
             AN => AN

          );
          
--***************
--clock
--***************
--20ns clock running forever

 process 

  begin
    
   CLK100MHZ <= '0';
   wait for T/2;
   CLK100MHZ <= '1';
   wait for T/2;
   
  end process;
  
  process
  
   begin
   
--**********
--initial input
--**********           

btnl <= '0';              --m_next
btnr <= '0';              --push values into the stack
btnu <= '0';              --universal reset button
  SW <= (others => '0');
  
      wait until rising_edge(CLK100MHZ);
      wait until rising_edge(CLK100MHZ);

--***************
--testing reset
--***************

btnu <= '1';                               --reset

    wait until rising_edge(CLK100MHZ);
    wait until rising_edge(CLK100MHZ);

 assert LED = "0000000000000000"         --FSM goes back to load_stack
report "Error : reset button failed"
severity error;
    
    wait until rising_edge(CLK100MHZ);
    
btnu <= '0';

    wait until rising_edge(CLK100MHZ);
    wait until rising_edge(CLK100MHZ);
    
 --***************
--testing push button
--***************

           btnr <= '1';                    --we push the first value into the stack in state load_stack
SW(12 downto 0) <= "0101010100000";
 
 wait for 1 ns;
 wait until rising_edge(CLK100MHZ);
 
           btnr <= '0';

 wait until rising_edge(CLK100MHZ);
 wait until rising_edge(CLK100MHZ);
   
--***************
--testing m_next button
--*************** 
      
btnl <= '1';                               

    wait for 1 ns;
    wait until rising_edge(CLK100MHZ);     --we move on to add_pop_a, where first value is popped from the stack and stored in a_reg which will be displayed in the next state
         
btnl <= '0';
    
    wait until rising_edge(CLK100MHZ);     --at the rising edge, we change state again to add_disp_a
    wait for 1 ns;
    
  assert LED = "0000101010100000"          --a_reg displayed at the LEDs
  report "Error : LED output failed"
 severity error;    

 wait until rising_edge(CLK100MHZ);
 wait until rising_edge(CLK100MHZ);

--************
--terminate simulation
--************

  report "Simulation Completed, all cases passed";
  
  wait;
  
 end process;

end arch;
