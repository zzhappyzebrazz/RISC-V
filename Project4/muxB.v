module mux_B (input [31:0] imm,// gia tri so tu don immediate lay tu khoi immGen
		 rs2,// gia tri toanhang hai cua khoi ALU duoc luu trong khoi Reg[] rs2,
              input B_sel,
              output reg [31:0] muxB_out);
always @(B_sel, imm, rs2) begin
  if (B_sel)// Bsel = 1 chon lay gia tri immediatecho cac phep jump, so sanh nhay
    muxB_out= imm;
  else//Bsel = 0 chon lay gia tri rs2 cho vao toan hang 2 cua khoi ALU tinh toan cac phep tinh binh thuong
    muxB_out= rs2;
end
endmodule