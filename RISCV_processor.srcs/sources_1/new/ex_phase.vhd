----------------------------------------------------------------------------------
-- Company: tum 
-- Engineer: lijian
-- 
-- Create Date: 2023/09/11 10:27:16
-- Design Name: 
-- Module Name: ex_phase - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Execute phase
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

entity ex_phase is
Port ( clk : in bit; 
       reset : in bit;
       reg_a_ex : in data_type;                       --register operand 
       reg_b_ex : in data_type;                       --register operand 
       imm_ex : in std_logic_vector (7 downto 0);     --immediate konstante operand
       dest_ex :in register_address_type;             --address to be passed 
       opc_ex : in opcode_type;                       --opcode
       
       zflag,nflag : out bit;                         --register flag 
       op_result_mem :out data_type;                  --alu output 
       reg_mem : out data_type;                       --reg.value for dram
       dest_mem: out register_address_type;           --passed through
       opc_mem: out opcode_type                       --pipelined opcode
       );
end ex_phase;

architecture Behavioral of ex_phase is
signal opa , opb : data_type;
signal op_result: data_type;
signal zflg,nflg,update_flag : bit;
constant zero : data_type := (others=>'0');

begin
--alu multiplexers
opa <= reg_a_ex;

opb_mux: process(reg_b_ex,imm_ex,opc_ex)
begin 
    case opc_ex is 
        when addo | subo | ando | oro |xoro =>opb <= reg_b_ex after 5 ns ;
        when others =>opb <= zero_ext(imm_ex,data_width) after 5 ns ;
    end case;
end process opb_mux;

--main alu 
alu:process(opa,opb,opc_ex)
begin 
--alu operation
    op_result <= (others =>'0');  --default output signal 
    update_flag<= '0'after 5 ns ; --default no flag update 
    case opc_ex is 
        when addo => op_result <=std_logic_vector (signed(opa) + signed(opb)) after 5 ns ;
            update_flag <= '1' after 5 ns;
        when subo => op_result <= std_logic_vector(signed(opa) - signed(opb)) after 5 ns; 
            update_flag <= '1' after 5 ns; 
        when ando => op_result <= opa and opb after 5 ns; 
            update_flag <= '1' after 5 ns; 
        when oro => op_result <= opa or opb after 5 ns; 
            update_flag <= '1' after 5 ns; 
        when xoro => op_result <= opa xor opb after 5 ns; 
            update_flag <= '1' after 5 ns; 
            -- simply shift left and append a zero: 
        when slao => op_result <= opa(data_width-2 downto 0) & '0' after 5 ns; 
            update_flag <= '1' after 5 ns; 
            -- shift right and perform sign extension for the msb: 
        when srao => op_result <= opa(data_width-1) & opa(data_width-1 downto 1) after 5 ns; 
            update_flag <= '1' after 5 ns; 
        when mvo | ldo | sto => op_result(data_width-1 downto 0) <= opa after 5 ns; 
            -- pass src_1 addressed reg_a 
        when addilo => op_result <= opa(15 downto 8) & std_logic_vector(signed(opa(7 downto 0)) + signed(opb(7 downto 0))) after 5 ns; 
            update_flag <= '1' after 5 ns; 
        when addiho => op_result <= std_logic_vector(signed(opa(15 downto 8)) + signed(opb(7 downto 0))) & opa(7 downto 0) after 5 ns; 
            update_flag <= '1' after 5 ns; 
        when others => null; 
    end case; 
end process alu;

-- flag generation: 
flag_gen: process(op_result) 
begin
    zflg <= '0' after 5 ns; -- default 
    if op_result = zero then 
        zflg <= '1' after 5 ns; -- combinational flag generation 
    end if;   
    nflg <= to_bit(op_result(data_width -1)) after 5 ns; 
end process flag_gen; 

--ex/mem pipeline register including conditional flag storage 
ex_mem_interface: process(reset,clk) 
begin
    if reset = '1' then
        op_result_mem <= (others=>'0') after 5 ns; 
        reg_mem <= (others=>'0') after 5 ns; 
        dest_mem <= (others=>'0') after 5 ns; 
        opc_mem <= nopo after 5 ns; 
        zflag <= '0' after 5 ns; 
        nflag <= '0' after 5 ns; 
    elsif clk='1' and clk'event then
        op_result_mem <= op_result after 5 ns; 
        reg_mem <= reg_b_ex after 5 ns; -- to store any other data 
        dest_mem <= dest_ex after 5 ns; 
        opc_mem <= opc_ex after 5 ns; 
        if update_flag = '1' then 
            zflag <= zflg after 5 ns; 
            nflag <= nflg after 5 ns; 
        end if; 
    end if; 
end process ex_mem_interface;
end Behavioral;
