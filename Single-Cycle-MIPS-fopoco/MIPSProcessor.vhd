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

	-- COMPONENTES
	component ProgramCounter is
		port (
			CLK    : in STD_LOGIC;
			Reset  : in STD_LOGIC;
			PC_in  : in STD_LOGIC_VECTOR(31 downto 0);
			PC_out : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

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

	component FPMult32_wrapper is
		port (
			CLK   : in  STD_LOGIC;
			Start : in  STD_LOGIC;
			A     : in  STD_LOGIC_VECTOR(31 downto 0);
			B     : in  STD_LOGIC_VECTOR(31 downto 0);
			R     : out STD_LOGIC_VECTOR(31 downto 0);
			Ready : out STD_LOGIC
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

	component ControlUnit is
		port (
		  Opcode    : in  STD_LOGIC_VECTOR (5 downto 0);
		  RegDst    : out  STD_LOGIC;
		  Jump      : out  STD_LOGIC;
		  Branch_E  : out  STD_LOGIC;
		  Branch_NE : out  STD_LOGIC;
		  MemRead   : out  STD_LOGIC;
		  MemtoReg  : out  STD_LOGIC;
		  ALUOp     : out  STD_LOGIC_VECTOR (1 downto 0);
		  MemWrite  : out  STD_LOGIC;
		  ALUSrc    : out  STD_LOGIC;
		  RegWrite  : out  STD_LOGIC
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

	-- SINAIS
	signal pcin, pcin_normal, pcout, pc4out : STD_LOGIC_VECTOR(31 downto 0);
	signal instruction : STD_LOGIC_VECTOR(31 downto 0);
	signal rs, rd, rt : STD_LOGIC_VECTOR(4 downto 0);
	signal opcode : STD_LOGIC_VECTOR(5 downto 0);
	signal immediate : STD_LOGIC_VECTOR(15 downto 0);
	signal funct : STD_LOGIC_VECTOR(5 downto 0);
	signal jumpinst : STD_LOGIC_VECTOR(25 downto 0);
	signal regdst, jump, branche, branchne, memread, memtoreg, memwrite, alusrc, regwrite : STD_LOGIC;
	signal aluop : STD_LOGIC_VECTOR(1 downto 0);
	signal regdstmuxout : STD_LOGIC_VECTOR(4 downto 0);
	signal memtoregmuxout, alusrcmuxout, branchmuxout : STD_LOGIC_VECTOR(31 downto 0);
	signal branchmuxselect : STD_LOGIC;
	signal rf_read_data_1, rf_read_data_2, dm_read_data : STD_LOGIC_VECTOR(31 downto 0);
	signal signimm, shifted_signimm, jumpaddr, alu_result, alu_result_adder : STD_LOGIC_VECTOR(31 downto 0);
	signal alu_operation : STD_LOGIC_VECTOR(3 downto 0);
	signal alu_zero : STD_LOGIC;

	-- Sinais FP
	signal isFP, fp_is_add, fp_is_mul, fp_busy, fp_op_add_started : STD_LOGIC := '0';
	signal fp_result_add, fp_result_mul, fp_result : STD_LOGIC_VECTOR(31 downto 0);
	signal fp_ready_add, fp_ready_mul, fp_start_add, fp_start_mul, fp_current_is_add, fp_ready_any : STD_LOGIC;

	-- *** CORREÇÃO: Buffer para salvar o registrador de destino ***
	signal fp_dest_reg_stored : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

	-- Sinais Efetivos
	signal regwrite_eff, memread_eff, memwrite_eff : STD_LOGIC;
	signal write_reg_eff : STD_LOGIC_VECTOR(4 downto 0);
	signal wb_data : STD_LOGIC_VECTOR(31 downto 0);

begin

	-- DECODIFICAÇÃO
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

    alu_result_adder <= std_logic_vector(signed(pc4out) + signed(shifted_signimm));
	branchmuxselect <= ((branche and alu_zero) or (branchne and (not alu_zero)));

	-- DATAPATH
	PC     	 	: ProgramCounter port map (CLK, Reset, pcin, pcout);
	PCA 		: ProgramCounterAdder port map (pcout, pc4out);
	SL 		 	: ShiftLefter port map (signimm, shifted_signimm);
	BranchMUX 	: Multiplexer generic map(32) port map (pc4out, alu_result_adder, branchmuxselect, branchmuxout);
	JumpMUX 	: Multiplexer generic map(32) port map (branchmuxout, jumpaddr, jump, pcin_normal);

    -- Lógica de Stall do PC
    pcin <= pcin_normal when fp_busy = '0' else pcout;

    IM 		 	: InstructionMemory port map (pcout, instruction);
	CU 		 	: ControlUnit port map (opcode, regdst, jump, branche, branchne, memread, memtoreg, aluop, memwrite, alusrc, regwrite);
	RegDstMUX 	: Multiplexer generic map(5) port map (rt, rd, regdst, regdstmuxout);

    -- Register File usa write_reg_eff e regwrite_eff
    RF 		  	: RegisterFile port map (CLK, regwrite_eff, rs, rt, write_reg_eff, wb_data, rf_read_data_1, rf_read_data_2);
	SE 		 	: SignExtender port map (immediate, signimm);
	ALUSrcMUX 	: Multiplexer generic map(32) port map (rf_read_data_2, signimm, alusrc, alusrcmuxout);
	ALUC 		: ArithmeticLogicUnitControl port map (funct, aluop, alu_operation);
	ALU 		: ArithmeticLogicUnit port map (rf_read_data_1, alusrcmuxout, alu_operation, alu_result, alu_zero);

    -- Memória de Dados usa memread_eff e memwrite_eff
    DM 			: DataMemory port map (CLK, alu_result, rf_read_data_2, memread_eff, memwrite_eff, dm_read_data);
    MemtoRegMUX : Multiplexer generic map(32) port map (alu_result, dm_read_data, memtoreg, memtoregmuxout);

	-- Ponto Flutuante
	FPADD 		: FPAdd32_wrapper  port map (CLK, fp_start_add,  rf_read_data_1, rf_read_data_2, fp_result_add, fp_ready_add);
	FPMUL 		: FPMult32_wrapper port map (CLK, fp_start_mul,  rf_read_data_1, rf_read_data_2, fp_result_mul, fp_ready_mul);

	-- Lógica de Controle FP
	isFP      <= '1' when opcode = "011111" else '0';
	fp_is_add <= '1' when (isFP = '1' and funct = "000000") else '0';
	fp_is_mul <= '1' when (isFP = '1' and funct = "000010") else '0';

	fp_start_add <= '1' when (fp_is_add = '1' and fp_busy = '0') else '0';
	fp_start_mul <= '1' when (fp_is_mul = '1' and fp_busy = '0') else '0';

	fp_ready_any <= (fp_current_is_add and fp_ready_add) or ((not fp_current_is_add) and fp_ready_mul);
	fp_result    <= fp_result_add when fp_current_is_add = '1' else fp_result_mul;

	-- *** LOGICA DE OVERRIDE (CORRIGIDA) ***

    -- Dado de escrita: Se FP pronto, usa FP. Senão, usa fluxo normal.
	wb_data <= fp_result when fp_ready_any = '1' else memtoregmuxout;

    -- *** CORREÇÃO PRINCIPAL: Destino da Escrita ***
    -- Se FP acabou de ficar pronto, use o registrador SALVO (fp_dest_reg_stored).
    -- Caso contrário, use a lógica normal.
	write_reg_eff <= fp_dest_reg_stored when fp_ready_any = '1' else regdstmuxout;

	-- Habilita escrita se for normal (e não FP) OU se FP terminou.
	regwrite_eff  <= (regwrite and (not isFP)) or fp_ready_any;

    -- *** CORREÇÃO: Bloqueia escrita na memória se estiver Ocupado esperando FP ***
    -- Se fp_busy='1', o processador está parado numa instrução SW. Não deixe ela escrever ainda!
	memread_eff   <= memread  when (isFP = '0' and fp_busy = '0') else '0';
	memwrite_eff  <= memwrite when (isFP = '0' and fp_busy = '0') else '0';

	-- FSM de Controle FP com Buffer de Destino
	process(CLK, Reset)
	begin
        if Reset = '1' then
            fp_busy <= '0';
            fp_current_is_add <= '0';
            fp_dest_reg_stored <= (others => '0');
		elsif rising_edge(CLK) then
			if fp_busy = '0' then
				if (fp_start_add = '1') or (fp_start_mul = '1') then
					fp_busy <= '1';
                    -- *** SALVA O DESTINO AGORA, ANTES QUE O PC MUDE ***
                    fp_dest_reg_stored <= rd;

                    if fp_start_add = '1' then
                        fp_current_is_add <= '1';
                    else
                        fp_current_is_add <= '0';
                    end if;
				end if;
			else
				if fp_current_is_add = '1' then
					if fp_ready_add = '1' then
						fp_busy <= '0';
					end if;
				else
					if fp_ready_mul = '1' then
						fp_busy <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	Debug_WB_En   <= regwrite_eff;
	Debug_WB_Reg  <= write_reg_eff;
	Debug_WB_Data <= wb_data;
	Debug_PC      <= pcout;

end Behavioral;
