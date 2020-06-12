`timescale 1 ns / 1 ps 
`include "ALU_all.v"
`include "ctrl.v"
`include "branch_detect.v"
`include "load_use_detect.v"
`include "pc_next_mux.v"
`include "Registers.v"
module mipscore(clk,  reset  ,pc_copy, inst_copy ,exmem_alu_output_copy ,exmem_memwrite_copy,exmem_memread_copy,exmem_write_data_copy,read_data_from_dcache_copy);
input clk; 
input reset;    
input [31:0] inst_copy;

///useless
wire [31:0]uselessco;

//not yes use

wire branch_bool;
reg [31:0] Write_data;
reg Write_reg;
reg [4:0]Reg_toWrite;


output [31:0] pc_copy;
wire [31:0] pc_copy;    
reg [31:0] pc;
assign pc_copy=pc;


wire [31:0] pcnext;
wire   [1:0]d_pcsrc;
wire if_flush;
wire nop_loaduse;

wire [31:0] pc_branch;
reg [31:0] pc_jump;
//wire [31:0] pc_jr;  data1_Registersfile
wire [31:0] pc_plus4;
wire [31:0]data1_Registersfile;
wire [31:0]data2_Registersfile;
reg [31:0] data1_after_wb_detect;                
reg [31:0] data2_after_wb_detect;  

//the caculate of pc+4 to pc_plus4
unsigned_adder_32bit pc4adder(pc,32'd4,1'b0,pc_plus4,uselessco);
//select for the pcnext and if_clush: by pcsrc and branch_bool
pc_next_mux pcmux(reset,
pcnext,if_flush,
pc_plus4,   pc_branch   ,pc_jump    ,data1_after_wb_detect, //pc_jr is data1_Registersfile
d_pcsrc,branch_bool);
//load use: pc and ifid freeze
always @(posedge clk or negedge reset)  //reset=0 ,do the reset
begin
    if(reset==0)
    begin
            pc<=32'd0;
    end
    else
    begin
 //pc freeze
            if(nop_loaduse) pc<=pc;
            else     pc<=pcnext;
    end
end

//read instraction from memory
wire [31:0] inst;
assign inst=inst_copy;
//Instruction_memory Im (reset,pc,inst);


//ifid regs
reg [31:0]ifid;
reg [31:0]ifid_pc_plus4;

//ifid regs how to update 
always @(posedge clk or negedge reset)  //reset=0 ,do the reset
begin
    if(reset==0)
    begin
            ifid<=32'd0;
            ifid_pc_plus4<=32'd4;
    end
    else
    begin
            if(nop_loaduse) 
            begin
                                if(if_flush)
                                begin
                                                    ifid<=0;
                                                    ifid_pc_plus4<=32'd4;
                                end
                                else 
                                begin
                                                    ifid<=ifid;
                                                    ifid_pc_plus4<=ifid_pc_plus4;
                                end
            end
            else            
            begin
                                if(if_flush)
                                begin
                                                    ifid<=0;
                                                    ifid_pc_plus4<=32'd4;
                                end
                                else 
                                begin
                                                    ifid<=inst;
                                                    ifid_pc_plus4<=pc_plus4;
                                end

            end 
    end
end


//read and write reg

Registers rg_file(
                ifid[25:21], data1_Registersfile,   //rs
                ifid[20:16], data2_Registersfile,   //rt
                Write_reg,    Write_data,Reg_toWrite, //rd //not use yet
                clk,reset );
       
//decode signal
wire d_overflowck; 
wire d_regwrite;
wire [1:0]d_regdst;
wire [1:0]d_memtoreg;
wire d_memwrite;
wire d_memread;
wire    d_alusrcA;
wire    d_alusrcB;
wire d_how_imm;
//reg  d_IFFlush;
wire  [3:0]d_aluop;
        
ctrl decoder (ifid,
    d_overflowck,
    d_regwrite,
    d_regdst[1:0],
    d_memtoreg[1:0],
    d_memwrite,
    d_memread,
    d_alusrcA,
    d_alusrcB,
    d_pcsrc[1:0],
//    d_IFFlush,
    d_aluop[3:0],
    d_how_imm
    );              
                
//idex regs
reg idex__overflowck; 
reg idex_how_imm;
reg idex_regwrite;
reg [1:0]idex_regdst;
reg [1:0]idex_memtoreg;
reg idex_memwrite;
reg idex_memread;
reg    idex_alusrcA;
reg    idex_alusrcB;
//reg   [1:0]idex_pcsrc; 
//reg  idex_IFFlush;
reg  [3:0]idex_aluop;

reg  [31:0]idex_pc_plus4;
reg [4:0]idex_rs;
reg [4:0]idex_rt;
reg [4:0]idex_rd;
reg [31:0]idex_data1;
reg [31:0]idex_data2;

reg [4:0]idex_sa;
reg [15:0]idex_imm;
//branch detect
branch_detect brdetect(d_pcsrc,data1_after_wb_detect,data2_after_wb_detect,ifid[26], branch_bool);
//load_use detect
load_use_detect lud(idex_memread,idex_rt,ifid[25:21],ifid[20:16],nop_loaduse);
//idex update
always @(posedge clk or negedge reset)
begin
    if(reset==0)
    begin
        idex__overflowck<=0;
        idex_regwrite<=0;
        idex_regdst<=0;
        idex_memtoreg<=0;
        idex_memwrite<=0;
        idex_memread<=0;
        idex_alusrcA<=0;
        idex_alusrcB<=0;
        idex_aluop<=0;
        
        idex_pc_plus4<=0;
        idex_rs<=0;
        idex_rt<=0;
        idex_rd<=0;
        
        idex_data1<=0;
        idex_data2<=0;
        
        idex_sa<=0;
        idex_imm<=0;
        
        idex_how_imm<=0;
    end
    else
    begin
        if(nop_loaduse==0)
        begin
            idex__overflowck<=d_overflowck;
            idex_regwrite<=d_regwrite;
            idex_regdst<=d_regdst;
            idex_memtoreg<=d_memtoreg;
            idex_memwrite<=d_memwrite;
            idex_memread<=d_memread;
            idex_alusrcA<=d_alusrcA;
            idex_alusrcB<=d_alusrcB;
            idex_aluop<=d_aluop;
            
            idex_pc_plus4<=ifid_pc_plus4;
            idex_rs<=ifid[25:21];
            idex_rt<=ifid[20:16];
            idex_rd<=ifid[15:11];
            
            idex_data1<=data1_after_wb_detect;
            idex_data2<=data2_after_wb_detect;
            
            idex_sa<=ifid[10:6];
            idex_imm<=ifid[15:0];
            idex_how_imm<=d_how_imm;
        end
        else
        begin
            idex__overflowck<=0;
            idex_regwrite<=0;
            idex_regdst<=0;
            idex_memtoreg<=0;
            idex_memwrite<=0;
            idex_memread<=0;
            idex_alusrcA<=0;
            idex_alusrcB<=0;
            idex_aluop<=0;
            
            idex_pc_plus4<=0;
            idex_rs<=0;
            idex_rt<=0;
            idex_rd<=0;
            
            idex_data1<=0;
            idex_data2<=0;
            
            idex_sa<=0;
            idex_imm<=0;
            idex_how_imm<=0;
        end
    end
end

// j/jr/branch addr generate
    //pc_branch
    wire [31:0] uselessco1;
    reg [31:0]offset_signed_extend_16;
    always @*
    begin
            offset_signed_extend_16<={{16{ifid[15]}}, ifid[15:0]};
    end
    unsigned_adder_32bit pc_branch_adder(
    ifid_pc_plus4,
    offset_signed_extend_16,
    1'b0,
    pc_branch,
    uselessco1);
    //pc_j
    always @*
    begin
            pc_jump<={ifid_pc_plus4[31:28],ifid[25:0],2'b00};
    end
// mux for alu
reg [31:0] alu_data1_mux1;
reg [31:0] alu_data1_mux2;

reg [31:0] alu_data2_mux1;
reg [31:0] alu_data2_mux2;

reg [1:0]forward_data1;
reg [1:0]forward_data2;

wire [31:0] forward1_01;
wire [31:0] forward1_10;
wire [31:0] forward2_01;
wire [31:0] forward2_10;
    //mux1
        always @*
        begin
            case(forward_data1)
            2'b00: alu_data1_mux1<=idex_data1;
            2'b01: alu_data1_mux1<=forward1_01;
            2'b10: alu_data1_mux1<=forward1_10;
            2'b11: alu_data1_mux1<=0;
            endcase
        end
        
        always @*
        begin
            case(forward_data2)
            2'b00: alu_data2_mux1<=idex_data2;
            2'b01: alu_data2_mux1<=forward2_01;
            2'b10: alu_data2_mux1<=forward2_10;
            2'b11: alu_data2_mux1<=0;
            endcase
        end
     //mux2
        always @*
        begin
            case(idex_alusrcA)
            1'b0: alu_data1_mux2<=alu_data1_mux1;  //rs
            1'b1: begin
                    alu_data1_mux2[31:5]<=27'd0;
                    alu_data1_mux2[4:0]<=idex_sa[4:0];
                  end
            endcase
        end
        
        always @*
        begin
            case(idex_alusrcB)
            1'b0: alu_data2_mux2<=alu_data2_mux1;  //rt
            1'b1: begin
                      //  alu_data2_mux2<=idex_how_imm?{  {16{idex_imm[15]}}  ,idex_imm[15:0]}:{  {16{0}}  ,idex_imm[15:0]};         //imm  
                        alu_data2_mux2[15:0]<=idex_imm[15:0];
                        if((idex_how_imm==1'b1) & (idex_imm[15]==1'b1) )alu_data2_mux2[31:16]<= 16'b1111111111111111;
                        else alu_data2_mux2[31:16]<=16'b0000000000000000;
                  end
            
            endcase
        end

// alu
wire [31:0]alu_opt;
wire alu_overflow;
ALU_all alu_full (alu_data1_mux2,alu_data2_mux2,
       idex_aluop,
       alu_opt,
       alu_overflow );    
//reg for exmem
reg [31:0]     exmem_alu_output;
reg [4:0]      exmem_rt;
reg [4:0]      pre_exmem_rt;
reg exmem_regwrite;
reg [1:0]exmem_memtoreg;
reg exmem_memwrite;
reg exmem_memread;
reg  [31:0]exmem_pc_plus4;
reg [31:0] exmem_write_data;


// reg dist
always @*
begin
    case(idex_regdst)
    2'b00:pre_exmem_rt<=idex_rt;
    2'b01:pre_exmem_rt<=idex_rd;
    2'b10:pre_exmem_rt<=5'd31;
    2'b11:pre_exmem_rt<=0;
    endcase
end
//exmem_update
always @(posedge clk or negedge reset)
begin
    if(reset==0)
    begin
        exmem_alu_output<=0;
        exmem_rt<=0;
        exmem_regwrite<=0;
        exmem_memtoreg<=0;
        exmem_memwrite<=0;
        exmem_memread<=0;
        exmem_pc_plus4<=0;
        exmem_write_data<=0;
    end
    else
    begin
    
        exmem_alu_output<=alu_opt;
        exmem_rt<=pre_exmem_rt;
        
        exmem_memtoreg<=idex_memtoreg;
        exmem_memwrite<=idex_memwrite;
        exmem_memread<=idex_memread;
        exmem_pc_plus4<=idex_pc_plus4;
        exmem_write_data<=alu_data2_mux1;
        if ( (idex__overflowck==1) & (alu_overflow==1) ) //overflow
        begin
            exmem_regwrite<=0;   
        end
        else
        begin
            exmem_regwrite<=idex_regwrite;    
        end
    end
end




//data_cache
wire [31:0] read_data_from_dcache;

output [31:0] exmem_alu_output_copy;
output exmem_memwrite_copy,exmem_memread_copy;
output [31:0] exmem_write_data_copy;
input [31:0] read_data_from_dcache_copy;
reg [31:0]     exmem_alu_output_copy; 
reg exmem_memwrite_copy; 
reg exmem_memread_copy;
reg [31:0] exmem_write_data_copy;
wire [31:0] read_data_from_dcache_copy;

assign read_data_from_dcache=read_data_from_dcache_copy;
always @*
begin
exmem_alu_output_copy=exmem_alu_output;
exmem_memwrite_copy=exmem_memwrite;
exmem_memread_copy=exmem_memread;
exmem_write_data_copy=exmem_write_data;
end

//Data_memory cashe_data (clk,reset       ,   
//                        exmem_alu_output,  
//                        exmem_memwrite  ,   exmem_memread ,
//                        exmem_write_data,   read_data_from_dcache);
//memwb regs
reg [4:0]   memwb_rt;
reg         memwb_regwrite;
reg [1:0]   memwb_memtoreg;
reg  [31:0] memwb_pc_plus4;
reg [31:0]  memwb_alu_data;
reg [31:0]  memwb_dcache_data;

always  @(posedge clk or negedge reset)
begin
        if(reset==0)
        begin
            memwb_rt<=0;
            memwb_regwrite<=0;
            memwb_memtoreg<=0;
            memwb_pc_plus4<=0;
            memwb_alu_data<=0;
            memwb_dcache_data<=0;
        end
        
        else
        begin
            memwb_rt<=exmem_rt;
            memwb_regwrite<=exmem_regwrite;
            memwb_memtoreg<=exmem_memtoreg;
            memwb_pc_plus4<=exmem_pc_plus4;
            memwb_alu_data<=exmem_alu_output;
            memwb_dcache_data<=read_data_from_dcache;
        end

end
// detect for data
reg [31:0]wb_data;
    //data1:
    assign     forward1_01 = exmem_alu_output;
    assign     forward1_10 = wb_data;
    
    always @*
    begin
        if(  (exmem_regwrite==1) & (~(exmem_rt == 5'd0))  &  (exmem_rt==idex_rs)    )   
        begin
            forward_data1<=2'b01;  
        end
        else   
        begin
            if ( (memwb_regwrite==1) &(~(memwb_rt==5'd0)) &(memwb_rt==idex_rs) )
            begin
                forward_data1<=2'b10;
            end
            else
            begin
                forward_data1<=2'b00;
            end
        end
    end
    //data2:
    assign     forward2_01 = exmem_alu_output;
    assign     forward2_10 = wb_data;  
    
    always @*
    begin
        if(  (exmem_regwrite==1) & (~(exmem_rt == 5'd0))  &  (exmem_rt==idex_rt)    )   
        begin
            forward_data2<=2'b01;  
        end
        else   
        begin
            if ( (memwb_regwrite==1) &(~(memwb_rt== 5'd0)) &(memwb_rt==idex_rt) )
            begin
                forward_data2<=2'b10;
            end
            else
            begin
                forward_data2<=2'b00;
            end
        end
    end
    



// writeback_mux
always    @*
begin
    case(memwb_memtoreg)
    2'b00:  wb_data<=memwb_alu_data;
    2'b01:  wb_data<=memwb_dcache_data;
    2'b10:  wb_data<=memwb_pc_plus4;
    2'b11:  wb_data<=0;
    endcase
end 

//wb_wire
always @*
begin
    Write_reg<=memwb_regwrite;
    Write_data<=wb_data;
    Reg_toWrite<=memwb_rt;
end

//wb_data_detect

always  @*
begin
    if( (memwb_regwrite==1)    & (~(memwb_rt== 5'd0)) & (memwb_rt==ifid[25:21]))
    begin
        data1_after_wb_detect <=wb_data;
    end
    else
    begin
        data1_after_wb_detect <=data1_Registersfile;
    end

end

always  @*
begin
    if( (memwb_regwrite==1)    & (~(memwb_rt== 5'd0)) & (memwb_rt==ifid[20:16]))
    begin
        data2_after_wb_detect <=wb_data;
    end
    else
    begin
        data2_after_wb_detect <=data2_Registersfile;
    end

end
endmodule
