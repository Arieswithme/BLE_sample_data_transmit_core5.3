module my_crc(
    input pka_1or2m_gclk,
    input fsm_crc_init,
	 input fsm_switch_crc,
	 input r_fsm_data,
    input r_tx_rst,
	 input crc_din_vld,
	 //input[4:0] r_tx_state,
    input[23:0] ble_crc_init,
	 
    output reg [23:0] r_crc_lfsr,//crc校验结果
	 //output reg fsm_vld_bit,
	 output r_data
);


  // polynomial: x^24 + x^10 + x^9 + x^6 + x^4 + x^3 + x^1 + 1
  // data width: 1
  // function [23:0] nextCRC24_D1;

    wire d;
    wire [23:0] c;
    
    assign d = r_fsm_data;
    assign c = r_crc_lfsr;
	 assign r_data = r_crc_lfsr[23];

    //always@(posedge pka_1or2m_gclk or posedge fsm_crc_init or posedge r_tx_rst) //对于广播信道包 AUX_SYNC_IND 和它的子集来说，移位寄存器的初始值应该与 AUX_ADV_IND 中 SyncInfo 的值相同。
	  
	 always@(posedge pka_1or2m_gclk or posedge r_tx_rst)                                     //除此之外，对于其余所有的广播信道包来说，移位寄存器的初始值都会被配置为 0x555555。
	 begin
        if(r_tx_rst)
            r_crc_lfsr <= 24'h000000;
        else if(fsm_crc_init)
            //r_crc_lfsr <= 24'h555555;
				r_crc_lfsr <= ble_crc_init;
		  else if(fsm_switch_crc && crc_din_vld)
		   begin
		      r_crc_lfsr[0] <= d ^ c[23];
				r_crc_lfsr[1] <= d ^ c[0] ^ c[23];//c[23]相当于一个1检测器
            r_crc_lfsr[2] <= c[1];
            r_crc_lfsr[3] <= d ^ c[2] ^ c[23];
            r_crc_lfsr[4] <= d ^ c[3] ^ c[23];
            r_crc_lfsr[5] <= c[4];
            r_crc_lfsr[6] <= d ^ c[5] ^ c[23];
            r_crc_lfsr[7] <= c[6];
            r_crc_lfsr[8] <= c[7];
            r_crc_lfsr[9] <= d ^ c[8] ^ c[23];
            r_crc_lfsr[10] <= d ^ c[9] ^ c[23];
            r_crc_lfsr[11] <= c[10];
            r_crc_lfsr[12] <= c[11];
            r_crc_lfsr[13] <= c[12];
            r_crc_lfsr[14] <= c[13];
            r_crc_lfsr[15] <= c[14];
            r_crc_lfsr[16] <= c[15];
            r_crc_lfsr[17] <= c[16];
            r_crc_lfsr[18] <= c[17];
            r_crc_lfsr[19] <= c[18];
            r_crc_lfsr[20] <= c[19];
            r_crc_lfsr[21] <= c[20];
            r_crc_lfsr[22] <= c[21];
            r_crc_lfsr[23] <= c[22];
         end
		  else 
		   begin
		      /*r_crc_lfsr[0] <= d;
				r_crc_lfsr[1] <= d ^ c[0]; 
            r_crc_lfsr[2] <= c[1];
            r_crc_lfsr[3] <= d ^ c[2];
            r_crc_lfsr[4] <= d ^ c[3];
            r_crc_lfsr[5] <= c[4];
            r_crc_lfsr[6] <= d ^ c[5];
            r_crc_lfsr[7] <= c[6];
            r_crc_lfsr[8] <= c[7];
            r_crc_lfsr[9] <= d ^ c[8];
            r_crc_lfsr[10] <= d ^ c[9]; 
            r_crc_lfsr[11] <= c[10];
            r_crc_lfsr[12] <= c[11];
            r_crc_lfsr[13] <= c[12];
            r_crc_lfsr[14] <= c[13];
            r_crc_lfsr[15] <= c[14];
            r_crc_lfsr[16] <= c[15];
            r_crc_lfsr[17] <= c[16];
            r_crc_lfsr[18] <= c[17];
            r_crc_lfsr[19] <= c[18];
            r_crc_lfsr[20] <= c[19];
            r_crc_lfsr[21] <= c[20];
            r_crc_lfsr[22] <= c[21];
            r_crc_lfsr[23] <= c[22];*/
				r_crc_lfsr <= r_crc_lfsr;
         end		      
    end
endmodule
