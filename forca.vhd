--------------------------------------------------------------------------------
-- Project :jogo da forca
-- Autor   :João Pedro Sales e Brian José

--------------------------------------------------------------------------------
--  Palavra secreta = "323017"
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY forca IS
  PORT (

    Sw : in std_logic_vector (10 downto 0); -- o s(10) funciona como reset e os outros como números
    clock_50      : IN  std_logic;                    
                       
  
 hex0        : OUT std_logic_vector(6 DOWNTO 0);     -- um display pra cada casa do jogo             
 hex1        : OUT std_logic_vector(6 DOWNTO 0);                   
 hex2        : OUT std_logic_vector(6 DOWNTO 0);                   
 hex3        : OUT std_logic_vector(6 DOWNTO 0);                   
 hex4        : OUT std_logic_vector(6 DOWNTO 0);                  
 hex5        : OUT std_logic_vector(6 DOWNTO 0);                    
 hex6        : OUT std_logic_vector(6 DOWNTO 0); 
 ledg         : OUT std_logic_vector(2 DOWNTO 0)  -- 3 leds para indicar as 3 vidas                 
    );
END forca;


ARCHITECTURE TypeArchitecture OF forca IS

-- deslcaro os estados da máquina 

type estados is (esperando, zero, um, dois, tres,
			  quatro, cinco, seis, sete, oito, nove); -- possiveis estados 

signal estado_atual, prox_estado : estados;
signal estado_displays : std_logic_vector (5 downto 0); -- vetor armazena quais displays já foram chutados corretamente
											 
signal vidas : unsigned (1 downto 0) := "11"; -- indica o numero de vidas

signal P : std_logic ; -- sinal de que o jogador perdeu
signal G : std_logic ; -- sinal de que o jogador ganhou


BEGIN

-- process para fazer a mudança de estado
process (clock_50, sw(10))
begin 
	if (sw(10) = '1')then -- reset
		estado_atual <= esperando;
		
	elsif (rising_edge(clock_50) and (sw(10) = '0') and (p = '0') and (g = '0')) then
		estado_atual <= prox_estado;
		
	end if;
end process;

process (estado_atual, sw)
begin
	if  (sw = "01000000000" or
		sw = "00100000000" or
		sw = "00010000000" or
		sw = "00001000000" or
		sw = "00000100000" or
		sw = "00000010000" or
		sw = "00000001000" or
		sw = "00000000100" or
		sw = "00000000010" or
		sw = "00000000001") then -- serve para evitar que mais de um switch esteja ligado ao mesmo tempo
		
		if (sw(0) = '1')  then  -- armazena o proximo estado dependendo do switch ligado
			prox_estado <= zero;

		elsif (sw(1) = '1')  then
			prox_estado <= um;

		elsif (sw(2) = '1')  then
			prox_estado <= dois;

		elsif (sw(3) = '1')  then
			prox_estado <= tres;

		elsif (sw(4) = '1')  then
			prox_estado <= quatro;

		elsif (sw(5) = '1')  then
			prox_estado <= cinco;

		elsif (sw(6) = '1')  then
			prox_estado <= seis;

		elsif (sw(7) = '1')  then
			prox_estado <= sete;

		elsif (sw(8) = '1')  then
			prox_estado <= oito;

		elsif (sw(9) = '1')  then
			prox_estado <= nove;
			
		end if;

	else
		prox_estado <= estado_atual; -- caso haja dois switches ao mesmo tempo, o estado não muda

	end if;
end process;

-- nesse process ele armazena o valor '1' em uma posição do "estado_displays" caso esteja no respectivo estado
-- caso o estado seja um número não presente na senha, ele diminui uma vida. antes disso ele checa se aquele número já foi chutado

process (estado_atual)
variable erros : std_logic_vector (9 downto 0):= "0000000000"; -- vetor com 10 número que armazena quais números já foram chutados

begin 

	case estado_atual is
			when zero =>				
				estado_displays(3) <= '1';
			
			when um =>			
				estado_displays(4) <= '1';
			
			
			when dois =>				
				estado_displays(1) <= '1';
			
			when tres =>				
				estado_displays(0) <= '1';
				estado_displays(2) <= '1';			

			when quatro =>
				if erros (3) = '0' then
					erros(3) := '1';
					vidas <= vidas - 1;
				end if;

			when cinco =>
				if erros (4) = '0' then
					erros(4) := '1';
					vidas <= vidas - 1;
				end if;

			when seis =>
				if erros (5) = '0' then
					erros(5) := '1';
					vidas <= vidas - 1;
				end if;
				
			when sete =>				
				estado_displays(5) <= '1';

			when oito =>
				if erros (7) = '0' then
					erros(7) := '1';
					vidas <= vidas - 1;
				end if;

			when nove =>
				if erros (8) = '0' then
					erros(8) := '1';
					vidas <= vidas - 1;
				end if;
			
			
			when esperando =>
				estado_displays <= "000000";
				vidas <= "11";
				erros := "0000000000";
		
		end case;	
		
	end process;

-- esse process checa se o jogador venceu ou perdeu 
process (estado_displays, estado_atual, sw(10))
begin
	if estado_displays = "111111" then -- caso os 6 displays estejam acesos ele vence
		g <= '1';
	else
		g <= '0';
	end if;

	if vidas = "00" then -- caso as vidas acabem ele perde
		p <= '1';
	else
		p<= '0';
	end if;

end process;

--aqui os displays de 7 seg recebem as respectivos números

hex0 <= "1111000" when estado_displays(5) = '1' else
		"1110111";
		
hex1 <= "1111001" when estado_displays(4) = '1' else
		"1110111";

hex2 <= "1000000" when estado_displays(3) = '1' else
		"1110111";

hex3 <= "0110000" when estado_displays(2) = '1' else
		"1110111";

hex4 <= "0100100" when estado_displays(1) = '1' else
		"1110111";

hex5 <= "0110000" when estado_displays(0) = '1' else
		"1110111";

hex6 <= "0001100" when p = '1' else
		"1000010" when g = '1'else
		"1111111";


-- statment para que cada led represente uma vida
ledg <=   "111" when vidas = "11" else
		"011" when vidas = "10" else
		"001" when vidas = "01" else
		"000" when vidas = "00" else
		"000";


END TypeArchitecture;
