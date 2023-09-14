----------------------------------------------------------------------------------
-- Company: tum 
-- Engineer: lijian
-- 
-- Create Date: 2023/09/12 21:51:58
-- Design Name: 
-- Module Name: risc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: top level entity for risc processor 
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

entity risc is
Port (clk : in bit ;                                 --system clock
      reset_a : in bit ;                             -- async.reset
      dip_sw : in bit_vector( 3 downto 0) ;          --dip switches| display control
      -- 7 segment signals
      disp_data : out std_logic_vector(15 downto 0); --display data 
      in_ext : in data_type;
      out_ext :out data_type;
      we_ext : out bit
      );
end risc;

architecture Behavioral of risc is


--wrapper and display signas 
signal temp,reset:bit;
signal regfilex : register_file_type; --regfile content can be displayed
--local signal declarations for risc
signal pc_act:pc_address_type;
signal i_id :instruction_type;
signal jump_dest_ex,pc_id :pc_address_type;
signal jump_taken_ex: bit;
signal opc_ex,opc_mem:opcode_type;
signal dest_ex,dest_mem,dest_wb : register_address_type;
signal dest_en_wb : bit;
signal nflag,zflag:bit;
signal reg_a_ex,reg_b_ex,op_result_mem,reg_mem,data_wb,dout: data_type;
signal imm_ex :std_logic_vector (7 downto 0);
signal en,we,we_ext_int:bit;

begin

async_reset: process(clk) --synchronize async.reset
begin 
    if clk='1' and clk'event then
        temp <= reset_a after 5 ns;
        reset <= temp after 5ns;
    end if ;
end process async_reset;

--the display multiplexer is coded as follows
--sw7 sw6 sw5 sw4  display
--0   0   0   0    i_id(instruction of decode phase)
--1 <reg address>  content of addressed register 
--0   0   0   1    ox00 & pc_act (programm center in the decode phase)
disp_mux:process (dip_sw,regfilex,pc_act,i_id)  -- 7 segment display mux
begin 
    case dip_sw is 
        when "0000" => disp_data <= i_id;        --display i_id 
        when "1000" => disp_data <= regfilex(0); --display r0
        when "1001" => disp_data <= regfilex(1); --display r1
        when "1010" => disp_data <= regfilex(2); --display r2
        when "1011" => disp_data <= regfilex(3); --display r3
        when "1100" => disp_data <= regfilex(4); --display r4
        when "1101" => disp_data <= regfilex(5); --display r5
        when "1110" => disp_data <= regfilex(6); --display r6
        when "1111" => disp_data <= regfilex(7); --display r7
        when others => disp_data <= x"00" & std_logic_vector (pc_act); -- pc_act
    end case;
end process disp_mux;

--instantiation of dp_ram memory
mymem: entity work.dp_bram
    port map (clk,unsigned (pc_act),i_id,unsigned(op_result_mem(7 downto 0)),reg_mem,we,en,dout);
    
--instantiation of dp_ram memory
if_inst: entity work.if_phase
    port map (clk,reset,jump_taken_ex,jump_dest_ex,pc_act,pc_id);
    
id_inst: entity work.id_phase
    port map(clk, reset, pc_id, i_id, data_wb, dest_wb, dest_en_wb, zflag, nflag, jump_taken_ex, jump_dest_ex, reg_a_ex, reg_b_ex, imm_ex, dest_ex, regfilex, opc_ex); 

ex_inst: entity work.ex_phase 
    port map(clk, reset, reg_a_ex, reg_b_ex, imm_ex, dest_ex, opc_ex, zflag, nflag, op_result_mem, reg_mem, dest_mem, opc_mem); 

mem_inst:entity work.mem_phase 
    port map(clk, reset, op_result_mem, reg_mem, dest_mem, opc_mem, dout, in_ext, data_wb, dest_wb, dest_en_wb, we, en, out_ext, we_ext_int); 
    
we_ext <= we_ext_int; 
    
end Behavioral;

        
          



        




