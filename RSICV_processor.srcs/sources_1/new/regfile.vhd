----------------------------------------------------------------------------------
-- Company: tum
-- Engineer: lijian
-- 
-- Create Date: 07/28/2023 02:31:56 PM
-- Design Name: registerfile
-- Module Name: regfile - Behavioral
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
-- 8x16 bit register file for rsic , 
-- 16 bit register with enable input 
----------------------------------------------------------------------------------

use work.risc_pack.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg is
  Port (clk,reset,csel:in bit; 
        data:in DATA_type;     --16bit data 
        reg_val:out data_type); --16 bit data 
end reg;

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

-----------------------------------------------------------------------------------------------------------
--register count x data type bit registerfile
use  work.risc_pack.all;
library  ieee;
use ieee.std_logic_1164 .all;
use ieee.numeric_std.all;

entity regfile is 
    port(src1, src2: in register_address_type; --3bit addresses
         data: in data_type ;              --16bit data 
         dest: in register_address_type;   --3bit address
         en : in bit ;
         regfilex :out register_file_type; --copy register to output 
         reg_a,reg_b :out data_type);      --16bit data  
end regfile;


architecture behave of regfile is 
signal regfile:register_file_type;    --registerfile array (7:0)
signal dest_sel:bit_vector (register_count -1 downto 0);
begin 
reg_muxa:process (regfile,src1)
begin 
  reg_a <= regfile (to_integer(unsigned (to_stdlogicvector (src1)))) after 5 ns;
  
end process reg_muxa;


reg_muxb:process (regfile,src2) 
begin 
  reg_b <= regfile (to_integer(unsigned (to_stdlogicvector (src2)))) after 5 ns;
end process reg_muxb;


dx_dest:process(dest,en)
begin 
  dest_sel <=(others=>'0');
  if en ='1' then 
  dest_sel(TO_integer(unsigned (to_stdlogicvector (dest))))<='1' after 5 ns;
  end if;
end process dx_dest;


gen:for i in 0 to register_count-1 generate --instantiate 8registers
wr:  entity work.reg  
     port map (clk,reset,dest_sel(I), data, regfile(I));
     end generate gen;
      
regfilex <= regfile; --copy regfile to output 
end behave; 


