library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PipeReg_ID_EX is
    port (
        CLK          : in  STD_LOGIC;
        Reset        : in  STD_LOGIC;
        En           : in  STD_LOGIC; -- Porta Essencial para o Stall

        -- Controle
        RegWrite_In, MemtoReg_In, MemRead_In, MemWrite_In, ALUSrc_In, RegDst_In : in STD_LOGIC;
        ALUOp_In     : in STD_LOGIC_VECTOR(1 downto 0);
        isFP_In      : in STD_LOGIC;

        -- Dados
        PC4_In, ReadData1_In, ReadData2_In, SignExt_In : in STD_LOGIC_VECTOR(31 downto 0);
        RS_In, RT_In, RD_In : in STD_LOGIC_VECTOR(4 downto 0);

        -- Saídas
        RegWrite_Out, MemtoReg_Out, MemRead_Out, MemWrite_Out, ALUSrc_Out, RegDst_Out : out STD_LOGIC;
        ALUOp_Out    : out STD_LOGIC_VECTOR(1 downto 0);
        isFP_Out     : out STD_LOGIC;

        PC4_Out, ReadData1_Out, ReadData2_Out, SignExt_Out : out STD_LOGIC_VECTOR(31 downto 0);
        RS_Out, RT_Out, RD_Out : out STD_LOGIC_VECTOR(4 downto 0)
    );
end PipeReg_ID_EX;

architecture Behavioral of PipeReg_ID_EX is
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            -- Reset Síncrono: Zera tudo
            RegWrite_Out <= '0'; MemtoReg_Out <= '0'; MemRead_Out <= '0'; MemWrite_Out <= '0';
            ALUSrc_Out <= '0'; RegDst_Out <= '0'; ALUOp_Out <= (others => '0'); isFP_Out <= '0';
            PC4_Out <= (others => '0'); ReadData1_Out <= (others => '0');
            ReadData2_Out <= (others => '0'); SignExt_Out <= (others => '0');
            RS_Out <= (others => '0'); RT_Out <= (others => '0'); RD_Out <= (others => '0');

        elsif rising_edge(CLK) then
            if En = '1' then -- Só atualiza se não estiver em Stall
                RegWrite_Out <= RegWrite_In; MemtoReg_Out <= MemtoReg_In;
                MemRead_Out <= MemRead_In; MemWrite_Out <= MemWrite_In;
                ALUSrc_Out <= ALUSrc_In; RegDst_Out <= RegDst_In;
                ALUOp_Out <= ALUOp_In; isFP_Out <= isFP_In;
                PC4_Out <= PC4_In; ReadData1_Out <= ReadData1_In;
                ReadData2_Out <= ReadData2_In; SignExt_Out <= SignExt_In;
                RS_Out <= RS_In; RT_Out <= RT_In; RD_Out <= RD_In;
            end if;
        end if;
    end process;
end Behavioral;
