`timescale 1 ns / 1 ps 

module ALU_32bit_adder(a,b,func,s,overf);
    input [31:0] a;
    input [31:0] b;
    input [1:0] func;
    output [31:0] s; 
    output overf;
    
    wire sign;
    wire sub;
    assign sign=func[0];
    assign sub=func[1];
    reg [31:0]bb;
    wire [31:0]co;
    reg ci;
    
    always @*
    begin
        case(func)
        2'b00: begin            //add unsigned
                    bb=b;
                    ci=0;
                end
        2'b01: begin            //add signed
                    bb=b;
                    ci=0;  
                end
        2'b10: begin            //sub unsigned
                    bb=~b;
                    ci=1;
                end
        2'b11: begin            //sub signed
                    bb=~b;
                    ci=1;
                end      
        endcase
    end
    unsigned_adder_32bit fst(a,bb,ci,s,co);
    assign overf=sign?(co[31]^co[30]):(sub^co[31]);
endmodule




module unsigned_adder_32bit(a,b,ci,     s,co);
    input [31:0]a;
    input [31:0]b;
    input ci;
    output [31:0]s;
    output [31:0]co;
    
    wire cio1;
    wire cio2;
    wire cio3;
    wire cio4;
    wire cio5;
    wire cio6;
    wire cio7;
    wire cio8;
    
    adder4bits ad0(a[3:0],b[3:0],ci, s[3:0], co[3:0],cio1);
    adder4bits ad1(a[7:4],b[7:4],cio1, s[7:4], co[7:4],cio2);
    adder4bits ad2(a[11:8],b[11:8],cio2, s[11:8], co[11:8],cio3);
    adder4bits ad3(a[15:12],b[15:12],cio3, s[15:12], co[15:12],cio4);
    adder4bits ad4(a[19:16],b[19:16],cio4, s[19:16], co[19:16],cio5);
    adder4bits ad5(a[23:20],b[23:20],cio5, s[23:20], co[23:20],cio6);
    adder4bits ad6(a[27:24],b[27:24],cio6, s[27:24], co[27:24],cio7);
    adder4bits ad7(a[31:28],b[31:28],cio7, s[31:28], co[31:28],cio8);
endmodule



module adder4bits(a,b,ci,s,co,cio);
    input [3:0] a;
    input [3:0] b;
    input ci;
    output [3:0] s;
    output [3:0]co;
    output cio;
    
    wire [3:0] c;
    wire [3:0] g;
    wire [3:0] p;
    wire bp;
    
    //generate (setup) G and P
    assign g=a&b;
    assign p=a^b;
    
    //generate c and s
    assign c[0]=g[0]||(p[0]&&ci);
    assign c[1]=g[1]||(p[1]&&c[0]);
    assign c[2]=g[2]||(p[2]&&c[1]);
    assign c[3]=g[3]||(p[3]&&c[2]);
    assign s[0]=p[0]^ci;
    assign s[1]=p[1]^c[0];
    assign s[2]=p[2]^c[1];
    assign s[3]=p[3]^c[2];
    
    //do the multiple
    assign bp=p[0] && p[1] && p[2] && p[3];
    assign cio= bp? ci:c[3];
    
    //set the 4bit co for any use
    assign co=c;
endmodule