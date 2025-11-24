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
        opcode      : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
        funct3      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        funct7      : IN  STD_LOGIC;
        zero_flag   : IN  STD_LOGIC;
        alu_mux_sel : OUT STD_LOGIC;
        ret_mux_sel : OUT STD_LOGIC;
        mem_write   : OUT STD_LOGIC;
        reg_write   : OUT STD_LOGIC;
        out_buf_ctrl: OUT STD_LOGIC;
        imm_sel     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_ctrl    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        branch      : OUT STD_LOGIC
    );
END controller;

ARCHITECTURE Behavioral OF controller IS
    -- "controls" is a compact control word encoding all the main control signals.
    -- Bit mapping (from MSB to LSB):
    --   [10]  - Branch enable
    --   [9]   - Selects ALU B operand source (0 = register, 1 = immediate)
    --   [8]   - Selects write-back data source (0 = ALU result, 1 = memory read)
    --   [7]   - Enables register file write
    --   [6]   - Enables data memory write
    --   [5:3] - Selects immediate format depending on the instruction type (I, S, etc.)
    --   [2:0] - ALU control operation code
    SIGNAL controls : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');

    -- added for visibility in simulation
    TYPE instruction IS (LW, SW, ADD, BEQ, NOP);
    SIGNAL instr : instruction := NOP;

    -- Instruction opcodes.
    CONSTANT OPCODE_LW  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011";
    CONSTANT OPCODE_SW  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100011";
    CONSTANT OPCODE_ADD : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0110011";
    CONSTANT OPCODE_BEQ : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100011";

    -- Control signals per instruction
    CONSTANT CTRL_LW  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01110010100";
    CONSTANT CTRL_SW  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01001100100";
    CONSTANT CTRL_ADD : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00010000100";
    CONSTANT CTRL_BEQ : STD_LOGIC_VECTOR(10 DOWNTO 0) := "10000101101";
    CONSTANT CTRL_NOP : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');

BEGIN
    out_buf_ctrl <= '1';

    decode : PROCESS (opcode, funct3, funct7)
    BEGIN
        controls <= CTRL_NOP;
        instr    <= NOP;

        CASE opcode IS
            WHEN OPCODE_LW =>
                instr    <= LW;
                controls <= CTRL_LW;

            WHEN OPCODE_SW =>
                instr    <= SW;
                controls <= CTRL_SW;

            WHEN OPCODE_ADD =>
                IF funct3 = "000" AND funct7 = '0' THEN
                    instr    <= ADD;
                    controls <= CTRL_ADD;
                END IF;

            WHEN OPCODE_BEQ =>
                IF funct3 = "000" THEN
                    instr    <= BEQ;
                    controls <= CTRL_BEQ;
                END IF;

            WHEN OTHERS =>
                instr    <= NOP;
                controls <= CTRL_NOP;
        END CASE;
    END PROCESS;

    -- controller output assignments
    branch      <= controls(10) AND zero_flag;
    alu_mux_sel <= controls(9);
    ret_mux_sel <= controls(8);
    reg_write   <= controls(7);
    mem_write   <= controls(6);
    imm_sel     <= controls(5 DOWNTO 3);
    alu_ctrl    <= controls(2 DOWNTO 0);

END Behavioral;
