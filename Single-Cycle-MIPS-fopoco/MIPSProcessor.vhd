library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPSProcessor is
    port (
        CLK   : in STD_LOGIC;
        Reset : in STD_LOGIC;
        Debug_WB_En   : out STD_LOGIC;
        Debug_WB_Reg  : out STD_LOGIC_VECTOR(4 downto 0);
        Debug_WB_Data : out STD_LOGIC_VECTOR(31 downto 0);
        Debug_PC      : out STD_LOGIC_VECTOR(31 downto 0)
    );
end MIPSProcessor;

architecture Behavioral of MIPSProcessor is

    -- COMPONENTES BÁSICOS
    component ProgramCounter is port (CLK, Reset : in STD_LOGIC; PC_in : in STD_LOGIC_VECTOR(31 downto 0); PC_out : out STD_LOGIC_VECTOR(31 downto 0)); end component;
    component ProgramCounterAdder is port (PCA_in : in STD_LOGIC_VECTOR(31 downto 0); PCA_out : out STD_LOGIC_VECTOR(31 downto 0)); end component;
    component InstructionMemory is port (Address : in STD_LOGIC_VECTOR(31 downto 0); Instruction : out STD_LOGIC_VECTOR(31 downto 0)); end component;

    component ControlUnit is
        port (
          Opcode : in STD_LOGIC_VECTOR(5 downto 0);
          RegDst, Jump, Branch_E, Branch_NE, MemRead, MemtoReg : out STD_LOGIC;
          ALUOp : out STD_LOGIC_VECTOR(1 downto 0);
          MemWrite, ALUSrc, RegWrite : out STD_LOGIC
        );
    end component;

    component RegisterFile is port (CLK, RegWrite : in STD_LOGIC; Read_Register_1, Read_Register_2, Write_Register : in STD_LOGIC_VECTOR(4 downto 0); Write_Data : in STD_LOGIC_VECTOR(31 downto 0); Read_Data_1, Read_Data_2 : out STD_LOGIC_VECTOR(31 downto 0)); end component;
    component SignExtender is port (SE_in : in STD_LOGIC_VECTOR(15 downto 0); SE_out : out STD_LOGIC_VECTOR(31 downto 0)); end component;
    component Multiplexer is generic (N : integer := 32); port (MUX_in_0, MUX_in_1 : in STD_LOGIC_VECTOR(N - 1 downto 0); MUX_select : in STD_LOGIC; MUX_out : out STD_LOGIC_VECTOR(N - 1 downto 0)); end component;
    component ArithmeticLogicUnitControl is port (ALUC_funct : in STD_LOGIC_VECTOR(5 downto 0); ALUOp : in STD_LOGIC_VECTOR(1 downto 0); ALUC_operation : out STD_LOGIC_VECTOR(3 downto 0)); end component;
    component ArithmeticLogicUnit is port (Input_1, Input_2 : in STD_LOGIC_VECTOR(31 downto 0); ALU_control : in STD_LOGIC_VECTOR(3 downto 0); ALU_result : out STD_LOGIC_VECTOR(31 downto 0); Zero : out STD_LOGIC); end component;
    component DataMemory is port (CLK : in STD_LOGIC; Address, Write_Data : in STD_LOGIC_VECTOR(31 downto 0); MemRead, MemWrite : in STD_LOGIC; Read_Data : out STD_LOGIC_VECTOR(31 downto 0)); end component;
    component ShiftLefter is generic (N : integer := 2; W : integer := 32); port (SL_in  : in STD_LOGIC_VECTOR(W - 1 downto 0); SL_out : out STD_LOGIC_VECTOR(W - 1 downto 0)); end component;

    -- COMPONENTES HAZARD E PIPELINE
    component HazardUnit is port (Rs_E, Rt_E, WriteReg_M, WriteReg_W : in STD_LOGIC_VECTOR(4 downto 0); RegWrite_M, RegWrite_W, fp_busy : in STD_LOGIC; ForwardAE, ForwardBE : out STD_LOGIC_VECTOR(1 downto 0); Stall_F, Stall_D, Stall_E, Flush_E : out STD_LOGIC); end component;
    component FPAdd32_wrapper is port (CLK, Start : in STD_LOGIC; A, B : in STD_LOGIC_VECTOR(31 downto 0); R : out STD_LOGIC_VECTOR(31 downto 0); Ready : out STD_LOGIC); end component;
    component FPMult32_wrapper is port (CLK, Start : in STD_LOGIC; A, B : in STD_LOGIC_VECTOR(31 downto 0); R : out STD_LOGIC_VECTOR(31 downto 0); Ready : out STD_LOGIC); end component;

    component PipeReg_IF_ID is port (CLK, Reset, En, Flush : in STD_LOGIC; PC4_In, Instr_In : in STD_LOGIC_VECTOR(31 downto 0); PC4_Out, Instr_Out : out STD_LOGIC_VECTOR(31 downto 0)); end component;
    component PipeReg_ID_EX is port (CLK, Reset, En : in STD_LOGIC; RegWrite_In, MemtoReg_In, MemRead_In, MemWrite_In, ALUSrc_In, RegDst_In : in STD_LOGIC; ALUOp_In : in STD_LOGIC_VECTOR(1 downto 0); isFP_In : in STD_LOGIC; PC4_In, ReadData1_In, ReadData2_In, SignExt_In : in STD_LOGIC_VECTOR(31 downto 0); RS_In, RT_In, RD_In : in STD_LOGIC_VECTOR(4 downto 0); RegWrite_Out, MemtoReg_Out, MemRead_Out, MemWrite_Out, ALUSrc_Out, RegDst_Out : out STD_LOGIC; ALUOp_Out : out STD_LOGIC_VECTOR(1 downto 0); isFP_Out : out STD_LOGIC; PC4_Out, ReadData1_Out, ReadData2_Out, SignExt_Out : out STD_LOGIC_VECTOR(31 downto 0); RS_Out, RT_Out, RD_Out : out STD_LOGIC_VECTOR(4 downto 0)); end component;
    component PipeReg_EX_MEM is port (CLK, Reset : in STD_LOGIC; RegWrite_In, MemtoReg_In, MemRead_In, MemWrite_In : in STD_LOGIC; ALUResult_In, WriteData_In : in STD_LOGIC_VECTOR(31 downto 0); WriteReg_In : in STD_LOGIC_VECTOR(4 downto 0); RegWrite_Out, MemtoReg_Out, MemRead_Out, MemWrite_Out : out STD_LOGIC; ALUResult_Out, WriteData_Out : out STD_LOGIC_VECTOR(31 downto 0); WriteReg_Out : out STD_LOGIC_VECTOR(4 downto 0)); end component;
    component PipeReg_MEM_WB is port (CLK, Reset : in STD_LOGIC; RegWrite_In, MemtoReg_In : in STD_LOGIC; ReadData_In, ALUResult_In : in STD_LOGIC_VECTOR(31 downto 0); WriteReg_In : in STD_LOGIC_VECTOR(4 downto 0); RegWrite_Out, MemtoReg_Out : out STD_LOGIC; ReadData_Out, ALUResult_Out : out STD_LOGIC_VECTOR(31 downto 0); WriteReg_Out : out STD_LOGIC_VECTOR(4 downto 0)); end component;

    -- SINAIS
    signal pc_current, pc_next, pc_plus4_F, instr_F : STD_LOGIC_VECTOR(31 downto 0);
    signal stall_F, stall_D, stall_E, flush_E : STD_LOGIC;

    -- Sinais Auxiliares
    signal reset_ID_EX : STD_LOGIC;
    signal if_id_en, id_ex_en : STD_LOGIC;

    -- ID Stage
    signal instr_D, pc_plus4_D : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode_D : STD_LOGIC_VECTOR(5 downto 0);
    signal rs_D, rt_D, rd_D : STD_LOGIC_VECTOR(4 downto 0);
    signal imm_D : STD_LOGIC_VECTOR(15 downto 0);
    signal sign_ext_D, read_data1_D, read_data2_D : STD_LOGIC_VECTOR(31 downto 0);
    signal regwrite_D, memtoreg_D, memread_D, memwrite_D, alusrc_D, regdst_D, jump_D, branch_eq_D, branch_ne_D, isFP_D : STD_LOGIC;
    signal aluop_D : STD_LOGIC_VECTOR(1 downto 0);

    -- EX Stage
    signal pc_plus4_E, read_data1_E, read_data2_E, sign_ext_E : STD_LOGIC_VECTOR(31 downto 0);
    signal rs_E, rt_E, rd_E, write_reg_E : STD_LOGIC_VECTOR(4 downto 0);
    signal regwrite_E, memtoreg_E, memread_E, memwrite_E, alusrc_E, regdst_E, isFP_E : STD_LOGIC;
    signal aluop_E : STD_LOGIC_VECTOR(1 downto 0);
    signal alu_src_a_E, alu_src_b_temp, alu_src_b_E, alu_result_E : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_ctrl_E : STD_LOGIC_VECTOR(3 downto 0);
    signal forward_ae, forward_be : STD_LOGIC_VECTOR(1 downto 0);

    -- FP Logic
    signal fp_start_add, fp_start_mul, fp_ready_add, fp_ready_mul, fp_busy, fp_current_is_add : STD_LOGIC := '0';
    signal fp_result_add, fp_result_mul, fp_result_E : STD_LOGIC_VECTOR(31 downto 0);
    signal fp_done : STD_LOGIC := '0'; -- O Sinal "Matador" de instruções repetidas

    -- MEM & WB Signals
    signal regwrite_M, memtoreg_M, memread_M, memwrite_M : STD_LOGIC;
    signal alu_result_M, write_data_M, read_data_M : STD_LOGIC_VECTOR(31 downto 0);
    signal write_reg_M : STD_LOGIC_VECTOR(4 downto 0);
    signal regwrite_W, memtoreg_W : STD_LOGIC;
    signal read_data_W, alu_result_W, result_W : STD_LOGIC_VECTOR(31 downto 0);
    signal write_reg_W : STD_LOGIC_VECTOR(4 downto 0);
    signal alu_res_in_ex_mem : STD_LOGIC_VECTOR(31 downto 0);

