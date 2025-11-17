library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    port (
          -- Sinais de FSM e Stall
          CLK       : in  STD_LOGIC;
          Reset     : in  STD_LOGIC;
          FP_Ready  : in  STD_LOGIC;
          Opcode    : in  STD_LOGIC_VECTOR (5 downto 0);

          -- Sinais de Controle
		  RegDst    : out  STD_LOGIC;
		  Jump      : out  STD_LOGIC;
		  Branch_E  : out  STD_LOGIC;
		  Branch_NE : out  STD_LOGIC;
		  MemRead   : out  STD_LOGIC;
		  MemtoReg  : out  STD_LOGIC_VECTOR (1 downto 0);
		  ALUOp     : out  STD_LOGIC_VECTOR (1 downto 0);
		  MemWrite  : out  STD_LOGIC;
		  ALUSrc    : out  STD_LOGIC;
		  RegWrite  : out  STD_LOGIC;
          PC_Enable : out STD_LOGIC;
          FP_Start  : out STD_LOGIC
	 );
end ControlUnit;

architecture Behavioral of ControlUnit is
    type t_state is (S_FETCH_EXEC, S_WAIT_FP);
    signal state, next_state : t_state;

    signal RegDst_i, Jump_i, Branch_E_i, Branch_NE_i, MemRead_i, MemWrite_i, ALUSrc_i, RegWrite_i : STD_LOGIC;
    signal MemtoReg_i : STD_LOGIC_VECTOR (1 downto 0);
    signal ALUOp_i    : STD_LOGIC_VECTOR (1 downto 0);
    signal PC_Enable_i, FP_Start_i : STD_LOGIC;

begin

    -- Processo 1: Registrador de Estado (Síncrono)
    process (CLK, Reset)
    begin
        if Reset = '1' then
            state <= S_FETCH_EXEC;
        elsif rising_edge(CLK) then
            state <= next_state;
        end if;
    end process;

    -- Processo 2: Lógica Combinacional (Próximo estado e Saídas)
    process (state, Opcode, FP_Ready)
    begin
        -- Valores padrão
        RegDst_i    <= '0';
        Jump_i      <= '0';
        Branch_E_i  <= '0';
        Branch_NE_i <= '0';
        MemRead_i   <= '0';
        MemtoReg_i  <= "00"; -- Padrão: resultado da ALU
        ALUOp_i     <= "00";
        MemWrite_i  <= '0';
        ALUSrc_i    <= '0';
        RegWrite_i  <= '0';
        PC_Enable_i <= '1'; -- Padrão: PC avança
        FP_Start_i  <= '0';
        next_state  <= S_FETCH_EXEC;

        case state is
            when S_FETCH_EXEC =>
                PC_Enable_i <= '1';

                case Opcode is
                    when "000000" => -- R-type
                        RegDst_i    <= '1';
                        ALUOp_i     <= "10";
                        RegWrite_i  <= '1';

                    when "100011" => -- lw
                        MemRead_i   <= '1';
                        MemtoReg_i  <= "01";
                        ALUSrc_i    <= '1';
                        RegWrite_i  <= '1';

                    when "101011" => -- sw
                        MemWrite_i  <= '1';
                        ALUSrc_i    <= '1';

                    when "000100" => -- beq
                        Branch_E_i  <= '1';
                        ALUOp_i     <= "01";

                    when "000101" => -- bne
                        Branch_NE_i <= '1';
                        ALUOp_i     <= "01";

                    when "000010" => -- j
                        Jump_i      <= '1';

                    -- ########## INSTRUÇÃO DE PONTO FLUTUANTE ##########
                    when "010001" => -- COP1 (Nossa fadd customizada)

                        -- --- CORREÇÃO CRÍTICA ---
                        -- Ativa o RegDst para selecionar 'rd' (bits 15-11)
                        -- como o registrador de destino.
                        RegDst_i    <= '1';

                        FP_Start_i  <= '1';
                        PC_Enable_i <= '0'; -- Trava o PC (STALL)
                        RegWrite_i  <= '0'; -- Desabilita escrita (esperando)
                        next_state  <= S_WAIT_FP;

                    when others => null;
                end case;

            when S_WAIT_FP =>
                PC_Enable_i <= '0'; -- Mantém o PC travado
                FP_Start_i  <= '0';
                RegWrite_i  <= '0';

                if FP_Ready = '1' then
                    -- O FloPoCo terminou!
                    RegWrite_i  <= '1';   -- Habilita escrita
                    MemtoReg_i  <= "10";  -- Seleciona saída do FloPoCo
                    PC_Enable_i <= '1';   -- Libera o PC

                    -- --- CORREÇÃO CRÍTICA ---
                    -- Também precisamos do RegDst aqui, para garantir
                    -- que o destino 'rd' seja usado no ciclo de escrita.
                    RegDst_i    <= '1';

                    next_state  <= S_FETCH_EXEC;
                else
                    -- FloPoCo ainda está ocupado
                    next_state  <= S_WAIT_FP;
                end if;
        end case;
    end process;

    -- Atribuição final para as portas de saída
    RegDst    <= RegDst_i;
    Jump      <= Jump_i;
    Branch_E  <= Branch_E_i;
    Branch_NE <= Branch_NE_i;
    MemRead   <= MemRead_i;
    MemtoReg  <= MemtoReg_i;
    ALUOp     <= ALUOp_i;
    MemWrite  <= MemWrite_i;
    ALUSrc    <= ALUSrc_i;
    RegWrite  <= RegWrite_i;
    PC_Enable <= PC_Enable_i;
    FP_Start  <= FP_Start_i;

end Behavioral;
