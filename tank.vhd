LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY tank IS
   PORT(SIGNAL RGB 						: OUT std_logic_vector(11 DOWNTO 0);
		SIGNAL pixel_row, pixel_column  : IN std_logic_vector(10 DOWNTO 0);
		SIGNAL game_mode				: IN std_logic_vector(2 DOWNTO 0);
        SIGNAL Horiz_sync, Vert_sync	: IN std_logic;
		SIGNAL Seed						: IN std_logic_vector(10 DOWNTO 0);
		SIGNAL left_button				: IN std_logic;
		SIGNAL mouse_col				: IN std_logic_vector(9 DOWNTO 0);
		SIGNAL sw9						: IN std_logic;
		SIGNAL score					: OUT std_logic_vector(7 DOWNTO 0);
		SIGNAL game_out					: OUT std_logic := '1');		
END tank;

architecture behavior of tank is 
SIGNAL Tank_on, Player_on, Bullet_on		: std_logic := '0';
SIGNAL Bonus_on, Special_on					: std_logic := '0';
SIGNAL s_score								: std_logic_vector(7 DOWNTO 0) := X"00";
SIGNAL s_active, s_active2					: std_logic := '0';
SIGNAL Bullet_Y_motion						: std_logic_vector(10 DOWNTO 0);
SIGNAL Bullet_Y_pos, Bullet_X_pos			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320, 11);
SIGNAL Special_Y_motion						: std_logic_vector(10 DOWNTO 0);
SIGNAL Special_Y_pos, Special_X_pos			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320, 11);
SIGNAL Size, Bullet_Size					: std_logic_vector(10 DOWNTO 0);  
SIGNAL Tank_X_motion						: std_logic_vector(10 DOWNTO 0);
SIGNAL Tank_Y_pos, Tank_X_pos				: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50,11);
SIGNAL Bonus_X_motion						: std_logic_vector(10 DOWNTO 0);
SIGNAL Bonus_Y_pos, Bonus_X_pos				: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50,11);
SIGNAL Player_Y_pos, Player_X_pos			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320, 11);

BEGIN

Size <= CONV_STD_LOGIC_VECTOR(8,11);
Bullet_Size <= CONV_STD_LOGIC_VECTOR(4,11);
Player_Y_pos <= CONV_STD_LOGIC_VECTOR(430, 11);

-- இதை என்னும் பண்ணனும், இப்படியா விடமுடியாது 
RGB(0) <= '1' AND NOT Player_on AND NOT Bullet_on AND NOT Special_on;
RGB(1) <= '1' AND NOT Player_on AND NOT Bullet_on AND NOT Special_on;
RGB(2) <= '1' AND NOT Player_on AND NOT Bullet_on AND NOT Special_on;
RGB(3) <= '1' AND NOT Player_on AND NOT Bullet_on AND NOT Special_on;

RGB(4) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Bullet_on AND NOT Special_on;
RGB(5) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Bullet_on AND NOT Special_on;
RGB(6) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Bullet_on AND NOT Special_on;
RGB(7) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Bullet_on AND NOT Special_on;

RGB(8) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Player_on;
RGB(9) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Player_on;
RGB(10) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Player_on;
RGB(11) <= '1' AND NOT Tank_on AND NOT Bonus_on AND NOT Player_on;

RGB_Display: Process (game_mode, pixel_column, pixel_row, Size, Bullet_Size)
BEGIN
	IF game_mode = "001" OR game_mode = "010" OR game_mode = "100" OR game_mode = "110" THEN
		IF ('0' & Tank_X_pos <= pixel_column + Size) AND
		(Tank_X_pos + Size >= '0' & pixel_column) AND
		('0' & Tank_Y_pos <= pixel_row + Size) AND
		(Tank_Y_pos + Size >= '0' & pixel_row ) THEN
			Tank_on <= '1';
		ELSE
			Tank_on <= '0';
		END IF;
		
		IF game_mode = "100" OR game_mode = "110" THEN
			IF ('0' & Bonus_X_pos <= pixel_column + Size) AND
			(Bonus_X_pos + Size >= '0' & pixel_column) AND
			('0' & Bonus_Y_pos <= pixel_row + Size) AND
			(Bonus_Y_pos + Size >= '0' & pixel_row ) THEN
				Bonus_on <= '1';
			ELSE
				Bonus_on <= '0';
			END IF;
		ELSE
			Bonus_on <= '0';
		END IF;
		
		IF ('0' & Player_X_pos <= pixel_column + Size) AND
		(Player_X_pos + Size >= '0' & pixel_column) AND
		('0' & Player_Y_pos <= pixel_row + Size) AND
		(Player_Y_pos + Size >= '0' & pixel_row ) THEN
			Player_on <= '1';
		ELSE
			Player_on <= '0';
		END IF;
		
		IF s_active = '1' AND
		('0' & Bullet_X_pos <= pixel_column + Bullet_Size) AND
		(Bullet_X_pos + Bullet_Size >= '0' & pixel_column) AND
		('0' & Bullet_Y_pos <= pixel_row + Bullet_Size) AND
		(Bullet_Y_pos + Bullet_Size >= '0' & pixel_row ) THEN
			Bullet_on <= '1';
		ELSE
			Bullet_on <= '0';
		END IF;
		
		IF s_active2 = '1' AND
		('0' & Special_X_pos <= pixel_column + Bullet_Size) AND
		(Special_X_pos + Bullet_Size >= '0' & pixel_column) AND
		('0' & Special_Y_pos <= pixel_row + Bullet_Size) AND
		(Special_Y_pos + Bullet_Size >= '0' & pixel_row ) THEN
			Special_on <= '1';
		ELSE
			Special_on <= '0';
		END IF;
	END IF;
