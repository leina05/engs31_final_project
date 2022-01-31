----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2018 03:48:51 AM
-- Design Name: 
-- Module Name: binary_to_BCD - Behavioral
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

entity binary_to_BCD is port(
	clk			:	in STD_LOGIC;
    update_en	:	in STD_LOGIC; 
	binary_in 	: 	in STD_LOGIC_VECTOR(7 downto 0); 
    tens_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0000"; 
    ones_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0000"); 
end binary_to_BCD;

architecture behavior of binary_to_BCD is 

signal shift_reg : unsigned(15 downto 0) := (others => '0'); 
type state_type is (idle, input, shift, load); 
signal current_state, next_state : state_type;
signal shift_counter : unsigned(3 downto 0) := "0000"; 
signal shift_done, input_en, shift_en, load_en, add : STD_LOGIC := '0'; 

begin 
---------------------------
--FSM
---------------------------

-- state update
process(clk) 
begin 
	if rising_edge(clk) then 
    	current_state <= next_state; 
    end if; 
end process;

-- next state logic
process(update_en, shift_done, current_state) 
begin
	next_state <= current_state;
    input_en <= '0';
    shift_en <= '0'; 
    load_en <= '0'; 
    case current_state is 
    	when idle => 
        	if update_en = '1' then
            	next_state <= input; 
            end if; 
        when input => 
        	input_en <= '1'; 
            next_state <= shift; 
        when shift => 
        	shift_en <= '1'; 
            if shift_done = '1' then 
            	next_state <= load; 
            end if; 
        when load => 
        	load_en <= '1';
            next_state <= idle; 
    end case; 
end process; 

---------------------------
--Datapath
---------------------------

process(clk) 
begin
	if rising_edge(clk) then 
    	if input_en = '1' then 
        	shift_reg <= "00000000" & unsigned(binary_in); 
    	end if; 
        
        shift_done <= '0'; 
        if shift_en = '1' then 
        	-- check if any digit is greater than or equal to 5
        	if ((shift_reg(11 downto 8) >= 5) OR (shift_reg(15 downto 12) >= 5)) AND (add = '0') then 
            	if (shift_reg(11 downto 8) >= 5) then 
            		shift_reg(11 downto 8) <= shift_reg(11 downto 8) + 3; 
            	end if; 
            	if shift_reg(15 downto 12) >= 5 then 
            		shift_reg(15 downto 12) <= shift_reg(15 downto 12) + 3; 
           		end if;
                add <= '1'; 
            else 
            
                -- left shift register by one 
                shift_reg <= shift_reg(14 downto 0) & '0'; 

                -- increase shift counter
                shift_counter <= shift_counter+1;
                add <= '0';
                if shift_counter = "0111" then 
                	shift_counter <= "0000";
            		shift_done <= '1'; 
                    shift_reg <= shift_reg;
                    add <= add; 
           		end if; 
            end if; 
            
        end if; 
        
        if load_en = '1' then 
        	shift_counter <= "0000";         
        	ones_out <= STD_LOGIC_VECTOR(shift_reg(11 downto 8)); 
            tens_out <= STD_LOGIC_VECTOR(shift_reg(15 downto 12)); 
        end if; 
    end if; 
end process;

end behavior;
            
        	

