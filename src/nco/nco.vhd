library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity nco is
    generic(
        C_PHASE_WIDTH : integer := 8;
        C_MULT_WIDTH  : integer := 2;
        C_SINE_WIDTH  : integer := 16
    );
    port(
        rst     : in  std_logic;
        clk     : in  std_logic;
		enable	: in  std_logic;
        
        fcw     : in  unsigned(C_PHASE_WIDTH-1 downto 0);
        pcw     : in  unsigned(C_PHASE_WIDTH-1 downto 0);
        acw     : in  unsigned(C_MULT_WIDTH-1 downto 0);

		sine    : out unsigned(C_SINE_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of nco is
    signal phase_acc : unsigned(C_PHASE_WIDTH-1 downto 0);
    signal phase     : unsigned(C_PHASE_WIDTH-1 downto 0);

    signal sine_lut_o : unsigned(C_SINE_WIDTH-C_MULT_WIDTH-1 downto 0);
begin
    sine <= sine_lut_o * acw;

    process(clk, rst)
    begin
        if rst = '0' then
            phase_acc <= (others=>'0');

        elsif rising_edge(clk) then
            if enable = '1' then
                phase_acc <= phase_acc + fcw; 
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '0' then
            phase <= (others=>'0');
        elsif rising_edge(clk) then
            phase <= phase_acc + pcw;
        end if;
    end process;

    sine_lut_I : entity work.sine_lut
        Generic Map(
            C_PHASE_WIDTH => C_PHASE_WIDTH,
            C_SINE_WITDH => (C_SINE_WIDTH-C_MULT_WIDTH)
        )
        Port Map( 
            rst    => rst,
            clk    => clk,
            phase  => phase,
            sine   => sine_lut_o
        );

end architecture;