module readmem();
    reg [7:0] test_memory [0:15];
    initial begin
        $display("Loading rom.");
        $readmemh("C:\Users\Computer\Desktop\RISC-V\CTMT_Single_Cycle\factorial.txt",test_memory);
    end
endmodule
