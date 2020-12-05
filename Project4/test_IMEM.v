module test_IMEM;
  reg [31:0] PC;
  wire [31:0] inst;
  
READ_IMEM dut (.PC(PC), .inst(inst));

initial begin
  PC=32'b00000000000000000000000000000001;
  $display("inst=%0h", inst);
  #20;
  PC=32'b00000000000000000000000000001000;
  $display("inst=%0h", inst); 
  #50;
end
endmodule