----------------------------------------------------------------------------------
-- Company: tum
-- Engineer: lijian
-- 
-- Create Date: 2023/09/11 14:36:40
-- Design Name: 
-- Module Name: mem_phase - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: memory access
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
entity mem_phase is
port( clk : in bit; 
    reset : in bit; 
    op_result_mem: in data_type; 
    reg_mem: in data_type; 
    dest_mem: in register_address_type; 
    opc_mem : in opcode_type; 
    dout: in data_type; 
    in_ext : in data_type; 
    
    data_wb : out data_type; 
    dest_wb : out register_address_type; 
    dest_en_wb : out bit; 
    we : out bit; 
    en : out bit; 
    out_ext : out data_type; 
    we_ext: out bit 
     ); 
end mem_phase; 

architecture behavioral of mem_phase is
signal en_ext: bit; 
signal dest_en: bit; 
signal en_int, we_int: bit; 
signal we_ext_int: bit; 
begin

addr_decoder: process(op_result_mem, opc_mem) 
begin
    we_int <= '0' after 5 ns; -- process defaults 
    en_int <= '0' after 5 ns; 
    we_ext_int <= '0' after 5 ns; 
    en_ext <= '0' after 5 ns; 
    if ((op_result_mem < x"0200") and (opc_mem = ldo)) then
        en_int <= '1' after 5 ns; -- read from data memory 
    elsif ((op_result_mem < x"0200") and (opc_mem=sto)) then
        we_int <= '1' after 5 ns; -- write to data memory 
        en_int <= '1' after 5 ns; 
    elsif ((op_result_mem >= x"0200") and (opc_mem = ldo)) then
        en_ext <= '1' after 5 ns; -- read from external memory 
    elsif ((op_result_mem >= x"0200") and (opc_mem = sto)) then
        en_ext <= '1' after 5 ns; -- write to ext. device 
        we_ext_int <= '1' after 5 ns; 
    end if; 
end process addr_decoder; 

en <= en_int; -- copy to output port
we <= we_int; -- copy to output port
we_ext <= we_ext_int; -- copy to output port

--Decode Register WriteBack Enable signal 
dest_en <= '1' after 1 ns 
when opc_mem=addo or opc_mem=subo or opc_mem=ando or opc_mem=oro or opc_mem=xoro or opc_mem=slao or opc_mem=srao or opc_mem=mvo 
    or opc_mem=addilo or opc_mem=addiho or opc_mem=ldo else '0' after 5 ns; 
--mem/wb pipeline register includes data multiplexer 

mem_wb_interface: process(reset,clk) 
begin
    if reset = '1' then
        data_wb <= (others=>'0') after 5 ns; 
        dest_wb <= (others=>'0') after 5 ns; 
        dest_en_wb <= '0' after 5 ns; 
    elsif clk='1' and clk'event then
        if (en_ext = '1') and (we_ext_int = '0') then
            data_wb <= in_ext after 5 ns; -- store data from external port 
        elsif (en_int = '1') and (we_int = '0') then
            data_wb <= dout after 5 ns; -- store data from memory 
        else
            data_wb <= op_result_mem after 5 ns; -- store alu result 
        end if; 
        dest_wb <= dest_mem after 5 ns; 
        dest_en_wb <= dest_en after 5 ns; 
    end if; 
end process mem_wb_interface; 
-- registered output (16 bit) 

gpo: process(reset, clk) 
begin
    if reset = '1' then
        out_ext <= (others=>'0') after 5 ns; 
    elsif clk='1' and clk'event then
        if we_ext_int = '1' then
            out_ext <= reg_mem after 5 ns; 
        end if; 
    end if; 
end process gpo; 

end behavioral;

