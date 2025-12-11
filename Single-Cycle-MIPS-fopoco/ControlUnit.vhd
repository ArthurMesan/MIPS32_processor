library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    port (
          Opcode    : in  STD_LOGIC_VECTOR (5 downto 0);
          RegDst    : out  STD_LOGIC;
          Jump      : out  STD_LOGIC;
          Branch_E  : out  STD_LOGIC;
          Branch_NE : out  STD_LOGIC;
          MemRead   : out  STD_LOGIC;
          MemtoReg  : out  STD_LOGIC;
          ALUOp     : out  STD_LOGIC_VECTOR (1 downto 0);
          MemWrite  : out  STD_LOGIC;
          ALUSrc    : out  STD_LOGIC;
          RegWrite  : out  STD_LOGIC
     );
end ControlUnit;

architecture Behavioral of ControlUnit is

begin

    process (Opcode)
    begin
        case Opcode is
            when "000000" => -- R-type commands (ADD, SUB, AND, OR, SLT)
                RegDst    <= '1';
                Jump      <= '0';
                Branch_E  <= '0';
                Branch_NE <= '0';
                MemRead   <= '0';
                MemtoReg  <= '0';
                ALUOp     <= "10";
                MemWrite  <= '0';
                ALUSrc    <= '0';
                RegWrite  <= '1';

            -- ADICIONADO: Floating Point (COP1 - Opcode 011111)
            -- FADD.S, FMUL.S, etc. se comportam como R-Type para o pipeline
            when "011111" => 
                RegDst    <= '1'; -- Destino é rd (bits 15-11)
                Jump      <= '0';
                Branch_E  <= '0';
                Branch_NE <= '0';
                MemRead   <= '0';
                MemtoReg  <= '0'; -- Dado vem da ALU/FPU
                ALUOp     <= "00"; -- ALUOp irrelevante para FPU (controlada por funct)
                MemWrite  <= '0';
                ALUSrc    <= '0'; -- Operando B é registrador
                RegWrite  <= '1'; -- HABILITA ESCRITA!

            when "100011" => -- lw
                RegDst    <= '0';
                Jump      <= '0';
                Branch_E  <= '0';
                Branch_NE <= '0';
                MemRead   <= '1';
                MemtoReg  <= '1';
                ALUOp     <= "00";
                MemWrite  <= '0';
                ALUSrc    <= '1';
                RegWrite  <= '1';
            when "101011" => -- sw
                RegDst    <= 'X';
                Jump      <= '0';
                Branch_E  <= '0';
                Branch_NE <= '0';
                MemRead   <= '0';
                MemtoReg  <= 'X';
                ALUOp     <= "00";
                MemWrite  <= '1';
                ALUSrc    <= '1';
                RegWrite  <= '0';
            when "000100" => -- beq
                RegDst    <= 'X';
                Jump      <= '0';
                Branch_E  <= '1';
                Branch_NE <= '0';
                MemRead   <= '0';
                MemtoReg  <= 'X';
                ALUOp     <= "01";
                MemWrite  <= '0';
                ALUSrc    <= '0';
                RegWrite  <= '0';
            when "000101" => -- bne
                RegDst    <= 'X';
                Jump      <= '0';
                Branch_E  <= '0';
                Branch_NE <= '1';
                MemRead   <= '0';
                MemtoReg  <= 'X';
                ALUOp     <= "01";
                MemWrite  <= '0';
                ALUSrc    <= '0';
                RegWrite  <= '0';
            when "000010" => -- j
                RegDst    <= 'X';
                Jump      <= '1';
                Branch_E  <= '0';
                Branch_NE <= '0';
                MemRead   <= '0';
                MemtoReg  <= 'X';
                ALUOp     <= "00";
                MemWrite  <= '0';
                ALUSrc    <= '0';
                RegWrite  <= '0';
            when others => 
                RegDst    <= '0';
                Jump      <= '0';
                Branch_E  <= '0';
                Branch_NE <= '0';
                MemRead   <= '0';
                MemtoReg  <= '0';
                ALUOp     <= "00";
                MemWrite  <= '0';
                ALUSrc    <= '0';
                RegWrite  <= '0';
        end case;
    end process;

end Behavioral;