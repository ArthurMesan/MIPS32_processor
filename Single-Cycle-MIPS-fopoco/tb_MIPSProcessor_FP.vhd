library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MIPSProcessor_FP is
end tb_MIPSProcessor_FP;

architecture behavior of tb_MIPSProcessor_FP is
  component MIPSProcessor is
    port (
      CLK   : in  std_logic;
      Reset : in  std_logic;
      Debug_WB_En   : out std_logic;
      Debug_WB_Reg  : out std_logic_vector(4 downto 0);
      Debug_WB_Data : out std_logic_vector(31 downto 0);
      Debug_PC      : out std_logic_vector(31 downto 0)
    );
  end component;

  signal CLK         : std_logic := '0';
  signal Reset       : std_logic := '0';
  signal Debug_WB_En   : std_logic;
  signal Debug_WB_Reg  : std_logic_vector(4 downto 0);
  signal Debug_WB_Data : std_logic_vector(31 downto 0);
  signal Debug_PC      : std_logic_vector(31 downto 0);

  constant CLK_period : time := 10 ns;

  signal seen_add : boolean := false;
  signal seen_mul : boolean := false;

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

  -- clock
  clk_process: process
  begin
    CLK <= '0'; wait for CLK_period/2;
    CLK <= '1'; wait for CLK_period/2;
  end process;

  -- monitor writebacks and assert expected FP results
  monitor: process(CLK)
  begin
    if rising_edge(CLK) then
      if Debug_WB_En = '1' then
        if Debug_WB_Reg = "00011" then -- $3
          assert Debug_WB_Data = x"40600000"
            report "FADD.S result mismatch: expected 0x40600000 (3.5f), got " & to_hstring(Debug_WB_Data)
            severity failure;
          seen_add <= true;
        elsif Debug_WB_Reg = "00100" then -- $4
          assert Debug_WB_Data = x"40400000"
            report "FMUL.S result mismatch: expected 0x40400000 (3.0f), got " & to_hstring(Debug_WB_Data)
            severity failure;
          seen_mul <= true;
        end if;
      end if;

      if seen_add and seen_mul then
        assert false report "FP test passed (add=3.5, mul=3.0)" severity failure;
      end if;
    end if;
  end process;

  -- stimulus
  stim: process
  begin
    Reset <= '1';
    wait for 20 ns;
    Reset <= '0';

    -- safety timeout
    wait for 2 us;
    assert false report "Timeout: FP test did not complete in time" severity failure;
  end process;

end behavior;
