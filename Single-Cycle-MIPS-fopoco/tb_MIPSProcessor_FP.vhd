library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MIPSProcessor_FP is
end tb_MIPSProcessor_FP;

architecture behavior of tb_MIPSProcessor_FP is

  -- Componente do Processador (UUT)
  component MIPSProcessor is
    port (
      CLK           : in  std_logic;
      Reset         : in  std_logic;
      Debug_WB_En   : out std_logic;
      Debug_WB_Reg  : out std_logic_vector(4 downto 0);
      Debug_WB_Data : out std_logic_vector(31 downto 0);
      Debug_PC      : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Sinais
  signal CLK           : std_logic := '0';
  signal Reset         : std_logic := '0';
  signal Debug_WB_En   : std_logic;
  signal Debug_WB_Reg  : std_logic_vector(4 downto 0);
  signal Debug_WB_Data : std_logic_vector(31 downto 0);
  signal Debug_PC      : std_logic_vector(31 downto 0);

  -- Controle de Simulação
  signal stop_clock    : boolean := false;
  constant CLK_period  : time := 10 ns; -- 100 MHz

begin

  -- Instância do Processador
  uut: MIPSProcessor
    port map (
      CLK => CLK,
      Reset => Reset,
      Debug_WB_En => Debug_WB_En,
      Debug_WB_Reg => Debug_WB_Reg,
      Debug_WB_Data => Debug_WB_Data,
      Debug_PC => Debug_PC
    );

  -- Processo de Clock (com parada controlada)
  clk_process: process
  begin
    while not stop_clock loop
      CLK <= '0';
      wait for CLK_period/2;
      CLK <= '1';
      wait for CLK_period/2;
    end loop;
    wait; -- Trava o processo quando stop_clock for true
  end process;

  -- Processo de Monitoramento (Apenas imprime o que está acontecendo)
  monitor: process(CLK)
  begin
    if rising_edge(CLK) then
      if Debug_WB_En = '1' then
        -- Imprime no console sempre que houver uma escrita em registrador
        report "WriteBack -> Reg: " & integer'image(to_integer(unsigned(Debug_WB_Reg))) &
               " Data: " & to_hstring(Debug_WB_Data);

        -- Verificações opcionais (apenas avisam, não param a simulação)
        if Debug_WB_Reg = "00011" then -- $3
            if Debug_WB_Data = x"40600000" then
                report "SUCESSO: Soma (3.5) calculada corretamente!";
            else
                report "ERRO: Soma incorreta. Esperado 3.5, recebido: " & to_hstring(Debug_WB_Data) severity warning;
            end if;
        elsif Debug_WB_Reg = "00100" then -- $4
            if Debug_WB_Data = x"40400000" then
                report "SUCESSO: Multiplicacao (3.0) calculada corretamente!";
            else
                report "ERRO: Mult incorreta. Esperado 3.0, recebido: " & to_hstring(Debug_WB_Data) severity warning;
            end if;
        end if;
      end if;
    end if;
  end process;

  -- Processo de Estímulo (Sua estrutura adaptada)
  stim_proc: process
  begin
    -- 1. Reset Inicial (Fundamental para limpar os 'X')
    Reset <= '1';
    wait for 40 ns; -- 4 ciclos de clock para garantir o reset da FSM e Memórias
    Reset <= '0';

    -- 2. Execução
    -- Deixamos rodar por tempo suficiente para instruções FP (que têm latência)
    -- LW (1) + LW (1) + FADD (8+1) + SW (1) + FMUL (1+1) + SW (1) ~= 20 ciclos = 200ns
    -- Deixamos 400ns para ter folga.
    wait for 400 ns;

    -- 3. Finalização
    stop_clock <= true; -- Manda o clock parar
    wait for 1 ns;      -- Espera o clock parar

    -- Encerra a simulação forçadamente com mensagem de sucesso
    assert false report "FIM DA SIMULACAO (Tempo esgotado conforme planejado)." severity failure;

    wait;
  end process;

end behavior;
