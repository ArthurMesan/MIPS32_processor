library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PipeReg_ID_EX is
    port (
        CLK          : in  STD_LOGIC;
        Reset        : in  STD_LOGIC;

        -- Sinais de Controle (Entrada)
        -- WB (Write Back)
        RegWrite_In  : in STD_LOGIC;
        MemtoReg_In  : in STD_LOGIC;
        -- MEM (Memory)
        MemRead_In   : in STD_LOGIC;
        MemWrite_In  : in STD_LOGIC;
        -- EX (Execute)
        ALUSrc_In    : in STD_LOGIC;
        RegDst_In    : in STD_LOGIC;
        ALUOp_In     : in STD_LOGIC_VECTOR(1 downto 0);
        -- Sinais FP (Se necessário passar adiante)
        isFP_In      : in STD_LOGIC;

        -- Dados (Entrada)
        PC4_In       : in STD_LOGIC_VECTOR(31 downto 0);
        ReadData1_In : in STD_LOGIC_VECTOR(31 downto 0);
        ReadData2_In : in STD_LOGIC_VECTOR(31 downto 0);
        SignExt_In   : in STD_LOGIC_VECTOR(31 downto 0);
        RS_In        : in STD_LOGIC_VECTOR(4 downto 0);
        RT_In        : in STD_LOGIC_VECTOR(4 downto 0);
        RD_In        : in STD_LOGIC_VECTOR(4 downto 0);

        -- SAÍDAS (Espelho das Entradas)
        RegWrite_Out : out STD_LOGIC;
        MemtoReg_Out : out STD_LOGIC;
        MemRead_Out  : out STD_LOGIC;
        MemWrite_Out : out STD_LOGIC;
        ALUSrc_Out   : out STD_LOGIC;
        RegDst_Out   : out STD_LOGIC;
        ALUOp_Out    : out STD_LOGIC_VECTOR(1 downto 0);
        isFP_Out     : out STD_LOGIC;

        PC4_Out      : out STD_LOGIC_VECTOR(31 downto 0);
        ReadData1_Out: out STD_LOGIC_VECTOR(31 downto 0);
        ReadData2_Out: out STD_LOGIC_VECTOR(31 downto 0);
        SignExt_Out  : out STD_LOGIC_VECTOR(31 downto 0);
        RS_Out       : out STD_LOGIC_VECTOR(4 downto 0);
        RT_Out       : out STD_LOGIC_VECTOR(4 downto 0);
        RD_Out       : out STD_LOGIC_VECTOR(4 downto 0)
    );
end PipeReg_ID_EX;

architecture Behavioral of PipeReg_ID_EX is
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            -- Zerar todos os controles críticos para evitar escritas indesejadas
            RegWrite_Out <= '0'; MemWrite_Out <= '0';
            ReadData1_Out <= (others => '0'); ReadData2_Out <= (others => '0');
            -- (Pode zerar o resto ou deixar, o importante é desativar WB e MEM)
        elsif rising_edge(CLK) then
            RegWrite_Out <= RegWrite_In; MemtoReg_Out <= MemtoReg_In;
            MemRead_Out  <= MemRead_In;  MemWrite_Out <= MemWrite_In;
            ALUSrc_Out   <= ALUSrc_In;   RegDst_Out   <= RegDst_In;
            ALUOp_Out    <= ALUOp_In;    isFP_Out     <= isFP_In;

            PC4_Out       <= PC4_In;
            ReadData1_Out <= ReadData1_In;
            ReadData2_Out <= ReadData2_In;
            SignExt_Out   <= SignExt_In;
            RS_Out        <= RS_In;
            RT_Out        <= RT_In;
            RD_Out        <= RD_In;
        end if;
    end process;
end Behavioral;
