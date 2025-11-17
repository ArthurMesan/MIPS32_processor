library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Multiplexer_4_1 is
	 generic (
		N : integer := 32
	 );
	 port (
		MUX_in_0   : in  STD_LOGIC_VECTOR(N - 1 downto 0); -- "00"
		MUX_in_1   : in  STD_LOGIC_VECTOR(N - 1 downto 0); -- "01"
		MUX_in_2   : in  STD_LOGIC_VECTOR(N - 1 downto 0); -- "10"
		MUX_in_3   : in  STD_LOGIC_VECTOR(N - 1 downto 0); -- "11"
		MUX_select : in  STD_LOGIC_VECTOR(1 downto 0);
		MUX_out    : out  STD_LOGIC_VECTOR(N - 1 downto 0)
	);
end Multiplexer_4_1;

architecture Behavioral of Multiplexer_4_1 is
begin
    with MUX_select select
        MUX_out <= MUX_in_0 when "00",
                   MUX_in_1 when "01",
                   MUX_in_2 when "10",
                   MUX_in_3 when others; -- "11"
end Behavioral;
