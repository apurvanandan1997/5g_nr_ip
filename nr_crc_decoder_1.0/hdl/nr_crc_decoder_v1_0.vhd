library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nr_crc_decoder_v1_0 is
	port (
		-- Ports of Axi Master Bus Interface M00_AXIS
		s00_axis_aclk    : in  std_logic;
		s00_axis_aresetn : in  std_logic;
		s00_axis_tready  : out std_logic;
		s00_axis_tdata   : in  std_logic_vector(7 downto 0);
		s00_axis_tlast   : in  std_logic;
		s00_axis_tvalid  : in  std_logic;
		--s00_axis_tstrb : in std_logic_vector(0 downto 0);

		-- Ports of Axi Master Bus Interface M00_AXIS
		--m00_axis_aclk : out std_logic;
		--m00_axis_aresetn : out std_logic;
		m00_axis_tvalid : out std_logic;
		m00_axis_tdata  : out std_logic_vector(7 downto 0);
		m00_axis_tlast  : out std_logic;
		m00_axis_tready : in  std_logic;
		--m00_axis_tstrb : out std_logic_vector(0 downto 0);
		crc_err : out std_logic_vector(23 downto 0)
	);

end entity nr_crc_decoder_v1_0;

architecture rtl of nr_crc_decoder_v1_0 is

	component crc_decoder is
		port(
			clk        : in  std_logic;
			reset      : in  std_logic;
			enb        : in  std_logic;
			in0        : in  std_logic_vector(7 downto 0); -- uint8
			in1_start  : in  std_logic;
			in1_end    : in  std_logic;
			in1_valid  : in  std_logic;
			out0       : out std_logic_vector(7 downto 0); -- uint8
			out1_start : out std_logic;
			out1_end   : out std_logic;
			out1_valid : out std_logic;
			out2       : out std_logic_vector(23 downto 0)
		);
	end component;

	signal inter_blk_latency   : std_logic_vector(6 downto 0);
	signal s00_axis_tvalid_del : std_logic := '0';
	signal s00_axis_startIn    : std_logic;
	signal s00_axis_areset     : std_logic;
	signal not_rdy_state       : std_logic;

begin

	s00_axis_areset  <= not s00_axis_aresetn;
	s00_axis_startIn <= not s00_axis_tvalid_del and s00_axis_tvalid;
	s00_axis_tready  <= not not_rdy_state and m00_axis_tready and not s00_axis_areset ;
	--m00_axis_aclk <= s00_axis_aclk;
	--m00_axis_aresetn <= s00_axis_aresetn;

	process(s00_axis_aclk)
	begin
		if rising_edge(s00_axis_aclk) then
			if s00_axis_aresetn = '0' then
				s00_axis_tvalid_del <= '0';

			else
				s00_axis_tvalid_del <= s00_axis_tvalid;

			end if;
		end if;
	end process;

	process(s00_axis_aclk)
	begin
		if rising_edge(s00_axis_aclk) then
			if s00_axis_aresetn = '0' then
				not_rdy_state <= '0';

			else
				if inter_blk_latency < "1001101" then
					not_rdy_state <= (s00_axis_tlast or not_rdy_state);

				else
					not_rdy_state <= s00_axis_tlast;

				end if;
			end if;
		end if;
	end process;

	process(s00_axis_aclk)
	begin
		if rising_edge(s00_axis_aclk) then
			if s00_axis_aresetn = '0' then
				inter_blk_latency <= (others => '0');

			else
				if not_rdy_state = '1' then
					if inter_blk_latency >= "1001101" then
						inter_blk_latency <= (others => '0');
					
					else
						inter_blk_latency <= inter_blk_latency + '1';

					end if;
				end if;
			end if;
		end if;
	end process;

	CRC_Decoder_inst : CRC_Decoder
		port map (
			clk        => s00_axis_aclk,
			reset      => s00_axis_areset,
			enb        => m00_axis_tready,
			in0        => s00_axis_tdata,
			in1_start  => s00_axis_startIn,
			in1_end    => s00_axis_tlast,
			in1_valid  => s00_axis_tvalid,
			out0       => m00_axis_tdata,
			out1_start => open,
			out1_end   => m00_axis_tlast,
			out1_valid => m00_axis_tvalid,
			out2       => crc_err
		);

end architecture rtl;