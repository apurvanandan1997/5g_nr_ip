library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity nr_modulation_v1_0 is
	port (
		axis_aclk	: in std_logic;
		axis_aresetn	: in std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(127 downto 0);
		s00_axis_tstrb	: in std_logic_vector(15 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		--m00_axis_aclk	: in std_logic;
		--m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(127 downto 0);
		m00_axis_tstrb	: out std_logic_vector(15 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end nr_modulation_v1_0;

architecture arch_imp of nr_modulation_v1_0 is
	signal counter : std_logic_vector(3 downto 0) := (others => '0');
	signal index : integer;
	signal dibits : std_logic_vector(7 downto 0);

begin
	m00_axis_tvalid <= s00_axis_tvalid;
	m00_axis_tstrb <= (others => '1');
	s00_axis_tready <= counter(0) and counter(1) and counter(2) and counter(3) and m00_axis_tready;
	m00_axis_tlast <= s00_axis_tlast and counter(0) and counter(1) and counter(2) and counter(3) and m00_axis_tready;
	index <= to_integer(unsigned(counter(3 downto 0)));
	dibits <= s00_axis_tdata((index + 1)*8-1 downto index*8);

	GEN_ROM: for I in 0 to 3 generate
		with dibits((I+1)*2-1 downto I*2) select m00_axis_tdata((I+1)*32-1 downto I*32) <=
			x"2D412D41" when "00",
			x"2D41D2BF" when "01",
			x"D2BF2D41" when "10",
			x"D2BFD2BF" when "11",
			x"2D412D41" when others;

    end generate GEN_ROM;

process(axis_aclk)
	begin
		if rising_edge(axis_aclk) then
			if axis_aresetn = '0' then
				counter <= (others => '0');

			else
				if s00_axis_tvalid = '1' then
					counter <= counter + '1';
				else
					counter <= (others => '0');

				end if;
			end if;
		end if;
	end process;

end arch_imp;
