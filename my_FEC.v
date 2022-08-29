module my_FEC(
input pka_1or2m_gclk,
input r_tx_rst,
//input[4:0] r_tx_state,
input input_data,
input input_data_vld_bit,
input r_coded_en,
input s,
//output s_data,
output [1:0] code_data_2,
output [7:0] code_data_8,
output reg [2:0] coded_r
    );

//reg [2:0] coded_r;//移位寄存器
reg r_data0_reg,r_data1_reg;
wire r_data0,r_data1;
//wire code_data_vld;

wire [3:0] map_code_data_a0_8;
wire [3:0] map_code_data_a1_8;
wire map_code_data_a0_2;
wire map_code_data_a1_2;



assign map_code_data_a0_8 = (r_data0) ? 4'b1100 : 4'b0011;
assign map_code_data_a1_8 = (r_data1) ? 4'b1100 : 4'b0011;
assign map_code_data_a0_2 = (r_data0) ? 1'b1 : 1'b0;
assign map_code_data_a1_2 = (r_data1) ? 1'b1 : 1'b0;


assign code_data_2 = (s) ? 2'd0 : {map_code_data_a0_2,map_code_data_a1_2};
assign code_data_8 = (s) ? {map_code_data_a0_8,map_code_data_a1_8} : 8'd0;

//my_mapper u1(.pka_1or2m_gclk(pka_1or2m_gclk),.r_tx_rst(r_tx_rst),.s(s),.r_data0(r_data0),.r_data1(r_data1),.code_data_vld(code_data_vld),.s_data(s_data));


//always @(posedge pka_1or2m_gclk or negedge r_tx_rst)
always @(posedge pka_1or2m_gclk)
begin
    if(r_tx_rst)
        begin
            coded_r <= 3'd0;
				r_data0_reg <= 0;
				r_data1_reg <= 0;
        end 
    else
        begin
            coded_r <= (input_data_vld_bit && r_coded_en) ? ({coded_r[1:0],input_data}) : coded_r;
				r_data0_reg <= (input_data_vld_bit && r_coded_en) ? input_data ^ coded_r[0] ^ coded_r[1] ^ coded_r[2] : r_data0_reg;
				r_data1_reg <= (input_data_vld_bit && r_coded_en) ? input_data ^ coded_r[1] ^ coded_r[2] : r_data1_reg;
        end
end
//assign code_data_vld = input_data_vld_bit && r_coded_en;
assign r_data0 = r_data0_reg;
assign r_data1 = r_data1_reg;
//assign r_data0 = dwh_data ^ coded_r[0] ^ coded_r[1] ^ coded_r[2];  // G0(x) = 1 + x + x^2 + x^3
//assign r_data1 = dwh_data ^ coded_r[1] ^ coded_r[2]; // G1(x) = 1 + x^2 + x^3

endmodule