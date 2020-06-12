`include "mipscore.v"
`include "cache.v"

module tb;
reg clk;
reg reset;
initial
begin
    clk=0;
    forever
    begin
        #1 clk=~clk;
    end
end
initial
begin
    reset=0;
    
    #9 reset=1;
end
wire [31:0] pc;
wire [31:0] inst;
wire [31:0]     exmem_alu_output; 
wire exmem_memwrite; 
wire exmem_memread;
wire [31:0] exmem_write_data;
wire [31:0] read_data_from_dcache;


Instruction_memory Im (reset,pc,inst);
mipscore mp(clk,reset,pc,inst,exmem_alu_output ,exmem_memwrite,exmem_memread,exmem_write_data,read_data_from_dcache);
Data_memory cashe_data (clk,reset       ,   
                        exmem_alu_output,  
                        exmem_memwrite  ,   exmem_memread ,
                        exmem_write_data,   read_data_from_dcache);
endmodule