begin

    HU: HazardUnit port map (
        Rs_E => rs_E, Rt_E => rt_E,
        WriteReg_M => write_reg_M, WriteReg_W => write_reg_W,
        RegWrite_M => regwrite_M, RegWrite_W => regwrite_W,
        fp_busy => fp_busy,
        ForwardAE => forward_ae, ForwardBE => forward_be,
        Stall_F => stall_F, Stall_D => stall_D, Stall_E => stall_E, Flush_E => flush_E
    );

    -- IF STAGE
    PC : ProgramCounter port map(CLK, Reset, pc_next, pc_current);
    PCA : ProgramCounterAdder port map(pc_current, pc_plus4_F);
    IM : InstructionMemory port map(pc_current, instr_F);

    pc_next <= pc_current when stall_F = '1' else pc_plus4_F;
    if_id_en <= not stall_D;

    Reg_IF_ID : PipeReg_IF_ID port map (
        CLK => CLK, Reset => Reset, En => if_id_en, Flush => '0',
        PC4_In => pc_plus4_F, Instr_In => instr_F,
        PC4_Out => pc_plus4_D, Instr_Out => instr_D
    );

    -- ID STAGE
    opcode_D <= instr_D(31 downto 26);
    rs_D <= instr_D(25 downto 21);
    rt_D <= instr_D(20 downto 16);
    rd_D <= instr_D(15 downto 11);
    imm_D <= instr_D(15 downto 0);

    CU : ControlUnit port map(
        Opcode => opcode_D, RegDst => regdst_D, Jump => jump_D, Branch_E => branch_eq_D, Branch_NE => branch_ne_D,
        MemRead => memread_D, MemtoReg => memtoreg_D, ALUOp => aluop_D, MemWrite => memwrite_D, ALUSrc => alusrc_D, RegWrite => regwrite_D
    );
    isFP_D <= '1' when opcode_D = "011111" else '0';

    RF : RegisterFile port map(CLK, regwrite_W, rs_D, rt_D, write_reg_W, result_W, read_data1_D, read_data2_D);
    SE : SignExtender port map(imm_D, sign_ext_D);

    -- *** CORREÇÃO VITAL: RESETAR ID/EX SE FPU TERMINOU (fp_done) ***
    reset_ID_EX <= Reset or flush_E or fp_done;

    id_ex_en <= not stall_E;

    Reg_ID_EX : PipeReg_ID_EX port map(
        CLK => CLK, Reset => reset_ID_EX, En => id_ex_en,
        RegWrite_In => regwrite_D, MemtoReg_In => memtoreg_D, MemRead_In => memread_D, MemWrite_In => memwrite_D,
        ALUSrc_In => alusrc_D, RegDst_In => regdst_D, ALUOp_In => aluop_D, isFP_In => isFP_D,
        PC4_In => pc_plus4_D, ReadData1_In => read_data1_D, ReadData2_In => read_data2_D, SignExt_In => sign_ext_D,
        RS_In => rs_D, RT_In => rt_D, RD_In => rd_D,
        RegWrite_Out => regwrite_E, MemtoReg_Out => memtoreg_E, MemRead_Out => memread_E, MemWrite_Out => memwrite_E,
        ALUSrc_Out => alusrc_E, RegDst_Out => regdst_E, ALUOp_Out => aluop_E, isFP_Out => isFP_E,
        PC4_Out => pc_plus4_E, ReadData1_Out => read_data1_E, ReadData2_Out => read_data2_E, SignExt_Out => sign_ext_E,
        RS_Out => rs_E, RT_Out => rt_E, RD_Out => rd_E
    );

    -- EX STAGE
    alu_src_a_E <= read_data1_E when forward_ae = "00" else result_W when forward_ae = "01" else alu_result_M;
    alu_src_b_temp <= read_data2_E when forward_be = "00" else result_W when forward_be = "01" else alu_result_M;
    alu_src_b_E <= alu_src_b_temp when alusrc_E = '0' else sign_ext_E;

    ALU_Ctrl : ArithmeticLogicUnitControl port map(sign_ext_E(5 downto 0), aluop_E, alu_ctrl_E);
    Main_ALU : ArithmeticLogicUnit port map(alu_src_a_E, alu_src_b_E, alu_ctrl_E, alu_result_E, open);

    -- FPU Start Logic
    fp_start_add <= '1' when (isFP_E='1' and sign_ext_E(5 downto 0)="000000" and fp_busy='0') else '0';
    fp_start_mul <= '1' when (isFP_E='1' and sign_ext_E(5 downto 0)="000010" and fp_busy='0') else '0';

    FPADD : FPAdd32_wrapper port map (CLK, fp_start_add, alu_src_a_E, alu_src_b_temp, fp_result_add, fp_ready_add);
    FPMUL : FPMult32_wrapper port map (CLK, fp_start_mul, alu_src_a_E, alu_src_b_temp, fp_result_mul, fp_ready_mul);

    -- FSM de Controle da FPU Atualizada
    process(CLK, Reset)
    begin
        if Reset = '1' then
            fp_busy <= '0'; fp_current_is_add <= '0'; fp_done <= '0';
        elsif rising_edge(CLK) then
            fp_done <= '0'; -- Default: fp_done é um pulso de 1 ciclo

            if fp_busy = '0' then
                if fp_start_add = '1' then fp_busy <= '1'; fp_current_is_add <= '1';
                elsif fp_start_mul = '1' then fp_busy <= '1'; fp_current_is_add <= '0';
                end if;
            else
                -- Quando termina, liberamos o busy E ativamos o done
                if (fp_current_is_add = '1' and fp_ready_add = '1') or (fp_current_is_add = '0' and fp_ready_mul = '1') then
                    fp_busy <= '0';
                    fp_done <= '1'; -- Isso vai limpar o ID/EX no próximo ciclo
                end if;
            end if;
        end if;
    end process;

    fp_result_E <= fp_result_add when fp_current_is_add='1' else fp_result_mul;

    Mux_RegDst : Multiplexer generic map(5) port map(rt_E, rd_E, regdst_E, write_reg_E);

    alu_res_in_ex_mem <= fp_result_E when isFP_E='1' else alu_result_E;

    Reg_EX_MEM : PipeReg_EX_MEM port map(
        CLK => CLK, Reset => Reset,
        RegWrite_In => regwrite_E, MemtoReg_In => memtoreg_E, MemRead_In => memread_E, MemWrite_In => memwrite_E,
        ALUResult_In => alu_res_in_ex_mem,
        WriteData_In => alu_src_b_temp, WriteReg_In => write_reg_E,
        RegWrite_Out => regwrite_M, MemtoReg_Out => memtoreg_M, MemRead_Out => memread_M, MemWrite_Out => memwrite_M,
        ALUResult_Out => alu_result_M, WriteData_Out => write_data_M, WriteReg_Out => write_reg_M
    );

    -- MEM STAGE
    DM : DataMemory port map(CLK, alu_result_M, write_data_M, memread_M, memwrite_M, read_data_M);

    Reg_MEM_WB : PipeReg_MEM_WB port map(
        CLK => CLK, Reset => Reset,
        RegWrite_In => regwrite_M, MemtoReg_In => memtoreg_M,
        ReadData_In => read_data_M, ALUResult_In => alu_result_M, WriteReg_In => write_reg_M,
        RegWrite_Out => regwrite_W, MemtoReg_Out => memtoreg_W,
        ReadData_Out => read_data_W, ALUResult_Out => alu_result_W, WriteReg_Out => write_reg_W
    );

    -- WB STAGE
    Mux_MemtoReg : Multiplexer generic map(32) port map(alu_result_W, read_data_W, memtoreg_W, result_W);

    Debug_WB_En   <= regwrite_W;
    Debug_WB_Reg  <= write_reg_W;
    Debug_WB_Data <= result_W;
    Debug_PC      <= pc_current;

end Behavioral;
