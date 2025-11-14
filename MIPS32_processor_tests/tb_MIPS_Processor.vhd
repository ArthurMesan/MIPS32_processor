library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.all;

entity tb_MIPS_Processor is
end tb_MIPS_Processor;

architecture testbench of tb_MIPS_Processor is
    -- O único componente é o processador inteiro
    component MIPS_Processor is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC);
    end component;

    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';

    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instanciar o processador
    uut: MIPS_Processor port map (
        clk => clk,
        reset => reset
    );

    -- Gerador de Clock
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Processo de Estímulo
    stim_proc: process
    begin
        -- 1. Iniciar com o reset ligado
        reset <= '1';
        wait for CLK_PERIOD;

        -- 2. Soltar o reset e deixar o processador rodar
        reset <= '0';

        -- Deixar o programa rodar por 10 ciclos (o programa tem 5 instruções)
        wait for CLK_PERIOD * 10;

        -- 3. Parar a simulação
        report "Simulação do processador concluída.";
        std.env.finish;
    end process;

end testbench;
