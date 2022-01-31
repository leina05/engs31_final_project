----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2018 10:31:02 PM
-- Design Name: 
-- Module Name: pmod_da2 - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;



entity pmod_da2 is port (
        -- interface to top level
        sclk		: in std_logic;	    -- serial clock
        start		: in STD_LOGIC;
        data_in     : in STD_LOGIC_VECTOR (11 downto 0);

      -- SPI bus interface to Pmod DA1
        spi_sclk    : out std_logic;
        spi_cs      : out std_logic;    -- chip select, active low
        spi_sdata   : out std_logic );
end pmod_da2; 

ARCHITECTURE Behavioral of pmod_da2 is

type state_type is (idle, shift, syncdata);
signal current_state, next_state : state_type;
signal done, shift_en : STD_LOGIC;
signal shift_reg : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 
signal shift_count_flag : STD_LOGIC := '0';   
signal counter : unsigned(3 downto 0) := "0000";         

begin

spi_sclk <= sclk;

----------------------------------------
-----FSM
----------------------------------------

--State Update--
process(sclk) is 
begin
    if rising_edge(sclk) then
        current_state <= next_state;
    end if; 
end process; 

--Next State Logic--
process(start, shift_count_flag, current_state) is 
begin 
    next_state <= current_state;
    shift_en <= '0';
    spi_cs <= '1'; 
    done <= '1';
    
    case (current_state) is 
        when (idle) =>  
            if start = '1' then 
                next_state <= shift; 
            end if; 
        when (shift) => 
            shift_en <= '1'; 
            spi_cs <= '0'; 
            done <= '0';
            if shift_count_flag = '1' then
                next_state <= syncdata; 
            end if; 
        when (syncdata) => 
            --spi_cs <= '1'; 
            done <= '0';
            if start = '0' then 
            	next_state <= idle; 
            end if; 
    end case; 
end process; 

----------------------------------------
-----end of FSM
----------------------------------------

----------------------------------------
-----Datapath
----------------------------------------

--Shift register--
process(sclk) is
begin
    if rising_edge(sclk) then
    	if done = '1' then 
        	shift_reg <= "0000" & NOT(data_in(11)) & data_in(10 downto 0); 
        end if; 
        if shift_en = '1' then
            shift_reg <= shift_reg(14 downto 0) & '0'; 
        end if; 
    end if; 
end process; 

--shift counter--          
process(sclk) is
begin 
    if rising_edge(sclk) then
        shift_count_flag <= '0';
        
        if shift_en = '1' then 
            counter <= counter + 1; 
            if counter = "1110" then 
                shift_count_flag <= '1'; 
            end if;   
        end if;
    end if; 
end process; 
                          
spi_sdata <= shift_reg(15);


end Behavioral;

