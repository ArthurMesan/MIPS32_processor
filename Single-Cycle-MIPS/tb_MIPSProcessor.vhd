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
   constant CLK_period : time := 10 ns;

   -- Sinal para parar o clock
   signal stop_clock : boolean := false;
BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: MIPSProcessor PORT MAP (
          CLK => CLK,
          Reset => Reset
        );

   -- Clock process definitions (agora pode parar)
   CLK_process :process
   begin
        if not stop_clock then
            CLK <= '0';
            wait for CLK_period/2;
            CLK <= '1';
            wait for CLK_period/2;
        else
            wait;
        end if;
   end process;

   -- Stimulus process
   stim_proc: process
   begin

		Reset <= '1';
		wait for 10 ns;
		Reset <= '0';

        -- --- MODIFICADO ---
        -- Deixa o processador rodar por 500ns (50 ciclos)
        -- O original (100 ns) não era suficiente
        -- para testar uma instrução multi-ciclo.
		wait for 500 ns;

      -- Simulação termina aqui
      stop_clock <= true;
      wait for 1 ns;

      -- Isso vai parar o "run -all"
      assert false report "Simulacao finalizada com sucesso."
      severity failure;

   end process;

END;
