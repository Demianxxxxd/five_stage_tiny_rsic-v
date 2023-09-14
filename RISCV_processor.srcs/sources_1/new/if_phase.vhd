----------------------------------------------------------------------------------
-- Company: tum     
-- Engineer:lijian
-- 
-- Create Date: 2023/09/08 22:02:26
-- Design Name: 
-- Module Name: if_phase - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: instruction fetch phase
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

use work.risc_pack.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity if_phase is
Port( clk : in bit ;
      reset : in bit;
      jump_taken_ex : in bit;
      jump_dest_ex : in pc_address_type; --8bit
      pc_act : out pc_address_type;
      pc_id : out pc_address_type
    );
end if_phase;

architecture Behavioral of if_phase is
signal pc_act_int : pc_address_type; --actual programm counter 8bit
begin

pc:process(clk,reset)  --programm counter 
begin 
    if reset ='1' then 
        pc_act_int <=(others => '1') after 5 ns ;
    elsif  clk = '0' and clk'event then --on falling edge!
    --next follows the pc_act miltiplexer, the priority us important!
        if jump_taken_ex = '1' then -- if jump,call or branch to be taken
            pc_act_int <= jump_dest_ex after 5 ns; --load destination address
        else
           pc_act_int <= pc_act_int + 1 after 5ns ;--else increment pc 
        end if;
    end if;
end process pc;

if_id :process(clk,reset) -- if pipeline register 
begin 
    if reset ='1' then 
        pc_id <= (others => '0') after 5 ns;
    elsif clk='1' and clk'event then 
        pc_id <= pc_act_int after 5ns;
    end if ;
end process if_id;

pc_act <= pc_act_int; --cope to out port
            
end Behavioral;










