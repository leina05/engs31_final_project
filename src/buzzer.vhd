----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2018 10:30:02 PM
-- Design Name: 
-- Module Name: buzzer - Behavioral
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity buzzer is port(
	clk			:	in STD_LOGIC;	-- 10 MHz clk
	buzzer_en	:	in STD_LOGIC; 
    counter_step	:	in STD_LOGIC_VECTOR(6 downto 0); 
    
    LUT_addr    :   out STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
    start		:   out STD_LOGIC); 
end buzzer; 

architecture behavior of buzzer is

signal counter_step_s : integer; 
signal start_counter : unsigned(7 downto 0) := (others => '0'); 	-- produces start signal every 40 kHz
signal frequency_counter : unsigned(11 downto 0) := (others => '0'); 	-- determines frequency of tone
signal start_s : STD_LOGIC := '0';

begin

--da_data <= data; 
start <= start_s;
LUT_addr(11 downto 0) <= std_logic_vector(frequency_counter);
counter_step_s <= to_integer(unsigned(counter_step));

process(clk) 
begin
	if rising_edge(clk) then 
    	start_counter <= (others => '0');
    	if buzzer_en = '1' then 
        	-- counter to generate start signal at 40 kHz
        	start_s <= '0';
        	start_counter <= start_counter+1; 
            if start_counter = "11111010" then 
            	start_s <= '1'; 
                start_counter <= (others => '0'); 
            end if; 
            
            if start_s = '1' then 
            	frequency_counter <= frequency_counter + counter_step_s;
            end if; 
        else
        	frequency_counter <= (others => '0');
		end if; 
    end if; 
end process; 

end behavior;
                	
            
            
            