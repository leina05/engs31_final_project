----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2018 05:30:23 PM
-- Design Name: 
-- Module Name: input_module - Behavioral
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
use IEEE.numeric_std.all;


entity input_module is port(
	clk, input_en	:	in STD_LOGIC; 
    B0, B1, B2, B3	:	in STD_LOGIC;  -- debounced button inputs
    data_sequence	:	in STD_LOGIC_VECTOR(3 downto 0); 
    input_count		: 	out STD_LOGIC_VECTOR(4 downto 0); 
    correct_input	:	out STD_LOGIC := '1';
    button_out		: 	out STD_LOGIC_VECTOR(3 downto 0) := "0000"); 
end input_module; 

architecture behavior of input_module is
signal button_in		: STD_LOGIC_VECTOR(3 downto 0) := "0000"; 
signal input_count_s	: unsigned(4 downto 0) := "00000"; 
signal new_input		: STD_LOGIC := '0';
signal button_en		: STD_LOGIC := '1';
signal display_count	: integer := 0;

begin 

-- accept input from buttons
process(clk) 
begin
    if rising_edge(clk) then
        correct_input <= '1'; 
    	if input_en = '1' then 
            if button_en = '1' then 
                if (B0='1' OR B1='1' OR B2='1' OR B3='1') then 
                	button_in(0) <= B0; 
               		button_in(1) <= B1; 
                	button_in(2) <= B2; 
                	button_in(3) <= B3; 
                    new_input <= '1'; 
                else 
                    new_input <= '0'; 
                end if; 

                if new_input = '1' then 
                    button_en <= '0';
                end if; 
            else 
            	button_in <= button_in;
                new_input <= '0';
                display_count <= display_count+1;
                if display_count = 4999999 then 	-- count up to desired display time
                    display_count <= 0;
                    button_en <= '1'; 
					input_count_s <= input_count_s +1; -- increment input counter once input has been displayed for the desired amount of time 
                    button_in <= "0000";
                    
                    -- comparator
                    if button_in = data_sequence then 
                        correct_input <= '1';
                    else 
                        correct_input <= '0';
                    end if; 
                end if; 
            end if; 
        else 
        	input_count_s <= "00000"; 
        end if;
    end if;
end process; 


input_count <= STD_LOGIC_VECTOR(input_count_s); 
button_out <= button_in; 

end behavior;