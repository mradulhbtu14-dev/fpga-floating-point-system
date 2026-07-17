library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_fsm is
end tb_fsm;

architecture arch of tb_fsm is

constant T : time := 20 ns;

signal clk, reset, m_next, push : std_logic;
signal stack_op : std_logic_vector(1 downto 0);
signal disp_sel : std_logic_vector(2 downto 0);
signal a_en, b_en, sum_en : std_logic;
signal comp_en, con_en, intcon_en : std_logic;

begin

fsm_unit : entity work.FSM_fps
port map (
    clk       => clk,
    reset     => reset,
    m_next    => m_next,
    push      => push,
    stack_op  => stack_op,
    disp_sel  => disp_sel,
    a_en      => a_en,
    b_en      => b_en,
    sum_en    => sum_en,
    comp_en   => comp_en,
    con_en    => con_en,
    intcon_en => intcon_en
);

-- clock
process
begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
end process;

-- stimulus
process
begin

    reset  <= '1';
    m_next <= '0';
    push   <= '0';

    wait for 2*T;

    reset <= '0';
    wait for T;

    -- load_stack push test
    push <= '1';
    wait for 1 ns;

    assert stack_op = "00"
    report "load_stack push failed"
    severity error;

    push <= '0';
    wait for T;

    -- leave load_stack -> add_pop_a
    m_next <= '1';
    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert (stack_op = "10" and a_en = '1')
    report "add_pop_a failed"
    severity error;

    -- add_pop_a automatically -> add_disp_a
    wait until rising_edge(clk);
    wait for 1 ns;

    assert disp_sel = "001"
    report "add_disp_a display failed"
    severity error;

    -- add_disp_a -> add_disp_b, pop/load b
    m_next <= '1';
    wait for 1 ns;

    assert (stack_op = "10" and b_en = '1')
    report "add_disp_a b_en failed"
    severity error;

    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert disp_sel = "010"
    report "add_disp_b display failed"
    severity error;

    -- add_disp_b -> add_disp_res, load sum
    m_next <= '1';
    wait for 1 ns;

    assert sum_en = '1'
    report "add_disp_b sum_en failed"
    severity error;

    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert disp_sel = "011"
    report "add_disp_res display failed"
    severity error;

    -- add_disp_res -> comp_pop_a
    m_next <= '1';
    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert (stack_op = "10" and a_en = '1')
    report "comp_pop_a failed"
    severity error;

    -- comp_pop_a -> comp_disp_a
    wait until rising_edge(clk);
    wait for 1 ns;

    assert disp_sel = "001"
    report "comp_disp_a display failed"
    severity error;

    -- comp_disp_a -> comp_disp_b
    m_next <= '1';
    wait for 1 ns;

    assert (stack_op = "10" and b_en = '1')
    report "comp_disp_a b_en failed"
    severity error;

    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert disp_sel = "010"
    report "comp_disp_b display failed"
    severity error;

    -- comp_disp_b -> comp_disp_res
    m_next <= '1';
    wait for 1 ns;

    assert comp_en = '1'
    report "comp_disp_b comp_en failed"
    severity error;

    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert disp_sel = "100"
    report "comp_disp_res display failed"
    severity error;

    -- comp_disp_res -> fpcon_pop_a
    m_next <= '1';
    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert (stack_op = "10" and a_en = '1')
    report "fpcon_pop_a failed"
    severity error;

    -- fpcon_pop_a -> fpcon_disp_a
    wait until rising_edge(clk);
    wait for 1 ns;

    assert disp_sel = "001"
    report "fpcon_disp_a display failed"
    severity error;

    -- fpcon_disp_a -> fpcon_disp_res
    m_next <= '1';
    wait for 1 ns;

    assert con_en = '1'
    report "fpcon_disp_a con_en failed"
    severity error;

    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert disp_sel = "101"
    report "fpcon_disp_res display failed"
    severity error;

    -- fpcon_disp_res -> intcon_cap
    m_next <= '1';
    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert intcon_en = '1'
    report "intcon_cap failed"
    severity error;

    -- intcon_cap -> intcon_disp
    wait until rising_edge(clk);
    wait for 1 ns;

    assert disp_sel = "110"
    report "intcon_disp display failed"
    severity error;

    -- intcon_disp -> next case add_pop_a
    m_next <= '1';
    wait until rising_edge(clk);
    m_next <= '0';
    wait for 1 ns;

    assert (stack_op = "10" and a_en = '1')
    report "loop back to add_pop_a failed"
    severity error;

    report "FSM basic sequence test passed";

    wait;

end process;

end arch;