----------------------------------------------------------------------------------
-- Company: ENGS 31
-- Engineer: Leina McDermott and Alex Newman
-- 
-- Create Date: 05/24/2018 05:29:19 PM
-- Design Name: 
-- Module Name: sequence_array - Behavioral
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


entity sequence_array is port(
	clk				:	in STD_LOGIC;
    update_en		: 	in STD_LOGIC; 
    display_count	: 	in STD_LOGIC_VECTOR(4 downto 0); 
    input_count		:	in STD_LOGIC_VECTOR(4 downto 0); 
    input_en		:	in STD_LOGIC;
    data_in			: 	in STD_LOGIC_VECTOR(3 downto 0);
    reset			: 	in STD_LOGIC;
    difficulty      :   in STD_LOGIC;
    data_out		: 	out STD_LOGIC_VECTOR(3 downto 0); 
    final_level		:	out STD_LOGIC := '0';
    display_done	:	out STD_LOGIC := '0';
    input_done		:	out stD_LOGIC := '0';
    level           :   out STD_LOGIC_VECTOR(7 downto 0));
end sequence_array; 

architecture behavior of sequence_array is 
type reg_file is array(29 downto 0) of STD_LOGIC_VECTOR(3 downto 0); 
signal seq_reg		:	reg_file := (others => "0000"); 
signal level_count 	: 	integer := 0; 
signal R_ADDR_s		: 	integer := 0; 
begin 

-- sequence array and level count
process(clk) 
begin 
	if rising_edge(clk) then 
    	if update_en = '1' then 
        	seq_reg(level_count) <= data_in; 
        	level_count <= level_count+1; 
        end if; 
        if reset = '1' then 
        	seq_reg <= (others => "0000"); 
            level_count <= 0;
            final_level <= '0'; 
        end if; 
        final_level <= '0';
        if level_count = 29 AND difficulty = '1' then
        	final_level <= '1'; 
        end if; 
        if level_count = 5 AND difficulty = '0' then 
            final_level <= '1';
        end if; 
    end if; 
end process; 

-- mux to determine R_ADDR
process(clk)
begin
	if rising_edge(clk) then 
    	display_done <= '0';
        input_done <= '0';
        case input_en is 
            when '0' => 	-- not in input state
                if to_integer(unsigned(display_count)) = level_count then 
                    if level_count > 0 then
                        display_done <= '1';
                    end if;
                else 
                    R_ADDR_s <= to_integer(unsigned(display_count)); 
                end if;
            when '1' => 	-- in input state, read from input counter
                if to_integer(unsigned(input_count)) = level_count then
                	input_done <= '1'; 
                else
                	R_ADDR_s <= to_integer(unsigned(input_count)); 
                end if;
            when others => R_ADDR_s <= 0;
        end case; 
    end if; 
end process; 

level <= STD_LOGIC_VECTOR(to_unsigned(level_count, 8)); 
data_out <= seq_reg(R_ADDR_s); 

end behavior; 