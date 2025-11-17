LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_MIPSProcessor IS
END tb_MIPSProcessor;

ARCHITECTURE behavior OF tb_MIPSProcessor IS

    COMPONENT MIPSProcessor
    PORT(
         CLK : IN  std_logic;
         Reset : IN std_logic
        );
    END COMPONENT;

   --Inputs
   signal CLK : std_logic := '0';
   signal Reset : std_logic := '0';

   -- Clock period definitions
   constant CLK_period : time := 10 ns; [cite: 21]

   -- Sinal para parar o clock
   signal stop_clock : boolean := false; [cite: 22]
BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: MIPSProcessor PORT MAP (
          CLK => CLK,
          Reset => Reset
        ); [cite: 23]

   -- Clock process definitions (agora pode parar)
   CLK_process :process [cite: 24]
   begin
        if not stop_clock then
            CLK <= '0';
            wait for CLK_period/2; [cite: 25]
            CLK <= '1';
            wait for CLK_period/2;
        else
            wait; [cite: 26]
        end if;
   end process;

   -- Stimulus process
   stim_proc: process [cite: 27]
   begin

		Reset <= '1';
		wait for 10 ns;
		Reset <= '0';

        -- --- MODIFICADO ---
        -- Deixa o processador rodar por 500ns (50 ciclos)
        -- O original (100 ns) [cite: 28] não era suficiente
        -- para testar uma instrução multi-ciclo.
		wait for 500 ns;

      -- Simulação termina aqui
      stop_clock <= true; [cite: 29]
      wait for 1 ns; [cite: 30]

      -- Isso vai parar o "run -all"
      assert false report "Simulacao finalizada com sucesso."
      severity failure; [cite: 31]

   end process;

END;
