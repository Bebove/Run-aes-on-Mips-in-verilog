`timescale 1 ns / 1 ps 


module ctrl(inst[31:0],
    overflowck,
    regwrite,
    regdst[1:0],
    memtoreg[1:0],
    memwrite,
    memread,
    alusrcA,
    alusrcB,
    pcsrc[1:0],
   // IFFlush,
    aluop[3:0],
    how_imm
    );
    input [31:0] inst;
    
    
    output overflowck;
    output regwrite;
    output [1:0]regdst;
    output [1:0]memtoreg;
    output memwrite;
    output memread;
    output alusrcA;
    output alusrcB;
    output [1:0]pcsrc;
    //output IFFlush;
    output [3:0]aluop;
    output how_imm;
    //  *0000 :         (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26])
    // ( inst[])
    assign overflowck=(inst[29] & (~ inst[28]) & ( ~inst[27]) & (~ inst[26])) |
    (  (  (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26])) & (( inst[5])&(~ inst[3])&(~ inst[2])) );
    assign regwrite=~(  
                        (inst[31] & inst[29])                            | 
                        ((~inst[31]) & (~inst[30]) & (~inst[29])&inst[28])  |
                        ((~inst[28]) & inst[27] & (~inst[26]) )         |
                        (   ((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))    &  (    (~inst[5])  & (inst[3])    )    )   
                     );
     assign regdst[0]=(~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]);
     assign regdst[1]=(~ inst[31])&(~ inst[29])&( inst[27])&( inst[26]);
     assign memtoreg[0]=( inst[31]) & (~ inst[29]);
     assign memtoreg[1]=( ~inst[31])&( ~inst[29])&(~ inst[28])&( inst[26]);
     assign memwrite=( inst[31])&(~ inst[30])&( inst[29]);
     assign memread=( inst[31])&(~ inst[29]);
     assign alusrcA=((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))  &  (  ( ~inst[5]) &  ( ~inst[3]) );
     assign alusrcB=(( inst[31])) | (   (~ inst[31])&( ~inst[30])&( inst[29])   );
     assign pcsrc[0]=  (  (~ inst[29]) & ( inst[28])  &( ~inst[27])   )  |
                       (           ((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))&(( ~inst[5])&( inst[3]))           )  ;
     assign pcsrc[1]=(( ~inst[31])&( ~inst[28])&( inst[27]))|(  ((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))   & ((~ inst[5])&( inst[3])));
    // assign IFFlush=(  ( (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))   &  (  ( ~inst[5]) & ( inst[3]))      )|
    //                (    ( ~inst[29])&( inst[28])&( ~inst[27]))|
    //                (( ~inst[31])&( ~inst[29])&( inst[28]));
     assign aluop[0]=(  ((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))   &  ((~ inst[5])&( ~inst[3])&(~ inst[2])&( ~inst[1]))  )|
                        (   ( (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))   &  (( inst[2])&(~ inst[1])&( inst[0])) )|
                        (   ((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))  &  (( inst[5])&( ~inst[3])&(~ inst[2])&( inst[1])))|
                        (((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))  &  (( inst[5])&( inst[3])))|
                        (( inst[29])&( inst[28])&( ~inst[27])&( inst[26]));
     assign aluop[1]=((  (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))     &  (  ( inst[2])  &  (~ inst[1]))  )|
                    (  (  (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))  &  ((~ inst[5])&(~ inst[3])&(~ inst[2])&(~ inst[1])))|
                    ( ( ~inst[31])  &   ( inst[29])  &   ( inst[28])  &   (~ inst[27]))|
                    (   ( inst[29]) &  ( inst[28])  &  ( inst[27])  &  ( inst[26]));
     assign aluop[2]=(  (  (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26])) & (( inst[5])&( inst[2])&( inst[1])&(~ inst[0])))|
                       ((  (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))  & (( inst[5])&( inst[3])&( inst[1])&(~ inst[0])))|
                       ((  (~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))  & (( ~inst[5])&(~ inst[3])&(~ inst[1])))|
                       (( inst[29])&( inst[28])&( inst[27]));
     assign aluop[3]=((~inst[29]) & (~inst[28]) &(~inst[27]) &(~inst[26]))  &  ((~ inst[5])&(~ inst[2])&( inst[1])&(~ inst[0])); 
     assign how_imm=  ~((~(inst[27] & inst[26]))  & inst[29]  &inst[28]);
endmodule
