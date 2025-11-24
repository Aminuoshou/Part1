------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_controller.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Single-cycle control unit for a simple RISC-V processor.
--                Decodes opcode, funct3, and funct7 fields to generate
--                ALU, memory, and register control signals.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY controller IS
    PORT (
        <dp_1>    : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        <dp_2>    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        <dp_3>    : IN STD_LOGIC;
        zero_flag : IN STD_LOGIC;
        <dp_11>   : OUT STD_LOGIC;
        <dp_14>   : OUT STD_LOGIC;
        <dp_13>   : OUT STD_LOGIC;
        <dp_10>   : OUT STD_LOGIC;
        <dp_15>   : OUT STD_LOGIC;
        <dp_8>    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        <dp_12>   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END controller;

ARCHITECTURE Behavioral OF controller IS
    -- "controls" is a compact control word encoding all the main control signals.
    -- Bit mapping (from MSB to LSB):
    --   [9]   - Selects ALU B operand source (0 = register, 1 = immediate)
    --   [8]   - Selects write-back data source (0 = ALU result, 1 = memory read)
    --   [7]   - Enables register file write
    --   [6]   - Enables data memory write
    --   [5:3] - Selects immediate format depending on the instruction type (I, S, etc.)
    --   [2:0] - ALU control operation code
    --
    -- Each instruction assigns a 10-bit pattern to "controls" that defines its
    -- full control behavior in a single line using the WITH-SELECT statement below.
    SIGNAL controls     : STD_LOGIC_VECTOR(9 DOWNTO 0);

    -- added for visibility in simulation
    TYPE instruction IS (LW, SW, ADD, NOP);
    SIGNAL instr : instruction := NOP;
    SIGNAL aux          : STD_LOGIC_VECTOR(10 DOWNTO 0);

    -- Instruction opcodes. add new values for each instruction
    CONSTANT OPCODE_LW  : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0000011";
    CONSTANT OPCODE_SW  : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0100011";
    CONSTANT OPCODE_ADD : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0110011";

    -- Control signals per instruction
    CONSTANT CTRL_LW  : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1110010100";
    CONSTANT CTRL_SW  : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1101011100";
    CONSTANT CTRL_ADD : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0010011100";
    CONSTANT CTRL_NOP : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";

BEGIN
    <dp_15> <= '1';
    aux <= <dp_3> & <dp_2> & <dp_1>;

    decode : PROCESS (<dp_1>, <dp_2>, <dp_3>)
    BEGIN
        controls <= CTRL_NOP;

        CASE op_code IS
            WHEN OPCODE_LW =>
                instr <= LW;
                controls <= CTRL_LW;
            WHEN OPCODE_SW =>
                instr <= SW;
                controls <= CTRL_SW;
            WHEN OPCODE_ADD =>
                IF <dp_2> = "000" AND <dp_3> = '0' THEN
                    instr <= ADD;
                    controls <= CTRL_ADD;
                END IF;
            WHEN OTHERS =>
                instr <= NOP;
                controls <= CTRL_NOP;
        END CASE;
    END PROCESS;

    -- controller output assignments
    <dp_11> <= controls(9);
    <dp_14> <= controls(8);
    <dp_10> <= controls(7);
    <dp_13> <= controls(6);
    <dp_8>  <= controls(5 DOWNTO 3);
    <dp_12> <= controls(2 DOWNTO 0);

END Behavioral;
