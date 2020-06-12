`timescale 1 ns / 1 ps 

module pc_next_mux(reset,
pcnext,
if_flush,

pc_plus4,
pc_branch,
pc_jump,
pc_jr,

pcsrc,
branch_bool
    );
    
input reset;
input [31:0]pc_plus4;
input [31:0]pc_jump;
input [31:0]pc_jr;
input [31:0]pc_branch;
input [1:0]pcsrc;
input branch_bool;

output [31:0]pcnext;
output if_flush;

reg [31:0]pcnext;
reg if_flush;
//pcnext
always @*
begin
    if (reset==0)
    begin
        pcnext<=32'd4;
    end
    else
    begin
        case(pcsrc)
        2'b00:begin
                     pcnext<=pc_plus4;
                     if_flush<=0;
              end
        2'b01: begin
                        if(branch_bool==1)  
                        begin
                            pcnext<=pc_branch;
                            if_flush<=1;
                        end
                        else  
                        begin
                             pcnext<=pc_plus4;
                             if_flush<=0;
                        end             
               end
        2'b10:begin
                     pcnext<=pc_jump;
                     if_flush<=1;
              end
        2'b11: begin
                     pcnext<=pc_jr;    
                     if_flush<=1; 
               end
        endcase
    end
end
endmodule

