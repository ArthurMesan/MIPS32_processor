library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ALUControlUnit is
end tb_ALUControlUnit;

architecture testbench of tb_ALUControlUnit is
    component ALUControlUnit is
        Port ( ALUOp : in  STD_LOGIC_VECTOR (1 downto 0);
               funct : in  STD_LOGIC_VECTOR (5 downto 0);
               ALUControl : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
    signal funct : STD_LOGIC_VECTOR(5 downto 0);
    signal ALUControl : STD_LOGIC_VECTOR(3 downto 0);
begin
    uut: ALUControlUnit port map (ALUOp=>ALUOp, funct=>funct, ALUControl=>ALUControl);

    stim_proc: process
    begin
        -- Test for lw/sw
        ALUOp <= "00"; funct <= "XXXXXX"; wait for 10 ns;
        assert(ALUControl = "0000") report "lw/sw ALUControl failed" severity error;

        -- Test for beq
        ALUOp <= "01"; funct <= "XXXXXX"; wait for 10 ns;
        assert(ALUControl = "0001") report "beq ALUControl failed" severity error;

        -- Test for R-type add
        ALUOp <= "10"; funct <= "100000"; wait for 10 ns;
        assert(ALUControl = "0000") report "R-type add failed" severity error;

        -- Test for R-type sub
        ALUOp <= "10"; funct <= "100010"; wait for 10 ns;
        assert(ALUControl = "0001") report "R-type sub failed" severity error;

        report "ALUControlUnit test finished successfully.";
        wait;
    end process;
end testbench;
