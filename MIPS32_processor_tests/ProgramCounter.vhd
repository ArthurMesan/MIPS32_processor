library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ProgramCounter is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pc_in : in STD_LOGIC_VECTOR (31 downto 0);
           pc_out : out STD_LOGIC_VECTOR (31 downto 0));
end ProgramCounter;
architecture Behavioral of ProgramCounter is
signal pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            pc <= pc_in;
        end if;
    end process;
    pc_out <= pc;
end Behavioral;

-- Agulha que guia a execução do programa, isso ocorre manipulando o pc_in que armazena
-- o endereço de 32 bits da instrução atual.

-- O clock cordena o avanço para a proxima instrução.

-- Ele Controla o Fluxo do Programa O pc_in (a entrada) é conectado a um multiplexador
-- (Mux) que decide qual será o endereço da próxima instrução. Esse Mux escolhe entre:

-- PC + 4: A opção padrão. A ALU calcula o endereço atual (pc_out) + 4 (pois cada instrução
--MIPS tem 4 bytes) e o envia para o pc_in. Na próxima subida do clock, o PC "avança" para a instrução seguinte.

-- Endereço de Desvio (Branch): Se a instrução for um beq e a condição for verdadeira
-- (Flag Zero = 1), esse Mux seleciona o endereço de desvio (calculado pela ALU) e o
-- envia para o pc_in.
