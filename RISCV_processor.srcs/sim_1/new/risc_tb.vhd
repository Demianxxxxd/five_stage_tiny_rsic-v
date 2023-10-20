----------------------------------------------------------------------------------
-- Company: tum         
-- Engineer:Jian,li
-- 
-- Create Date: 2023/10/19 19:57:30
-- Design Name: 
-- Module Name: risc_tb - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use WORK.RISC_pack.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity risc_tb is
--  Port ( );
end risc_tb;

architecture Behavioral of risc_tb is
signal clk,resEt_a: bit;
signal in_ext, out_ext: data_type;
signal we_ext: bit;
signal dip_sw :bit_vector (3 downto 0):= "0000";
signal disp_data : std_logic_vector (15 downto 0);  

begin
DUT: entity work.risc
    port map(clk,reset_a, dip_sw, disp_data, in_ext, out_ext, we_ext);
    
p1: process --25 mhz clock
begin
    clk <= '1'; wait for 20 ns;
    clk <= '0'; wait for 20 ns;
end process p1;

reset_a <= '0', '1'after 33 ns,'0'after 85 ns;  --async.reset
in_ext <= x"AA55"; --external input port


end Behavioral;
