
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_stack is
--  Port ( );
end tb_stack;

architecture arch of tb_stack is

constant T : time := 20ns;

signal   clk,reset : std_logic;
signal    stack_op : std_logic_vector(1 downto 0);
signal   push_data : std_logic_vector(12 downto 0);
signal   pop_data1 : std_logic_vector (12 downto 0);
signal   pop_data2 : std_logic_vector (12 downto 0);
signal empty, full : std_logic;

begin

--****************
--instantiation
--***************

stack_unit : entity work.stack(arch)

port map(

         clk => clk,
       reset => reset,
    stack_op => stack_op,
   push_data => push_data,
   pop_data1 => pop_data1,
   pop_data2 => pop_data2,
       empty => empty,
        full => full
        
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
 stack_op <= (others => '1');     --do nothing
push_data <= (others => '0');

    wait until rising_edge(clk);
    wait until rising_edge(clk);

--***************
--reset
--***************
   
 reset <= '1';
 
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    
   assert (empty = '1')
   report "Error : Stack should be empty after reset"
   severity error;
    
reset <= '0';

    wait until rising_edge(clk);

--*************
--test push
--*************

stack_op <= "00";                     --we push first 13 bit fp number
push_data <= "0101010100000";

    wait until rising_edge(clk);

stack_op <= "11";

--*************
--pause 2 clocks
--*************

    wait until rising_edge(clk);
    wait until rising_edge(clk);

--*************
--test pop
--*************

stack_op <= "10";                     --we pop first value

wait for 1 ns;

assert pop_data1 = "0101010100000"
report "Error : single pushed value should be on top"
severity error;

wait until rising_edge(clk);

stack_op <= "11";

wait for 1 ns;

assert empty = '1'
report "Error : Stack should be empty after single pop"
severity error;

--*************
--test pushing 4 entries
--*************

 stack_op <= "00";                    --push first value
push_data <= "0101010100000";

 wait until rising_edge(clk);

stack_op <= "11";

    wait until rising_edge(clk);
    wait until rising_edge(clk);

 stack_op <= "00";                    --push second value
push_data <= "0101001100000";

 wait until rising_edge(clk);

stack_op <= "11";

    wait until rising_edge(clk);
    wait until rising_edge(clk);

 stack_op <= "00";                    --push third value
push_data <= "0101011100000";

    wait until rising_edge(clk);

stack_op <= "11";

    wait until rising_edge(clk);
    wait until rising_edge(clk);

 stack_op <= "00";                    --push fourth value
push_data <= "0101010000000";

 wait until rising_edge(clk);

stack_op <= "11";

    wait until rising_edge(clk);
    wait until rising_edge(clk);

   assert (full = '1')
   report "Error: Stack should be full"
   severity error;

--*************
--test pop 
--*************

stack_op <= "10";                               --we start popping

wait for 1 ns;

assert pop_data1 = "0101010000000"              -- we pop the topmost(fourth) value
report "Error : fourth value should pop first"
severity error;

wait until rising_edge(clk);                    --we wait for a rising edge so that the pointer moves to the next register revealing the next value

wait for 1 ns;

assert pop_data1 = "0101011100000"
report "Error : third value should pop second"
severity error;

wait until rising_edge(clk);

wait for 1 ns;

assert pop_data1 = "0101001100000"
report "Error : second value should pop third"
severity error;

wait until rising_edge(clk);

wait for 1 ns;

assert pop_data1 = "0101010100000"
report "Error : first value should pop last"
severity error;

wait until rising_edge(clk);

stack_op <= "11";                          --we stop popping

wait for 1 ns;

assert empty = '1'                         --stack is now empty (nothing to read anymore)
report "Error : Stack should be empty"
severity error;

--************
--terminate simulation
--************

  report "Simulation Completed, all cases passed";
  
  wait;
  
 end process;
 
end arch;
