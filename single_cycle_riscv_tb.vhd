LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY single_cycle_riscv_tb IS
END ENTITY;

ARCHITECTURE tb OF single_cycle_riscv_tb IS

    -- DUT port signals
    SIGNAL clock    : STD_LOGIC                     := '0';
    SIGNAL out_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- DUT instance
    DUT : ENTITY work.single_cycle_riscv(structural)
        PORT MAP(
            clock    => clock,
            out_data => out_data
        );

    clk_process : PROCESS
    BEGIN
        FOR i IN 0 TO 11 LOOP
            clock <= '0';
            WAIT FOR 1 ns;
            clock <= '1';
            WAIT FOR 1 ns;
        END LOOP;
        WAIT;
    END PROCESS;

    monitor : PROCESS
        VARIABLE cycle : INTEGER := 0;
    BEGIN
        WAIT UNTIL rising_edge(clock);

        CASE cycle IS
            WHEN 0 =>
                ASSERT out_data = x"66BEDEAD"
                    REPORT "LW x6 from address 4 mismatch"
                    SEVERITY error;

            WHEN 1 =>
                ASSERT out_data = x"00000000"
                    REPORT "BEQ subtract not zero (branch should be taken)"
                    SEVERITY error;

            WHEN 2 =>
                ASSERT out_data = x"12DABEEF"
                    REPORT "LW x2 from address 12 mismatch"
                    SEVERITY error;

            WHEN 3 =>
                ASSERT out_data = x"88888888"
                    REPORT "LW x7 mismatch (branch failed to skip SW)"
                    SEVERITY error;

            WHEN 4 =>
                ASSERT out_data = x"9B634777"
                    REPORT "ADD x8 result mismatch"
                    SEVERITY error;
                REPORT "Single-cycle program completed" SEVERITY note;

            WHEN OTHERS =>
                NULL;
        END CASE;

        cycle := cycle + 1;
    END PROCESS;

END ARCHITECTURE;
