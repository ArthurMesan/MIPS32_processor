-- use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_Processor is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC);
end MIPS_Processor;

architecture Structural of MIPS_Processor is
    -- (Declaração de todos os seus 7 componentes aqui)
    component ProgramCounter
        Port ( clk : in STD_LOGIC; reset : in STD_LOGIC; pc_in : in STD_LOGIC_VECTOR (31 downto 0); pc_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component InstructionMemory
        Port ( address : in STD_LOGIC_VECTOR (31 downto 0); instruction : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component ControlUnit
        Port ( opcode : in  STD_LOGIC_VECTOR (5 downto 0); RegWrite : out STD_LOGIC; MemRead : out STD_LOGIC; MemWrite : out STD_LOGIC; MemtoReg : out STD_LOGIC; ALUSrc : out STD_LOGIC; RegDst : out STD_LOGIC; Branch : out STD_LOGIC; ALUOp : out STD_LOGIC_VECTOR (1 downto 0));
    end component;
    component RegisterFile
        Port ( clk : in STD_LOGIC; reg_write : in STD_LOGIC; read_reg1 : in STD_LOGIC_VECTOR (4 downto 0); read_reg2 : in STD_LOGIC_VECTOR (4 downto 0); write_reg : in STD_LOGIC_VECTOR (4 downto 0); write_data : in STD_LOGIC_VECTOR (31 downto 0); read_data1 : out STD_LOGIC_VECTOR (31 downto 0); read_data2 : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component ALUControlUnit
        Port ( ALUOp : in  STD_LOGIC_VECTOR (1 downto 0); funct : in  STD_LOGIC_VECTOR (5 downto 0); ALUControl : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    component ALU
        Port ( A : in STD_LOGIC_VECTOR (31 downto 0); B : in STD_LOGIC_VECTOR (31 downto 0); ALUControl : in STD_LOGIC_VECTOR (3 downto 0); Result : out STD_LOGIC_VECTOR (31 downto 0); Zero : out STD_LOGIC);
    end component;
    component DataMemory
        Port ( clk : in STD_LOGIC; mem_read : in STD_LOGIC; mem_write : in STD_LOGIC; address : in STD_LOGIC_VECTOR (31 downto 0); write_data : in STD_LOGIC_VECTOR (31 downto 0); read_data : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    -- Sinais (fios) para conectar os componentes
    signal pc_current, pc_next, pc_plus_4, pc_branch : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal read_data1, read_data2, alu_result, mem_read_data, write_data_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_operand_b : STD_LOGIC_VECTOR(31 downto 0);
    signal immediate_signed : STD_LOGIC_VECTOR(31 downto 0);
    signal write_reg_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal alu_control_out : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_op_out : STD_LOGIC_VECTOR(1 downto 0);
    signal zero_flag, reg_write, mem_read, mem_write, mem_to_reg, alu_src, reg_dst, branch, branch_control : STD_LOGIC;

    -- Sinal para 'sll 2' (shift left 2)
    signal immediate_shifted : STD_LOGIC_VECTOR(31 downto 0);

begin
    -- 1. Instruction Fetch (IF)
    PC_unit: ProgramCounter port map (clk => clk, reset => reset, pc_in => pc_next, pc_out => pc_current);

    -- CORREÇÃO: Usar NUMERIC_STD para somar.
    -- (O '4' precisa ser um std_logic_vector de 32 bits)
    pc_plus_4 <= std_logic_vector(unsigned(pc_current) + 4);

    InstrMem_unit: InstructionMemory port map (address => pc_current, instruction => instruction);

    -- 2. Instruction Decode (ID)
    Control_unit: ControlUnit port map (opcode => instruction(31 downto 26), RegWrite => reg_write, MemRead => mem_read, MemWrite => mem_write, MemtoReg => mem_to_reg, ALUSrc => alu_src, RegDst => reg_dst, Branch => branch, ALUOp => alu_op_out);
    RegFile_unit: RegisterFile port map (clk => clk, reg_write => reg_write, read_reg1 => instruction(25 downto 21), read_reg2 => instruction(20 downto 16), write_reg => write_reg_addr, write_data => write_data_reg, read_data1 => read_data1, read_data2 => read_data2);

    -- Mux para o registrador de destino (rd ou rt)
    write_reg_addr <= instruction(15 downto 11) when reg_dst = '1' else instruction(20 downto 16);

    -- Extensão de sinal
    immediate_signed <= (31 downto 15 => instruction(15)) & instruction(15 downto 0);

    -- 3. Execute (EX)
    ALU_Control_unit: ALUControlUnit port map (ALUOp => alu_op_out, funct => instruction(5 downto 0), ALUControl => alu_control_out);

    -- Mux para a segunda entrada da ALU (registrador ou imediato)
    alu_operand_b <= read_data2 when alu_src = '0' else immediate_signed;

    ALU_unit: ALU port map (A => read_data1, B => alu_operand_b, ALUControl => alu_control_out, Result => alu_result, Zero => zero_flag);

    -- Cálculo do endereço de branch
    -- CORREÇÃO: Usar shift_left de NUMERIC_STD
    immediate_shifted <= std_logic_vector(shift_left(unsigned(immediate_signed), 2));
    pc_branch <= std_logic_vector(unsigned(pc_plus_4) + unsigned(immediate_shifted));

    branch_control <= branch and zero_flag;

    -- Mux para o próximo PC
    pc_next <= pc_branch when branch_control = '1' else pc_plus_4;

    -- 4. Memory Access (MEM)
    DataMem_unit: DataMemory port map (clk => clk, mem_read => mem_read, mem_write => mem_write, address => alu_result, write_data => read_data2, read_data => mem_read_data);

    -- 5. Write Back (WB)
    -- Mux para o dado que volta ao RegisterFile
    write_data_reg <= mem_read_data when mem_to_reg = '1' else alu_result;

end Structural;
