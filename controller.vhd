----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2018 05:41:04 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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
use IEEE.numeric_std.all;


ENTITY controller IS PORT ( 	
        clk	:	in	STD_LOGIC;
        final_level	:	in 	STD_LOGIC;
        on_off		: 	in 	STD_LOGIC;
        display_done :	in	STD_LOGIC;
        correct_input :	in 	STD_LOGIC;
        input_done	:	in 	STD_LOGIC;
        wait_done   :   in  STD_LOGIC;
        won_done    :   in  STD_LOGIC; 
        lost_done   :   in  STD_LOGIC;
        
        update_en	:	out	STD_LOGIC;
        display_en	:	out	STD_LOGIC;
        input_en	: 	out	STD_LOGIC;
        reset		: 	out STD_LOGIC;
        wait_en     :   out STD_LOGIC; 
        won_en      :   out STD_LOGIC;
        lost_en     :   out STD_LOGIC);
end controller; 


ARCHITECTURE behavior of controller is
type state_type is (off, update, display, read_input, waiting, won, lost);
signal current_state, next_state : state_type;


BEGIN

-----------------------
--FSM
-----------------------
	process(clk)
    BEGIN
    	if rising_edge(clk) then
			current_state <= next_state;
		end if;
    end process;

	process(current_state, on_off, display_done, correct_input, input_done, final_level, wait_done, won_done, lost_done)
    
    BEGIN
    	next_state <= current_state;
    	update_en <='0';
        display_en <= '0';
        input_en <= '0';
        reset <= '0';
        wait_en <= '0';
        won_en <= '0'; 
        lost_en <= '0'; 
        
    	case(current_state) IS
        
        	when(off)	=> 
            	reset <= '1';
                
                if on_off = '1' then
            		next_state <= update;
            	end if;
                
            when(update)  => 
            	update_en <='1';
                
            	next_state <= display;
            	if on_off = '1' then 
            	   next_state <= off;
            	end if; 
                
            when(display)  => 
                display_en <= '1';
                
                if display_done = '1' then
            		next_state <= read_input;
                end if;
                
                if on_off = '1' then 
                    next_state <= off;
                end if;
                
            when(read_input)  => 
                input_en <= '1';
                
                if correct_input = '0' then
            		next_state <= lost;
                end if;
                
                
                if final_level = '1' AND input_done = '1' then
                	next_state <= won;
                elsif input_done = '1' then
                    next_state <= waiting;
                end if;
                
                if on_off = '1' then 
                    next_state <= off;
                end if;
            
            when(waiting) =>
                input_en <= '1';
                wait_en <= '1';   
                
                if wait_done = '1' then
                    next_state <= update;
                end if; 
                 
            when(lost) =>
            	reset <= '1';
                lost_en <= '1';
                if lost_done = '1' then 
            	    next_state <= off;
            	end if; 
            
            when(won) =>
            	reset <= '1';
                won_en <= '1';
                
                if won_done = '1' then 
            	    next_state <= off;
            	end if; 
            
            when others => next_state <= off;
            
        end case;
    
    end process;

end behavior;
