----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2018 05:42:09 PM
-- Design Name: 
-- Module Name: display - Behavioral
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


ENTITY display IS PORT ( 	
        clk	:	in	STD_LOGIC;		
        display_en	:	in 	STD_LOGIC;
        data_sequence : in STD_LOGIC_VECTOR(3 downto 0);
        button_in : in STD_LOGIC_VECTOR(3 downto 0);
        wait_en     : in STD_LOGIC;
        won_en      : in STD_LOGIC; 
        lost_en     : in STD_LOGIC;
        won_lost_sequence : in STD_LOGIC_VECTOR(3 downto 0); 
        
        wait_done   : out STD_LOGIC := '0';
        display_count : out STD_LOGIC_VECTOR(4 downto 0);
        LED_out     : out STD_LOGIC_VECTOR(3 downto 0) := "0000");
end display; 


ARCHITECTURE behavior of display is


signal display_next: STD_LOGIC := '0';
signal One_HZ_Counter: integer := 0;
signal display_counter : unsigned(4 downto 0) := "00000";
signal delay_counter   : integer := 0;


BEGIN
	display_count <= std_logic_vector(display_counter);
    
	process(clk)
    BEGIN
    	if rising_edge(clk) then
        	if display_en = '0' then
            	LED_OUT <= button_in;
                One_HZ_Counter <= 0;
                display_counter <= "00000";
                delay_counter <= 0;
                
                if wait_en = '1' then    -- in wait state
                    LED_OUT <= "0000";
                    delay_counter <= delay_counter+1; 
                    if delay_counter = 4999999 then 
                        wait_done <= '1'; 
                        delay_counter <= 0; 
                    end if;
                else
                    wait_done <= '0';
                end if;
                
                if won_en = '1' OR lost_en = '1' then 
                    LED_OUT <= won_lost_sequence; 
                end if;
            end if;
        
        	if display_en = '1' then
        	    LED_OUT <= data_sequence;
            	One_HZ_Counter <= One_HZ_Counter + 1;
                
                if One_HZ_Counter = 4999999 then -- count up for desired display length (0.5 seconds)
                    LED_OUT <= "0000";                   
                    One_Hz_Counter <= One_Hz_Counter;
                    delay_counter <= delay_counter+1;
                    if delay_counter = 2499997 then
                	    display_counter <= display_counter + 1;
                	end if; 
                	if delay_counter = 2499999 then 
                        One_HZ_Counter <= 0;
                        delay_counter <= 0;
                    end if;
                end if;
            end if;
		end if;
    end process;

end behavior;