END process RGB_Display;

Move_Tank: process(vert_sync, game_mode, sw9)
	VARIABLE temp : std_logic_vector(3 DOWNTO 0) := X"0";
BEGIN
	IF sw9 = '0' THEN
		IF rising_edge(vert_sync) THEN
			
			IF game_mode = "000" THEN
				s_score <= X"00";
				game_out <= '1';
			END IF;
			
			IF game_mode = "000" OR game_mode = "011" OR game_mode = "101" OR game_mode = "111" THEN
				game_out <= '1';
				IF Seed >= (CONV_STD_LOGIC_VECTOR(640,11) - Size) THEN
					Tank_X_pos <= CONV_STD_LOGIC_VECTOR(640,11) - Size;
					Bonus_X_pos <= Size;
				ELSIF Seed <= Size THEN
					Tank_X_pos <= Size;
					Bonus_X_pos <= CONV_STD_LOGIC_VECTOR(640,11) - Size;
				ELSE
					Tank_X_pos <= Seed;
					Bonus_X_pos <= (CONV_STD_LOGIC_VECTOR(640,11) - Seed);
				END IF;
				
				Bonus_Y_pos <= CONV_STD_LOGIC_VECTOR(50,11);
				
				IF Seed(5) = '1' THEN
					Tank_X_motion <= - CONV_STD_LOGIC_VECTOR(2,11);
					Bonus_X_motion <= CONV_STD_LOGIC_VECTOR(2,11);
				ELSE	
					Tank_X_motion <= CONV_STD_LOGIC_VECTOR(2,11);
					Bonus_X_motion <= - CONV_STD_LOGIC_VECTOR(2,11);
				END IF;
				s_active <= '0';
				s_active2 <= '0';
				Player_X_pos <= CONV_STD_LOGIC_VECTOR(320, 11);
			ELSE
				-- टैंक  ௧

				IF ('0' & Tank_X_pos) >= CONV_STD_LOGIC_VECTOR(640,11) - Size THEN
					Tank_X_motion <= - CONV_STD_LOGIC_VECTOR(2,11);
				ELSIF Tank_X_pos <= Size THEN
					Tank_X_motion <= CONV_STD_LOGIC_VECTOR(2,11);
				END IF;

				Tank_X_pos <= Tank_X_pos + Tank_X_motion;
				
				-- टैंक ௨
				
				IF game_mode = "100" OR game_mode = "110" THEN
					IF ('0' & Bonus_X_pos) >= CONV_STD_LOGIC_VECTOR(640,11) - Size THEN
						Bonus_X_motion <= - CONV_STD_LOGIC_VECTOR(2,11);
					ELSIF Bonus_X_pos <= Size THEN
						Bonus_X_motion <= CONV_STD_LOGIC_VECTOR(2,11);
					END IF;

					Bonus_X_pos <= Bonus_X_pos + Bonus_X_motion;
				END IF;
				
				IF game_mode = "110" THEN
					IF temp = X"5" THEN
						Bonus_Y_pos <= Bonus_Y_pos + CONV_STD_LOGIC_VECTOR(1,11);
						temp := X"0";
					END IF;
					temp := temp + '1';
					
					IF s_active2 = '0' AND Seed(7) = '1' AND Seed(3) = '1' THEN
						s_active2 <= '1';
						Special_X_pos <= Tank_X_pos;
						Special_Y_pos <= Tank_Y_pos;
						Special_Y_motion <= CONV_STD_LOGIC_VECTOR(3,11);
					END IF;
				END IF;
				
				-- प्लेयर 
				
				IF ('0' & mouse_col) >= "0111000000" THEN
					Player_X_pos <= Player_X_pos + CONV_STD_LOGIC_VECTOR(2,11);
				ELSIF mouse_col <= "0100000000" THEN
					Player_X_pos <= Player_X_pos - CONV_STD_LOGIC_VECTOR(2,11);
				ELSE
					Player_X_pos <= Player_X_pos;
				END IF;
				
				-- बुलेट
				
				IF Bullet_Y_pos <= Bullet_Size THEN
					s_active <= '0';
				END IF;
				
				IF Special_Y_pos >= (CONV_STD_LOGIC_VECTOR(480,11) - Bullet_Size) THEN
					s_active2 <= '0';
				END IF;
				
				IF left_button = '1' AND s_active = '0' THEN
					s_active <= '1';
					Bullet_Y_pos <= Player_Y_pos;
					Bullet_X_pos <= Player_X_pos;
					Bullet_Y_motion <= - CONV_STD_LOGIC_VECTOR(3,11);
				END IF;
				
				IF s_active = '1' THEN
					Bullet_Y_pos <= Bullet_Y_pos + Bullet_Y_motion;
				END IF;
				
				IF s_active2 = '1' THEN
					Special_Y_pos <= Special_Y_pos + Special_Y_motion;
				END IF;
				
				-- कोल्लिसिओं ई बुलेट
				
				IF ('0' & Player_X_pos <= Special_X_pos + Size) AND
				(Player_X_pos + Size >= '0' & Special_X_pos) AND
				('0' & Player_Y_pos <= Special_Y_pos + Size) AND
				(Player_Y_pos + Size >= '0' & Special_Y_pos ) THEN
					s_active2 <= '0';
					game_out <= '0';
				END IF;
				
				-- कोल्लिसिओं टैंक ௧
				
				IF ('0' & Tank_X_pos <= Bullet_X_pos + Size) AND
				(Tank_X_pos + Size >= '0' & Bullet_X_pos) AND
				('0' & Tank_Y_pos <= Bullet_Y_pos + Size) AND
				(Tank_Y_pos + Size >= '0' & Bullet_Y_pos ) THEN
					s_active <= '0';
					s_score <= s_score + '1';
					Bullet_Y_pos <= Player_Y_pos;
					Bullet_X_pos <= Player_X_pos;
					
					IF Seed >= (CONV_STD_LOGIC_VECTOR(640,11) - Size) THEN
						Tank_X_pos <= CONV_STD_LOGIC_VECTOR(640,11) - Size;
					ELSIF Seed <= Size THEN
						Tank_X_pos <= Size;
					ELSE
						Tank_X_pos <= Seed;
					END IF;
					
					IF Seed(5) = '1' THEN
						Tank_X_motion <= - CONV_STD_LOGIC_VECTOR(2,11);
					ELSE
						Tank_X_motion <= CONV_STD_LOGIC_VECTOR(2,11);
					END IF;
				END IF;
				
				-- कोल्लिसिओं टैंक ௨
				
				IF ('0' & Bonus_X_pos <= Bullet_X_pos + Size) AND
				(Bonus_X_pos + Size >= '0' & Bullet_X_pos) AND
				('0' & Bonus_Y_pos <= Bullet_Y_pos + Size) AND
				(Bonus_Y_pos + Size >= '0' & Bullet_Y_pos ) THEN
					s_active <= '0';
					s_score <= s_score + '1';
					Bullet_Y_pos <= Player_Y_pos;
					Bullet_X_pos <= Player_X_pos;
					
					IF Seed >= (CONV_STD_LOGIC_VECTOR(640,11) - Size) THEN
						Bonus_X_pos <= Size;
					ELSIF Seed <= Size THEN		
						Bonus_X_pos <= CONV_STD_LOGIC_VECTOR(640,11) - Size;
					ELSE
						Bonus_X_pos <= Seed(0) & Seed(1) & Seed(2) & Seed(4) & Seed(5) & Seed(6) & Seed(8) & Seed(9) & Seed(10) & NOT Seed(3) & NOT Seed(7);
					END IF;
					
					Bonus_Y_pos <= CONV_STD_LOGIC_VECTOR(50,11);
					
					IF Seed(5) = '1' THEN
						Bonus_X_motion <= CONV_STD_LOGIC_VECTOR(2,11);
					ELSE
						Bonus_X_motion <= - CONV_STD_LOGIC_VECTOR(2,11);
					END IF;
				END IF;
				
				IF Bonus_Y_pos = (CONV_STD_LOGIC_VECTOR(480,11) - Size) THEN
					game_out <= '0';
				END IF;
			END IF;
		END IF;
	END IF;
END process Move_Tank;

score <= s_score;

END behavior;

