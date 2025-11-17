library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionMemory is
	port (
		Address     : in STD_LOGIC_VECTOR(31 downto 0);
		Instruction : out STD_LOGIC_VECTOR(31 downto 0)
	);
end InstructionMemory;

architecture Behavioral of InstructionMemory is
	type Memory is array (0 to 15) of STD_LOGIC_VECTOR(31 downto 0);

    -- --- MODIFICADO: Novo programa de teste para o FloPoCo ---
	signal IMem : Memory := (
        -- 0: lw $t0, 0($zero)  ($t0 = Reg 8. Carrega DMem[0])
		 X"8C080000",
        -- 1: lw $t1, 4($zero)  ($t1 = Reg 9. Carrega DMem[1])
		 X"8C090004",
        -- 2: fadd $t2, $t0, $t1 (CUSTOM OPCODE 010001)
        --    Op=010001, rs=01000($t0), rt=01001($t1), rd=01010($t2)
        --    Esta instrução irá acionar o STALL.
		 X"45095000",
        -- 3: nop (Esta instrução ficará "parada" no PC+4 por 8 ciclos)
		 X"00000000",
        -- 4: nop
		 X"00000000",
        -- 5: sw $t2, 8($zero)  ($t2 = Reg 10. Salva resultado em DMem[2])
		 X"AC0A0008",
        -- 6: j 6 (Loop infinito)
		 X"08000006",
		 X"00000000", -- 7
		 X"00000000", -- 8
		 X"00000000", -- 9
		 X"00000000", -- 10
		 X"00000000", -- 11
		 X"00000000", -- 12
		 X"00000000", -- 13
		 X"00000000", -- 14
		 X"00000000"  -- 15
	);
begin

	process (Address)
	begin
        -- Converte o endereço de byte (PC) para um índice de palavra (Memória)
		Instruction <= IMem(TO_INTEGER(UNSIGNED(Address(5 downto 2))));
	end process;

end Behavioral;
