----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2018 06:00:19 PM
-- Design Name: 
-- Module Name: Simon - Behavioral
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
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use IEEE.math_real.all;				-- needed for automatic register sizing

library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity Simon is port (
    mclk		: in std_logic;	    -- FPGA board master clock (100 MHz)   
    on_off      : in STD_LOGIC;     -- on/off button
    
    -- difficulty switch input
    difficulty : in STD_LOGIC; 
     
    -- button inputs
	B0 :   in STD_LOGIC; 
	B1 :   in STD_LOGIC; 
	B2 :   in STD_LOGIC; 
	B3 :   in STD_LOGIC; 
	
	-- LED outputs
    LED_OUT : out STD_LOGIC_VECTOR(3 downto 0) := "0000"; 
    
     -- interface to Pmod DA2
    spi_sclk    : out std_logic;
    spi_cs      : out std_logic;    -- chip select, active low
    spi_sdata   : out std_logic;
    
	-- multiplexed seven segment display
      seg    : out std_logic_vector(0 to 6);
      dp    : out std_logic;
      an     : out std_logic_vector(3 downto 0) );   
end Simon; 

architecture Behavioral of Simon is

-----------------------------------
-- COMPONENT INSTANTIATIONS
-----------------------------------

-- Controller
component controller is port ( 	
    clk	:	in	STD_LOGIC;
    final_level    :    in     STD_LOGIC;
    on_off        :     in     STD_LOGIC;
    display_done :    in    STD_LOGIC;
    correct_input :    in     STD_LOGIC;
    input_done    :    in     STD_LOGIC;
    wait_done   :   in  STD_LOGIC;
    won_done    :   in  STD_LOGIC; 
    lost_done   :   in  STD_LOGIC;

    update_en    :    out    STD_LOGIC;
    display_en    :    out    STD_LOGIC;
    input_en    :     out    STD_LOGIC;
    reset        :     out STD_LOGIC;
    wait_en     :   out STD_LOGIC; 
    won_en      :   out STD_LOGIC;
    lost_en     :   out STD_LOGIC);
end component; 

signal on_off_mp, update_en_s, display_en_s, input_en_s, reset_s, wait_en_s : STD_LOGIC := '0'; 
signal on_off_sync : STD_LOGIC_VECTOR(1 downto 0) :=  "00"; 

-- Input module
component input_module is port(
	clk, input_en	:	in STD_LOGIC; 
    B0, B1, B2, B3    :    in STD_LOGIC;  -- debounced button inputs
    data_sequence    :    in STD_LOGIC_VECTOR(3 downto 0); 
    input_count        :     out STD_LOGIC_VECTOR(4 downto 0); 
    correct_input    :    out STD_LOGIC := '1';
    button_out        :     out STD_LOGIC_VECTOR(3 downto 0) := "0000"); 
end component; 

signal B0_mp, B1_mp, B2_mp, B3_mp : STD_LOGIC := '0';
signal B0_sync, B1_sync, B2_sync, B3_sync : STD_LOGIC_VECTOR(1 downto 0) := "00"; 
signal input_count_s :   STD_LOGIC_VECTOR(4 downto 0); 
signal correct_input_s : STD_LOGIC; 
signal button_out_s    : STD_LOGIC_VECTOR(3 downto 0); 

