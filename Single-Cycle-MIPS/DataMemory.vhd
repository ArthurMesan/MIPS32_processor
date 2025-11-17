library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    port (
		CLK		  : in STD_LOGIC;
		Address    : in  STD_LOGIC_VECTOR (31 downto 0);
		Write_Data : in  STD_LOGIC_VECTOR (31 downto 0);
		MemRead    : in  STD_LOGIC; -- Embora não seja usado na leitura, é bom manter
		MemWrite   : in  STD_LOGIC;
		Read_Data  : out  STD_LOGIC_VECTOR (31 downto 0)
	 );
end DataMemory;

architecture Behavioral of DataMemory is
	type Memory is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
	signal DMem : Memory := (
		X"40490FDB", -- 1 (IEEE-754 para 3.14159)
		X"40000000", -- 2 (IEEE-754 para 2.0)
		X"00000011",
		X"00000033",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000"
	);

    -- Sinal interno para o índice do array
    signal index : integer range 0 to 31;

begin

    -- --- LÓGICA DE LEITURA (COMBINACIONAL) ---
    -- A leitura agora é assíncrona.
    -- O dado fica disponível assim que o Endereço muda.
    index <= TO_INTEGER(UNSIGNED(Address(6 downto 2))); -- Endereçamento de palavra
    Read_Data <= DMem(index);


    -- --- LÓGICA DE ESCRITA (SÍNCRONA) ---
    -- A escrita só ocorre na borda de subida do clock
    process (CLK)
	begin
		if (RISING_EDGE(CLK)) then
			if (MemWrite = '1') then
				DMem(index) <= Write_Data;
			end if;
		end if;
	end process;

end Behavioral;
