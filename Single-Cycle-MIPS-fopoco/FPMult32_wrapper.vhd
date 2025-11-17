library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Wrapper para FPMult_8_23_8_23_8_23_uid2_F400_uid3 do FloPoCo
-- Converte 2x 32-bit IEEE-754 em 34-bit ("00" & word) e retorna 32-bit (descarta exceções).
-- Handshake: Start (pulso) -> Ready (pulso após LAT=1 ciclo).

entity FPMult32_wrapper is
  port (
    CLK   : in  STD_LOGIC;
    Start : in  STD_LOGIC; -- pulso de 1 ciclo para iniciar
    A     : in  STD_LOGIC_VECTOR(31 downto 0);
    B     : in  STD_LOGIC_VECTOR(31 downto 0);
    R     : out STD_LOGIC_VECTOR(31 downto 0);
    Ready : out STD_LOGIC
  );
end FPMult32_wrapper;

architecture Behavioral of FPMult32_wrapper is
  -- Componente gerado pelo FloPoCo (nome extraído do .vhdl gerado)
  component FPMult_8_23_8_23_8_23_uid2_F400_uid3 is
    port (
      clk : in std_logic;
      X   : in std_logic_vector(8+23+2 downto 0);
      Y   : in std_logic_vector(8+23+2 downto 0);
      R   : out std_logic_vector(8+23+2 downto 0)
    );
  end component;

  constant LATENCY : integer := 1; -- conforme log do FloPoCo

  signal a_reg, b_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
  signal x34, y34     : STD_LOGIC_VECTOR(33 downto 0) := (others => '0');
  signal r34          : STD_LOGIC_VECTOR(33 downto 0);

  signal busy    : STD_LOGIC := '0';
  signal counter : integer range 0 to LATENCY := 0;
  signal ready_i : STD_LOGIC := '0';

begin
  x34 <= "01" & a_reg;
  y34 <= "01" & b_reg;

  U_MUL: FPMult_8_23_8_23_8_23_uid2_F400_uid3
    port map (
      clk => CLK,
      X   => x34,
      Y   => y34,
      R   => r34
    );

  R     <= r34(31 downto 0);
  Ready <= ready_i;

  process(CLK)
  begin
    if rising_edge(CLK) then
      ready_i <= '0';
      if Start = '1' and busy = '0' then
        a_reg <= A;
        b_reg <= B;
        busy <= '1';
        counter <= 1;
      elsif busy = '1' then
        if counter = LATENCY then
          ready_i <= '1';
          busy <= '0';
          counter <= 0;
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process;

end Behavioral;
