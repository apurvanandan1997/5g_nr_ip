-- -------------------------------------------------------------
-- 
-- File Name: /home/apurvan/BBU/CRC_decoder_export/hdlsrc/ltehdlCRCDecoderModel/CRCCompNet.vhd
-- Created: 2019-12-10 03:50:22
-- 
-- Generated by MATLAB 9.6 and HDL Coder 3.14
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: CRCCompNet
-- Source Path: ltehdlCRCDecoderModel/HDL Algorithm/CRC Decoder/CRCCompNet
-- Hierarchy Level: 2
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CRCCompNet IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        in1                               :   IN    std_logic_vector(7 DOWNTO 0);  -- uint8
        in2                               :   IN    std_logic_vector(7 DOWNTO 0);  -- uint8
        en                                :   IN    std_logic;  -- ufix1
        rst                               :   IN    std_logic;  -- ufix1
        gateErrIn                         :   IN    std_logic;  -- ufix1
        err                               :   OUT   std_logic_vector(23 DOWNTO 0)  -- ufix24
        );
END CRCCompNet;


ARCHITECTURE rtl OF CRCCompNet IS

  TYPE vector_of_unsigned8 IS ARRAY (NATURAL RANGE <>) OF unsigned(7 DOWNTO 0);
  -- Signals
  SIGNAL in1_unsigned                     : unsigned(7 DOWNTO 0);  -- uint8
  SIGNAL in2_unsigned                     : unsigned(7 DOWNTO 0);  -- uint8
  SIGNAL CRCComp_crc_in                   : vector_of_unsigned8(0 TO 3);  -- ufix8 [4]
  SIGNAL CRCComp_crc_rec                  : vector_of_unsigned8(0 TO 3);  -- ufix8 [4]
  SIGNAL CRCComp_crc_in_next              : vector_of_unsigned8(0 TO 3);  -- ufix8 [4]
  SIGNAL CRCComp_crc_rec_next             : vector_of_unsigned8(0 TO 3);  -- ufix8 [4]
  SIGNAL err_tmp                          : unsigned(23 DOWNTO 0);  -- ufix24

BEGIN
  in1_unsigned <= unsigned(in1);

  in2_unsigned <= unsigned(in2);

  -- CRCCompareFunction
  CRCComp_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      CRCComp_crc_in(0) <= to_unsigned(16#00#, 8);
      CRCComp_crc_in(1) <= to_unsigned(16#00#, 8);
      CRCComp_crc_in(2) <= to_unsigned(16#00#, 8);
      CRCComp_crc_in(3) <= to_unsigned(16#00#, 8);
      CRCComp_crc_rec(0) <= to_unsigned(16#00#, 8);
      CRCComp_crc_rec(1) <= to_unsigned(16#00#, 8);
      CRCComp_crc_rec(2) <= to_unsigned(16#00#, 8);
      CRCComp_crc_rec(3) <= to_unsigned(16#00#, 8);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        CRCComp_crc_in(0) <= CRCComp_crc_in_next(0);
        CRCComp_crc_in(1) <= CRCComp_crc_in_next(1);
        CRCComp_crc_in(2) <= CRCComp_crc_in_next(2);
        CRCComp_crc_in(3) <= CRCComp_crc_in_next(3);
        CRCComp_crc_rec(0) <= CRCComp_crc_rec_next(0);
        CRCComp_crc_rec(1) <= CRCComp_crc_rec_next(1);
        CRCComp_crc_rec(2) <= CRCComp_crc_rec_next(2);
        CRCComp_crc_rec(3) <= CRCComp_crc_rec_next(3);
      END IF;
    END IF;
  END PROCESS CRCComp_process;

  CRCComp_output : PROCESS (CRCComp_crc_in, CRCComp_crc_rec, en, gateErrIn, in1_unsigned, in2_unsigned,
       rst)
    VARIABLE crc_in_temp : vector_of_unsigned8(0 TO 3);
    VARIABLE crc_rec_temp : vector_of_unsigned8(0 TO 3);
    VARIABLE add_temp : unsigned(26 DOWNTO 0);
  BEGIN
    crc_in_temp(0) := CRCComp_crc_in(0);
    crc_in_temp(1) := CRCComp_crc_in(1);
    crc_in_temp(2) := CRCComp_crc_in(2);
    crc_in_temp(3) := CRCComp_crc_in(3);
    crc_rec_temp(0) := CRCComp_crc_rec(0);
    crc_rec_temp(1) := CRCComp_crc_rec(1);
    crc_rec_temp(2) := CRCComp_crc_rec(2);
    crc_rec_temp(3) := CRCComp_crc_rec(3);
    IF rst /= '0' THEN 
      crc_in_temp(0) := to_unsigned(16#00#, 8);
      crc_in_temp(1) := to_unsigned(16#00#, 8);
      crc_in_temp(2) := to_unsigned(16#00#, 8);
      crc_in_temp(3) := to_unsigned(16#00#, 8);
      crc_rec_temp(0) := to_unsigned(16#00#, 8);
      crc_rec_temp(1) := to_unsigned(16#00#, 8);
      crc_rec_temp(2) := to_unsigned(16#00#, 8);
      crc_rec_temp(3) := to_unsigned(16#00#, 8);
    ELSIF en /= '0' THEN 
      crc_in_temp(0) := CRCComp_crc_in(1);
      crc_in_temp(1) := CRCComp_crc_in(2);
      crc_in_temp(2) := CRCComp_crc_in(3);
      crc_in_temp(3) := in1_unsigned;
      crc_rec_temp(0) := CRCComp_crc_rec(1);
      crc_rec_temp(1) := CRCComp_crc_rec(2);
      crc_rec_temp(2) := CRCComp_crc_rec(3);
      crc_rec_temp(3) := in2_unsigned;
    END IF;
    IF gateErrIn /= '0' THEN 
      add_temp := resize(resize(crc_in_temp(0) XOR crc_rec_temp(0), 24) sll 16, 27) + resize(resize(crc_in_temp(1) XOR crc_rec_temp(1), 24) sll 8, 27);
      err_tmp <= resize(resize(add_temp, 28) + resize(resize(crc_in_temp(2) XOR crc_rec_temp(2), 24) sll 0, 28), 24);
    ELSE 
      err_tmp <= to_unsigned(16#000000#, 24);
    END IF;
    CRCComp_crc_in_next(0) <= crc_in_temp(0);
    CRCComp_crc_in_next(1) <= crc_in_temp(1);
    CRCComp_crc_in_next(2) <= crc_in_temp(2);
    CRCComp_crc_in_next(3) <= crc_in_temp(3);
    CRCComp_crc_rec_next(0) <= crc_rec_temp(0);
    CRCComp_crc_rec_next(1) <= crc_rec_temp(1);
    CRCComp_crc_rec_next(2) <= crc_rec_temp(2);
    CRCComp_crc_rec_next(3) <= crc_rec_temp(3);
  END PROCESS CRCComp_output;


  err <= std_logic_vector(err_tmp);

END rtl;

