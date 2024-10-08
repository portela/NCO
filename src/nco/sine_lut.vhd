library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity sine_lut is
    generic(
        C_PHASE_WIDTH : integer := 8;
        C_SINE_WITDH  : integer := 16
    );
    port(
        rst    : in std_logic;
        clk    : in std_logic;
        phase  : in  std_logic_vector(C_PHASE_WIDTH-1 downto 0);
		sine   : out std_logic_vector(C_SINE_WITDH-1 downto 0)
    );
end entity;


architecture rtl of sine_lut is
    type sine_table_type is array (0 to 2**C_PHASE_WIDTH-1) of STD_LOGIC_VECTOR(C_SINE_WITDH-1 downto 0);
    signal sine_table : sine_table_type;

begin

    process(rst, clk)
    begin
        if rst='0' then
            sine <= (others=> '0');
        elsif rising_edge(clk) then
            sine   <= sine_table(to_integer(unsigned(phase)));
        end if;
    end process;

    GENLUT: FOR i in 0 TO 2**C_PHASE_WIDTH-1 GENERATE
        CONSTANT x: REAL := (1.0 + SIN(2.0*MATH_PI*real(i)/real(2**C_PHASE_WIDTH-1))) / 2.0;
        CONSTANT xn: UNSIGNED (C_SINE_WITDH-1 DOWNTO 0) := to_unsigned(INTEGER(x*real(2**C_SINE_WITDH-1)), C_SINE_WITDH);
    BEGIN
        sine_table(i) <= STD_LOGIC_VECTOR(xn); 
    END GENERATE; 


end architecture;