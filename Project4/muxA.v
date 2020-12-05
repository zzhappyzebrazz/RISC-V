module mux_A (input [31:0] pc // gia tri PC hien hanh
		, rs1 // gia tri luu trong DataA cua Reg[] la rs1 
              ,input A_sel,
              output reg [31:0] muxA_out);
always @(A_sel, pc, rs1) begin
  if (A_sel)// A_sel = 1  chon toan hang 1 la gia tri PC cho ALU tinh toan phuc vu cac cau lenh nhay
    muxA_out= pc;
  else// A_sel = 0 chon du lieu tu Reg[] DataA laf toan hang 1 rs1 cho ALU
    muxA_out= rs1;
end
endmodule
