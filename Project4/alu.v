module alu (input [31:0] in1, in2,
            input [3:0] alu_sel,
            output reg [31:0] alu_out);

//Find max{in1, in2} for SLT, SLTU            
wire lt1, lt2, eq1, eq2;
// so sanh co dau 2 so in1 va in2 tu khoi branch_comp ket qua luu vap eq1, lt1
branch_comp c1 (.rs1(in1), .rs2(in2), .BrUn(1'b0), .BrEq(eq1), .BrLt(lt1));
//so sanh khong dau 2 so in1 va in2 
branch_comp c2 (.rs1(in1), .rs2(in2), .BrUn(1'b1), .BrEq(eq2), .BrLt(lt2));

always @(alu_sel, in1, in2, eq1, eq2, lt1, lt2) begin
  case (alu_sel)
    4'b0000: alu_out= in1 + in2;

    4'b0001: alu_out= in1 - in2;
    
    4'b0010: alu_out= in1 << in2;// shift left logical
    
    4'b0011: begin// so sanh in1 va in2 co dau 
               if (eq1)// in1 =  in2 rd=0
                 alu_out= 32'h00000000;
               else if (lt1)//in1 < in2 -> rd = 1
                 alu_out= 32'hffffffff;
               else// lon hon hoac bang
                 alu_out= 32'h00000000;
             end
               
    4'b0100: begin// so sanh 2 so in1 va in2 khong dau
               if (eq2)// bang nhau
                 alu_out= 32'h00000000;
               else if (lt2)//nho hon
                 alu_out= 32'hffffffff;
               else// lon hon hoac bang
                 alu_out= 32'h00000000;
             end
    4'b0101: alu_out = in1 ^ in2;// XOR
    
    4'b0110: alu_out= in1 >> in2;//dich right logical
    
    4'b0111: alu_out= in1 >>> in2;//shift right arithmetic
    
    4'b1000: alu_out= in1 | in2;// OR
    
    4'b1001: alu_out= in1 & in2;//NAD
    
    4'b1010: alu_out= in2; // for LUI buffer
    
    default: alu_out= 32'hxxxxxxxx;
  endcase
end
endmodule
               