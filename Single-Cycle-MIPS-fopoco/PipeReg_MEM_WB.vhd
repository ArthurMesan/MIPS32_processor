library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PipeReg_MEM_WB is
    port (
        CLK          : in  STD_LOGIC;
        Reset        : in  STD_LOGIC;
        En           : in  STD_LOGIC; -- ADICIONADO: Enable para Stall

        -- Controle
        RegWrite_In  : in STD_LOGIC;
        MemtoReg_In  : in STD_LOGIC;

        -- Dados
        ReadData_In  : in STD_LOGIC_VECTOR(31 downto 0);
        ALUResult_In : in STD_LOGIC_VECTOR(31 downto 0);
        WriteReg_In  : in STD_LOGIC_VECTOR(4 downto 0);

        -- Saídas
        RegWrite_Out : out STD_LOGIC;
        MemtoReg_Out : out STD_LOGIC;

        ReadData_Out : out STD_LOGIC_VECTOR(31 downto 0);
        ALUResult_Out: out STD_LOGIC_VECTOR(31 downto 0);
        WriteReg_Out : out STD_LOGIC_VECTOR(4 downto 0)
    );
end PipeReg_MEM_WB;

architecture Behavioral of PipeReg_MEM_WB is
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            RegWrite_Out <= '0';
            ReadData_Out <= (others => '0');
            -- Resetar outros
            MemtoReg_Out <= '0';
            ALUResult_Out <= (others => '0');
            WriteReg_Out <= (others => '0');
            
        elsif rising_edge(CLK) then
            -- Só atualiza se En = '1'
            if En = '1' then
                RegWrite_Out <= RegWrite_In;
                MemtoReg_Out <= MemtoReg_In;

                ReadData_Out <= ReadData_In;
                ALUResult_Out<= ALUResult_In;
                WriteReg_Out <= WriteReg_In;
            end if;
        end if;
    end process;
end Behavioral;