
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_datapath is
--  Port ( );
end tb_datapath;

architecture arch of tb_datapath is

constant T : time := 20ns;

signal                  clk,reset,mode : std_logic;
signal                       pop_data1 : std_logic_vector(12 downto 0);
signal a_en,b_en,sum_en,comp_en,con_en : std_logic;
signal             a_out,b_out,sum_out : std_logic_vector(12 downto 0);
signal                        comp_out : std_logic_vector(1 downto 0);
signal                         con_out : std_logic_vector(7 downto 0);

begin

datapath_unit : entity work.datapath_fps

port map (

      clk => clk,
    reset => reset,
     mode => mode,
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
  
--***************
--clock
--***************
--20ns clock running forever

 process 

  begin
    
   clk <= '0';
   wait for T/2;
   clk <= '1';
   wait for T/2;
   
  end process;
  
  process
  
   begin
   
--**********
--initial input
--********** 

    reset <= '0';
     mode <= '0';                     --we start with signed mode
pop_data1 <= (others => '0');
     a_en <= '0';
     b_en <= '0';  
   sum_en <= '0';
  comp_en <= '0';
   con_en <= '0';
   
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    
--***************
--reset
--***************
   
 reset <= '1';
 
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    
 assert (a_out = "0000000000000" and b_out = "0000000000000" and sum_out = "0000000000000" and comp_out = "00" and con_out = "00000000")    
 report "Error : All register outputs should be zero"
 severity error;

reset <= '0';

    wait until rising_edge(clk);

--***************
--testing a_out and b_out
--***************

     a_en <= '1';
pop_data1 <= "0101010100000";        --(+5)

 wait until rising_edge(clk);
 
 wait for 1 ns;
 
assert a_out = "0101010100000"
report "Error : a_out test1 failed"
severity error;

 wait until rising_edge(clk);
 
 a_en <= '0';
 
     wait until rising_edge(clk);
     wait until rising_edge(clk);
 
 --==============================
 
      b_en <= '1';
pop_data1 <= "0101001100000";         --(+3)

 wait until rising_edge(clk);
 
 wait for 1 ns;
 
assert b_out = "0101001100000"
report "Error : b_out test failed"
severity error;

 wait until rising_edge(clk);
 
 b_en <= '0';

     wait until rising_edge(clk);
     wait until rising_edge(clk);

--***************
--testing sum_out,comp_out and con_out
--***************

  sum_en <= '1';

wait until rising_edge(clk);

wait for 1 ns;

assert sum_out = "0101110000000"     --(+8)
report "Error : sum_out test failed"
severity error;

wait until rising_edge(clk);

  sum_en <= '0';
  
     wait until rising_edge(clk);
     wait until rising_edge(clk);
  
--================================  
  
 comp_en <= '1';
 
wait until rising_edge(clk);  

wait for 1 ns;

assert comp_out = "01"                --(GT) a>b
report "Error : comp_out test failed"
severity error;

wait until rising_edge(clk); 

 comp_en <= '0';

     wait until rising_edge(clk);
     wait until rising_edge(clk);

--=============================

con_en <= '1';

wait until rising_edge(clk); 

wait for 1 ns;

assert con_out = "00000101"                --(+5) in signed int form
report "Error : con_out test failed"
severity error;

wait until rising_edge(clk); 

con_en <= '0';

     wait until rising_edge(clk);
     wait until rising_edge(clk);

--***************
--testing a_out and con_out with mode = 1
--***************

     a_en <= '1';
pop_data1 <= "0111111111010";              --(+250)

 wait until rising_edge(clk);
 
 wait for 1 ns;
 
assert a_out = "0111111111010"
report "Error : a_out test2 failed"
severity error;

 wait until rising_edge(clk);
 
 a_en <= '0';
 
     wait until rising_edge(clk);
     wait until rising_edge(clk);

--============================

  mode <= '1';                             --unsigned mode
con_en <= '1';

wait until rising_edge(clk); 

wait for 1 ns;

assert con_out = "11111010"                --(+250) in unsigned int form
report "Error : con_out unsigned test failed"
severity error;

wait until rising_edge(clk); 

con_en <= '0';

     wait until rising_edge(clk);
     wait until rising_edge(clk);

--************
--terminate simulation
--************

  report "Simulation Completed, all cases passed";
  
  wait;
  
 end process;

end arch;
