library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_VHDL is
    Port (
        clk : in STD_LOGIC;  -- 50-MHz clock
        sf_e : out STD_LOGIC; -- LCD access enable
        e : out STD_LOGIC;   -- Enable
        rs : out STD_LOGIC;  -- Register Select
        rw : out STD_LOGIC;  -- Read/Write
        db_4 : out STD_LOGIC;   -- Data bit 4
        db_3 : out STD_LOGIC;   -- Data bit 3
        db_2 : out STD_LOGIC;   -- Data bit 2
        db_1 : out STD_LOGIC    -- Data bit 1
    );
end LCD_VHDL;

architecture Behavioral of LCD_VHDL is
    signal count : STD_LOGIC_VECTOR(26 downto 0) := (others => '0'); -- 27-bit counter
    signal code : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');   -- Command/data to send
    signal refresh : STD_LOGIC := '0';                              -- Refresh LCD rate
begin

    process(clk)
    begin
        if rising_edge(clk) then
            -- Increment counter
            count <= count + 1;

            -- State machine for LCD control
            case count(26 downto 21) is
                when "000000" => code <= "000011"; -- Power-on init sequence
                when "000001" => code <= "000011"; -- Repeat power-on sequence
                when "000010" => code <= "000011"; -- Ensure initialization
                when "000011" => code <= "000010"; -- Transition to 4-bit mode

                -- Function Set
                when "000100" => code <= "000010"; -- Upper nibble 0010
                when "000101" => code <= "001000"; -- Lower nibble 1000

                -- Entry Mode Set
                when "000110" => code <= "000000"; -- Upper nibble 0000
                when "000111" => code <= "000110"; -- Lower nibble 0110 (increment, no shift)

                -- Display On/Off Control
                when "001000" => code <= "000000"; -- Upper nibble 0000
                when "001001" => code <= "001100"; -- Lower nibble 1100 (Display ON, cursor OFF)

                -- Clear Display
                when "001010" => code <= "000000"; -- Upper nibble 0000
                when "001011" => code <= "000001"; -- Lower nibble 0001 (Clear)

                -- Write "SSE"
                when "001100" => code <= "100101"; -- 'S' upper nibble
                when "001101" => code <= "100011"; -- 'S' lower nibble
                when "001110" => code <= "100101"; -- 'S' upper nibble
                when "001111" => code <= "100011"; -- 'S' lower nibble
                when "010000" => code <= "100100"; -- 'E' upper nibble
                when "010001" => code <= "100101"; -- 'E' lower nibble
            
                -- Set Cursor to 2nd Line
                when "011000" => code <= "001100"; -- Cursor to 2nd line (upper nibble)
                when "011001" => code <= "000000"; -- Lower nibble

                -- Write "ENSIAS"
                when "011010" => code <= "100100"; 
                when "011011" => code <= "100101"; 
                when "011100" => code <= "100100";
                when "011101" => code <= "101110"; 
                when "011110" => code <= "100101"; 
                when "011111" => code <= "100011"; 
                when "100000" => code <= "100100"; 
                when "100001" => code <= "101001"; 
                when "100010" => code <= "100100"; 
                when "100011" => code <= "100001"; 
                when "100100" => code <= "100101"; 
                when "100101" => code <= "100011"; 

                -- Default case: Idle state
                when others => code <= "010000"; -- Default idle
            end case;

            -- Refresh logic
            refresh <= count(20); -- Toggles at ~25 Hz

            -- Output assignments
            sf_e <= '1'; -- Enable LCD access
            e <= refresh; -- Toggle enable signal
            rs <= code(5); -- RS is the MSB of `code`
            rw <= code(4); -- RW is the second MSB of `code`
            db_4 <= code(3); -- Data bit 4
            db_3 <= code(2); -- Data bit 3
            db_2 <= code(1); -- Data bit 2
            db_1 <= code(0); -- Data bit 1
        end if;
    end process;

end Behavioral;
