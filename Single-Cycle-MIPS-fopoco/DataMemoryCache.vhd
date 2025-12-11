library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemoryCache is
    port (
        CLK        : in STD_LOGIC;
        Reset      : in STD_LOGIC;
        Address    : in STD_LOGIC_VECTOR (31 downto 0);
        Write_Data : in STD_LOGIC_VECTOR (31 downto 0);
        MemRead    : in STD_LOGIC;
        MemWrite   : in STD_LOGIC;
        
        -- Saídas
        Read_Data  : out STD_LOGIC_VECTOR (31 downto 0);
        MemBusy    : out STD_LOGIC -- '1' = Cache Miss (Processador deve congelar)
    );
end DataMemoryCache;

architecture Behavioral of DataMemoryCache is

    -- --- ESTRUTURA DA CACHE ---
    -- Vamos usar:
    -- 16 Linhas (Index = 4 bits)
    -- Tag = 32 - 4 (Index) - 2 (Byte Offset) = 26 bits
    
    type CacheLine is record
        Valid : STD_LOGIC;
        Tag   : STD_LOGIC_VECTOR(25 downto 0);
        Data  : STD_LOGIC_VECTOR(31 downto 0);
    end record;
    
    type CacheArray is array (0 to 15) of CacheLine;
    signal Cache : CacheArray;

    -- --- MEMÓRIA PRINCIPAL (SIMULADA) ---
    type MainMemArray is array (0 to 127) of STD_LOGIC_VECTOR(31 downto 0);
    signal MainMem : MainMemArray := (
        0 => X"3FC00000", -- 1.5
        1 => X"40000000", -- 2.0
        others => X"00000000"
    );

    -- --- SINAIS INTERNOS ---
    signal index : integer range 0 to 15;
    signal tag_in : STD_LOGIC_VECTOR(25 downto 0);
    signal mem_addr_index : integer;
    
    -- Máquina de Estados
    type State_Type is (IDLE, COMPARE, ALLOCATE, WRITE_THROUGH);
    signal current_state : State_Type := IDLE;
    
    signal wait_counter : integer range 0 to 15 := 0;
    constant MISS_PENALTY : integer := 10; -- Penalidade de ciclos para buscar na RAM

begin

    -- Decodificação do Endereço
    -- Endereço: [Tag (31-6)] [Index (5-2)] [ByteOffset (1-0)]
    index <= TO_INTEGER(UNSIGNED(Address(5 downto 2))) mod 16;
    tag_in <= Address(31 downto 6);
    
    -- Índice linear para a Main Memory (simulação)
    mem_addr_index <= TO_INTEGER(UNSIGNED(Address(8 downto 2))); -- Pequeno slice para simulação

    process(CLK, Reset)
    begin
        if Reset = '1' then
            current_state <= IDLE;
            wait_counter <= 0;
            MemBusy <= '0';
            Read_Data <= (others => '0');
            -- Resetar cache valid bits
            for i in 0 to 15 loop
                Cache(i).Valid <= '0';
            end loop;
            
        elsif rising_edge(CLK) then
            case current_state is
                
                when IDLE =>
                    MemBusy <= '0';
                    if MemRead = '1' then
                        current_state <= COMPARE;
                        MemBusy <= '1'; -- Assume ocupado até verificar
                    elsif MemWrite = '1' then
                        current_state <= WRITE_THROUGH;
                        MemBusy <= '1';
                    end if;

                when COMPARE =>
                    -- Verifica se temos um HIT
                    if (Cache(index).Valid = '1' and Cache(index).Tag = tag_in) then
                        -- CACHE HIT!
                        Read_Data <= Cache(index).Data;
                        MemBusy <= '0'; -- Libera processador
                        current_state <= IDLE;
                    else
                        -- CACHE MISS!
                        wait_counter <= 0;
                        current_state <= ALLOCATE; -- Vai buscar na RAM
                    end if;

                when ALLOCATE =>
                    -- Simula a lentidão da memória principal
                    MemBusy <= '1';
                    if wait_counter < MISS_PENALTY then
                        wait_counter <= wait_counter + 1;
                    else
                        -- Traz dado da RAM para Cache
                        if mem_addr_index >= 0 and mem_addr_index <= 127 then
                            Cache(index).Data <= MainMem(mem_addr_index);
                            Cache(index).Tag  <= tag_in;
                            Cache(index).Valid <= '1';
                            -- Entrega o dado imediatamente
                            Read_Data <= MainMem(mem_addr_index);
                        else
                            Read_Data <= (others => '0');
                        end if;
                        
                        MemBusy <= '0'; -- Miss resolvido
                        current_state <= IDLE;
                    end if;

                when WRITE_THROUGH =>
                    -- Escreve na Cache E na Memória (Write-Through)
                    MemBusy <= '1';
                    
                    -- Atualiza Cache (apenas se já estiver alocado ou sempre? Vamos forçar update)
                    Cache(index).Data <= Write_Data;
                    Cache(index).Tag  <= tag_in;
                    Cache(index).Valid <= '1';
                    
                    -- Atualiza RAM
                    if mem_addr_index >= 0 and mem_addr_index <= 127 then
                        MainMem(mem_addr_index) <= Write_Data;
                    end if;
                    
                    -- Simula 1 ciclo de escrita ou mais se quiser
                    MemBusy <= '0';
                    current_state <= IDLE;

            end case;
        end if;
    end process;

end Behavioral;