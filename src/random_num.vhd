----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2018 05:32:59 PM
-- Design Name: 
-- Module Name: random_num - Behavioral
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

entity random_num is port(
	clk			:	in STD_LOGIC; 
    random_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0001"); 
end random_num; 

architecture behavior of random_num is

signal counter	: 	unsigned(1 downto 0) := "00"; 

begin

process(clk) 
begin
	if rising_edge(clk) then 
    	counter <= counter +1; 
    	case counter is 
        	when "00" => random_out <= "0001"; 
            when "01" => random_out <= "0010"; 
            when "10" => random_out <= "0100"; 
            when "11" => random_out <= "1000"; 
            when others => random_out <= "0001";
        end case; 
    end if; 
end process; 

end behavior; 
        
