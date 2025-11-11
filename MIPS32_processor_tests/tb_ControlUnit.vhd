library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ControlUnit is
end tb_ControlUnit;

architecture testbench of tb_ControlUnit is
    component ControlUnit is
        Port ( opcode : in  STD_LOGIC_VECTOR (5 downto 0);
               RegWrite : out STD_LOGIC; MemRead : out STD_LOGIC; MemWrite : out STD_LOGIC;
               MemtoReg : out STD_LOGIC; ALUSrc : out STD_LOGIC; RegDst : out STD_LOGIC;
               Branch : out STD_LOGIC; ALUOp : out STD_LOGIC_VECTOR (1 downto 0));
    end component;

    signal opcode : STD_LOGIC_VECTOR(5 downto 0);
    signal RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst, Branch : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
begin
    uut: ControlUnit port map (opcode=>opcode, RegWrite=>RegWrite, MemRead=>MemRead, MemWrite=>MemWrite, MemtoReg=>MemtoReg, ALUSrc=>ALUSrc, RegDst=>RegDst, Branch=>Branch, ALUOp=>ALUOp);

    stim_proc: process
    begin
        -- Test R-type
        opcode <= "000000"; wait for 10 ns;
        assert(RegDst='1' and ALUSrc='0' and MemtoReg='0' and RegWrite='1' and MemRead='0' and MemWrite='0' and Branch='0' and ALUOp="10") report "R-type failed" severity error;

        -- Test lw
        opcode <= "100011"; wait for 10 ns;
        assert(RegDst='0' and ALUSrc='1' and MemtoReg='1' and RegWrite='1' and MemRead='1' and MemWrite='0' and Branch='0' and ALUOp="00") report "lw failed" severity error;

        -- Test sw
        opcode <= "101011"; wait for 10 ns;
        assert(ALUSrc='1' and RegWrite='0' and MemWrite='1' and Branch='0' and ALUOp="00") report "sw failed" severity error;

        -- Test beq
        opcode <= "000100"; wait for 10 ns;
        assert(ALUSrc='0' and RegWrite='0' and Branch='1' and ALUOp="01") report "beq failed" severity error;

        -- Test addi
        opcode <= "001000"; wait for 10 ns;
        assert(RegDst='0' and ALUSrc='1' and RegWrite='1' and ALUOp="00") report "addi failed" severity error;

        report "ControlUnit test finished successfully.";
        wait;
    end process;
end testbench;
