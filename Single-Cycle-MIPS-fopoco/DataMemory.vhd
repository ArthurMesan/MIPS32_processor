library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    port (
		CLK		  : in STD_LOGIC;
		Address    : in  STD_LOGIC_VECTOR (31 downto 0);
		Write_Data : in  STD_LOGIC_VECTOR (31 downto 0);
		MemRead    : in  STD_LOGIC;
		MemWrite   : in  STD_LOGIC;
		Read_Data  : out  STD_LOGIC_VECTOR (31 downto 0)
	 );
end DataMemory;

architecture Behavioral of DataMemory is
	type Memory is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

	signal DMem : Memory := (
		0      => X"3FC00000", -- Posição 0 (1.5f)
		1      => X"40000000", -- Posição 1 (2.0f)
		others => X"00000000"
	);

    -- Sinal para o índice, calculado combinacionalmente
    signal mem_index : integer range 0 to 31;

begin

    -- Converte o endereço de byte (32-bit) para um índice de palavra (5-bit)
    mem_index <= TO_INTEGER(UNSIGNED(Address(6 downto 2)));

    -- --- LÓGICA DE LEITURA (COMBINACIONAL) ---
    -- Este processo é "sensível" ao índice e à própria memória.
    -- Se qualquer um deles mudar, ele re-executa imediatamente.
    -- ISSO CORRIGE O BUG DO XXXX.
    process(mem_index, DMem)
    begin
        Read_Data <= DMem(mem_index);
    end process;


    -- --- LÓGICA DE ESCRITA (SÍNCRONA) ---
    -- A escrita só ocorre na borda de subida do clock
    process (CLK)
	begin
		if (RISING_EDGE(CLK)) then
			if (MemWrite = '1') then
				DMem(mem_index) <= Write_Data;
			end if;
		end if;
	end process;

end Behavioral;
