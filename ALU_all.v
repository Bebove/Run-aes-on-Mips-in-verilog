`timescale 1 ns / 1 ps 
`include "adder.v"
module ALU_all(
data1,
data2,

aluop,

result,
overflow
    );
    
input [31:0]data1;
input [31:0]data2;
input [3:0]aluop;

output [31:0]result;
output overflow;

reg [31:0]result;
//0000 :add ..
//0001 :sub ..
//0010 :and ..
//0011 :or  ..
//0100 :xor ..
//0101 ;compare
//0110 :fix << ..
//0111 :<< ..
//1000 :>> ..


wire [31:0]re_and;
wire [31:0]re_or;
wire [31:0]re_xor;
wire [31:0]re_fix;
wire [31:0]re_c;
wire [31:0]re_D;
wire [31:0]re_add;
wire [31:0]re_sub;
wire [31:0]re_compare;

//add sub and compare
wire [31:0]alu_result;
wire overf;
reg [1:0] func;

always @*
begin
    if(aluop==4'b0000)  func<=2'b01;
    else 
    begin
            if((aluop==4'b0001) | (aluop==4'b0101) ) func<=2'b11;
            else func<=2'b01;
    end
end

ALU_32bit_adder alu_full_inadder (data1,data2,func,alu_result,overf);

assign re_and=data1 & data2;
assign re_or=data1 | data2;
assign re_xor=data1 ^ data2;
//assign re_fix={data2[15:0],{16{0}}};
assign re_fix[15:0]=16'd0;
assign re_fix[31:16]=data2[15:0];
assign re_c=data2<<data1;
assign re_D=data2>>data1;
assign re_add=alu_result;
assign re_sub=alu_result;
//assign re_compare={{31{0}},alu_result[31]};  //31=1, data1<data2
assign re_compare[31:1]=31'd0;  //31=1, data1<data2
assign re_compare[0]=alu_result[31];  //31=1, data1<data2
assign overflow=overf;


always @*
begin
    case(aluop)
    4'b0000:  result=re_add;
    4'b0001:  result=re_sub;
    4'b0010:  result=re_and;
    4'b0011:  result=re_or;
    4'b0100:  result=re_xor;
    4'b0101:  result=re_compare;
    4'b0110:  result=re_fix;
    4'b0111:  result=re_c;
    4'b1000:  result=re_D;
    default:  result=0;
    endcase
end
endmodule
