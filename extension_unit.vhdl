------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : extension_unit.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Immediate extension unit supporting RISC-V I, U, S, B, and J
--                type immediates. Extends 25-bit instruction slice
--                (instruction[31:7]) to a 32-bit signed value based on
--                the control input.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY extension_unit IS
    PORT (
        din  : IN  STD_LOGIC_VECTOR(31 DOWNTO 7);
        ctrl : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY extension_unit;

ARCHITECTURE Behavioral OF extension_unit IS
BEGIN
    PROCESS (din, ctrl)
        VARIABLE imm_val : SIGNED(31 DOWNTO 0) := (OTHERS => '0');
        VARIABLE s_imm   : STD_LOGIC_VECTOR(11 DOWNTO 0);
        VARIABLE b_imm   : STD_LOGIC_VECTOR(12 DOWNTO 0);
        VARIABLE j_imm   : STD_LOGIC_VECTOR(20 DOWNTO 0);
    BEGIN
        imm_val := (OTHERS => '0');

        CASE ctrl IS
            WHEN "010" => -- I-type immediate (bits 31 downto 20)
                imm_val := RESIZE(SIGNED(din(31 DOWNTO 20)), 32);

            WHEN "011" => -- U-type immediate (bits 31 downto 12, lower 12 bits zero)
                imm_val := SIGNED(din(31 DOWNTO 12) & (11 DOWNTO 0 => '0'));

            WHEN "100" => -- S-type immediate (bits 31 downto 25 & 11 downto 7)
                s_imm   := din(31 DOWNTO 25) & din(11 DOWNTO 7);
                imm_val := RESIZE(SIGNED(s_imm), 32);

            WHEN "101" => -- B-type immediate (bits 31, 7, 30 downto 25, 11 downto 8, 0)
                b_imm   := din(31) & din(7) & din(30 DOWNTO 25) & din(11 DOWNTO 8) & '0';
                imm_val := RESIZE(SIGNED(b_imm), 32);

            WHEN "110" => -- J-type immediate (bits 31, 19 downto 12, 20, 30 downto 21, 0)
                j_imm   := din(31) & din(19 DOWNTO 12) & din(20) & din(30 DOWNTO 21) & '0';
                imm_val := RESIZE(SIGNED(j_imm), 32);

            WHEN OTHERS =>
                imm_val := (OTHERS => '0');
        END CASE;

        dout <= STD_LOGIC_VECTOR(imm_val);
    END PROCESS;
END Behavioral;
