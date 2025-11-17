library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPSProcessor is
	port (
		CLK   : in STD_LOGIC;
		Reset : in STD_LOGIC
	);
end MIPSProcessor;

architecture Behavioral of MIPSProcessor is
	----------------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------------
	component ProgramCounter is
		port (
			CLK       : in STD_LOGIC;
			Reset     : in STD_LOGIC;
            PC_Enable : in STD_LOGIC;  -- --- MODIFICADO: Adicionado Enable para Stall
			PC_in     : in STD_LOGIC_VECTOR(31 downto 0);
			PC_out    : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	component ProgramCounterAdder is
		port (
			PCA_in  : in STD_LOGIC_VECTOR(31 downto 0);
			PCA_out : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	component InstructionMemory is
		port (
			Address     : in STD_LOGIC_VECTOR(31 downto 0);
			Instruction : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

    --- MODIFICADO: Definição da ControlUnit alterada para FSM e Stall ---
	component ControlUnit is
		port (
              -- Sinais da FSM e Stall
              CLK       : in  STD_LOGIC;
              Reset     : in  STD_LOGIC;
              FP_Ready  : in  STD_LOGIC; -- ENTRADA: 'Pronto' do FloPoCo
              Opcode    : in  STD_LOGIC_VECTOR (5 downto 0);

              -- Sinais de Controle Originais (com MemtoReg modificado)
              RegDst    : out  STD_LOGIC;
              Jump      : out  STD_LOGIC;
              Branch_E  : out  STD_LOGIC;
              Branch_NE : out  STD_LOGIC;
              MemRead   : out  STD_LOGIC;
              MemtoReg  : out  STD_LOGIC_VECTOR (1 downto 0); -- MODIFICADO: 2 bits
              ALUOp     : out  STD_LOGIC_VECTOR (1 downto 0);
              MemWrite  : out  STD_LOGIC;
              ALUSrc    : out  STD_LOGIC;
              RegWrite  : out  STD_LOGIC;

              -- Novos Sinais de Controle para Stall
              PC_Enable : out STD_LOGIC; -- SAÍDA: Habilita o PC
              FP_Start  : out STD_LOGIC  -- SAÍDA: Inicia o FloPoCo
		);
	end component;

	component Multiplexer is
		 generic (
			N : integer := 32
		 );
		 port (
			MUX_in_0   : in  STD_LOGIC_VECTOR(N - 1 downto 0);
			MUX_in_1   : in  STD_LOGIC_VECTOR(N - 1 downto 0);
			MUX_select : in  STD_LOGIC;
			MUX_out    : out  STD_LOGIC_VECTOR(N - 1 downto 0)
		);
	end component;

    --- NOVO: Componente MUX 4-para-1 para o Write-Back ---
    component Multiplexer_4_1 is
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
    end component;

	component RegisterFile is
		port (
			CLK 		    : in STD_LOGIC;
			RegWrite 	    : in STD_LOGIC;
			Read_Register_1 : in STD_LOGIC_VECTOR(4 downto 0);
			Read_Register_2 : in STD_LOGIC_VECTOR(4 downto 0);
			Write_Register  : in STD_LOGIC_VECTOR(4 downto 0);
			Write_Data      : in STD_LOGIC_VECTOR(31 downto 0);
			Read_Data_1     : out STD_LOGIC_VECTOR(31 downto 0);
			Read_Data_2     : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	component ArithmeticLogicUnit is
		port (
			Input_1 	: in STD_LOGIC_VECTOR(31 downto 0);
			Input_2 	: in STD_LOGIC_VECTOR(31 downto 0);
			ALU_control : in STD_LOGIC_VECTOR(3 downto 0);
			ALU_result 	: out STD_LOGIC_VECTOR(31 downto 0);
			Zero 		: out STD_LOGIC
		);
	end component;

	component SignExtender is
		port (
			SE_in  : in STD_LOGIC_VECTOR(15 downto 0);
			SE_out : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	component ArithmeticLogicUnitControl is
		port (
			ALUC_funct 	 	: in STD_LOGIC_VECTOR(5 downto 0);
			ALUOp 	 		: in STD_LOGIC_VECTOR(1 downto 0);
			ALUC_operation  : out STD_LOGIC_VECTOR(3 downto 0)
		);
	end component;

	component DataMemory is
		port (
			CLK		   : in STD_LOGIC;
			Address    : in  STD_LOGIC_VECTOR (31 downto 0);
			Write_Data : in  STD_LOGIC_VECTOR (31 downto 0);
			MemRead    : in  STD_LOGIC;
			MemWrite   : in  STD_LOGIC;
			Read_Data  : out  STD_LOGIC_VECTOR (31 downto 0)
		);
	end component;

	component ShiftLefter is
		generic (
			N : integer := 2;
			W : integer := 32
		);
		port (
			SL_in  : in STD_LOGIC_VECTOR(W - 1 downto 0);
			SL_out : out STD_LOGIC_VECTOR(W - 1 downto 0)
		);
	end component;

    --- NOVO: Componente wrapper do FloPoCo ---
    component FPAdd32_wrapper is
      port (
        CLK   : in  STD_LOGIC;
        Start : in  STD_LOGIC;
        A     : in  STD_LOGIC_VECTOR(31 downto 0);
        B     : in  STD_LOGIC_VECTOR(31 downto 0);
        R     : out STD_LOGIC_VECTOR(31 downto 0);
        Ready : out STD_LOGIC
      );
    end component;

	----------------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------------
	signal pcin : STD_LOGIC_VECTOR(31 downto 0);
	signal pcout : STD_LOGIC_VECTOR(31 downto 0);
	signal pc4out : STD_LOGIC_VECTOR(31 downto 0);

	signal instruction : STD_LOGIC_VECTOR(31 downto 0);
	signal rs, rd, rt : STD_LOGIC_VECTOR(4 downto 0);
	signal opcode : STD_LOGIC_VECTOR(5 downto 0);
	signal immediate : STD_LOGIC_VECTOR(15 downto 0);
	signal funct : STD_LOGIC_VECTOR(5 downto 0);
	signal jumpinst : STD_LOGIC_VECTOR(25 downto 0);

    -- --- MODIFICADO: memtoreg removido desta linha ---
	signal regdst, jump, branche, branchne, memread, memwrite, alusrc, regwrite : STD_LOGIC;
    signal memtoreg : STD_LOGIC_VECTOR(1 downto 0); -- --- MODIFICADO: Agora é um vetor de 2 bits
	signal aluop : STD_LOGIC_VECTOR(1 downto 0);

	signal regdstmuxout : STD_LOGIC_VECTOR(4 downto 0);
    -- --- REMOVIDO: Sinal antigo do MUX 2-para-1
	-- signal memtoregmuxout : STD_LOGIC_VECTOR(31 downto 0);
	signal alusrcmuxout : STD_LOGIC_VECTOR(31 downto 0);
	signal branchmuxout : STD_LOGIC_VECTOR(31 downto 0);
	signal branchmuxselect : STD_LOGIC;

	signal rf_read_data_1, rf_read_data_2, dm_read_data : STD_LOGIC_VECTOR(31 downto 0);

	signal signimm : STD_LOGIC_VECTOR(31 downto 0);
	signal shifted_signimm : STD_LOGIC_VECTOR(31 downto 0);
	signal jumpaddr : STD_LOGIC_VECTOR(31 downto 0);

	signal alu_operation : STD_LOGIC_VECTOR(3 downto 0);
	signal alu_result : STD_LOGIC_VECTOR(31 downto 0);
	signal alu_zero : STD_LOGIC;
	signal alu_result_adder : STD_LOGIC_VECTOR(31 downto 0);

    --- NOVO: Sinais para controlar o FloPoCo e o Stall ---
    signal s_pc_enable      : STD_LOGIC; -- Controla o 'Enable' do PC
    signal s_fp_start       : STD_LOGIC; -- Envia 'Start' para o FloPoCo
    signal s_fp_ready       : STD_LOGIC; -- Recebe 'Ready' do FloPoCo
    signal s_fp_result      : STD_LOGIC_VECTOR(31 downto 0); -- Resultado do FloPoCo
    signal s_writeback_data : STD_LOGIC_VECTOR(31 downto 0); -- Dado final para o RegFile


begin

	opcode <= instruction(31 downto 26);
	rs <= instruction(25 downto 21);
	rt <= instruction(20 downto 16);
	rd <= instruction(15 downto 11);
	funct <= instruction(5 downto 0);
	immediate <= instruction(15 downto 0);
	jumpinst <= instruction(25 downto 0);

	jumpaddr(31 downto 28) <= pc4out(31 downto 28);
	jumpaddr(27 downto 2) <= jumpinst;
	jumpaddr(1 downto 0) <= (others => '0');

	--alu_result_adder <= pc4out + shifted_signimm;
    --alu_result_adder <= std_logic_vector(unsigned(pc4out) + signed(shifted_signimm));
	alu_result_adder <= std_logic_vector(signed(pc4out) + signed(shifted_signimm));
	branchmuxselect <= ((branche and alu_zero) or (branchne and (not alu_zero)));

	----------------------------------------------------------------------------------
	-- Port Map of Components
	----------------------------------------------------------------------------------

    --- MODIFICADO: Instância do PC agora inclui PC_Enable para Stall ---
	PC     	 	: ProgramCounter port map (
        CLK       => CLK,
        Reset     => Reset,
        PC_Enable => s_pc_enable, -- Controlado pela CU
        PC_in     => pcin,
        PC_out    => pcout
    );

	PCA 		: ProgramCounterAdder port map (pcout, pc4out);
	SL 		 	: ShiftLefter port map (signimm, shifted_signimm);
	BranchMUX 	: Multiplexer generic map(32) port map (pc4out, alu_result_adder, branchmuxselect, branchmuxout);
	JumpMUX 	: Multiplexer generic map(32) port map (branchmuxout, jumpaddr, jump, pcin);
	IM 		 	: InstructionMemory port map (pcout, instruction);

    --- MODIFICADO: Instância da CU agora é síncrona (FSM) e controla o Stall ---
	CU 		 	: ControlUnit port map (
        CLK       => CLK,
        Reset     => Reset,
        FP_Ready  => s_fp_ready,  -- Entrada do FloPoCo
        Opcode    => opcode,
        RegDst    => regdst,
        Jump      => jump,
        Branch_E  => branche,
        Branch_NE => branchne,
        MemRead   => memread,
        MemtoReg  => memtoreg,    -- Saída de 2 bits
        ALUOp     => aluop,
        MemWrite  => memwrite,
        ALUSrc    => alusrc,
        RegWrite  => regwrite,
        PC_Enable => s_pc_enable, -- Saída para o PC
        FP_Start  => s_fp_start   -- Saída para o FloPoCo
    );

	RegDstMUX 	: Multiplexer generic map(5) port map (rt, rd, regdst, regdstmuxout);

    --- MODIFICADO: Instância do RF agora usa a saída do novo MUX de Write-Back ---
	RF 		 	: RegisterFile port map (
        CLK             => CLK,
        RegWrite        => regwrite,
        Read_Register_1 => rs,
        Read_Register_2 => rt,
        Write_Register  => regdstmuxout,
        Write_Data      => s_writeback_data, -- Vindo do MUX_4_1
        Read_Data_1     => rf_read_data_1,
        Read_Data_2     => rf_read_data_2
    );

	SE 		 	: SignExtender port map (immediate, signimm);
	ALUSrcMUX 	: Multiplexer generic map(32) port map (rf_read_data_2, signimm, alusrc, alusrcmuxout);
	ALUC 		: ArithmeticLogicUnitControl port map (funct, aluop, alu_operation);
	ALU 		: ArithmeticLogicUnit port map (rf_read_data_1, alusrcmuxout, alu_operation, alu_result, alu_zero);
	DM 			: DataMemory port map (CLK, alu_result, rf_read_data_2, memread, memwrite, dm_read_data);

    --- REMOVIDO: O MUX 2-para-1 antigo foi substituído ---
	-- MemtoRegMUX : Multiplexer generic map(32) port map (alu_result, dm_read_data, memtoreg, memtoregmuxout);

    --- NOVO: MUX 4-para-1 (usado como 3-para-1) para o Write-Back ---
    -- Seleciona qual resultado será escrito no RegisterFile
    WriteBackMUX : Multiplexer_4_1 generic map(32)
        port map (
            MUX_in_0   => alu_result,     -- "00": Resultado da ALU (Inteiros)
            MUX_in_1   => dm_read_data,   -- "01": Dado vindo da Memória (lw)
            MUX_in_2   => s_fp_result,    -- "10": Resultado do FloPoCo (FP)
            MUX_in_3   => (others => '0'),-- "11": Não utilizado
            MUX_select => memtoreg,     -- Sinal de 2 bits da CU
            MUX_out    => s_writeback_data
        );

    --- NOVO: Instância do wrapper do FloPoCo ---
    U_FP_ADDER : FPAdd32_wrapper
        port map (
            CLK   => CLK,
            Start => s_fp_start,       -- Controlado pela CU
            A     => rf_read_data_1,   -- Operando 1 (do RegFile)
            B     => rf_read_data_2,   -- Operando 2 (do RegFile)
            R     => s_fp_result,      -- Resultado (para o MUX de Write-Back)
            Ready => s_fp_ready        -- 'Pronto' (para a CU)
        );

end Behavioral;
