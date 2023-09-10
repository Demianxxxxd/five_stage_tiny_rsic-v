----------------------------------------------------------------------------------
-- Company: tum
-- Engineer: lijian 
-- 
-- Create Date: 2023/09/08 23:18:05
-- Design Name: 
-- Module Name: id_phase - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: instruction decode phase
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

entity id_phase is
Port (clk :in bit;
      reset : in bit;
      pc_id : pc_address_type;
      i_id : in instruction_type;
      data_wb : in data_type;
      dest_wb : in register_address_type;
      dest_en_wb : in register_address_type;
      zflag, nflag : in bit ;
      
      jump_taken_ex : out bit;
      jump_dest_ex : out pc_address_type;
      reg_a_ex : out data_type;
      reg_b_ex : out data_type;
      imm_ex : out std_logic_vector (7 downto 0);
      dest_ex :out register_address_type;
      regfilex : out register_file_type;
      opc_ex : out opcode_type
      );
end id_phase;

architecture decode of id_phase is
signal reg_a,reg_b:data_type;
signal src1,src2: register_address_type;
signal jump_taken : bit ;
signal jump_dest : pc_address_type;
signal opc_id_int : opcode_type;

begin
--process opdec decode the actual instruction
opdec:process(i_id)
begin 
--decoding correspinds to the risc.buch.tab assembler table
    case i_id(15 downto 11 ) is 
        when "00000" => opc_id_int <= nopo after 5 ns;
        when "00001" => OPC_ID_int <= addo after 5 ns; 
        when "00010" => OPC_ID_int <= subo after 5 ns; 
        when "00011" => OPC_ID_int <= ando after 5 ns; 
        when "00100" => OPC_ID_int <= oro after 5 ns; 
        when "00101" => OPC_ID_int <= xoro after 5 ns; 
        when "00110" => OPC_ID_int <= slao after 5 ns; 
        when "00111" => OPC_ID_int <= srao after 5 ns; 
        when "01000" => OPC_ID_int <= mvo after 5 ns; 
        when "01001" => OPC_ID_int <= addilo after 5 ns; 
        when "01010" => OPC_ID_int <= addiho after 5 ns; 
        when "01011" => OPC_ID_int <= ldo after 5 ns; 
        when "01100" => OPC_ID_int <= sto after 5 ns; 
        when "01101" => OPC_ID_int <= jmpo after 5 ns; 
        when "01110" => OPC_ID_int <= bneo after 5 ns; 
        when "01111" => OPC_ID_int <= blto after 5 ns; 
        when "10000" => OPC_ID_int <= bgeo after 5 ns; 
        when others => OPC_ID_int <= nopo after 5 ns; 
    end case;
end process opdec; 
-- Register selection MUXes: 
src1_mux: process(i_id, opc_id_int) 
begin
    case opc_id_int is 
        -- use rdest bit fields as a operand 
        when addilo | addiho => src1 <= to_bitvector(i_id(10 downto 8)); 
        -- use rsrc1 bit fields 
        when others => src1 <= to_bitvector(i_id(7 downto 5));
    end case; 
end process src1_mux;
 
src2_mux: process(i_id, opc_id_int) 
begin
    case opc_id_int is 
        -- use rdest bit fields to address register to be stored
        when sto => src2 <= to_bitvector(i_id(10 downto 8)); 
        -- use rsrc2 bit fields
        when others => src2 <= to_bitvector(i_id(4 downto 2));
    end case; 
end process src2_mux;

-- address alu for branch target calculation includes address mux! 
addr_alu: process(opc_id_int, pc_id, i_id) 
begin
    -- default: for jmp 
     jump_dest <= unsigned(i_id(pc_address_width-1 downto 0)) after 5 ns; 
     -- for all branches: 
     if (opc_id_int = bneo) or (opc_id_int = blto) or (opc_id_int = bgeo) then 
         jump_dest <= unsigned(signed(i_id(pc_address_width-1 downto 0)) + signed(pc_id)) after 5 ns; 
     end if; 
end process addr_alu; 
-- jump_taken generator 
jump_taken_p: process(opc_id_int, zflag, nflag) 
begin
    jump_taken <= '0' after 5 ns; -- default: no jump or branch 
    if ( (opc_id_int = jmpo) -- first treat the unconditional jump 
        or ((opc_id_int = bneo) and (zflag ='0')) -- next consider branches 
        or ((opc_id_int = blto) and (nflag ='1')) 
        or ((opc_id_int = bgeo) and ((nflag='0') or (zflag='1'))) ) then
        jump_taken <= '1' after 5 ns; 
    end if; 
end process jump_taken_p; 
-- registerfile component instantiation 
dut: regfile port map(clk, reset, src1, src2, data_wb, dest_wb, dest_en_wb, regfilex, reg_a, reg_b); 
--id/ex pipeline register 
id_ex_interface: process(reset,clk) 
begin
    if reset = '1' then
        reg_a_ex <= (others => '0') after 5 ns; 
        reg_b_ex <= (others => '0') after 5 ns; 
        imm_ex <= (others=>'0') after 5 ns; 
        dest_ex <= (others=>'0') after 5 ns; 
        opc_ex <= nopo after 5 ns; 
    elsif clk='1' and clk'event then
        reg_a_ex <= reg_a after 5 ns; 
        reg_b_ex <= reg_b after 5 ns; 
        imm_ex <= i_id(7 downto 0) after 5 ns; 
        dest_ex <= to_bitvector(i_id(10 downto 8)) after 5 ns; 
        opc_ex <= opc_id_int after 5 ns; 
    end if; 
end process id_ex_interface; 

jump_taken_ex <= jump_taken; -- note that these are comb!!! outputs 
jump_dest_ex <= jump_dest; 

end decode;
