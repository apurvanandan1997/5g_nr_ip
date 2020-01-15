library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity m_axis_counter_v1_0 is
	generic (
		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 8;
		C_M00_AXIS_WAIT_COUNT	: integer	:= 8;
		NUMBER_OF_OUTPUT_WORDS : integer := 48   
	);
	port (
		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end m_axis_counter_v1_0;

architecture arch_imp of m_axis_counter_v1_0 is
                                                                                                                          
	signal mst_state : std_logic_vector(1 downto 0);                                                   
	signal counter	: std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);


begin
	-- I/O Connections assignments
	m00_axis_tdata <= counter when mst_state = "01" else (others => '0');

	process(m00_axis_aclk)
	begin
		if rising_edge(m00_axis_aclk) then
			if m00_axis_aresetn = '0' then
				mst_state <= "00";
				counter <= (others => '0');
				m00_axis_tvalid <= '0';
				m00_axis_tlast <= '0';

			else
				case mst_state is
					when "00" => if counter = std_logic_vector(to_unsigned(C_M00_AXIS_WAIT_COUNT, C_M00_AXIS_TDATA_WIDTH)) then
								mst_state <= "01";
								counter <= (others => '0');
								m00_axis_tvalid <= '1';
								else
								 counter <= counter + '1';
								 mst_state <= "00";
								 m00_axis_tvalid <= '0';
								end if;
								m00_axis_tlast <= '0';
					when "01" => if counter = NUMBER_OF_OUTPUT_WORDS-1 then
									mst_state <= "11";
									m00_axis_tvalid <= '0';
									counter <= (others => '0');
								else
									counter <= counter + '1';
									mst_state <= "01";
									m00_axis_tvalid <= '1';
								end if;

								if counter = NUMBER_OF_OUTPUT_WORDS-2 then
									m00_axis_tlast <= '1';
								
								else
									m00_axis_tlast <= '0';
								
								end if;

					when "11" => if m00_axis_tready = '1' then
								mst_state <= "00";
								else
								mst_state <= "11";
								end if;
								m00_axis_tvalid <= '0';
								counter <= (others => '0');
								m00_axis_tlast <= '0';

					when others => mst_state <= "00";
						counter <= (others => '0');
						m00_axis_tvalid <= '0';
						m00_axis_tlast <= '0';

				end case;
			end if;
		end if;
	end process;

	m00_axis_tstrb	<= (others => '1');

end arch_imp;
