library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Necessário para '+' e 'unsigned'
use std.env.all;

entity tb_ProgramCounter is
end tb_ProgramCounter;

architecture testbench of tb_ProgramCounter is
    component ProgramCounter is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               pc_in : in STD_LOGIC_VECTOR (31 downto 0);
               pc_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal clk, reset : STD_LOGIC := '0';
    signal pc_in, pc_out : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: ProgramCounter port map (
        clk => clk,
        reset => reset,
        pc_in => pc_in,
        pc_out => pc_out
    );

    -- Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Test reset
        reset <= '1';
        pc_in <= (others => 'X'); -- Não importa durante o reset
        wait for CLK_PERIOD;

        reset <= '0';
        pc_in <= (others => '0'); -- Valor inicial após o reset
        wait for CLK_PERIOD; -- Primeira borda de clock após o reset
        assert(pc_out = x"00000000") report "Reset failed" severity error;

        -- Teste 1: Simular PC + 4 (vai de 0 para 4)
        -- Simula a ALU calculando pc_out + 4 e enviando para pc_in
        pc_in <= std_logic_vector(unsigned(pc_out) + 4);
        wait for CLK_PERIOD; -- Borda de clock
        assert(pc_out = x"00000004") report "PC+4 (de 0 para 4) failed" severity error;

        -- Teste 2: Simular PC + 4 (vai de 4 para 8)
        pc_in <= std_logic_vector(unsigned(pc_out) + 4);
        wait for CLK_PERIOD; -- Borda de clock
        assert(pc_out = x"00000008") report "PC+4 (de 4 para 8) failed" severity error;

        -- Teste 3: Simular PC + 4 (vai de 8 para C)
        pc_in <= std_logic_vector(unsigned(pc_out) + 4);
        wait for CLK_PERIOD; -- Borda de clock
        assert(pc_out = x"0000000C") report "PC+4 (de 8 para C) failed" severity error;

        report "ProgramCounter (PC+4 test) finished successfully.";
        std.env.finish; -- Finaliza a simulação
    end process;
end testbench;
