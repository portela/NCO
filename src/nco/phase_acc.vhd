library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity phase_acc is
    generic(
        C_PHASE_WIDTH : integer := 8
    );
    port(
        clk     : in  std_logic;
        reset   : in  std_logic;
		enable	: in  std_logic;
        fcw     : in  std_logic_vector(C_PHASE_WIDTH-1 downto 0);
		phase   : out std_logic_vector(C_PHASE_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of phase_acc is
    signal phase_acumulator : unsigned(C_PHASE_WIDTH-1 downto 0);
begin
    phase <= std_logic_vector(phase_acumulator);

    process(clk, reset)
    begin
        if reset = '0' then
            phase_acumulator <= (others=>'0');

        elsif rising_edge(clk) then
            if enable = '1' then
                phase_acumulator <= phase_acumulator + unsigned(fcw); 
            end if;
        end if;
    end process;

end architecture;