----------------------------------------------------------------------------------
--lijian 27.07.2023 munich

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
package RSIC_pack is
--list of instructions 
type OPCODE_TYPE is (nopo,addo,subo,ando,oro,xoro,also,srao,mvo,addilo,addiho,ldi,sto,jmpo,bne,blt,bgeo);
constant DATA_WIDTH :natural:=16;
constant INSTRUCTION_WIDTH :natural:=16;
constant OPCODE_WIDTH :natural :=5;
constant REGISTER_ADDRESS_WIDTH : natural:= 3;
constant REGISTER_COUNT:natural:=8;
constant PC_ADDRESS_WIDTH :natural :=8;
constant DATA_ADDRESS_WIDTH:natural :=9;--including memory mapped i/o

subtype DATA_TYPE is std_logic_vector(DATA_WIDTH - 1 downto 0);
subtype INSTRUCTION_TYPE is std_logic_vector(INSTRUCTION_WIDTH - 1 downto 0);
subtype PC_ADDRESS_TYPE is unsigned (PC_ADDRESS_WIDTH-1 downto 0 );
subtype DATA_ADDRESS_TYPE is unsigned (DATA_ADDRESS_WIDTH - 1 downto 0);
subtype REGISTER_ADDRESS_TYPE is bit_vector (REGISTER_ADDRESS_WIDTH - 1 downto 0);

type register_fil_type is array(0 to register_count-1) of DATA_TYPE;

--function protopytes 
function Zreo_ext (INP : std_logic_vector ;L: natural )return 
                                                       std_logic_vector ;
                            
function Sign_ext ( INP :std_logic_vector; L: natural )return 
                                                       std_logic_vector ;
end RSIC_pack;

package body RSIC_pack is 
--zero extension input to L bits (L must be larger than INP'length):
function  Zero_ext (INP :std_logic_vector; L :natural )return
std_logic_vector is 
variable RESULT :std_logic_vector(L -1 downto 0);
begin   
       RESULT(INP'length -1 downto 0):=INP;
       for J in L-1 downto INP'length loop
       
        
                                                       
                                                       


 









