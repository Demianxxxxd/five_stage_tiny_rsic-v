----------------------------------------------------------------------------------
-- Company: tum     
-- Engineer: lijian 
-- 
-- Create Date: 2023/09/08 08:36:38
-- Design Name: 
-- Module Name: reg - Behavioral
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

-- 8x16 bit register file for rsic , 
-- 16 bit register with enable input 
----------------------------------------------------------------------------------

use work.risc_pack.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity REG is
  Port (clk,reset,csel:in bit; 
        data:in data_type;     --16bit data 
        reg_val:out data_type); --16 bit data 
end REG;
architecture Behave of reg is
begin
p1:process(clk,reset)
   begin 
   if reset='1'then 
         reg_val<=(others=>'0')after 5 ns ;
   elsif clk='0' and clk'event then
   --store ai falling clk edge 
        if csel ='1' then --register enable 
            reg_val <= DATA after 5ns ;
        end if ;
   end if ;
end process p1;
end behave;     


