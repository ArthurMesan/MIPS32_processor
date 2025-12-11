library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PipeReg_EX_MEM is
    port (
        CLK          : in  STD_LOGIC;
        Reset        : in  STD_LOGIC;
        En           : in  STD_LOGIC; -- ADICIONADO: Enable para Stall

        -- Controle
        RegWrite_In  : in STD_LOGIC;
        MemtoReg_In  : in STD_LOGIC;
        MemRead_In   : in STD_LOGIC;
        MemWrite_In  : in STD_LOGIC;

        -- Dados
        ALUResult_In : in STD_LOGIC_VECTOR(31 downto 0);
        WriteData_In : in STD_LOGIC_VECTOR(31 downto 0);
        WriteReg_In  : in STD_LOGIC_VECTOR(4 downto 0);

        -- Saídas
        RegWrite_Out : out STD_LOGIC;
        MemtoReg_Out : out STD_LOGIC;
        MemRead_Out  : out STD_LOGIC;
        MemWrite_Out : out STD_LOGIC;

        ALUResult_Out: out STD_LOGIC_VECTOR(31 downto 0);
        WriteData_Out: out STD_LOGIC_VECTOR(31 downto 0);
        WriteReg_Out : out STD_LOGIC_VECTOR(4 downto 0)
    );
end PipeReg_EX_MEM;

architecture Behavioral of PipeReg_EX_MEM is
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            RegWrite_Out <= '0'; MemWrite_Out <= '0';
            ALUResult_Out <= (others => '0');
            -- Resetar outros sinais para evitar lixo
            MemtoReg_Out <= '0'; MemRead_Out <= '0';
            WriteData_Out <= (others => '0'); WriteReg_Out <= (others => '0');
            
        elsif rising_edge(CLK) then
            -- Só atualiza se En = '1'
            if En = '1' then
                RegWrite_Out <= RegWrite_In;
                MemtoReg_Out <= MemtoReg_In;
                MemRead_Out  <= MemRead_In;
                MemWrite_Out <= MemWrite_In;

                ALUResult_Out <= ALUResult_In;
                WriteData_Out <= WriteData_In;
                WriteReg_Out  <= WriteReg_In;
            end if;
        end if;
    end process;
end Behavioral;