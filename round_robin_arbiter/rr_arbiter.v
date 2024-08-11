module rr_arbiter(
    input                clk         ,
    input                rstn        ,
    input        [7:0]   req         ,
 
    output  reg  [7:0]   grant       
);
 
reg  [7:0] shift_req;
wire [7:0] prio_grant;
wire [2:0] shift_length;
 
// 根据上一周期的grant，修改request，使得最低bit位优先级最高。
always @(*)begin
    case(grant)     //this grant is pre-cycle request's result
        8'b0000_0001:shift_req = {req[0:0],req[7:1]};
        8'b0000_0010:shift_req = {req[1:0],req[7:2]};
        8'b0000_0100:shift_req = {req[2:0],req[7:3]};
        8'b0000_1000:shift_req = {req[3:0],req[7:4]};
        8'b0001_0000:shift_req = {req[4:0],req[7:5]};
        8'b0010_0000:shift_req = {req[5:0],req[7:6]};
        8'b0100_0000:shift_req = {req[6:0],req[7:7]};
        default:shift_req = req;
    endcase
end
 
// 找到修改后最低位的one-hot码（参考fixed_arbiter设计）
assign prio_grant = shift_req & (~(shift_req-1));  
 
// 如果grant信号是1，那么移动长度计算需要+1，如果grant信号是0则不+1.
// 这是因为$clog2函数，有$clog2(0)=$clog2(1)=0的缘故，所以我们需要区分grant是不是0.
assign shift_length = grant?($clog2(prio_grant) + $clog2(grant)+1):($clog2(prio_grant) + $clog2(grant));
 
always @(posedge clk)begin
    if(!rstn)begin
        grant <= 8'd0;
    end
    else if(req==0) // 如果输入为0，那么grant信号直接给0
        grant <= 8'd0;
    else
        case(shift_length)
            3'd0:grant <= 8'b0000_0001;
            3'd1:grant <= 8'b0000_0010;
            3'd2:grant <= 8'b0000_0100;
            3'd3:grant <= 8'b0000_1000;
            3'd4:grant <= 8'b0001_0000;
            3'd5:grant <= 8'b0010_0000;
            3'd6:grant <= 8'b0100_0000;
            3'd7:grant <= 8'b1000_0000;
        endcase
end
 
endmodule