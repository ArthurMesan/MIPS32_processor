library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PipeReg_IF_ID is
    port (
        CLK         : in  STD_LOGIC;
        Reset       : in  STD_LOGIC;
        En          : in  STD_LOGIC; -- '1' = Normal, '0' = Stall (Congela)
        Flush       : in  STD_LOGIC; -- '1' = Zera a instrução (NOP)

        -- Entradas
        PC4_In      : in  STD_LOGIC_VECTOR(31 downto 0);
        Instr_In    : in  STD_LOGIC_VECTOR(31 downto 0);

        -- Saídas
        PC4_Out     : out STD_LOGIC_VECTOR(31 downto 0);
        Instr_Out   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end PipeReg_IF_ID;

architecture Behavioral of PipeReg_IF_ID is
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            PC4_Out   <= (others => '0');
            Instr_Out <= (others => '0');
        elsif rising_edge(CLK) then
            if En = '1' then
                if Flush = '1' then
                    Instr_Out <= (others => '0'); -- Injeta NOP
                    PC4_Out   <= (others => '0');
                else
                    PC4_Out   <= PC4_In;
                    Instr_Out <= Instr_In;
                end if;
            end if;
            -- Se En = '0', mantém o valor antigo (Stall)
        end if;
    end process;
end Behavioral;
