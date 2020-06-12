`timescale 1 ns / 1 ps 

module branch_detect(
pcsrc[1:0],
data1[31:0],
data2[31:0],
beq_pr_bne,

branch_bool
    );
    
//beq:0
//bne:1

input [1:0]pcsrc;
input [31:0]data1;
input [31:0]data2;
input beq_pr_bne;

output branch_bool;
reg branch_bool;

reg bool1;
always @*
begin
    if(data1==data2) bool1<=1;
    else bool1<=0;
end



always @*
begin
    if(pcsrc==2'b01)
    begin
        branch_bool<=beq_pr_bne?(~bool1):bool1; //0:beq,= then branch
    end
    else
    begin
        branch_bool<=0;
    end

end    
    
endmodule
