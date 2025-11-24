------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : instruction_memory.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 1 KB instruction memory (ROM) storing a simple RISC-V program.
--                Provides 32-bit instruction fetch based on byte address.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY instr_mem IS
    PORT (
        address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF instr_mem IS

    -- Byte-addressable ROM
    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT ROM : memory_data := (
        -- Program (little-endian)
        -- 0x0044A303   lw x6, 4(x9)
        0 => x"03", 1 => x"A3", 2 => x"44", 3 => x"00",
        -- 0x00630463   beq x6, x6, +8
        4 => x"63", 5 => x"04", 6 => x"63", 7 => x"00",
        -- 0x0064A423   sw x6, 8(x9)
        8 => x"23", 9 => x"A4", 10 => x"64", 11 => x"00",
        -- 0x00C02103   lw x2, 12(x0)
        12 => x"03", 13 => x"21", 14 => x"C0", 15 => x"00",
        -- 0x0084A383   lw x7, 8(x9)
        16 => x"83", 17 => x"A3", 18 => x"84", 19 => x"00",
        -- 0x00710433   add x8, x2, x7
        20 => x"33", 21 => x"04", 22 => x"71", 23 => x"00",
        OTHERS => (OTHERS => '0')
    );

    SIGNAL addr_int : INTEGER := 0;

BEGIN
    addr_int <= to_integer(unsigned(address(9 DOWNTO 0))); -- Address conversion fits 1 KB of ROM

    -- read 4 consecutive bytes form one 32-bit word
    data <= ROM(addr_int + 3) &
            ROM(addr_int + 2) &
            ROM(addr_int + 1) &
            ROM(addr_int);

END ARCHITECTURE rtl;
