library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---16,100 para simulacion rapida
entity relojdigitalv1 is
port (
  clk50mhz: 	in STD_LOGIC;
  Simuhora: in STD_LOGIC;
  displaymin: 	out STD_LOGIC_VECTOR(7 downto 0);
  display10min: 	out STD_LOGIC_VECTOR(7 downto 0);
  displayh: 	out STD_LOGIC_VECTOR(7 downto 0);
  display10h: 	out STD_LOGIC_VECTOR(7 downto 0)
);
end relojdigitalv1;

architecture relojito of relojdigitalv1 is
  constant max_tictac: INTEGER := 2; -- 50000000/2 ---flancos 10 para simu og 25000000
  signal tictac: INTEGER range 0 to max_tictac;--cuentaflancos
  signal clk_state: STD_LOGIC := '0';--bit de segundo
  shared variable hora1, hora2, min1, min2: INTEGER range 0 to 10 := 0; 
  shared variable segundos: INTEGER range 0 to 59 := 0;
	
  begin
    gen_clock: process(clk50mhz, clk_state, tictac)
    begin
	if clk50mhz'event and clk50mhz='1' then --cada que evento flanco H en reloj
		-- contador 1HZ
		if tictac < max_tictac then 
			tictac <= tictac + 1;
		else
			clk_state <= not clk_state; --invierte el bit para generar 1 hz signal y reinicia contador
			tictac <= 0;
		end if;
        end if; 
    end process; 

  show_display: process(clk_state) --actualiza displays cada 1Hz
        begin -- selección del display          
            -- mostrar hora 
            case hora2 is
		when 0 => display10h <= "11000000"; -- 0 
		when 1 => display10h <= "11111001"; -- 1
		when 2 => display10h <= "10100100"; -- 2
		when 3 => display10h <= "10110000"; -- 3
		when 4 => display10h <= "10011001"; -- 4
		when 5 => display10h <= "10010010"; -- 5
		when 6 => display10h <= "10000011"; -- 6
		when 7 => display10h <= "11111000"; -- 7 
		when 8 => display10h <= "10000000"; -- 8
		when 9 => display10h <= "10010000"; -- 9
		when others => display10h <= "11111111";
	end case;
	case hora1 is
		when 0 => displayh <= "11000000"; -- 0 
		when 1 => displayh <= "11111001"; -- 1
		when 2 => displayh <= "10100100"; -- 2
		when 3 => displayh <= "10110000"; -- 3
		when 4 => displayh <= "10011001"; -- 4
		when 5 => displayh <= "10010010"; -- 5
		when 6 => displayh <= "10000011"; -- 6
		when 7 => displayh <= "11111000"; -- 7 
		when 8 => displayh <= "10000000"; -- 8
		when 9 => displayh <= "10010000"; -- 9
		when others => displayh <= "11111111";
	end case;
	case min2 is
		when 0 => display10min <= "11000000"; -- 0 
		when 1 => display10min <= "11111001"; -- 1
		when 2 => display10min <= "10100100"; -- 2
		when 3 => display10min <= "10110000"; -- 3
		when 4 => display10min <= "10011001"; -- 4
		when 5 => display10min <= "10010010"; -- 5
		when 6 => display10min <= "10000011"; -- 6
		when 7 => display10min <= "11111000"; -- 7 
		when 8 => display10min <= "10000000"; -- 8
		when 9 => display10min <= "10010000"; -- 9
		when others => display10min <= "11111111";
	end case;
	case min1 is
		when 0 => displaymin <= "11000000"; -- 0 
		when 1 => displaymin <= "11111001"; -- 1
		when 2 => displaymin <= "10100100"; -- 2
		when 3 => displaymin <= "10110000"; -- 3
		when 4 => displaymin <= "10011001"; -- 4
		when 5 => displaymin <= "10010010"; -- 5
		when 6 => displaymin <= "10000011"; -- 6
		when 7 => displaymin <= "11111000"; -- 7 
		when 8 => displaymin <= "10000000"; -- 8
		when 9 => displaymin <= "10010000"; -- 9
		when others => displaymin <= "11111111";
	end case;
	    -- parpadeo del punto
	    displayh(7) <= clk_state;
  end process;
	-----PARTE DE ESTADOS
  persecond: process (clk_state)  --cambia los estados y conteos cada segundo
  begin
	if clk_state'event and clk_state='1' then
		
		-- contador de segundos y minutero
if Simuhora = '0' then
    if segundos < 59 then
        segundos := segundos + 1;
    else 
        segundos := 0;
        min1 := min1 + 1; -- +1 minuto
    end if;
elsif Simuhora = '1' then
    if segundos < 2 then --cada 2 seg avanza
        segundos := segundos + 1;
    else 
        segundos := 0;
        min1 := min1 + 5; -- +5 minuto
    end if;
end if;

		--ORIGINAL
--		if segundos < 59 then
--			segundos := segundos + 1;
--		else 
--			segundos := 0;
--			min1 := min1 + 1; -- +1 minuto
--		end if;
		
		-- segundo dígito minutero y reset cada 10
		if min1 = 10 then
			min2 := min2 + 1;
			min1 := 0;
		end if;
		
		-- primer dígito hora -cambio a 6/10m reinicio 10minutero 
		if min2 = 6 then
			hora1 := hora1 + 1;
			min2 := 0;
		end if;
		
		-- segundo dígito hora --cambio a 10h y reinicio de hora
		if hora1 = 10 then
			hora2 := hora2 + 1;
			hora1 := 0;
		end if;
			
		if hora2=2 and hora1=4 then --vuelta de 24h a cero
			hora2 := 0;
			hora1 := 0;
		end if;
	end if;
  end process;
	
end relojito;