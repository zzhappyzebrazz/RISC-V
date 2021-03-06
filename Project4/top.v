module cpu_top (input clk, rst_n);
  
  //I/O PCmux khoi 1to2
  wire [31:0] alu_out, pc_add4, pc_mux_out;// pc_mux_out = pcmux(pc_out)
  wire  pc_sel;
    //neu pc_sel = 1 thi chon alu_out , khong thi chon gia tri dua ra tu khoi pcadd4
    PCmux PCmux (.alu_out(alu_out), .pc_add4(pc_add4), .pc_sel(pc_sel), .pc_out(pc_mux_out));
    
  //I/O PC
  wire [31:0] pc_out;
	//clk, rst_n khoi reset gia tri pc khi !rst_n pc_out <= 32'h00400000
	// else pc_out <= pc_in = pc_mux_out = pcmux(pc_out)
    PC PC (.clk(clk), .rst_n(rst_n), .pc_in(pc_mux_out), .pc_out(pc_out));
     //khoi PC + 4 pc
// khi co gia tri PC_in thi tang PC len 4   
    pc_add4 pc_add (.pc_in(pc_out), .pc_out(pc_add4));
    
//I/O IMEM thay doi gia tri khi co gia tri PC moi
//cau lenh instruction duoc lay ra tu bo nhom IMEM boi gia tri cua khoi PC
// PC duoc chia thanh 2 gia tri pWord va pByte
  wire [31:0] inst;
    READ_IMEM IMEM (.PC(pc_out), .inst(inst));
     
  //I/O regs khoi lua chon thanh ghi cho dataA, dataB va gia tri write back
  wire RegWen;
  //rs1 tu bit 15-19 cua instruction vaf rs tu 20-14, toan hang dich duoc luu va thanh ghi co gia tri bit 7-11 cua instruction
  // gia tri write back duoc dua vao tu khoi WriteBackSelect
//gia tri Register Write enable duoc trigger boi khoi controller cho phep ghi vao thanh ghi
//khi cho phep ghi vao thanh ghi gia tri rd duoc luu vao vi tri cua gia tri wb
  wire [31:0] wb, dataA, dataB;
  
    regs regs (.clk(clk), .rst_n(rst_n), .rs1(inst[19:15]), .rs2(inst[24:20]), .rd(inst[11:7]), .RegWen(RegWen), .wb(wb), .dataA(dataA), .dataB(dataB));
  
  //I/O imm_gen khoi tao ra gi tri tuc thi immediate gen
  wire [2:0] imm_sel;// gia tri immediate select duoc lay ra tu khoi controller de chon cac loai immediate
	// nhu I, S, B, U, J, R formar
  wire [31:0] imm_out;
//immediate input la 26 bit cuoi cua cau lenh instuctrion se duoc cat ra ung voi moi loai format
//trong khoi immgen nay sex noi dau cho immediate
//ngo ra la 1 so co dau 32 bit
    imm_gen imm_gen (.imm_in(inst[31:7]), .imm_sel(imm_sel), .imm_out(imm_out));
    
  //I/O branch_comp
  wire BrUn, BrLt, BrEq;
  //so sanh 2 gia tri dau vao dataA va dataB, cho do co dau hoac khong dau
//ngo ra la gia tri Branch Equal hoac Branch Lessthan
// neu so sanh co dau thi 2 toan hang duoc bu 2 de so sanh va doi dau  
    branch_comp branch_comp (.rs1(dataA), .rs2(dataB), .BrUn(Brun), .BrEq(BrEq), .BrLt(BrLt));
  
  //I/O mux_A khoi chon gia tri toan hang 1 cho khoi ALU
//chon giua 2 gia tri PC va gia tri toan hang 1 rs1 tu khoi reg[]
  wire A_sel;  
  wire [31:0] muxA_out;
    mux_A mux_A (.pc(pc_out), .rs1(dataA), .A_sel(A_sel), .muxA_out(muxA_out));
    
    
  //I/O mux_B chon giua 2 gia tri immediate out tu khoi immgen hoac toan hang 2 tu khoi reg[] rs2
// trigger B_sel tu khoi controller
  wire B_sel;  
  wire [31:0] muxB_out;
    mux_B mux_B (.imm(imm_out), .rs2(dataB), .B_sel(B_sel), .muxB_out(muxB_out));
    
  //I/O alu khoi chon cac che do va dau vao khoi ALU
  wire [3:0] alu_sel;
//lay cac gia tri dau ra cua 2 khoi muxA va muxB la cac toan hang
//tu khoi controler cac operation duoc dua vao khoi ALU bang bien alu_select
//gia tri ngo ra duoc luu vao bien alu_out
    alu alu (.in1(muxA_out), .in2(muxB_out), .alu_sel(alu_sel), .alu_out(alu_out));
    
  //I/O DMEM khoi Dmem do dai bo nho la 32bit
// va co 256 stack bo nho
//address duoc lay ra tu ket qua cua khoi ALU
//dataWrite la gia tri cua dataB tu khoi reg[]
// gia tri MemRW trigger cho phep viet hoac doc tu khoi controller
  wire MemRW;
  wire [31:0] dataR;
  DMEM DMEM (.clk(clk), .rst_n(rst_n), .dataW(dataB), .Addr(alu_out), .MemRW(MemRW), .dataR(dataR));
  //DMEM_2 DMEM (.clk(clk), .rst_n(rst_n), .dataW(dataB), .Addr(alu_out[4:0]), .MemRW(MemRW), .dataR(dataR));
  
  //I/O mux_W khoi chon WriteBack vao khoi Reg cho dataD
  wire [1:0] WBsel;
//mem la gia tri dataR tu khoi Dmem, gia tri ket qua cua ALU, gia tri PC + 4 cho cau lenh jump and link register 
// trigger WbSelect tu khoi controller de chon cho ket qua ra Write Back vao dataD
    mux_W mux_W (.mem(dataR), .alu(alu_out), .pc_add4(pc_add4), .WB_sel(WBsel), .wb(wb));
 
//khoi controller
//instruction tu khoi IMEM
//Branch Equal, Branch Lessthan tu khoi branch compare
//PC_sel chon PC +4 hoac gia tri tu khoi ALU
//Bsel Asel de chon gia toan hang cho khoi ALU
//BrUn trigger so sanh co dau hoac khong dau
//RegWen cho phep ghi vao thanh ghi
//Cho phep doc hoa ghi vao DMEM MemRW
//imm_sel chon 8 che do cho immediate gen cho cac format cau lenh
//Alu_sel chon cac operation cho khoi ALU
//chon gia tri WriteBack ALU, PC + 4, Dmem   
  controller controller (.inst(inst), .BrEq(BrEq), .BrLt(BrLt), .PCsel(pc_sel), .RegWen(RegWen), .BrUn(BrUn), 
                         .Bsel(B_sel), .Asel(A_sel), .MemRW(MemRW), .imm_sel(imm_sel), .Alu_sel(alu_sel), .WBsel(WBsel));
endmodule 
    
    