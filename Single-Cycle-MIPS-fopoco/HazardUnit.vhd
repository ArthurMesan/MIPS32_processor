library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HazardUnit is
    port (
        Rs_E, Rt_E, WriteReg_M, WriteReg_W : in STD_LOGIC_VECTOR(4 downto 0);
        RegWrite_M, RegWrite_W, fp_busy, mem_busy : in STD_LOGIC;
        fpu_start : in STD_LOGIC; -- NOVO SINAL: Indica que FPU disparou neste ciclo
        
        ForwardAE, ForwardBE : out STD_LOGIC_VECTOR(1 downto 0);
        Stall_F, Stall_D, Stall_E, Stall_M, Flush_E : out STD_LOGIC
    );
end HazardUnit;

architecture Behavioral of HazardUnit is
begin
    process(Rs_E, Rt_E, WriteReg_M, WriteReg_W, RegWrite_M, RegWrite_W, fp_busy, mem_busy, fpu_start)
    begin
        -- Forwarding (Sem alterações)
        if (RegWrite_M = '1' and WriteReg_M /= "00000" and WriteReg_M = Rs_E) then ForwardAE <= "10";
        elsif (RegWrite_W = '1' and WriteReg_W /= "00000" and WriteReg_W = Rs_E) then ForwardAE <= "01";
        else ForwardAE <= "00"; end if;

        if (RegWrite_M = '1' and WriteReg_M /= "00000" and WriteReg_M = Rt_E) then ForwardBE <= "10";
        elsif (RegWrite_W = '1' and WriteReg_W /= "00000" and WriteReg_W = Rt_E) then ForwardBE <= "01";
        else ForwardBE <= "00"; end if;

        -- STALL LOGIC
        -- Prioridade: Cache Miss > FPU Busy/Start
        
        if mem_busy = '1' then
            -- Cache Miss: Para tudo
            Stall_F <= '1'; Stall_D <= '1'; Stall_E <= '1'; Stall_M <= '1'; Flush_E <= '0';
            
        -- Se FPU estiver ocupada OU estiver começando agora
        elsif fp_busy = '1' or fpu_start = '1' then 
            Stall_F <= '1'; -- Segura fetch
            Stall_D <= '1'; -- Segura decode
            Stall_E <= '1'; -- Segura execução (MANTÉM FADD AQUI)
            Stall_M <= '0'; -- Deixa o resto fluir (bolhas)
            Flush_E <= '0';
        else
            Stall_F <= '0'; Stall_D <= '0'; Stall_E <= '0'; Stall_M <= '0'; Flush_E <= '0';
        end if;
    end process;
end Behavioral;