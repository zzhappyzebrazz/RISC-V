
/******** Read Data From I-MEM *********/
module READ_IMEM(output inst,
		 input  PC);

parameter	INST_WIDTH_LENGTH = 32;
parameter	PC_WIDTH_LENGTH = 32;
parameter       MAX_MEM_DEPTH_BIT = 18;

input		[PC_WIDTH_LENGTH-1:0]PC;
output		[INST_WIDTH_LENGTH-1:0]inst;

wire [31:0]PC_seg;

assign PC_seg = {15'b000000000000000, PC[MAX_MEM_DEPTH_BIT:2]};//PC_seg = 15bit 0 va 16bit cua PC tu bit 2 den 18
IMEM	w0(.inst(inst),.PC(PC_seg));//gia tri PC cua khoi IMEM = PC_seg


endmodule