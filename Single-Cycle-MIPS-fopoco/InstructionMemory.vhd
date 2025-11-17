library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
	port (
		Address     : in STD_LOGIC_VECTOR(31 downto 0);
		Instruction : out STD_LOGIC_VECTOR(31 downto 0)
	);
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    type Memory is array (0 to 15) of STD_LOGIC_VECTOR(31 downto 0);

    signal IMem : Memory := (
	    X"8C010000", -- 0: lw  $1, 0($0)       (Lê DMem[0])
	    X"8C020004", -- 1: lw  $2, 4($0)       (Lê DMem[1]) <-- CORRIGIDO
	    X"7C221800", -- 2: fadd.s $3,$1,$2
	    X"AC030008", -- 3: sw  $3, 8($0)       (Escreve em DMem[2]) <-- CORRIGIDO
	    X"7C222002", -- 4: fmul.s $4,$1,$2
	    X"AC04000C", -- 5: sw  $4, 12($0)      (Escreve em DMem[3]) <-- CORRIGIDO
	    X"08000006", -- 6: j 6 (Loop infinito para parar o PC)
	    X"00000000", -- 7
	    X"00000000", -- 8
	    X"00000000", -- 9
	    X"00000000", -- 10
	    X"00000000", -- 11
	    X"00000000", -- 12
	    X"00000000", -- 13
	    X"00000000", -- 14
	    X"00000000"  -- 15 (Último item não tem vírgula)
    );
begin

	process (Address)
        variable index : integer range 0 to 15;
	begin
        -- Converte o endereço de byte (PC) para um índice de palavra (array)
        index := TO_INTEGER(UNSIGNED(Address(5 downto 2)));
		Instruction <= IMem(index);
	end process;

end Behavioral;
