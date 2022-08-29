module my_dwh(
    input pka_1or2m_gclk,
	 input fsm_dwh_init,
	 input fsm_switch_dwh,
	 input vld_data_coded,
    input r_tx_rst,
    //input[215:0] data,
	 input r_data,
    input[6:0] ble_dwh_init,
	 
    output reg [6:0] r_dwh_lfsr,
    output s_data

    );

	 //wire d;
    wire [6:0] c;
    //reg r_data;
	 //reg[215:0] data_reg;
	 reg s_data_reg;
	 
    //assign d = r_data;
    assign c = r_dwh_lfsr;
	 assign s_data = s_data_reg;
	 
	//always@(posedge pka_1or2m_gclk or posedge r_tx_rst) 
	always@(posedge pka_1or2m_gclk)                                                    
	 begin
        if(r_tx_rst)
            begin
				r_dwh_lfsr <= 7'b0000000;
				s_data_reg <=0;
				end
        else if(fsm_dwh_init)
            begin
				r_dwh_lfsr <= ble_dwh_init;
				//data_reg <= data;
				//r_data <= data[0];
				end
		  else if(fsm_switch_dwh && vld_data_coded)
		      begin
		      r_dwh_lfsr[0] <= c[6];
			   r_dwh_lfsr[1] <= c[0];
				r_dwh_lfsr[2] <= c[1];
				r_dwh_lfsr[3] <= c[2];
				r_dwh_lfsr[4] <= c[3] ^ c[6];
				r_dwh_lfsr[5] <= c[4];
				r_dwh_lfsr[6] <= c[5];
				s_data_reg <= c[6] ^ r_data;
				//r_data <= data_reg[0];
            end
		  else 
		      begin
		      r_dwh_lfsr <= r_dwh_lfsr;
				end
    end
	 
endmodule