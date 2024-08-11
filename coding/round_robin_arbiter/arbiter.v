module arbiter (
    input clk,
    input rst_n,
    input [7:0] req,
    output reg [7:0] grant
);

reg [7:0] req_shfit;


//调整优先级
always @(*) begin
    case(grant)
        8'b0000_0001:req_shfit = {req[0],req[7:1]};
        8'b0000_0010:req_shfit = {req[1:0],req[7:2]};
        8'b0000_0100:req_shfit = {req[2:0],req[7:3]};
        8'b0000_1000:req_shfit = {req[3:0],req[7:4]};
        8'b0001_0000:req_shfit = {req[4:0],req[7:5]};
        8'b0010_0000:req_shfit = {req[5:0],req[7:6]};
        8'b0100_0000:req_shfit = {req[6:0],req[7]};
        default:req_shfit = req;
    endcase
end

wire [7:0]prio_req;
assign prio_req = req_shfit & (~req_shfit + 1);//one-hot

wire [2:0] shfit;
assign shfit = grant ? ($clog2(grant) + $clog2(prio_req) + 1) : ($clog2(grant) + $clog2(prio_req)) ;

always @(posedge clk ,negedge rst_n) begin
    if(!rst_n)
        grant <= 0;
    else begin
        case(shfit)
            'd0:grant = 8'b0000_0001;
            'd1:grant = 8'b0000_0010;
            'd2:grant = 8'b0000_0100;
            'd3:grant = 8'b0000_1000;
            'd4:grant = 8'b0001_0000;
            'd5:grant = 8'b0010_0000;
            'd6:grant = 8'b0100_0000;
            'd7:grant = 8'b1000_0000;
            default:grant = 8'b0000_0000;
        endcase
    end 
end

    
endmodule