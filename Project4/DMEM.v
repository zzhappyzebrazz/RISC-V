module DMEM (input clk, rst_n,
             input [31:0] dataW, Addr,
             input MemRW,               //0: read, 1: write
             output [31:0] dataR);
reg [31:0] DMEMi [0:256];

assign dataR= DMEMi[Addr];//dataR = gia tri cua Dmem tai vi tri Addr(la gia tri tu khoi ALU)
always @(posedge clk) begin//canh len cua xung clock
  if (!rst_n) begin
    //dataR <= 32'hxxxxxxxx;
    DMEMi[Addr] <= 32'hxxxxxxxx;//tuy dinh vi tri o nho Addr cua khoi Dmem
  end
  else begin
    if (MemRW==1'b1) begin//ghi vao khoi Dmem tai vi tri Addr noi dung dataW(dataB tu khoi reg[])
      DMEMi[Addr] <= dataW;
      //dataR <= 32'bxxxxxxxx;
    end
    else begin//khong lam gi ghi de len tai address nay bang gia tri moi
      DMEMi[Addr] <=  DMEMi[Addr];
      //dataR <= DMEMi[Addr];
    end
  end
end
endmodule
    
    