\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])

   m4_test_prog()

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   
   $reset = *reset;
   
   
   // YOUR CODE HERE
   
   $pc[31:0] = >>1$next_pc[31:0];
   $next_pc[31:0] =
      $reset    ? 0 :
      $taken_br ? $br_tgt_pc[31:0] :
      $pc[31:0] + 4;
   
   `READONLY_MEM($pc, $$instr[31:0])
   
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   $is_b_instr = $instr[6:2] ==  5'b11000;
   $is_j_instr = $instr[6:2] ==  5'b11011;
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   $is_i_instr = $instr[6:2] == 5'b11001 ||
                 $instr[6:2] == 5'b11100 ||
                 ($instr[6:2] != 5'b00101 && $instr[6:2] ==? 5'b00xxx);
   $is_r_instr = $instr[6:2] == 5'b01011 ||
                 $instr[6:2] == 5'b01110 ||
                 $instr[6:2] == 5'b01100 ||
                 $instr[6:2] == 5'b10100;
   
   $opcode[6:0] = $instr[6:0];
   $rd_valid = ($is_r_instr ||
                $is_i_instr ||
                $is_u_instr ||
                $is_j_instr) &&
               $rd[4:0] != 5'b00000;
   $rd[4:0] = $instr[11:7];
   $rs1_valid = $is_r_instr ||
                $is_i_instr ||
                $is_b_instr ||
                $is_s_instr;
   $rs1[4:0] = $instr[19:15];
   $rs2_valid = $is_r_instr ||
                $is_b_instr ||
                $is_s_instr;
   $rs2[4:0] = $instr[24:20];
   $funct3_valid = $is_r_instr ||
                   $is_i_instr ||
                   $is_b_instr ||
                   $is_s_instr;
   $funct3[2:0] = $instr[14:12];
   $imm_valid = !$is_r_instr;
   $imm[31:0] =
      $is_i_instr ? {{21{$instr[31]}}, $instr[30:20]} :
      $is_u_instr ? {$instr[31:12], 12'b0} :
      $is_j_instr ? {{12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 1'b0} :
      $is_b_instr ? {{19{$instr[31]}}, {2{$instr[7]}}, $instr[30:25], $instr[11:8], 1'b0} :
      $is_s_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
      32'b0;
   
   $dec_bits[10:0] = {$instr[30], $funct3, $opcode};
   
   $is_beq   = $dec_bits ==? 11'bx_000_1100011;
   $is_bne   = $dec_bits ==? 11'bx_001_1100011;
   $is_blt   = $dec_bits ==? 11'bx_100_1100011;
   $is_bge   = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu  = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu  = $dec_bits ==? 11'bx_111_1100011;
   $is_addi  = $dec_bits ==? 11'bx_000_0010011;
   $is_add   = $dec_bits ==  11'b0_000_0110011;
   $is_lui   = $dec_bits ==? 11'bx_xxx_0110111;
   $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
   $is_jal   = $dec_bits ==? 11'bx_xxx_1101111;
   $is_jalr  = $dec_bits ==? 11'bx_000_1100111;
   $is_slti  = $dec_bits ==? 11'bx_010_0010011;
   $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
   $is_xori  = $dec_bits ==? 11'bx_100_0010011;
   $is_ori   = $dec_bits ==? 11'bx_110_0010011;
   $is_andi  = $dec_bits ==? 11'bx_111_0010011;
   $is_slli  = $dec_bits ==? 11'b0_001_0010011;
   $is_srli  = $dec_bits ==? 11'b0_101_0010011;
   $is_srai  = $dec_bits ==? 11'b1_101_0010011;
   $is_sub   = $dec_bits ==  11'b1_000_0110011;
   $is_sll   = $dec_bits ==  11'b0_001_0110011;
   $is_slt   = $dec_bits ==  11'b0_010_0110011;
   $is_sltu  = $dec_bits ==  11'b0_011_0110011;
   $is_xor   = $dec_bits ==  11'b0_100_0110011;
   $is_srl   = $dec_bits ==  11'b0_101_0110011;
   $is_sra   = $dec_bits ==  11'b1_101_0110011;
   $is_or    = $dec_bits ==  11'b0_110_0110011;
   $is_and   = $dec_bits ==  11'b0_111_0110011;
   
   $is_load = $opcode[6:0] == 7'b0000011;
   
   $result[31:0] =
      $is_addi ? $src1_value[31:0] + $imm[31:0] :
      $is_add  ? $src1_value[31:0] + $src2_value[31:0] :
      32'b0;

   $taken_br =
      $is_beq  ? $src1_value[31:0] == $src2_value[31:0] :
      $is_bne  ? $src1_value[31:0] != $src2_value[31:0] :
      $is_blt  ? ($src1_value[31:0] < $src2_value[31:0]) ^ ($src1_value[31] != $src2_value[31]) :
      $is_bge  ? ($src1_value[31:0] >= $src2_value[31:0]) ^ ($src1_value[31] != $src2_value[31]) :
      $is_bltu ? $src1_value[31:0] < $src2_value[31:0] :
      $is_bgeu ? $src1_value[31:0] >= $src2_value[31:0] :
      0;

   $br_tgt_pc[31:0] = $pc[31:0] + $imm[31:0];

   // Assert these to end simulation (before Makerchip cycle limit).
   m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
   
   m4+rf(32, 32, $reset, $rd_valid, $rd[4:0], $result[31:0], $rs1_valid, $rs1[4:0], $src1_value, $rs2_valid, $rs2[4:0], $src2_value)
   `BOGUS_USE($funct3_valid $imm_valid $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu)
   //m4+dmem(32, 32, $reset, $addr[4:0], $wr_en, $wr_data[31:0], $rd_en, $rd_data)
   m4+cpu_viz()
\SV
   endmodule