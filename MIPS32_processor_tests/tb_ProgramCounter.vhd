library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all; -- <--- CORREÇÃO 1: Adicionar biblioteca 'env'

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
    -- CORREÇÃO 2: Inicializar pc_in para evitar 'XXX'
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
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;
        -- (Agora pc_in é '0', então a primeira carga no clock será '0')
        assert(pc_out = x"00000000") report "Reset failed" severity error;

        -- Test loading values
        pc_in <= x"00000004";
        wait for CLK_PERIOD;
        assert(pc_out = x"00000004") report "PC load 1 failed" severity error;

        pc_in <= x"00000008";
        wait for CLK_PERIOD;
        assert(pc_out = x"00000008") report "PC load 2 failed" severity error;

        report "ProgramCounter test finished successfully.";
        std.env.finish; -- <--- CORREÇÃO 1: Finalizar a simulação
    end process;
end testbench;
