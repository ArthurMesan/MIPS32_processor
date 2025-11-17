library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ProgramCounter is
	port (
		CLK       : in STD_LOGIC;
		Reset     : in STD_LOGIC;
        PC_Enable : in STD_LOGIC;  -- << NOVO SINAL DE CONTROLE
		PC_in     : in STD_LOGIC_VECTOR(31 downto 0);
		PC_out    : out STD_LOGIC_VECTOR(31 downto 0)
	);
end ProgramCounter;

architecture Behavioral of ProgramCounter is
begin
    process (CLK, Reset)
    begin
        if (Reset = '1') then
            PC_out <= X"00000000";
        elsif (RISING_EDGE(CLK)) then
            if (PC_Enable = '1') then -- << LÓGICA DE ENABLE
                PC_out <= PC_in;
            end if;
            -- Se PC_Enable = '0', PC_out mantém seu valor antigo (stall)
        end if;
    end process;
end Behavioral;
