--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner, C3C Harris
--| CREATED       : 03/14/2024
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
	 i_clk, i_reset  : in    std_logic;
     i_left, i_right : in    std_logic;
     o_lights_L      : out   std_logic_vector(2 downto 0);
     o_lights_R      : out   std_logic_vector(2 downto 0)
	 );
	end component thunderbird_fsm;

	-- test I/O signals
	-- input signals
	signal w_right : std_logic := '0';
	signal w_left : std_logic := '0';
    signal w_reset : std_logic := '0';
    signal w_clk : std_logic := '0';
    
    -- output signals
    signal w_lights_R : std_logic_vector(2 downto 0) := "000"; 
    signal w_lights_L : std_logic_vector(2 downto 0) := "000"; 
	
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	
-- Instantiate the Unit Under Test (UUT)
   uut: thunderbird_fsm port map (
          i_left => w_left,
          i_right => w_right,
          i_reset => w_reset,
          i_clk => w_clk,
          o_lights_L => w_lights_L,
          o_lights_R => w_lights_R
        );
        
  -- make clock process
   clk_proc : process
            begin
                w_clk <= '0';
                wait for k_clk_period/2;
                w_clk <= '1';
                wait for k_clk_period/2;
            end process;
            
  -- Simulation process
	sim_proc : process
	begin
	-- sequential timing		
    w_reset <= '1';
    wait for k_clk_period*1;
      assert w_lights_L = "000" report "bad reset" severity failure;
      assert w_lights_R = "000" report "bad reset" severity failure;
    w_reset <= '0';
    wait for k_clk_period*1;
    
    
    -- flip left signal and leave on indefinitely (should continue iterating through left signal process)
    
    w_left <= '1'; wait for k_clk_period;
    assert w_lights_L = "001" report "bad left signal" severity failure;
    wait for k_clk_period;
    -- next left light should turn on
    assert w_lights_L = "011" report "bad left signal" severity failure;
    wait for k_clk_period;
    -- all three left lights should be on
    assert w_lights_L = "111" report "bad left signal" severity failure;
    wait for k_clk_period;
    -- should return to OFF state
    assert w_lights_L = "000" report "bad left signal" severity failure;
    assert w_lights_R = "000" report "bad left signal" severity failure;
    -- since left signal is still flipped, process should iterate. one left light should be on and all right lights still off
    wait for k_clk_period;
    assert w_lights_L = "001" report "bad left signal" severity failure;
    assert w_lights_R = "000" report "bad left signal" severity failure;
    
    -- turn left signal off while left signal in process (should continue through process)
    
    --wait for k_clk_period;
    w_left <= '0';
    wait for k_clk_period;
    assert w_lights_L = "011" report "incorrect when turning left switch off during process" severity failure;
    
      -- hit reset while left signal in process (should immediately turn off)
      
    
     w_reset <= '1'; wait for k_clk_period;
     assert w_lights_L = "000" report "bad reset during left turn" severity failure;
     assert w_lights_R = "000" report "bad reset during left turn" severity failure;
     w_reset <= '0'; wait for k_clk_period;
         
    -- flip right signal and leave on indefinitely (should continue iterating through right signal process)
    
    w_right <= '1'; wait for k_clk_period;
    assert w_lights_R = "001" report "bad right signal" severity failure;
    wait for k_clk_period;
    -- next right light should turn on
    assert w_lights_R = "011" report "bad right signal" severity failure;
    wait for k_clk_period;
    -- all three right lights should be on
    assert w_lights_R = "111" report "bad right signal" severity failure;
    wait for k_clk_period;
    -- should return to OFF state
    assert w_lights_L = "000" report "bad right signal" severity failure;
    assert w_lights_R = "000" report "bad right signal" severity failure;
    -- since right signal is still flipped, process should iterate. one right light should be on and all left lights still off
    wait for k_clk_period;
    assert w_lights_R = "001" report "bad right signal" severity failure;
    assert w_lights_L = "000" report "bad right signal" severity failure;
    
    -- turn right signal off while right signal in process (should continue through process)
        
        
        w_right <= '0'; wait for k_clk_period;
        assert w_lights_R = "011" report "incorrect when turning right switch off during process" severity failure;
       
        
     -- hit reset while right signal in process (should immediately turn off)
          
        
         w_reset <= '1'; wait for k_clk_period;
         assert w_lights_L = "000" report "bad reset during right turn" severity failure;
         assert w_lights_R = "000" report "bad reset during right turn" severity failure;
         w_reset <= '0';
    
        -- flip both right and left signals on (all lights should blink)
        
        wait for k_clk_period;
        w_right <= '1';
        w_left <= '1';
        -- ensure it begins blinking both lights
         wait for k_clk_period;
         assert w_lights_L = "111" report "incorrect when both L/R switched on" severity failure;
         assert w_lights_R = "111" report "incorrect when both L/R switched on" severity failure;
         
         wait for k_clk_period;
         assert w_lights_L = "000" report "incorrect when both L/R switched on" severity failure;
         assert w_lights_R = "000" report "incorrect when both L/R switched on" severity failure;
         
         wait for k_clk_period;
         assert w_lights_L = "111" report "incorrect when both L/R switched on" severity failure;
         assert w_lights_R = "111" report "incorrect when both L/R switched on" severity failure;
         
         wait;
         end process;
    
end test_bench;
