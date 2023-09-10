----------------------------------------------------------------------------------
-- Company: tum
-- Engineer: lijian 
-- 
-- Create Date: 2023/09/08 12:08:16
-- Design Name: dual ported block RAM    
-- Module Name: DP_BRAM - Behavioral
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

entity dp_bram is 
Port (clk :in bit ;
       -- instruction.memory inferface :
      pc_act :in unsigned (pc_address_width - 2 downto  0); -- 8bit
      i_id : out instruction_type ; --16bit
      --data memory interface :
      op_result_mem : in unsigned (data_address_width- 2 downto  0); --8 bit 
      reg_mem :in data_type; --16bit
      we : in bit;
      en : in bit;
      dout : out data_type 
       );
end DP_BRAM;

architecture rtl of DP_BRAM is
--hochste address des speichers :2hoch9 - 1 = 511:
type ram_type is array (0 to 2**(pc_address_width + 1)-1) of instruction_type; --2 hoch 9 -1 =512-1=511/array indices form 0 to 511/instruktion type 16 bit 
signal i_addr, d_addr : unsigned(8 downto 0); --effektive addressen
signal myram: ram_type :=
(x"4911", x"4A22", x"4B33", x"4C44", x"4D55", x"6820", x"0000", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"0B70", x"0000", x"0000", x"1374", x"0000", x"0000", x"6840", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"16AC", x"0000", x"7005", x"0F28", x"0000", x"0000", x"0000", x"6860", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
 x"6120", x"5A20", x"0000", x"0000", x"6864", x"1248", x"0000", x"0000", 
 others => (x"0000")
);

attribute ram_style :string;
attribute ram_style of myram :signal is "distributed"; --dpram architektur 
begin
--eff.addresse nebenlauefig berechnen
i_addr <= '0' & pc_act;
d_addr <= '1' & op_result_mem(7 downto 0);

--instruktionsspeicher bei steigender flanke
p1 : process (clk)
begin
    if clk'event and clk = '1' then
        i_id <= myram(to_integer(i_addr)) after 5 ns;
    end if;
end process p1;

--datenspeicher bei fallender flanke
p2: process(CLK)
begin
    if clk'event and clk = '0' then --write first modus
        if en = '1' then
            if we = '1' then
                myram(TO_INTEGER (d_addr)) <= reg_mem after 5 ns;
            else
                dout <= myram(TO_INTEGER (d_addr)) after 5ns;
            end if;
        end if;
    end if;
end process p2;    
end rtl;





