library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MIPS_Pipeline is
end tb_MIPS_Pipeline;

architecture behavior of tb_MIPS_Pipeline is

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

  signal CLK           : std_logic := '0';
  signal Reset         : std_logic := '0';
  signal Debug_WB_En   : std_logic;
  signal Debug_WB_Reg  : std_logic_vector(4 downto 0);
  signal Debug_WB_Data : std_logic_vector(31 downto 0);
  signal Debug_PC      : std_logic_vector(31 downto 0);

  signal stop_clock    : boolean := false;
  constant CLK_period  : time := 10 ns;

begin

  uut: MIPSProcessor
    port map (
      CLK => CLK,
      Reset => Reset,
      Debug_WB_En => Debug_WB_En,
      Debug_WB_Reg => Debug_WB_Reg,
      Debug_WB_Data => Debug_WB_Data,
      Debug_PC => Debug_PC
    );

  clk_process: process
  begin
    while not stop_clock loop
      CLK <= '0'; wait for CLK_period/2;
      CLK <= '1'; wait for CLK_period/2;
    end loop;
    wait;
  end process;

  -- Monitoramento de Resultados no Pipeline
  monitor: process(CLK)
  begin
    if rising_edge(CLK) then
      if Debug_WB_En = '1' then
        report "WriteBack -> Reg: " & integer'image(to_integer(unsigned(Debug_WB_Reg))) &
               " Data: " & to_hstring(Debug_WB_Data) & " at PC=" & to_hstring(Debug_PC);
      end if;
    end if;
  end process;

  stim_proc: process
  begin
    -- 1. Reset do Pipeline
    Reset <= '1';
    wait for 50 ns;
    Reset <= '0';

    -- 2. Execução
    -- Esperamos um pouco mais (600ns) pois o pipeline + stalls da FPU levam tempo
    wait for 2000 ns;

    stop_clock <= true;
    wait for 1 ns;

    assert false report "FIM DA SIMULACAO PIPELINE." severity failure;
    wait;
  end process;

end behavior;
