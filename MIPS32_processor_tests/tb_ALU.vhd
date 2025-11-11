library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ALU is
end tb_ALU;

architecture testbench of tb_ALU is
    component ALU is
        Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
               B : in STD_LOGIC_VECTOR (31 downto 0);
               ALUControl : in STD_LOGIC_VECTOR (3 downto 0);
               Result : out STD_LOGIC_VECTOR (31 downto 0);
               Zero : out STD_LOGIC);
    end component;

    signal A, B, Result : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUControl : STD_LOGIC_VECTOR(3 downto 0);
    signal Zero : STD_LOGIC;
begin
    uut: ALU port map (A => A, B => B, ALUControl => ALUControl, Result => Result, Zero => Zero);

    stim_proc: process
    begin
        -- Test ADD
        A <= x"00000005"; B <= x"0000000A"; ALUControl <= "0000";
        wait for 10 ns;
        assert(Result = x"0000000F") report "ADD failed" severity error;
        assert(Zero = '0') report "Zero flag failed for ADD" severity error;

        -- Test SUB and Zero flag
        A <= x"00000005"; B <= x"00000005"; ALUControl <= "0001";
        wait for 10 ns;
        assert(Result = x"00000000") report "SUB failed" severity error;
        assert(Zero = '1') report "Zero flag failed for SUB" severity error;

        -- Test AND
        A <= x"FFFF0000"; B <= x"0000FFFF"; ALUControl <= "0010";
        wait for 10 ns;
        assert(Result = x"00000000") report "AND failed" severity error;

        -- Test OR
        A <= x"FFFF0000"; B <= x"0000FFFF"; ALUControl <= "0011";
        wait for 10 ns;
        assert(Result = x"FFFFFFFF") report "OR failed" severity error;

        report "ALU test finished successfully.";
        wait;
    end process;
end testbench;
