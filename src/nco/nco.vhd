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
    signal phase_acumulator : unsigned(C_PHASE_WIDTH-1 downto 0);
    signal sine_i           : unsigned(C_SINE_WITDH-1 downto 0);

    type sine_lut_type is array (0 to 2**C_PHASE_WIDTH-1) of STD_LOGIC_VECTOR(C_SINE_WITDH-1 downto 0);
    signal sine_lut : sine_lut_type;
begin
    sine_i <= unsigned(sine_lut(to_integer(phase_acumulator)));
    sine   <= std_logic_vector(sine_i);


    GENLUT: FOR i in 0 TO 2**C_PHASE_WIDTH-1 GENERATE
        CONSTANT x: REAL := (1.0 + SIN(2.0*MATH_PI*real(i)/real(2**C_PHASE_WIDTH-1))) / 2.0;
        CONSTANT xn: UNSIGNED (15 DOWNTO 0) := to_unsigned(INTEGER(x*real(2**C_SINE_WITDH-1)), 16);
    BEGIN
        sine_lut(i) <= STD_LOGIC_VECTOR(xn); 
    END GENERATE; 


    process(clk, reset)
    begin
        if reset = '0' then
            phase_acumulator <= (others=>'0');

        elsif rising_edge(clk) then
            if enable = '1' then
                phase_acumulator <= phase_acumulator + unsigned(fcw) + 1; 
            end if;
        end if;
    end process;


end architecture;