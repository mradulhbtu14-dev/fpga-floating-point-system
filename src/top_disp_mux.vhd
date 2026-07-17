
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_with_hex is

  Port ( 
  
              clk, reset : in std_logic;
  hex3, hex2, hex1, hex0 : in std_logic_vector (4 downto 0);
                   dp_in : in std_logic_vector (3 downto 0);
                      an : out std_logic_vector (7 downto 0);
                    sseg : out std_logic_vector (7 downto 0)
  
  );
end disp_with_hex;

architecture arch of disp_with_hex is

constant N : integer := 18;

signal q_reg, q_next : unsigned (N-1 downto 0);
signal           sel : std_logic_vector (1 downto 0);
signal           hex : std_logic_vector (4 downto 0);
signal            dp : std_logic;

begin

process (clk, reset)

begin

 if reset = '1' then
   
    q_reg <= (others => '0');
    
 elsif (clk'event and clk = '1') then
 
    q_reg <= q_next;
    
 end if;
 
end process;

-- next state logic for the counter

q_next <= q_reg + 1;

-- 2 MSBs of counter to control 4-to-1 multiplexer

sel <= std_logic_vector (q_reg (N-1 downto N-2));

process (sel, hex0, hex1, hex2, hex3, dp_in)

begin

    an  <= "11111111";
    hex <= "11111";
    dp  <= '1';

 case sel is
 
  when "00" =>
  
   an <= "11111110";
  hex <= hex0;
   dp <= dp_in(0);
   
  when "01" =>
  
   an <= "11111101";
  hex <= hex1;
   dp <= dp_in(1);
   
  when "10" =>
  
   an <= "11111011";
  hex <= hex2;
   dp <= dp_in(2);
   
  when "11" =>
  
   an <= "11110111";
  hex <= hex3;
   dp <= dp_in(3);
   
  when others =>
  
  null; 
   
  end case;
  
 end process;
 
 -- hex-to-7 segment led decoding
 
 with hex select
 
  sseg (6 downto 0) <= 
  
     "1000000" when "00000",   --0
     "1111001" when "00001",   --1
     "0100100" when "00010",   --2
     "0110000" when "00011",   --3
     "0011001" when "00100",   --4
     "0010010" when "00101",   --5
     "0000010" when "00110",   --6
     "1111000" when "00111",   --7
     "0000000" when "01000",   --8
     "0010000" when "01001",   --9
     "0001000" when "01010",   --a
     "0000011" when "01011",   --b
     "1000110" when "01100",   --c
     "0100001" when "01101",   --d
     "0000110" when "01110",   --e
     "0001110" when "01111",   --f
     "0000010" when "10000",   --g
     "0000111" when "10001",   --t
     "1000111" when "10010",   --L
     "1111111" when others;    --blank
     
    
   sseg(7) <= dp;


end arch;