-- Random number generator
component random_num is port(
	clk			:	in STD_LOGIC; 
    random_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0001"); 
end component; 

signal random_out_s : STD_LOGIC_VECTOR(3 downto 0); 

-- Sequence Array
component sequence_array is port(
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
end component; 

signal data_out_s : STD_LOGIC_VECTOR(3 downto 0); 
signal final_level_s, display_done_s, input_done_s : STD_LOGIC; 
signal level_s : STD_LOGIC_VECTOR(7 downto 0); 

-- Display module
component display is port(
    clk	:	in	STD_LOGIC;		
    display_en    :    in     STD_LOGIC;
    data_sequence : in STD_LOGIC_VECTOR(3 downto 0);
    button_in : in STD_LOGIC_VECTOR(3 downto 0);
    wait_en     : in STD_LOGIC;
    won_en      : in STD_LOGIC; 
    lost_en     : in STD_LOGIC;
    won_lost_sequence : in STD_LOGIC_VECTOR(3 downto 0); 

    wait_done   : out STD_LOGIC := '0';
    display_count : out STD_LOGIC_VECTOR(4 downto 0);
    LED_out     : out STD_LOGIC_VECTOR(3 downto 0) := "0000");
end component; 

signal display_count_s : STD_LOGIC_VECTOR(4 downto 0); 
signal wait_done_s : STD_LOGIC;
signal LED_OUT_s   : STD_LOGIC_VECTOR(3 downto 0); 

-- Buzzer module
component buzzer is port(
	clk			    :	in STD_LOGIC;	-- 10 MHz clk
	buzzer_en	    :	in STD_LOGIC; 
    counter_step	:	in STD_LOGIC_VECTOR(6 downto 0); 
    
    LUT_addr    :   out STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
    start		:   out STD_LOGIC := '0'); 
end component; 

signal buzzer_en_s, start_s : STD_LOGIC := '0'; 
signal counter_step_s : STD_LOGIC_VECTOR(6 downto 0); 
signal LUT_addr_s : STD_LOGIC_VECTOR(15 downto 0); 

component dds_compiler_0 PORT (
    aclk : IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
end component;

signal da_data_s  : STD_LOGIC_VECTOR(15 downto 0); 

component pmod_da2 is port (
    -- interface to top level
    sclk		: in std_logic;	    -- serial clock
    start		: in STD_LOGIC;
    data_in     : in STD_LOGIC_VECTOR (11 downto 0);

    -- SPI bus interface to Pmod DA2
    spi_sclk    : out std_logic;
    spi_cs      : out std_logic;    -- chip select, active low
    spi_sdata   : out std_logic );
end component; 

component binary_to_BCD is port(
	clk			:	in STD_LOGIC;
    update_en	:	in STD_LOGIC; 
	binary_in 	: 	in STD_LOGIC_VECTOR(7 downto 0); 
    tens_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0000"; 
    ones_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0000"); 
end component;

signal tens_out_s, ones_out_s : STD_LOGIC_VECTOR(3 downto 0); 

component mux7seg is Port ( 
    clk : in  STD_LOGIC;									-- runs on a fast (1 MHz or so) clock
    y0, y1, y2, y3 : in  STD_LOGIC_VECTOR (3 downto 0);	-- digits
    dp_set : in std_logic_vector(3 downto 0);            -- decimal points
    seg : out  STD_LOGIC_VECTOR(0 to 6);				    -- segments (a...g)
    dp : out std_logic;
    an : out  STD_LOGIC_VECTOR (3 downto 0) );	      -- anodes
end component;

component won_lost_module is port(
	clk 	: 	in STD_LOGIC; 
	won_en	:	in STD_LOGIC;
    lost_en	:	in STD_LOGIC; 
    
    sequence_out	:	out STD_LOGIC_VECTOR(3 downto 0) := "0000";
    won_done		:	out STD_LOGIC := '0';
    lost_done		:	out STD_LOGIC := '0'); 
end component; 

signal won_en_s, lost_en_s, won_done_s, lost_done_s : STD_LOGIC; 
signal sequence_out_s : STD_LOGIC_VECTOR(3 downto 0); 

-- Signals for the clock divider, which divides the master clock from 100 MHz down to 10 MHz
-- Master clock frequency / CLOCK_DIVIDER_VALUE = 20 MHz
constant CLOCK_DIVIDER_VALUE: integer := 5;  
signal clkdiv: unsigned(22 downto 0) := (others => '0');    -- clock divider counter
signal clkdiv_tog: std_logic := '0';                        -- terminal count
signal clk: std_logic := '0';

-------------------------------------------------
begin

-------------------------------------------------
-- PORT MAPS
-------------------------------------------------
-- Controller 
simon_controller: controller port map(
     clk => clk, 
     final_level => final_level_s, 
     on_off => on_off_mp, 
     display_done => display_done_s,
     correct_input => correct_input_s, 
     input_done => input_done_s,
     wait_done => wait_done_s, 
     won_done => won_done_s,
     lost_done => lost_done_s,
     update_en => update_en_s, 
     display_en => display_en_s, 
     input_en => input_en_s, 
     reset => reset_s,
     wait_en => wait_en_s,
     won_en => won_en_s,
     lost_en => lost_en_s);

-- Input module
input: input_module port map(
    clk => clk, 
    input_en => input_en_s, 
    B0 => B0_mp, 
    B1 => B1_mp, 
    B2 => B2_mp, 
    B3 => B3_mp, 
    data_sequence => data_out_s, 
    input_count => input_count_s, 
    correct_input => correct_input_s,
    button_out => button_out_s);

-- Random number generator
random: random_num port map(
    clk => clk, 
    random_out => random_out_s);

-- Sequence Array
s_array: sequence_array port map(
    clk => clk, 
    update_en => update_en_s, 
    display_count => display_count_s, 
    input_count => input_count_s, 
    input_en => input_en_s, 
    data_in => random_out_s, 
    reset => reset_s, 
    difficulty => difficulty,
    data_out => data_out_s, 
    final_level => final_level_s, 
    display_done => display_done_s, 
    input_done => input_done_s, 
    level => level_s);
    
-- Display Module
simon_display: display port map(
    clk => clk, 
    display_en => display_en_s, 
    data_sequence => data_out_s, 
    button_in => button_out_s,
    wait_en => wait_en_s,
    won_en => won_en_s,
    lost_en => lost_en_s, 
    won_lost_sequence => sequence_out_s,
    wait_done => wait_done_s,
    display_count => display_count_s, 
    LED_OUT => LED_OUT_s); 

-- buzzer module
simon_buzzer: buzzer port map(
    clk => clk, 
    buzzer_en => buzzer_en_s, 
    counter_step => counter_step_s, 
    LUT_addr => LUT_addr_s,
    start => start_s);
 
-- DDS Compiler (sine wave LUT) 
dds : dds_compiler_0 PORT MAP (
     aclk => clk,
     s_axis_phase_tvalid => buzzer_en_s,
     s_axis_phase_tdata => LUT_addr_s,
     m_axis_data_tdata =>  da_data_s);
   
-- Pmod DA2 interface
interface: pmod_da2 port map(
    sclk => clk, 
    start => start_s, 
    data_in => da_data_s(11 downto 0), 
    spi_sclk => spi_sclk, 
    spi_cs => spi_cs, 
    spi_sdata => spi_sdata); 
     
BCD_converter : binary_to_BCD port map(
    clk => clk, 
    update_en => update_en_s,
    binary_in => level_s, 
    ones_out => ones_out_s, 
    tens_out => tens_out_s);

seven_segment: mux7seg port map(
    clk => clk, 
    y0 => ones_out_s, 
    y1 => tens_out_s, 
    y2 => "0000", 
    y3 => "0000", 
    dp_set => "0000",
    seg => seg, 
    dp => dp, 
    an => an); 

won_lost: won_lost_module port map(
    clk => clk, 
    won_en => won_en_s, 
    lost_en => lost_en_s, 
    sequence_out => sequence_out_s, 
    won_done => won_done_s,
    lost_done => lost_done_s);
        
--------------------------------------
-- TOP LEVEL PROCESSES
--------------------------------------
LED_OUT <= LED_OUT_s;

-- mux for sine wave counter step sizes
process(clk) 
begin 
    if rising_edge(clk) then 
        case LED_OUT_s is 
            when "0000" => 
                buzzer_en_s <= '0'; 
                counter_step_s <= "0000000"; 
            when "0001" =>
                buzzer_en_s <= '1'; 
                counter_step_s <= "0100010";
            when "0010" =>
                buzzer_en_s <= '1';
                counter_step_s <= "0101101";
            when "0100" => 
                buzzer_en_s <= '1'; 
                counter_step_s <= "0111001";
            when "1000" => 
                buzzer_en_s <= '1';
                counter_step_s <= "1000011";
            when others => 
                buzzer_en_s <= '0';
                counter_step_s <= "0000000";
        end case;
    end if; 
end process;  
        
                
-- Clock buffer for the 10 MHz clock
-- The BUFG component puts the slow clock onto the FPGA clocking network
slow_clock_buffer: BUFG
      port map (I => clkdiv_tog,
                O => clk );

-- Divide the master clock down to 20 MHz, then toggling the
-- clkdiv_tog signal at 20 MHz gives a 10 MHz clock with 50% duty cycle.
clock_divider: process(mclk)
begin
	if rising_edge(mclk) then
	   	if clkdiv = CLOCK_DIVIDER_VALUE-1 then 
	   		clkdiv_tog <= NOT(clkdiv_tog);        -- T flip flop
			clkdiv <= (others => '0');
		else
			clkdiv <= clkdiv + 1;                 -- Counter
		end if;
	end if;
end process clock_divider; 

-- Monopulse the buttons
monopulser: process(clk, B0_sync, B1_sync, B2_sync, B3_sync, on_off_sync)
begin	
	if rising_edge(clk) then	
		B0_sync <= B0 & B0_sync(1);	
		B1_sync <= B1 & B1_sync(1);	
		B2_sync <= B2 & B2_sync(1);	
		B3_sync <= B3 & B3_sync(1);	
		on_off_sync <= on_off & on_off_sync(1);
	end if;
	
	B0_mp <= B0_sync(1) and not(B0_sync(0));
	B1_mp <= B1_sync(1) and not(B1_sync(0));
	B2_mp <= B2_sync(1) and not(B2_sync(0));
	B3_mp <= B3_sync(1) and not(B3_sync(0));
    on_off_mp <= on_off_sync(1) and not(on_off_sync(0)); 
    
end process monopulser;

end Behavioral; 