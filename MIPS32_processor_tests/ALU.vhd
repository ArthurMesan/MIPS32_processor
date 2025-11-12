library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           ALUControl : in STD_LOGIC_VECTOR (3 downto 0);
           Result : out STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
begin
    process(A, B, ALUControl)
        variable temp_result : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    begin

        case ALUControl is
            when "0000" => -- Addition
                temp_result := std_logic_vector(unsigned(A) + unsigned(B));
            when "0001" => -- Subtraction
                temp_result := std_logic_vector(unsigned(A) - unsigned(B));
            when "0010" => -- AND
                temp_result := A and B;
            when "0011" => -- OR
                temp_result := A or B;
            when others =>
                temp_result := (others => '0');
        end case;

        if temp_result = x"00000000" then
            Zero <= '1';
        else
            Zero <= '0';
        end if;

        Result <= temp_result;

    end process;
end Behavioral;
