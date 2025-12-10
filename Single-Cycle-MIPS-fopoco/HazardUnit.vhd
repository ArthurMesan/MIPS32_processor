library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HazardUnit is
    port (
        Rs_E, Rt_E, WriteReg_M, WriteReg_W : in STD_LOGIC_VECTOR(4 downto 0);
        RegWrite_M, RegWrite_W, fp_busy : in STD_LOGIC;
        ForwardAE, ForwardBE : out STD_LOGIC_VECTOR(1 downto 0);
        Stall_F, Stall_D, Stall_E, Flush_E : out STD_LOGIC
    );
end HazardUnit;

architecture Behavioral of HazardUnit is
begin
    process(Rs_E, Rt_E, WriteReg_M, WriteReg_W, RegWrite_M, RegWrite_W, fp_busy)
    begin
        -- 1. FORWARDING (Adiantamento de dados)
        if (RegWrite_M = '1' and WriteReg_M /= "00000" and WriteReg_M = Rs_E) then
            ForwardAE <= "10"; -- Do MEM
        elsif (RegWrite_W = '1' and WriteReg_W /= "00000" and WriteReg_W = Rs_E) then
            ForwardAE <= "01"; -- Do WB
        else
            ForwardAE <= "00";
        end if;

        if (RegWrite_M = '1' and WriteReg_M /= "00000" and WriteReg_M = Rt_E) then
            ForwardBE <= "10"; -- Do MEM
        elsif (RegWrite_W = '1' and WriteReg_W /= "00000" and WriteReg_W = Rt_E) then
            ForwardBE <= "01"; -- Do WB
        else
            ForwardBE <= "00";
        end if;

        -- 2. STALL LOGIC (Pausa devido à FPU)
        if fp_busy = '1' then
            Stall_F <= '1'; -- Congela PC
            Stall_D <= '1'; -- Congela IF/ID
            Stall_E <= '1'; -- Congela ID/EX (Mantém a instrução FP executando)
            Flush_E <= '0'; -- Não apaga ainda!
        else
            Stall_F <= '0';
            Stall_D <= '0';
            Stall_E <= '0';
            Flush_E <= '0';
        end if;
    end process;
end Behavioral;
