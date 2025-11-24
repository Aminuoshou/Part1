------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_riscv.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Top-level RISC-V CPU combining single-cycle datapath and control logic.
--                Executes basic load, store, branch, and arithmetic instructions.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY single_cycle_riscv IS
    PORT (
        clock    : IN STD_LOGIC;
        out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Structural OF single_cycle_riscv IS
    SIGNAL zero_flag                     : STD_LOGIC := '0';
    SIGNAL mem_write, reg_write          : STD_LOGIC := '0';
    SIGNAL alu_mux_sel, ret_mux_sel      : STD_LOGIC := '0';
    SIGNAL out_buf_ctrl, branch          : STD_LOGIC := '0';
    SIGNAL imm_sel                       : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_ctrl                      : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL opcode                        : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL funct3                        : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL funct7                        : STD_LOGIC := '0';

BEGIN

    datapath : ENTITY work.lw_sw_datapath(structural)
        PORT MAP(
            clock        => clock,
            mem_write    => mem_write,
            reg_write    => reg_write,
            alu_mux_sel  => alu_mux_sel,
            ret_mux_sel  => ret_mux_sel,
            out_buf_ctrl => out_buf_ctrl,
            imm_sel      => imm_sel,
            alu_ctrl     => alu_ctrl,
            branch       => branch,
            opcode       => opcode,
            funct3       => funct3,
            funct7       => funct7,
            zero_flag    => zero_flag,
            out_data     => out_data
        );

    control_unit : ENTITY work.controller(behavioral)
        PORT MAP(
            opcode       => opcode,
            funct3       => funct3,
            funct7       => funct7,
            zero_flag    => zero_flag,
            alu_mux_sel  => alu_mux_sel,
            ret_mux_sel  => ret_mux_sel,
            mem_write    => mem_write,
            reg_write    => reg_write,
            out_buf_ctrl => out_buf_ctrl,
            imm_sel      => imm_sel,
            alu_ctrl     => alu_ctrl,
            branch       => branch
        );
END Structural;
