library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_RegisterFile is
end tb_RegisterFile;

architecture testbench of tb_RegisterFile is
    component RegisterFile is
        Port ( clk : in STD_LOGIC;
               reg_write : in STD_LOGIC;
               read_reg1 : in STD_LOGIC_VECTOR (4 downto 0);
               read_reg2 : in STD_LOGIC_VECTOR (4 downto 0);
               write_reg : in STD_LOGIC_VECTOR (4 downto 0);
               write_data : in STD_LOGIC_VECTOR (31 downto 0);
               read_data1 : out STD_LOGIC_VECTOR (31 downto 0);
               read_data2 : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal clk, reg_write : STD_LOGIC := '0';
    signal read_reg1, read_reg2, write_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal write_data, read_data1, read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    constant CLK_PERIOD : time := 10 ns;
begin
    uut: RegisterFile port map (clk=>clk, reg_write=>reg_write, read_reg1=>read_reg1, read_reg2=>read_reg2, write_reg=>write_reg, write_data=>write_data, read_data1=>read_data1, read_data2=>read_data2);

    clk_process: process begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        -- Write to register $t0 (8)
        write_reg <= "01000";
        write_data <= x"AAAAAAAA";
        reg_write <= '1';
        wait for CLK_PERIOD;

        -- Write to register $t1 (9)
        write_reg <= "01001";
        write_data <= x"BBBBBBBB";
        wait for CLK_PERIOD;
        reg_write <= '0';

        -- Read $t0 and $t1
        read_reg1 <= "01000";
        read_reg2 <= "01001";
        wait for CLK_PERIOD;

        assert(read_data1 = x"AAAAAAAA") report "Read reg1 failed" severity error;
        assert(read_data2 = x"BBBBBBBB") report "Read reg2 failed" severity error;

        report "RegisterFile test finished successfully.";
        wait;
    end process;
end testbench;
