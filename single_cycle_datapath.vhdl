------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_datapath.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Structural implementation of a single-cycle RISC-V datapath.
--                Includes PC, instruction fetch, decode, ALU, memory, and write-back.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY lw_sw_datapath IS
    PORT (
        clock       : IN STD_LOGIC;
        <dp_13>     : IN STD_LOGIC;
        <dp_10>     : IN STD_LOGIC;
        <dp_11>     : IN STD_LOGIC;
        <dp_14>     : IN STD_LOGIC;
        <dp_15>     : IN STD_LOGIC;
        <dp_8>      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        <dp_12>     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        <dp_1>      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        <dp_2>      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        <dp_3>      : OUT STD_LOGIC;
        zero_flag   : OUT STD_LOGIC;
        out_data   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF lw_sw_datapath IS

    SIGNAL pc, pc_next                      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, imm_ext, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, rd_data      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL result_mux_o                     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_mux_o                        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN
    <dp_1>   <= instruction(6 DOWNTO 0);
    <dp_2>   <= instruction(14 DOWNTO 12);
    <dp_3>   <= instruction(30);

------------------------------------------------------------------------
-- FETCH BLOCK
------------------------------------------------------------------------
    dp_pc : ENTITY work.program_counter(Behavioral)
        PORT MAP(
            clock   => clock,
            pc_out  => pc,
            pc_next => pc_next
        );

    dp_pc_adder : ENTITY work.pc_adder(structural)
        PORT MAP(
            pc_current => pc,
            pc_next    => pc_next
        );

    dp_instr_mem : ENTITY work.instr_mem(rtl)
        PORT MAP(
            address => pc,
            data    => instruction
        );

------------------------------------------------------------------------
-- DECODE BLOCK
------------------------------------------------------------------------
    dp_regfile : ENTITY work.register_file(behavioral)
        PORT MAP(
            clock    => clock,
            rs1_addr => <dp_4>,
            rs2_addr => <dp_5>,
            rd_addr  => <dp_6>,
            rd_data  => result_mux_o,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rd_we    => <dp_10>
        );

    -- TODO: Instantiate your immediate extension unit here.
    --       Connect it to the 'instruction(31 DOWNTO 7)' input,
    --       the 'imm_sel' control signal, and drive the 'imm_ext' output.

------------------------------------------------------------------------
-- EXECUTE & MEMORY BLOCK
------------------------------------------------------------------------
    dp_alu_src : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => rs2_data,
            in1   => imm_ext,
            out_y => alu_mux_o,
            sel   => <dp_11>
        );

    dp_alu : ENTITY work.alu(behavioral)
        PORT MAP(
            src_a     => rs1_data,
            src_b     => alu_mux_o,
            alu_ctrl  => <dp_12>,
            result    => alu_result,
            zero_flag => zero_flag
        );

    dp_data_mem : ENTITY work.data_mem(rtl)
        PORT MAP(
            clock      => clock,
            address    => alu_result,
            write_data => rs2_data,
            data       => rd_data,
            write_en   => <dp_13>
        );

------------------------------------------------------------------------
-- WRITE-BACK BLOCK
------------------------------------------------------------------------
    dp_result_src : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => alu_result,
            in1   => rd_data,
            out_y => result_mux_o,
            sel   => <dp_14>
        );

    dp_tri_state_buffer: ENTITY work.tri_state_buffer(Behavioral)
        PORT MAP(
            output_en => <dp_15>,
            buffer_input => result_mux_o,
            buffer_output=> out_data
        );

END structural;
