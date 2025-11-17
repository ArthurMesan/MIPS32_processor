LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_MIPSProcessor IS
END tb_MIPSProcessor;

ARCHITECTURE behavior OF tb_MIPSProcessor IS

    COMPONENT MIPSProcessor
    PORT(
         CLK : IN  std_logic;
         Reset : IN std_logic;
         -- Novas saídas de debug (não usadas neste TB)
         Debug_WB_En   : OUT std_logic;
         Debug_WB_Reg  : OUT std_logic_vector(4 downto 0);
         Debug_WB_Data : OUT std_logic_vector(31 downto 0);
         Debug_PC      : OUT std_logic_vector(31 downto 0)
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
                    Reset => Reset,
                    Debug_WB_En => open,
                    Debug_WB_Reg => open,
                    Debug_WB_Data => open,
                    Debug_PC => open
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
            wait; -- Se stop_clock for true, pare o clock
        end if;
   end process;


   -- Stimulus process
   stim_proc: process
   begin

		Reset <= '1';
		wait for 10 ns;
		Reset <= '0';
		wait for 100 ns; -- Deixa o processador rodar por 100ns

      -- Simulação termina aqui
      stop_clock <= true; -- Manda o clock parar
      wait for 1 ns; -- Espera o clock parar

      -- Isso vai parar o "run -all"
      assert false report "Simulacao finalizada com sucesso." severity failure;

   end process;

END;
