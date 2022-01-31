----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2018 06:49:27 PM
-- Design Name: 
-- Module Name: won_lost_module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity won_lost_module is port(
	clk 	: 	in STD_LOGIC; 
	won_en	:	in STD_LOGIC;
    lost_en	:	in STD_LOGIC; 
    
    sequence_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0000";
    won_done		:	out STD_LOGIC := '0';
    lost_done		:	out STD_LOGIC := '0'); 
end won_lost_module; 

architecture behavior of won_lost_module is 

signal delay_counter, final_note_counter : integer := 0; 
signal won_counter, lost_counter, sequence_count : unsigned(1 downto 0) := "00"; 
signal ready : STD_LOGIC := '0';

begin 

process(clk)
begin
	if rising_edge(clk) then 
    	delay_counter <= 0;
        won_done <= '0'; 
        lost_done <= '0';
        
        if (won_en = '1' OR lost_en = '1') AND ready = '0' then 
            delay_counter <= delay_counter + 1; 
            if delay_counter = 2499999 then 
                ready <= '1'; 
                delay_counter <= 0; 
            end if; 
        end if; 
        
        won_counter <= "00";
    	if won_en = '1' AND ready = '1' then 
        	won_counter <= won_counter;
        	sequence_count <= won_counter; 
        	delay_counter <= delay_counter+1; 
            if delay_counter = 1249999 then 
            	delay_counter <= 0; 
                won_counter <= won_counter+1; 	-- increment sequence every .125 seconds 
                if won_counter = "11" then 
                    won_counter <= won_counter; 
                    delay_counter <= delay_counter; 
                    final_note_counter <= final_note_counter+1;
                    if final_note_counter = 1249999 then    -- hold final note twice as long
                        won_done <= '1'; 
                        won_counter <= won_counter; 
                        delay_counter <= 0; 
                        final_note_counter <= 0;
                        ready <= '0';
                    end if;
                end if; 
            end if; 
        end if; 
        
        lost_counter <= "11";
       	if lost_en = '1' AND ready = '1' then 
        	lost_counter <= lost_counter; 
        	sequence_count <= lost_counter;
        	delay_counter <= delay_counter+1; 
            if delay_counter = 1249999 then 
            	delay_counter <= 0; 
                lost_counter <= lost_counter-1; 	-- decrement sequence every .125 seconds 
                if lost_counter = "00" then 
                	lost_done <= '1'; 
                    lost_counter <= lost_counter; 
                    ready <= '0'; 
                end if; 
            end if; 
        end if; 
    end if; 
end process; 

process(sequence_count, ready) 
begin 
  	case sequence_count is 
  		when "00" => sequence_out <= "0001"; 
  		    if ready = '0' then 
  		        sequence_out <= "0000";
  		    end if; 
  		when "01" => sequence_out <= "0010"; 
 		when "10" => sequence_out <= "0100"; 
    	when "11" => sequence_out <= "1000"; 
    	   if ready = '0' then 
    	       sequence_out <= "0000"; 
    	   end if; 
    	when others => sequence_out <= "0000"; 
    end case; 
end process; 
              
end behavior; 
