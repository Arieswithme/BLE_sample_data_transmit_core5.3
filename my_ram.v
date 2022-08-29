module my_ram
#(parameter DW = 32,AW = 7)
(
    input clk,
    input [AW-1:0]a1,//address
    input cs1,// chip select
    input oe1,// output enable
    input we1,// write enable
    inout [DW-1:0]d1,// data
    // 
    input [AW-1:0]a2,//address
    input cs2,// chip select
    input oe2,// output enable
    input we2,// write enable
    inout [DW-1:0]d2// data
    );
 
// 
parameter DP = 1 << AW;// depth=128
reg [DW-1:0]mem[0:DP-1];
reg [DW-1:0]reg_d1;
reg [DW-1:0]reg_d2;

//initialization
// synopsys_translate_off
integer i;
initial begin
    for(i=0; i < DP; i = i + 1) begin
        mem[i] = 32'h0000_0000;
    end
end
// synopsys_translate_on

 
// read declaration
// port1
always@(posedge clk)
begin
    if(cs1 & !we1 & oe1)
	 //if(cs1 & !we1)
        begin
            reg_d1 <= mem[a1];
        end
    else
        begin
            reg_d1 <= reg_d1;
        end
end
// port2
always@(posedge clk)
begin
    if(cs2 & !we2 & oe2)
	 //if(cs2 & !we2)
        begin
            reg_d2 <= mem[a2];
        end
    else
        begin
            reg_d2 <= reg_d2;
        end
end
 
// wrirte declaration
always@(posedge clk)
begin
    if(cs1 & we1)//port1 higher priority
        begin
            mem[a1] <= d1;
        end
    else if(cs2 & we2)
        begin
            mem[a2] <= d2;
        end
    else
        begin
            mem[a1] <= mem[a1];
            mem[a2] <= mem[a2];
        end    
end
 
// 三态逻辑
assign d1 = (cs1 & !we1 & oe1) ? reg_d1 : {DW{1'bz}};
assign d2 = (cs2 & !we2 & oe2) ? reg_d2 : {DW{1'bz}};
endmodule