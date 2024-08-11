module afifo
#(
    parameter                           DEEPWID = 3                ,
    parameter                           DEEP    = 8                ,
    parameter                           BITWID  = 8                 
)
(
    input                               wr_clk                     ,
    input                               wr_rst_n                   ,
    input                               wr                         ,
    input              [BITWID - 1 : 0] wr_dat                     ,

    input                               rd_clk                     ,
    input                               rd_rst_n                   ,
    input                               rd                         ,
    output      reg    [BITWID - 1 : 0] rd_dat                     ,
    output      reg    [BITWID - 1 : 0] rd_dat_valid               ,

    input              [DEEPWID - 1 : 0]cfg_almost_full            ,
    input              [DEEPWID - 1 : 0]cfg_almost_empty           ,

    output                              almost_full                ,
    output                              almost_empty               ,

    output                              full                       ,
    output                              empty                      ,
    output             [DEEPWID - 1 : 0]wr_num                     ,
    output             [DEEPWID - 1 : 0]rd_num                      
);

wire [DEEPWID - 1 : 0] wr_ptr;
wire [DEEPWID - 1 : 0] rd_ptr;
reg [DEEPWID : 0] wr_ptr_exp;
reg [DEEPWID : 0] rd_ptr_exp;

reg [DEEPWID : 0] wr_ptr_exp_r;
reg [DEEPWID : 0] wr_ptr_exp_cross;
reg [DEEPWID : 0] wr_ptr_exp_cross_r;
wire [DEEPWID : 0] wr_ptr_exp_cross_trans;

reg [DEEPWID : 0] rd_ptr_exp_r;
reg [DEEPWID : 0] rd_ptr_exp_cross;
reg [DEEPWID : 0] rd_ptr_exp_cross_r;
wire [DEEPWID : 0] rd_ptr_exp_cross_trans;

reg [BITWID - 1 : 0] my_memory[DEEPWID - 1 : 0];
integer ii;

//--------------------Indicator signal----------------------//
assign wr_num = wr_ptr - rd_ptr_exp_cross_trans;
assign rd_num = rd_ptr - rd_ptr_exp_cross_trans;

assign almost_full = (wr_num >= cfg_almost_full) || ((wr_num == cfg_almost_full - 1)&&(wr == 1));
assign almost_empty = (rd_num >= cfg_almost_empty) || ((rd_num == cfg_almost_empty - 1)&&(rd == 1));

assign full = (wr_num == DEEP) || ((wr_num - 1)&&(wr));
assign empty = (rd_num == 0) || ((rd_num == 1)&&(rd));

//---------------------wr_ptr and rd_ptr-------------------//
always @(posedge wr_clk,negedge wr_rst_n) begin
    if(!wr_rst_n)
        wr_ptr_exp <= 'b0;
    else if(wr)
        wr_ptr_exp <= {1'b0,wr_ptr} + {{DEEPWID{1'b0}},1'b1};
end

always @(posedge rd_clk,negedge rd_rst_n) begin
    if(!rd_rst_n)
        rd_ptr_exp <= 'b0;
    else if(rd)
        rd_ptr_exp <= {1'b0,rd_ptr} + {{DEEPWID{1'b0}},1'b1};
end

//----------------------------CDC---------------------------//
always @(posedge wr_clk,negedge wr_rst_n) begin
    if(!wr_rst_n)begin
        wr_ptr_exp_r <= 'b0;
        rd_ptr_exp_cross <= 'b0;
        rd_ptr_exp_cross_r <= 'b0;
    end else begin
        rd_ptr_exp_cross <= rd_ptr_exp_r;
        rd_ptr_exp_cross_r <= rd_ptr_exp_cross;
        wr_ptr_exp_r <= graycode(wr_ptr_exp);
    end
end

always @(posedge rd_clk,negedge rd_rst_n) begin
    if(!rd_rst_n)begin
        rd_ptr_exp_r <= 'b0;
        wr_ptr_exp_cross <= 'b0;
        wr_ptr_exp_cross_r <= 'b0;
    end else begin
        wr_ptr_exp_cross <= wr_ptr_exp_r;
        wr_ptr_exp_cross_r <= wr_ptr_exp_cross;
        rd_ptr_exp_r <= graycode(rd_ptr_exp);
    end
end

assign wr_ptr_exp_cross_trans = degraycode(wr_ptr_exp_cross_r);
assign rd_ptr_exp_cross_trans = degraycode(rd_ptr_exp_cross_r);


//-----------------------write and read memory-----------------//
always @(posedge wr_clk,negedge wr_rst_n) begin
    if(!wr_rst_n)begin
        for (ii = 0;ii < 8 ;ii = ii + 1) begin
            my_memory[ii] <= 8'b0;
        end
    end else begin
        if(wr)
            for (ii = 0;ii < 8 ;ii = ii + 1) begin
                if(wr_ptr == ii)
                    my_memory[ii] <= wr_dat;
            end
    end
end

always @(posedge rd_clk,negedge rd_rst_n) begin
    if(!rd_rst_n)begin
        for (ii = 0;ii < 8 ;ii = ii + 1) begin
            my_memory[ii] <= 8'b0;
        end
    end else begin
        if(rd)
            for (ii = 0;ii < 8 ;ii = ii + 1) begin
                if(rd_ptr == ii)
                    rd_dat <= my_memory[ii];
            end
    end
end

always @(posedge rd_clk,negedge rd_rst_n) begin
    if(!rd_rst_n)
        rd_dat_valid <= 0;
    else
        rd_dat_valid <= rd;
end


//---------------------graycode to binary-------------------//
//bin to graycode
function [DEEPWID : 0] graycode;
    input [ DEEPWID : 0] val_in;
    reg [DEEPWID + 1 : 0] val_in_exp;
    integer i;
    begin
        val_in_exp = {1'b0,val_in};
        for (i = 0;i < DEEPWID + 1 ;i = i + 1) begin
            graycode[i] = val_in[i] ^ val_in_exp[i+1];  
        end
    end
endfunction

// graycode to bin
function [DEEPWID : 0] degraycode;
    input [DEEPWID : 0] val_in;
    reg [DEEPWID + 1 : 0]val_in_temp;
    integer i;
    begin
        val_in_temp = {(DEEPWID + 2){1'b0}};
        for (i = DEEPWID + 1;i > 0;i = i - 1) begin
            val_in_temp[i - 1] = val_in[i - 1] ^ val_in_temp[i];
        end
        degraycode = val_in_temp[DEEPWID : 0];
    end
    
endfunction

endmodule