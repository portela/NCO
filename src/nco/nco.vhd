library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity nco is
    generic(
        C_PHASE_WIDTH : integer := 8;
        C_SINE_WITDH  : integer := 16
    );
    port(
        clk     : in  std_logic;
        reset   : in  std_logic;
		enable	: in  std_logic;
        fcw     : in  std_logic_vector(C_PHASE_WIDTH-1 downto 0);
		sine    : out std_logic_vector(C_SINE_WITDH-1 downto 0)
    );
end entity;

architecture rtl of nco is
    signal phase : std_logic_vector(C_PHASE_WIDTH-1 downto 0);

begin


    phase_acc_I : entity work.phase_acc
        Generic Map(
            C_PHASE_WIDTH => C_PHASE_WIDTH
        )
        Port Map( 
            clk    => clk,
            reset  => reset,
		    enable => enable,
            fcw    => fcw,
            phase  => phase
        );

    sine_lut_I : entity work.sine_lut
        Generic Map(
            C_PHASE_WIDTH => C_PHASE_WIDTH,
            C_SINE_WITDH => C_SINE_WITDH
        )
        Port Map( 
            phase  => phase,
            sine   => sine
        );

end architecture;