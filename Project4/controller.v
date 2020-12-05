module controller (input [31:0] inst,// instruction
                   input BrEq, BrLt, // branch equal, branch lessthan
                   output reg PCsel// chon pc + 4 hay chon ket qua tu khoi alu
				, RegWen // register write enable cho phep viet vao thanh ghi
				, BrUn // so sanh branch khong dau branch unsigned
				, Bsel // branch select chon so sanh branch voi branch hoac branch voi immediate : Mux B Bselect
				, Asel // Alu select chon data A hoac PC de dua vao khoi ALU toan hang 1
				, MemRW, //
                   output reg [2:0] imm_sel, // chon so imediate
                   output reg [3:0] Alu_sel,// chon cac function lam viec 4 bit => 16 function
                   output reg [1:0] WBsel); //


always @(inst, BrEq, BrLt) begin //khi co instruction nap vao tin hieu so sanh 2 branch 
  case (inst[6:2])// set opcode
    //R-instruction
    5'b01100:  begin 
                 PCsel = 1'b0;// khong lay ket qua tu ALU
                 imm_sel = 3'b101;//nhom lenh R fromat khong signed extention cho nhom lenh nay
                 RegWen = 1'b1; // cho phep ghi vao thanh ghi
                 //BrUn = 1'b0; //=x
                 Asel= 1'b0; // chon toan hang 1
                 Bsel= 1'b0; //chon toan hang 2
                 MemRW= 1'b0; 
                 WBsel= 2'b01; // lay ket qua tu alu viet vao thanh ghi dich DataD
                  case ({inst[30], inst[14:12]}) //ADD-SUB va Shift right arithmetic-SRlogic
                    4'b0000:  Alu_sel= 4'b0000; //ADD
                    4'b1000:  Alu_sel= 4'b0001; //SUB
                    4'b0001:  Alu_sel= 4'b0010; //SLL
                    4'b0010:  Alu_sel= 4'b0011; //SLT
                    4'b0011:  Alu_sel= 4'b0100; //SLTU
                    4'b0100:  Alu_sel= 4'b0101; //XOR
                    4'b0101:  Alu_sel= 4'b0110; //SRL
                    4'b1101:  Alu_sel= 4'b0111; //SRA
                    4'b0110:  Alu_sel= 4'b1000; //OR
                    4'b0111:  Alu_sel= 4'b1001; //AND
                    default:  Alu_sel= 4'bxxxx;
                  endcase
                BrUn= (Alu_sel==4'b0100);//
              end
     
     //I-instruction (arithmetic)
     5'b00100: begin
                 PCsel = 1'b0;// khong phao lenh nhay PC
                 imm_sel = 3'b000;// noi dau cho nhom lenh I
                 RegWen = 1'b1;// cho phep ghi vao Resigter
                 //BrUn = 1'b0;//=x
                 Asel= 1'b0;//chon toan hang A
                 Bsel= 1'b1;//chon immediate
                 MemRW= 1'b0;//khong ghi vao mem
                 WBsel= 2'b01;// lay ket qua tua alu viet vao thanh ghi rd DataD
                 casex ({inst[30], inst[14:12]})// shift right logical immediate va SR arithmetic immediate
/*ALUSel	
0000	ADD
0001	SUB
0010	SLL
0011	SLT
0100	SLTU
0101	XOR
0110	SRL
0111	SRA
1000	OR
1001	AND
1010	BUFFER*/

                   4'bx000: Alu_sel= 4'b0000;
                   4'bx010: Alu_sel= 4'b0011;
                   4'bx011: Alu_sel= 4'b0100;
                   4'bx100: Alu_sel= 4'b0101;
                   4'bx110: Alu_sel= 4'b1000;
                   4'bx111: Alu_sel= 4'b1001;
                   4'b0001: Alu_sel= 4'b0010;
                   4'b0101: Alu_sel= 4'b0110;
                   4'b1101: Alu_sel= 4'b0111;
                 endcase
                 BrUn= (Alu_sel==4'b0100);//?
               end
     
      //I-instruction (load-LW)          
      5'b0000: begin
                 PCsel = 1'b0;//PC + 4
                 imm_sel = 3'b000;// noi dau cho nhom lenh I
                 RegWen = 1'b1;// regsister write enable
                 BrUn = 1'b0; //=x
                 Alu_sel= 4'b0000;// lay rs1 + immediate sau khi noi dau
                 Asel= 1'b0; //chon toan hang A rs1
                 Bsel= 1'b1; //chon immediate toan hang B 
                 MemRW= 1'b0; //khong viet vao DMEM lay dia chi tu ket qua cua ALU
                 WBsel= 2'b00;// chon ket qua , o nho vi tri ALU tron DMEM viet vao rd DataD
               end
               
      //S-instruction (store-SW)
      5'b01000: begin
                 PCsel = 1'b0;//PC = PC +4
                 imm_sel = 3'b001;// chon noi dau cho nhom lenh S imm_in[30:25], imm_in[11:7]
                 RegWen = 1'b0;// khong cho phep ghi vao bo nho thanh ghi
                 BrUn = 1'b0;//=x
                 Alu_sel= 4'b0000;//chon cong 2 toan hang in1 va in2
                 Asel= 1'b0;// chon in1 = dataA = rs1
                 Bsel= 1'b1; // chon in2 = immediate sau khi noi dau
                 MemRW= 1'b1;// cho phep ghi vao bo nho DMEM tai vi tri cua DataB rs2
                 WBsel= 2'b00;//=xx chon ket qua DataR tu bo nho DMEM
               end
               
      //B-instruction
      5'b11000: begin
                  case (inst[14:12])
                    3'b000: begin //BEQ
                              imm_sel=3'b010; // noi dau cho  imm_in[7], imm_in[30:25], imm_in[11:8], 1'b0
                              RegWen= 1'b0;//khong cho viet vao bang thanh ghi
                              BrUn= 1'b0;//so sanh branch co dau
                              Asel= 1'b1;//lay du lieu tu PC
                              Bsel= 1'b1;//lya du lieu tu khoi immGen
                              Alu_sel=4'b0000;// aluOut = in1(PC) + in2(immGen)
                              MemRW= 1'b0;//cho phep read
                              WBsel= 2'b00;//lay duu lieu tu DMEM ghi nguoc
                              if (BrEq) 
                                PCsel=1'b1;// bang nhau thi lay ket qua tu ALU
                              else
                                PCsel= 1'b0;// khong bang nhau chay tiep PC+4
                            end
                    3'b001: begin //BNE
                              imm_sel=3'b010;
                              RegWen= 1'b0;
                              BrUn= 1'b0;//=x
                              Asel= 1'b1;
                              Bsel= 1'b1;
                              Alu_sel=4'b0000;
                              MemRW= 1'b0;
                              WBsel= 2'b00;//=xx
                              if (BrEq) 
                                PCsel=1'b0;
                              else
                                PCsel= 1'b1;
                            end
                                
                    3'b100: begin //BLT
                              imm_sel=3'b010;
                              RegWen= 1'b0;
                              BrUn= 1'b0;
                              Asel= 1'b1;
                              Bsel= 1'b1;
                              Alu_sel=4'b0000;
                              MemRW= 1'b0;
                              WBsel= 2'b00;//=xx
                              if (BrLt) 
                                PCsel= 1'b1;
                              else
                                PCsel= 1'b0;
                            end 
                    3'b110: begin //BLTU
                              imm_sel=3'b010;
                              RegWen= 1'b0;
                              BrUn= 1'b1;
                              Asel= 1'b1;
                              Bsel= 1'b1;
                              Alu_sel=4'b0000;
                              MemRW= 1'b0;
                              WBsel= 2'b00;//=xx
                              if (BrLt) 
                                PCsel= 1'b1;
                              else
                                PCsel= 1'b0;
                            end 
                    3'b101: begin //BGE
                              imm_sel=3'b010;
                              RegWen= 1'b0;
                              BrUn= 1'b0;
                              Asel= 1'b1;
                              Bsel= 1'b1;
                              Alu_sel=4'b0000;
                              MemRW= 1'b0;
                              WBsel= 2'b00;//=xx
                              if (BrLt) 
                                PCsel= 1'b0;
                              else
                                PCsel= 1'b1;
                            end 
                    3'b111: begin //BGEU
                              imm_sel=3'b010;
                              RegWen= 1'b0;
                              BrUn= 1'b1;
                              Asel= 1'b1;
                              Bsel= 1'b1;
                              Alu_sel=4'b0000;
                              MemRW= 1'b0;
                              WBsel= 2'b00;//=xx
                              if (BrLt) 
                                PCsel= 1'b0;
                              else
                                PCsel= 1'b1;
                            end
                  endcase
                end
          //U-instruction (LUI) load gia tri imm vao thanh ghi rdh
          5'b01101:  begin
                       PCsel = 1'b0;//chon PC = PC+4
                       imm_sel = 3'b011;// chon tao imm theo kieu U-format
                       RegWen = 1'b1;// cho phep doc va ghi vao bang thanh ghi
                       BrUn = 1'b0;//so sanh so co dau
                       Alu_sel= 4'b1010;//buffer aluout = in2(immGen)
                       Asel= 1'b0; //lay du lieu tu bang thanh ghi
                       Bsel= 1'b1;//lau du lieu tu immGen
                       MemRW= 1'b0;//cho phep read vao DMEM
                       WBsel= 2'b01;//lay du lieu tu ALU de ghi nguoc
                     end
          //U-instruction (AUIPC) load gia tri thanh ghi PC vao thanh ghi rd
          5'b00101:  begin
                       PCsel = 1'b0;// PC = PC+4
                       imm_sel = 3'b011;//tao imm theo U-format
                       RegWen = 1'b1;//cho phep viet vao bang thanh ghi
                       BrUn = 1'b0;//so sanh so co dau
                       Alu_sel= 4'b0000;//add in1(PC) in2(immGen)
                       Asel= 1'b1;//PC
                       Bsel= 1'b1;//immGen
                       MemRW= 1'b0;//cho phep read
                       WBsel= 2'b01;//lau giu lieu tu ALU
                     end
           //J-instruction (JAL) jump and link: nhay vaf luu dia chi PC +4 vao thanh ghi rd
           5'b11011: begin
                       PCsel = 1'b1;//PC = ALUout
                       imm_sel = 3'b100;//che do J-format
                       RegWen = 1'b1;//cho phep ghi vao bang thanh ghi
                       BrUn = 1'b0;//so sanh so co dau
                       Alu_sel= 4'b0000;//add PC + immGen
                       Asel= 1'b1;//PC
                       Bsel= 1'b1;//immGen
                       MemRW= 1'b0;//cho phep read
                       WBsel= 2'b10;//lay du lieu tu PC+4 luu vao thanh ghi rd
                     end
                                              
           //J-instruction (JARL) jump and link resisgter: nhay toi nhan duoc luu vao thanh ghi rs + immediate, luu PC + 4 vao thanh ghi rd
           5'b11001: begin
//                       if (inst[14:12]==3'b000) begin//de phan biet giua jal va jalr
                         PCsel = 1'b1;//PC = ALUout
                         imm_sel = 3'b000;//noi dau theo I-format
                         RegWen = 1'b1;//cho phep ghi vao bang thanh ghi
                         BrUn = 1'b0;//so sanh co dau
                         Alu_sel= 4'b0000;//add in1(rs1) + in2(immGen)
                         Asel= 1'b0;//rs1
                         Bsel= 1'b1;//immGen
                         MemRW= 1'b0;//cho phep read
                         WBsel= 2'b10;// lay PC+4 luu vao thanh ghi rd
 //                      end
                     end
   endcase
 end
 endmodule
     
     
     
     