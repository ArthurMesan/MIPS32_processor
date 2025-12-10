library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_PipelineRegisters is
end tb_PipelineRegisters;

architecture behavior of tb_PipelineRegisters is

    -- Componente sob teste (PipeReg_ID_EX)
    component PipeReg_ID_EX is
        port (
            CLK, Reset : in STD_LOGIC;
            RegWrite_In, MemtoReg_In, MemRead_In, MemWrite_In, ALUSrc_In, RegDst_In : in STD_LOGIC;
            ALUOp_In : in STD_LOGIC_VECTOR(1 downto 0); isFP_In : in STD_LOGIC;
            PC4_In, ReadData1_In, ReadData2_In, SignExt_In : in STD_LOGIC_VECTOR(31 downto 0);
            RS_In, RT_In, RD_In : in STD_LOGIC_VECTOR(4 downto 0);
            -- Saídas (Simplificadas para o teste)
            RegWrite_Out : out STD_LOGIC;
            ReadData1_Out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Sinais
    signal CLK, Reset : std_logic := '0';
    signal stop_clock : boolean := false; -- Sinal para parar o clock

    -- Entradas de Teste
    signal RegWrite_In : std_logic := '0';
    signal ReadData1_In : std_logic_vector(31 downto 0) := (others => '0');

    -- Saídas Observadas
    signal RegWrite_Out : std_logic;
    signal ReadData1_Out : std_logic_vector(31 downto 0);

    constant CLK_period : time := 10 ns;

begin

    uut: PipeReg_ID_EX port map (
        CLK => CLK, Reset => Reset,
        RegWrite_In => RegWrite_In, MemtoReg_In => '0', MemRead_In => '0', MemWrite_In => '0',
        ALUSrc_In => '0', RegDst_In => '0', ALUOp_In => "00", isFP_In => '0',
        PC4_In => (others => '0'), ReadData1_In => ReadData1_In, ReadData2_In => (others => '0'),
        SignExt_In => (others => '0'), RS_In => (others => '0'), RT_In => (others => '0'), RD_In => (others => '0'),
        RegWrite_Out => RegWrite_Out, ReadData1_Out => ReadData1_Out
    );

    -- Processo de Clock com Parada Segura
    clk_process : process
    begin
        while not stop_clock loop
            CLK <= '0'; wait for CLK_period/2;
            CLK <= '1'; wait for CLK_period/2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        -- 1. Teste de Reset
        Reset <= '1';
        RegWrite_In <= '1';
        ReadData1_In <= X"AAAAAAAA";
        wait for 20 ns;
        Reset <= '0';

        wait for 1 ns; -- Pequeno delta para estabilizar
        -- O registrador deve estar zerado após reset
        if ReadData1_Out /= X"00000000" then
            report "FALHA: Reset nao funcionou!" severity error;
        else
            report "SUCESSO: Reset OK";
        end if;

        -- 2. Teste de Escrita Normal
        wait for CLK_period;
        -- Na borda de subida, o dado AAAAAAAA deve passar
        if ReadData1_Out /= X"AAAAAAAA" then
            report "FALHA: Escrita nao funcionou! Esperado AAAAAAAA, recebido " & to_hstring(ReadData1_Out) severity error;
        else
            report "SUCESSO: Escrita OK";
        end if;

        -- 3. Mudança de dado
        ReadData1_In <= X"BBBBBBBB";
        wait for CLK_period;
        if ReadData1_Out /= X"BBBBBBBB" then
            report "FALHA: Atualizacao nao funcionou!" severity error;
        else
            report "SUCESSO: Atualizacao OK";
        end if;

        report "--- FIM DO TESTE DE REGISTRADORES ---";

        -- Para o clock e encerra a simulação
        stop_clock <= true;
        wait for 1 ns;
        assert false report "Simulacao finalizada com sucesso." severity failure;
        wait;
    end process;

end behavior;
