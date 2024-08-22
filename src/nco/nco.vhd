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
        pcw     : in  std_logic_vector(C_PHASE_WIDTH-1 downto 0);
        --acp     : in  std_logic_vector(C_SINE_WITDH-1 downto 0);
		sine    : out std_logic_vector(C_SINE_WITDH-1 downto 0)
    );
end entity;

architecture rtl of nco is
    signal phase_acc : unsigned(C_PHASE_WIDTH-1 downto 0);
    signal phase     : unsigned(C_PHASE_WIDTH-1 downto 0);


begin

    process(clk, reset)
    begin
        if reset = '0' then
            phase_acc <= (others=>'0');

        elsif rising_edge(clk) then
            if enable = '1' then
                phase_acc <= phase_acc + unsigned(fcw); 
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '0' then
            phase <= (others=>'0');
        elsif rising_edge(clk) then
            phase <= phase_acc + unsigned(pcw);
        end if;
    end process;

    sine_lut_I : entity work.sine_lut
        Generic Map(
            C_PHASE_WIDTH => C_PHASE_WIDTH,
            C_SINE_WITDH => C_SINE_WITDH
        )
        Port Map( 
            phase  => std_logic_vector(phase),
            sine   => sine
        );

end architecture;