library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
    Port ( address : in STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    -- Definimos uma ROM (Read Only Memory)
    type instruction_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);

    -- Pré-carregamos a memória com um programa de teste
    signal mem : instruction_array := (
        -- Programa:
        -- 0: addi $t0, $zero, 5   ($t0 = 5)
        0  => x"20080005",
        -- 4: addi $t1, $zero, 10  ($t1 = 10)
        1  => x"2009000A",
        -- 8: add $t2, $t0, $t1    ($t2 = $t0 + $t1 = 15)
        2  => x"01095020",
        -- 12: sw $t2, 0($zero)     (mem[0] = 15)
        3  => x"AC0A0000",
        -- 16: beq $zero, $zero, -1 (loop infinito para parar)
        4  => x"0400FFFF",

        -- O resto da memória é zero
        others => (others => '0')
    );
begin
    -- A leitura é combinacional (instantânea)
    -- Dividimos o endereço por 4 para usá-lo como índice do array
    instruction <= mem(to_integer(unsigned(address(9 downto 2))));

end Behavioral;
