`timescale 1 ns / 1 ps 
module load_use_detect(
memread_en,
idexrt[4:0],
ifidrs[4:0],
ifidrt[4:0],

load_use_en
    );
    
input     memread_en;
input [4:0]idexrt;
input [4:0]ifidrs;
input [4:0]ifidrt;

output load_use_en;
reg load_use_en;


always @*
begin
    if(memread_en)
    begin
        if((idexrt==ifidrs) || (idexrt==ifidrt) )
        begin
            load_use_en<=1;
        end
        else
        begin
         load_use_en<=0;    
        end
    end
    else
    begin
        load_use_en<=0;
    end


end
endmodule
