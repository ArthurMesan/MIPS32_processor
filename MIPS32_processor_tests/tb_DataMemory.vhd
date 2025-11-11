library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_DataMemory is
end tb_DataMemory;

architecture testbench of tb_DataMemory is
    component DataMemory is
        Port ( clk : in STD_LOGIC;
               mem_read : in STD_LOGIC;
               mem_write : in STD_LOGIC;
               address : in STD_LOGIC_VECTOR (31 downto 0);
               write_data : in STD_LOGIC_VECTOR (31 downto 0);
               read_data : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal clk, mem_read, mem_write : STD_LOGIC := '0';
    signal address, write_data, read_data : STD_LOGIC_VECTOR(31 downto 0);
    constant CLK_PERIOD : time := 10 ns;
begin
    uut: DataMemory port map (clk=>clk, mem_read=>mem_read, mem_write=>mem_write, address=>address, write_data=>write_data, read_data=>read_data);

    clk_process: process begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        -- Test write
        address <= x"00000020";
        write_data <= x"DEADBEEF";
        mem_write <= '1';
        mem_read <= '0';
        wait for CLK_PERIOD;
        mem_write <= '0';

        -- Test read
        address <= x"00000020";
        mem_read <= '1';
        wait for CLK_PERIOD;
        assert(read_data = x"DEADBEEF") report "Memory read failed" severity error;

        report "DataMemory test finished successfully.";
        wait;
    end process;
end testbench;
