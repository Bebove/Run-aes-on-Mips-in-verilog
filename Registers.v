`timescale 1 ns / 1 ps 
module Registers(
                readreg1, data1,
                readreg2, data2,
                Write_reg,    Write_data,Reg_toWrite,
                clk ,rst);

    input [4:0] readreg1,readreg2,Reg_toWrite;
    input [31:0] Write_data;
    input Write_reg;
    input clk;
    input rst;
    output [31:0] data1,data2;
 
    reg [31:0] RF [31:0];
 
    wire Write_reg_0;
    assign data1 = RF[readreg1];
    assign data2 = RF[readreg2];
    assign Write_reg_0=(Reg_toWrite==6'd0)?0:Write_reg;
always @(posedge clk or negedge rst)  //reset=0 ,do the reset
begin
    if(rst==0)
    begin
        RF[0]<=32'd0;
        RF[1]<=32'd0;
        RF[2]<=32'd0;
        RF[3]<=32'd0;
        RF[4]<=32'd0;
        RF[5]<=32'd0;
        RF[6]<=32'd0;
        RF[7]<=32'd0;
        RF[8]<=32'd0;
        RF[9]<=32'd0;
        
        RF[10]<=32'd0;
        RF[11]<=32'd0;
        RF[12]<=32'd0;
        RF[13]<=32'd0;
        RF[14]<=32'd0;
        RF[15]<=32'd0;
        RF[16]<=32'd0;
        RF[17]<=32'd0;
        RF[18]<=32'd0;
        RF[19]<=32'd0;
        
        RF[20]<=32'd0;
        RF[21]<=32'd0;
        RF[22]<=32'd0;
        RF[23]<=32'd0;
        RF[24]<=32'd0;
        RF[25]<=32'd0;
        RF[26]<=32'd0;
        RF[27]<=32'd0;
        RF[28]<=32'd0;
        RF[29]<=32'd0;
        
        RF[30]<=32'd0;
        RF[31]<=32'd0;
    end
      else
      begin  if(Write_reg_0) RF[Reg_toWrite] <= Write_data;
                else RF[Reg_toWrite] <= RF[Reg_toWrite];
        end
    end



endmodule
