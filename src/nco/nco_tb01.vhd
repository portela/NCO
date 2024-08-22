library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;


Entity nco_tb01 is
end entity;

Architecture Behavior of nco_tb01 is
constant C_PHASE_WIDTH : integer := 10;
constant C_SINE_WITDH  : integer := 16;

signal rst : std_logic;
signal clk : std_logic;

signal enable : std_logic;
signal fcw    : std_logic_vector(C_PHASE_WIDTH-1 downto 0);
signal pcw    : std_logic_vector(C_PHASE_WIDTH-1 downto 0);
signal sine   : std_logic_vector(C_SINE_WITDH-1 downto 0);


constant clk_period     : time := 10 ns;
constant clk_duty_cycle : real := 0.5;
constant delta_t        : time := 1 ns;
constant end_simulation : time := 10000 * clk_period;

begin

    enable <= '1';
    
    nco_I : entity work.nco
        Generic Map(
            C_PHASE_WIDTH => C_PHASE_WIDTH,
            C_SINE_WITDH => C_SINE_WITDH
        )
        Port Map( 
            clk     => clk,
            reset   => rst,
            enable  => enable,
            fcw     => fcw,
            pcw     => pcw,
            sine    => sine
        );

---------------------------------------------------------------------------------------
-- Simulation end assert for GHDL 
---------------------------------------------------------------------------------------

    process
    begin       
        wait for end_simulation;                 
        assert false report "NONE. End of simulation." severity failure;
    end process;

---------------------------------------------------------------------------------------
-- Rst and clk generator for simulation 
---------------------------------------------------------------------------------------

    process
    begin
        rst<='1';
        wait for 1*clk_period + delta_t;
        rst<='0';
        wait for 1*clk_period + delta_t;
        rst<='1';
        wait for end_simulation;
    end process;
   
    process
    begin
        clk<='0';
        clk_loop: loop
            wait for (clk_period - (clk_period * clk_duty_cycle));
            clk<='1';
            wait for (clk_period * clk_duty_cycle);
            clk<='0';   
        end loop;
    end process;

---------------------------------------------------------------------------------------
 -- Rst and clk generator for simulation 
---------------------------------------------------------------------------------------

    process
    begin
        fcw <= b"00_0000_0000";
        wait for 1000 * clk_period;
        fcw <= b"00_0000_0001";
        wait for 1000 * clk_period;
        fcw <= b"00_0000_0010";
        wait for 1000 * clk_period;
        fcw <= b"00_0000_0100";
        wait for 1000 * clk_period;
        fcw <= b"00_0000_1000";
        wait for end_simulation;
    end process;

    process
    begin
        pcw <= b"00_0000_0000";
        wait for 1514 * clk_period;
        pcw <= b"01_1111_1111";
        wait for 500 * clk_period;
        pcw <= b"00_0000_0000";
        wait for 500 * clk_period;
        pcw <= b"01_1111_1111";
        wait for 500 * clk_period;
        pcw <= b"00_0000_0000";
        wait for end_simulation;
    end process;

end architecture;