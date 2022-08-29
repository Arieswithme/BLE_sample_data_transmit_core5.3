module my_jtd(
 input pka_1or2m_gck,
 input start_flag,
 input[31:0] Preamble, //为了循环所以用32位的，并非preamble是32位的。
 input rst_n,
 
 input[2:0] BLE_TYPE,
 input BLE_ADV_STATE,
 input BLE_TX_RX_EN,
 //input reg BLE_WHITEN_EN,
 input[6:0] BLE_WHITEN_INIT,
 input[23:0] BLE_CRC_INIT,
 input[31:0] BLE_ACC_ADDR, 
 input[15:0] BLE_ADV_HEADER,
 input[15:0] BLE_DATA_HEADER,
 input[1:0] BLE_CI,
 input[2:0] BLE_TERM1,
 input[2:0] BLE_TERM2,
 
 input[6:0] ram_a1,
 //input[31:0] ram_d1,
 inout[31:0] ram_d1,
 input ram_cs1,
 input ram_we1,
 input ram_oe1,
 
 output reg r_fsm_data,
 output reg r_fsm_data_vld,
 
 output reg[3:0] current_state,next_state,
 output reg[7:0] r_cnt
 );
 
 //reg[3:0] current_state,next_state,r_cnt_cnt;
 //reg[7:0] r_cnt;
 reg[7:0] r_cnt_cnt;
 reg[7:0] r_bytes;
 reg[31:0] r_tx_shift_reg;
 reg[31:0] PAYLOAD;
 reg[6:0] RAM_A2;
 reg RAM_CS2,RAM_WEN2,RAM_OE2;
 reg r_switch_crc,r_switch_crc_coded,r_crc_init,r_crc_init_coded,r_switch_dwh,r_dwh_init,r_switch_dwh_coded,r_dwh_init_coded,tx_fsm_finished;
 reg r_rst_tx_reg; 
 reg payload_zz_flag;
 reg vld_flag_coded;
 reg vld_zz_flag;
 /*
 reg r_coded_en_1;
 reg r_coded_en_2;
 reg r_coded_en_3; */
 
 reg vld_flag_coded_dwh;
 reg vld_flag_coded_crc;
 reg vld_flag_uncoded_dwh;
 reg vld_flag_uncoded_crc;
 //reg r_input_coded_vld;
 
 
// wire[4:0] r_count;
// wire[3:0] r_cnt_count;
 wire[31:0] ram_d2;
 wire[6:0] ram_a2;
 wire ram_cs2,ram_we2,ram_oe2;
 wire switch_crc,crc_init,switch_dwh;
 wire switch_crc_coded,crc_init_coded,switch_dwh_coded;
 wire r_rst_tx;
 wire r_fsm_data_wire;
 wire[23:0] r_crc_lfsr;
 wire[6:0] r_dwh_lfsr;
 wire[23:0] r_crc_lfsr_coded;
 wire[6:0] r_dwh_lfsr_coded;
 wire r_dwh_data_wire,r_crc_data_wire,r_dwh_data_wire_coded,r_crc_data_wire_coded;
 wire s_crc_data;
 wire s_dwh_data;
 wire s_crc_data_coded;
 wire s_dwh_data_coded;
 wire s_2;
 /*====================coded模块的输出
 wire[1:0] code_data_2_1;
 wire[7:0] code_data_8_1;
 wire[1:0] code_data_2_2;
 wire[7:0] code_data_8_2;
 wire[1:0] code_data_2_2_term2;
 wire[7:0] code_data_8_2_term2;
 ==========================*/
/*
 wire r_input_coded_data_wire1;
 wire r_input_coded_data_wire2;
 wire r_input_coded_data_wire3;
 wire r_coded_en_wire1;
 wire r_coded_en_wire2;
 wire r_coded_en_wire3;*/
  //=====================================test 只使用一个coded的编码模块
 wire s;
 wire[1:0] code_data_2;
 wire[7:0] code_data_8;
 wire r_input_coded_data_wire;
 wire r_coded_en_wire;
 reg  r_coded_en;
 //=======================================警戒线
 wire vld_flag_coded_wire;
 wire vld_flag_coded_dwh_wire;
 wire vld_flag_coded_crc_wire;
 wire vld_flag_uncoded_dwh_wire;
 wire vld_flag_uncoded_crc_wire;
 //wire r_input_coded_vld_wire;
 wire[2:0] coded_r;
 
 parameter[3:0] s_idle=4'b0000,s_tx_preamble=4'b0001,s_tx_access=4'b0010,s_tx_ci=4'b0011,s_tx_term1=4'b0100,s_tx_pdu_header=4'b0101,s_tx_pdu_payload=4'b0110,s_wait_crc=4'b0111,s_tx_term2=4'b1000,s_end=4'b1001,s_reset=4'b1010;
 
 my_ram u2(.clk(pka_1or2m_gck),.a1(ram_a1),.d1(ram_d1),.we1(ram_we1),.cs1(ram_cs1),.oe1(ram_oe1),.a2(ram_a2),.d2(ram_d2),.we2(ram_we2),.cs2(ram_cs2),.oe2(ram_oe2));
 my_crc crc_uncoded(.pka_1or2m_gclk(pka_1or2m_gck),.fsm_crc_init(crc_init),.fsm_switch_crc(switch_crc),.r_fsm_data(r_crc_data_wire),.r_tx_rst(r_rst_tx),.crc_din_vld(vld_flag_uncoded_crc_wire),.ble_crc_init(BLE_CRC_INIT),.r_crc_lfsr(r_crc_lfsr),.r_data(s_crc_data));
 my_dwh dwh_uncoded(.pka_1or2m_gclk(pka_1or2m_gck),.fsm_dwh_init(dwh_init),.fsm_switch_dwh(switch_dwh),.vld_data_coded(vld_flag_uncoded_dwh_wire),.r_tx_rst(r_rst_tx),.r_data(r_dwh_data_wire),.ble_dwh_init(BLE_WHITEN_INIT),.r_dwh_lfsr(r_dwh_lfsr),.s_data(s_dwh_data));
 //my_FEC FEC1(.pka_1or2m_gclk(pka_1or2m_gck),.r_tx_rst(r_rst_tx),.input_data(r_input_coded_data_wire1),.input_data_vld_bit(vld_flag_coded_wire),.r_coded_en(r_coded_en_wire1),.s(1'd1),.code_data_2(code_data_2_1),.code_data_8(code_data_8_1));
 //my_FEC FEC2(.pka_1or2m_gclk(pka_1or2m_gck),.r_tx_rst(r_rst_tx),.input_data(r_input_coded_data_wire2),.input_data_vld_bit(vld_flag_coded_wire),.r_coded_en(r_coded_en_wire2),.s(s_2),.code_data_2(code_data_2_2),.code_data_8(code_data_8_2));
 //my_FEC FEC3(.pka_1or2m_gclk(pka_1or2m_gck),.r_tx_rst(r_rst_tx),.input_data(r_input_coded_data_wire3),.input_data_vld_bit(vld_flag_coded_wire),.r_coded_en(r_coded_en_wire3),.s(s_2),.code_data_2(code_data_2_2_term2),.code_data_8(code_data_8_2_term2));
 my_crc crc_coded(.pka_1or2m_gclk(pka_1or2m_gck),.fsm_crc_init(crc_init_coded),.fsm_switch_crc(switch_crc_coded),.r_fsm_data(r_crc_data_wire_coded),.r_tx_rst(r_rst_tx),.crc_din_vld(vld_flag_coded_crc_wire),.ble_crc_init(BLE_CRC_INIT),.r_crc_lfsr(r_crc_lfsr_coded),.r_data(s_crc_data_coded));
 my_dwh dwh_coded(.pka_1or2m_gclk(pka_1or2m_gck),.fsm_dwh_init(dwh_init_coded),.fsm_switch_dwh(switch_dwh_coded),.vld_data_coded(vld_flag_coded_dwh_wire),.r_tx_rst(r_rst_tx),.r_data(r_dwh_data_wire_coded),.ble_dwh_init(BLE_WHITEN_INIT),.r_dwh_lfsr(r_dwh_lfsr_coded),.s_data(s_dwh_data_coded));
 
 my_FEC test(.pka_1or2m_gclk(pka_1or2m_gck),.r_tx_rst(r_rst_tx),.input_data(r_input_coded_data_wire),.input_data_vld_bit(vld_flag_coded_wire),.r_coded_en(r_coded_en_wire),.s(s),.code_data_2(code_data_2),.code_data_8(code_data_8),.coded_r(coded_r));

assign r_rst_tx = r_rst_tx_reg;
assign ram_a2 = RAM_A2;
assign ram_cs2 = RAM_CS2;
assign ram_we2 = RAM_WEN2;
assign ram_oe2 = RAM_OE2;
assign switch_crc = r_switch_crc;
assign crc_init = r_crc_init;
assign switch_dwh = r_switch_dwh;
assign dwh_init = r_dwh_init;
assign switch_crc_coded = r_switch_crc_coded;
assign crc_init_coded = r_crc_init_coded;
assign switch_dwh_coded = r_switch_dwh_coded;
assign dwh_init_coded = r_dwh_init_coded;
assign r_fsm_data_wire = r_fsm_data;

assign r_dwh_data_wire = (current_state==s_wait_crc) ?  r_tx_shift_reg[31] :  r_tx_shift_reg[0];
assign r_crc_data_wire = r_tx_shift_reg[0];

assign r_dwh_data_wire_coded = (current_state==s_wait_crc) ? r_tx_shift_reg[31] : r_tx_shift_reg[0];
assign r_crc_data_wire_coded = r_tx_shift_reg[0];

assign vld_flag_coded_wire=vld_flag_coded;
assign vld_flag_coded_dwh_wire=vld_flag_coded_dwh;
assign vld_flag_coded_crc_wire=vld_flag_coded_crc;
assign vld_flag_uncoded_dwh_wire=vld_flag_uncoded_dwh;
assign vld_flag_uncoded_crc_wire=vld_flag_uncoded_crc;

assign s_2 = (BLE_CI==00) ? 1 : 0; //s=1代表编码类型为8，s=0代表编码类型为2
//assign r_count = r_cnt;
//assign r_cnt_count=r_cnt_cnt;


//**========================
 assign r_coded_en_wire = r_coded_en;
 assign r_input_coded_data_wire = ((current_state==s_tx_pdu_header)|(current_state==s_tx_pdu_payload)|current_state==(s_wait_crc)) ?  s_dwh_data_coded : r_tx_shift_reg[0]; 
 assign s = ((current_state==s_tx_pdu_header)|(current_state==s_tx_pdu_payload)|(current_state==s_wait_crc)) ? s_2 : 1'b1;
 //======================================test警戒线


always@(*) 
 begin
    case(current_state)
	  s_idle: 
	    begin
		   r_fsm_data=1'b0;
			if(BLE_TX_RX_EN) //发送使能应该在ram的payload以及preamble、header寄存器初始化，重要的就是在于ram
			//r_bytes=根据BLE_ADV_STATE的状态把当前要发送的payload的length赋值
			  begin
               r_rst_tx_reg=0;
					//注意此时默认header是16位，且只有连接和广播两种类型。
					if(BLE_ADV_STATE)    r_bytes=BLE_DATA_HEADER[15:8];
					else                 r_bytes=BLE_ADV_HEADER[15:8]; //r_bytes=length
			      
					if(start_flag)//起始时刻到来，在发送时隙的起始点或 150us 帧间隔来临
			       begin
				     //r_tx_shift_reg[31:0]=Preamble[31:0];
				     next_state=s_tx_preamble;
				     r_switch_crc=1'b1;
					  r_switch_dwh=1'b1;
					  r_switch_crc_coded=1'b1;
					  r_switch_dwh_coded=1'b1;  
					  //r_coded_en_1=1'b1;
					  r_coded_en=1'b1;
				    end //文献：状态跳转时，需要把状态机的输出使能信号置为有效状态，同时把 CRC 模块的使能信号也置为有效状态。
				   else  next_state=s_idle;
			  end
			else next_state=s_idle;  
	    end 
     s_tx_preamble: //公共部分
	    begin
		   //r_fsm_data=r_tx_shift_reg[0];  //发送数据流r_fsm_data
			if(BLE_TYPE==3'b010)//如果发送报文为 2Mbps 非编码类型，则在 r_cnt 第二次计数到 7 时，也就是preamble是2 octets
			  begin
				 r_fsm_data_vld=1'b1;
				 r_fsm_data=r_tx_shift_reg[0];
				 if(r_cnt==8'd15)  next_state=s_tx_access;
				 else              next_state=s_tx_preamble;
				end
			else if(BLE_TYPE==3'b100) //如果发送报文为 1Mbps 编码类型，则在 r_cnt 第十次计数到 7 时，也就是preamble是10 octets
			  begin
				 r_fsm_data=r_tx_shift_reg[0];
				 r_fsm_data_vld=1'b1;
				 if(r_cnt==8'd79)  
				   begin 
					  //r_fsm_data=0;
					  next_state=s_tx_access;
				     //vld_flag_coded=1'b1;
					  //r_input_coded_vld=1'b1;
				   end
				 else 
               begin 
					  //r_fsm_data=r_tx_shift_reg[0];
					  next_state=s_tx_preamble;
					end
			  end	
         else	//其他类型时，均在 r_cnt第一次计数到 7 时
           begin
			    r_fsm_data_vld=1'b1;
			    r_fsm_data=r_tx_shift_reg[0];
			    if(r_cnt==8'd7)   next_state=s_tx_access;
				 else              next_state=s_tx_preamble; 
			  end	  
       end
     s_tx_access: //公共部分
	     begin
			//r_fsm_data=r_tx_shift_reg[0];
         if(BLE_TYPE==3'b100) //如果发送报文为 1Mbps 编码类型，则需要把 2bits 的 CI 装载进移位寄存器，同时状态机跳转到s_tx_ci 状态
			  begin
				 if(r_cnt==8'd0)
				   begin
					  if(r_cnt_cnt==8'd0) 		r_fsm_data_vld=1'b0;
					  else                     r_fsm_data_vld=1'b1;
					  vld_flag_coded=1'b1;
					  r_cnt_cnt=r_cnt_cnt+8'd1;
					  //r_fsm_data=code_data_8_1[0];
					  r_fsm_data=code_data_8[0];
					end
				 else if(r_cnt==8'd1)
				   begin
					  r_fsm_data_vld=1'b1;
				     vld_flag_coded=1'b0;
					  //r_fsm_data=code_data_8_1[7];
					  r_fsm_data=code_data_8[7];
					end
			    else if((r_cnt==8'd2)|(r_cnt==8'd3)|(r_cnt==8'd4)|(r_cnt==8'd5)|(r_cnt==8'd6)|(r_cnt==8'd7))
				   begin
					  //r_fsm_data=code_data_8_1[8'd8-r_cnt];
					  r_fsm_data=code_data_8[8'd8-r_cnt];
					end
				 else
				   begin
					  next_state=s_tx_access;
					end
				 if(r_cnt_cnt==8'd33) 
				   begin
					 next_state=s_tx_ci;
					 r_cnt_cnt=8'd0;
					 vld_flag_coded=1'b0;
					end
				 else
				   begin
					next_state=s_tx_access;
					end
				end	
         else	//其他类型时，则把 16bits or 24bits （这里需要最后再解决一下，主要是数字信道的24和新的同步音频流？）的 Header 装载进移位寄存器，同时状态机跳转到 s_tx_pdu_header 状态
           begin
			  r_fsm_data=r_tx_shift_reg[0];
				if(r_cnt==8'd31) 
				   begin
					  next_state=s_tx_pdu_header;
					  r_crc_init=1'b1;
					  r_dwh_init=1'b1; 	  
					  RAM_A2=7'b1111111;
					end											
					//状态机跳转时，把 r_crc_init 置为 1，即对 CRC 模块进行初始化；
		         //同时为了方便后续对数据载荷的提取，令 TX-RAM 的地址指针指向末尾处。		  
				 else next_state=s_tx_access; 
			  end	  	   
		  end
     s_tx_ci: //这个状态仅在发送报文为 1Mbps 编码类型时才会被用到 
	     begin
			 if(r_cnt==8'd0)
			   begin
				  if(r_cnt_cnt==8'd0) 		r_fsm_data_vld=1'b0;
				  else                     r_fsm_data_vld=1'b1;
				  vld_flag_coded=1'b1;
				  r_cnt_cnt=r_cnt_cnt+8'd1;
				  //r_fsm_data=code_data_8_1[0];
				  r_fsm_data=code_data_8[0];
				end
			 else if(r_cnt==8'd1)
				begin
				  r_fsm_data_vld=1'b1;
				  vld_flag_coded=1'b0;
				  //r_fsm_data=code_data_8_1[7];
				  r_fsm_data=code_data_8[7];
				end
			 else if((r_cnt==8'd2)|(r_cnt==8'd3)|(r_cnt==8'd4)|(r_cnt==8'd5)|(r_cnt==8'd6)|(r_cnt==8'd7))
				begin
				  //r_fsm_data=code_data_8_1[8'd8-r_cnt];
				  r_fsm_data=code_data_8[8'd8-r_cnt];
				end
			 else
				begin
				  next_state=s_tx_ci;
				end
			 if(r_cnt_cnt==8'd3) 
				begin
				  next_state=s_tx_term1;
				  r_cnt_cnt=8'd0;
				  vld_flag_coded=1'b0;
				end
			 else
				begin
				  next_state=s_tx_ci;
			   end
		  end
     s_tx_term1: //这个状态在发送数据为 1Mbps 编码类型时才会被用到
	     begin
			 if(r_cnt==8'd0)
			   begin
				  if(r_cnt_cnt==8'd0) 		r_fsm_data_vld=1'b0;
				  else                     r_fsm_data_vld=1'b1;
				  vld_flag_coded=1'b1;
				  r_cnt_cnt=r_cnt_cnt+8'd1;
				  //r_fsm_data=code_data_8_1[0];
				  r_fsm_data=code_data_8[0];
				end
			 else if(r_cnt==8'd1)
				begin
				  r_fsm_data_vld=1'b1;
				  vld_flag_coded=1'b0;
				  //r_fsm_data=code_data_8_1[7];
				  r_fsm_data=code_data_8[7];
				end
			 else if((r_cnt==8'd2)|(r_cnt==8'd3)|(r_cnt==8'd4)|(r_cnt==8'd5)|(r_cnt==8'd6)|(r_cnt==8'd7))
				begin
				  r_fsm_data=code_data_8[8'd8-r_cnt];
				end
			 else
				begin
				  next_state=s_tx_term1;
				end
			 if(r_cnt_cnt==8'd4) 
				begin
				  next_state=s_tx_pdu_header;
				  r_cnt_cnt=8'd0;
				  vld_flag_coded=1'b0;
				  vld_flag_coded_dwh=1'b0;
				  vld_flag_coded_crc=1'b0;
				  r_crc_init_coded=1'b1;
				  r_dwh_init_coded=1'b1;
				  RAM_A2=7'b1111111;
				end
			 else
				begin
				  next_state=s_tx_term1;
			   end
		  end
     s_tx_pdu_header: //公共部分
	     begin
		    if((BLE_TYPE==3'b100))
			   begin
				  r_crc_init_coded=1'b0;
			     r_dwh_init_coded=1'b0;
				  if(s_2==1)
				    begin
					   if(r_cnt==8'd0)
						  begin
						    r_fsm_data=code_data_8[0];
						    if(r_cnt_cnt==8'd0)
							   begin
								  r_fsm_data_vld=1'b0;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd12)
							   begin  			  
		                    RAM_A2=RAM_A2+7'b1;
					           RAM_CS2=1;
					           RAM_WEN2=0;
					           RAM_OE2=1;
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd13)
							   begin
								  PAYLOAD=ram_d2;
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd16)
							   begin
								  vld_flag_coded=1'b1;
								  vld_flag_coded_dwh=1'b0;
							     vld_flag_coded_crc=1'b0;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
							   end
							 else if(r_cnt_cnt==8'd17)
							   begin
								  r_cnt_cnt=8'd0;
								  vld_flag_coded=1'b0;
								  vld_flag_coded_dwh=1'b0;
							     vld_flag_coded_crc=1'b0;
								  payload_zz_flag=1'b1;
								  next_state=s_tx_pdu_payload;
								end
							 else  
								begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
							   end	
						  end
						else if(r_cnt==8'd1)
				        begin
						    r_fsm_data_vld = (r_cnt_cnt==2) ? 1'd1 : r_fsm_data_vld;
				          vld_flag_coded=1'b0;
							 vld_flag_coded_dwh=1'b0;
							 vld_flag_coded_crc=1'b0;
							 r_fsm_data=code_data_8[7];
					     end
						else if((r_cnt==8'd2)|(r_cnt==8'd3)|(r_cnt==8'd4)|(r_cnt==8'd5)|(r_cnt==8'd6)|(r_cnt==8'd7))
						  begin
							 r_fsm_data=code_data_8[8'd8-r_cnt];
						  end
						else
				        begin
				          next_state=next_state;
				        end
					 end
				  else
				    begin
					   if(r_cnt==8'd0)
						  begin
						    r_fsm_data=code_data_2[0];
						    if(r_cnt_cnt==8'd0)
							   begin
								  r_fsm_data_vld=1'b0;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd12)
							   begin  			  
		                    RAM_A2=RAM_A2+7'b1;
					           RAM_CS2=1;
					           RAM_WEN2=0;
					           RAM_OE2=1;
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd13)
							   begin
								  PAYLOAD=ram_d2;
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd16)
							   begin
								  vld_flag_coded=1'b1;
								  vld_flag_coded_dwh=1'b0;
							     vld_flag_coded_crc=1'b0;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
							   end
							 else if(r_cnt_cnt==8'd17)
							   begin
								  r_cnt_cnt=8'd0;
								  vld_flag_coded=1'b0;
								  vld_flag_coded_dwh=1'b0;
							     vld_flag_coded_crc=1'b0;
								  payload_zz_flag=1'b1;
								  next_state=s_tx_pdu_payload;
								end
							 else  
								begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
							   end	
						  end
						else if(r_cnt==8'd1)
				        begin
						    r_fsm_data_vld = (r_cnt_cnt==2) ? 1'd1 : r_fsm_data_vld;
				          vld_flag_coded=1'b0;
							 vld_flag_coded_dwh=1'b0;
							 vld_flag_coded_crc=1'b0;
							 r_fsm_data=code_data_2[1];
					     end
						else
				        begin
				          next_state=next_state;
				        end 
				    end
				end
			 
			 else
			   begin
		        r_crc_init=1'b0;
			     r_dwh_init=1'b0; //不同于文献;
			     r_fsm_data=s_dwh_data;
			     if(r_cnt==8'd0)
				    begin
					   vld_flag_uncoded_dwh=1'b1;
			         vld_flag_uncoded_crc=1'b1;
					   r_fsm_data_vld=1'b0;
					 end
				  else if(r_cnt==8'd1)  //r_cnt 计数到 1,把白化模块的使能信号置为有效状态，开始对 Header 部分进行白化操作。
			       begin
					   //r_switch_dwh=1'b1;
					   r_fsm_data_vld=1'b1;
					   next_state=s_tx_pdu_header;
				    end
			     else if(r_cnt==8'd12)
			       begin
		            RAM_A2=RAM_A2+7'b1;
					   RAM_CS2=1;
					   RAM_WEN2=0;
					   RAM_OE2=1;
					   //PAYLOAD=32'd0;
					   next_state=s_tx_pdu_header;
			         //令 TX-RAM 的地址指针加 1，同时把 TX-RAM 的读使能信号置为有效状态，这样就可以从 TX-RAM中取出 32bits 的 payload
				    end 
			     else if(r_cnt==8'd13)
			       begin
				      PAYLOAD=ram_d2;
					   next_state=s_tx_pdu_header;
				    end
			     else if(r_cnt==8'd16) 
			       begin
					   vld_flag_uncoded_dwh=1'b0;
			         vld_flag_uncoded_crc=1'b0;
			         next_state=s_tx_pdu_payload;
					   payload_zz_flag=1'b1;
                end
	          end				 
		  end
     s_tx_pdu_payload: //公共部分
	     begin
		    if((BLE_TYPE==3'b100))
			   begin
				  payload_zz_flag=1'b0;
				  if(s_2)
				    begin
						if(r_cnt==8'd0)
						  begin
							 r_fsm_data=code_data_8[0];
                      if(next_state==s_wait_crc)
							   begin
								  vld_flag_coded_dwh=1'b0;
								  vld_flag_coded_crc=1'b0;
								  r_cnt_cnt=8'd0;
								end
							 else if(r_cnt_cnt==8'd0)
							   begin
								  r_fsm_data_vld=(vld_zz_flag) ? 1'b1 : 1'b0;
							     if(r_bytes==8'd0)  
								    begin
									   next_state=s_wait_crc;
										r_cnt_cnt=8'd0;
										vld_flag_coded_dwh=1'b0;
							         vld_flag_coded_crc=1'b0;
									 end
							     else               
								    begin
									   next_state=s_tx_pdu_payload;
										r_cnt_cnt=r_cnt_cnt+8'd1;
										vld_flag_coded_dwh=1'b1;
							         vld_flag_coded_crc=1'b1;
							       end	  
								end
							 else if(r_cnt_cnt==8'd8)
							   begin
								  if(r_bytes==8'd1)
								    begin
									   vld_flag_coded_dwh=1'b0;
								      vld_flag_coded_crc=1'b0; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								  else
								    begin
									   vld_flag_coded_dwh=1'b1;
								      vld_flag_coded_crc=1'b1; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								end
							 else if(r_cnt_cnt==8'd9 && r_bytes==8'd1)
							   begin
								  RAM_OE2=0;
								  r_cnt_cnt=8'd0;
								  next_state=s_wait_crc;
								end
							 else if(r_cnt_cnt==8'd16)
							   begin
								  if(r_bytes==8'd2)
								    begin
									   vld_flag_coded_dwh=1'b0;
								      vld_flag_coded_crc=1'b0; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								  else
								    begin
									   vld_flag_coded_dwh=1'b1;
								      vld_flag_coded_crc=1'b1; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								end
							 else if(r_cnt_cnt==8'd17 && r_bytes==8'd2)
							   begin
								  RAM_OE2=0;
								  r_cnt_cnt=8'd0;
								  next_state=s_wait_crc;
								end
							 else if(r_cnt_cnt==8'd24)
							   begin
								  if(r_bytes==8'd3)
								    begin
									   vld_flag_coded_dwh=1'b0;
								      vld_flag_coded_crc=1'b0; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								  else
								    begin
									   vld_flag_coded_dwh=1'b1;
								      vld_flag_coded_crc=1'b1; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								end
							 else if(r_cnt_cnt==8'd25 && r_bytes==8'd3)
							   begin
								  RAM_OE2=0;
								  r_cnt_cnt=8'd0;
								  next_state=s_wait_crc;
								end
						    else if(r_cnt_cnt==8'd29)
			               begin
			                 RAM_A2=RAM_A2+7'b1;
                          RAM_CS2=1;
					           RAM_WEN2=0;
					           RAM_OE2=1;
					           next_state=s_tx_pdu_payload;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;								  
				            //从 TX-RAM 中取出 32bits的 payload
			               end
                      else if(r_cnt_cnt==8'd32)	
	                     begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b0;
							     vld_flag_coded_crc=1'b0;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
	                     end							
							 else 
							   begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
								end
						  end
						else if(r_cnt==8'd1)
				        begin
						    if((r_cnt_cnt==1) && (vld_zz_flag))     
							   begin
								  r_fsm_data_vld = 1'd0;
								  vld_zz_flag = 1'b0;
								end	
							 else if((r_cnt_cnt==2) && (vld_flag_coded))                                    
							   begin
								  r_fsm_data_vld = 1'b1;
								end
							 else r_fsm_data_vld = r_fsm_data_vld;
				          vld_flag_coded=1'b0;
							 vld_flag_coded_dwh=1'b0;
							 vld_flag_coded_crc=1'b0;
							 r_fsm_data=code_data_8[7];
					     end
						else if((r_cnt==8'd2)|(r_cnt==8'd3)|(r_cnt==8'd4)|(r_cnt==8'd5)|(r_cnt==8'd6))
						  begin
							 r_fsm_data=code_data_8[8'd8-r_cnt];
						  end
						else if(r_cnt==8'd7)
						  begin
							 r_fsm_data=code_data_8[1];
							 if(r_cnt_cnt==8'd30)
							 	begin
				              PAYLOAD=ram_d2;
					           next_state=s_tx_pdu_payload;
						      end
							 else if(r_cnt_cnt==8'd33)
							   begin
							     payload_zz_flag=1'b1;
								  vld_zz_flag=1'b1;
							     r_cnt_cnt=8'd0;
							     r_bytes=r_bytes-8'd4;
							     if(r_bytes==0)
							       begin
								      RAM_OE2=0;
								      //next_state=s_wait_crc;
								      r_cnt_cnt=8'd0;
                              //vld_flag_coded=1'b0;
                              //vld_flag_coded_dwh=1'b0;
							         //vld_flag_coded_crc=1'b0;	
								    end
								  else next_state=next_state;  
								end
							 else
							   begin
								  next_state=next_state; 
								end
						  end
						else
				        begin
				          next_state=next_state;
				        end

					 end
				  else
				    begin
					   if(r_cnt==8'd0)
						  begin
						    r_fsm_data=code_data_2[0];
                      if(next_state==s_wait_crc)
							   begin
								  vld_flag_coded_dwh=1'b0;
								  vld_flag_coded_crc=1'b0;
								  r_cnt_cnt=8'd0;
								end
							 else if(r_cnt_cnt==8'd0)
							   begin
								  r_fsm_data_vld=(vld_zz_flag) ? 1'b1 : 1'b0;
							     if(r_bytes==8'd0)  
								    begin
									   next_state=s_wait_crc;
										r_cnt_cnt=8'd0;
										vld_flag_coded_dwh=1'b0;
							         vld_flag_coded_crc=1'b0;
									 end
							     else               
								    begin
									   next_state=s_tx_pdu_payload;
										r_cnt_cnt=r_cnt_cnt+8'd1;
										vld_flag_coded_dwh=1'b1;
							         vld_flag_coded_crc=1'b1;
							       end			
								end
							 else if(r_cnt_cnt==8'd8)
							   begin
								  if(r_bytes==8'd1)
								    begin
									   vld_flag_coded_dwh=1'b0;
								      vld_flag_coded_crc=1'b0; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								  else
								    begin
									   vld_flag_coded_dwh=1'b1;
								      vld_flag_coded_crc=1'b1; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								end
							 else if(r_cnt_cnt==8'd9 && r_bytes==8'd1)
							   begin
								  RAM_OE2=0;
								  r_cnt_cnt=8'd0;
								  next_state=s_wait_crc;
								end
							 else if(r_cnt_cnt==8'd16)
							   begin
								  if(r_bytes==8'd2)
								    begin
									   vld_flag_coded_dwh=1'b0;
								      vld_flag_coded_crc=1'b0; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								  else
								    begin
									   vld_flag_coded_dwh=1'b1;
								      vld_flag_coded_crc=1'b1; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								end
							 else if(r_cnt_cnt==8'd17 && r_bytes==8'd2)
							   begin
								  RAM_OE2=0;
								  r_cnt_cnt=8'd0;
								  next_state=s_wait_crc;
								end
							 else if(r_cnt_cnt==8'd24)
							   begin
								  if(r_bytes==8'd3)
								    begin
									   vld_flag_coded_dwh=1'b0;
								      vld_flag_coded_crc=1'b0; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								  else
								    begin
									   vld_flag_coded_dwh=1'b1;
								      vld_flag_coded_crc=1'b1; 
										vld_flag_coded=1'b1;
										r_cnt_cnt=r_cnt_cnt+8'd1;
									 end
								end
							 else if(r_cnt_cnt==8'd25 && r_bytes==8'd3)
							   begin
								  RAM_OE2=0;
								  r_cnt_cnt=8'd0;
								  next_state=s_wait_crc;
								end
						    else if(r_cnt_cnt==8'd29)
			               begin
			                 RAM_A2=RAM_A2+7'b1;
                          RAM_CS2=1;
					           RAM_WEN2=0;
					           RAM_OE2=1;
					           next_state=s_tx_pdu_payload;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;								  
				            //从 TX-RAM 中取出 32bits的 payload
			               end
                      else if(r_cnt_cnt==8'd32)	
	                     begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b0;
							     vld_flag_coded_crc=1'b0;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
	                     end							
							 else 
							   begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
							     vld_flag_coded_crc=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
								end
						  end
						else if(r_cnt==8'd1)
						  begin
							 r_fsm_data=code_data_2[1];
							 vld_flag_coded=1'b0;
							 vld_flag_coded_dwh=1'b0;
							 vld_flag_coded_crc=1'b0;
							 if((r_cnt_cnt==1) && (vld_zz_flag))     
							   begin
								  r_fsm_data_vld = 1'd0;
								  vld_zz_flag = 1'b0;
								end	
							 else if((r_cnt_cnt==2))                                    
							   begin
								  r_fsm_data_vld = 1'b1;
								end
							 else r_fsm_data_vld = r_fsm_data_vld;
							 
							 if(r_cnt_cnt==8'd30)
							 	begin
				              PAYLOAD=ram_d2;
					           next_state=s_tx_pdu_payload;
						      end
							 else if(r_cnt_cnt==8'd33)
							   begin
							     payload_zz_flag=1'b1;
								  vld_zz_flag=1'b1;
							     r_cnt_cnt=8'd0;
							     r_bytes=r_bytes-8'd4;
							     if(r_bytes==0)
							       begin
								      RAM_OE2=0;
								      //next_state=s_wait_crc;
								      r_cnt_cnt=8'd0;
                              //vld_flag_coded=1'b0;
                              //vld_flag_coded_dwh=1'b0;
							         //vld_flag_coded_crc=1'b0;	
								    end
								  else next_state=s_tx_pdu_payload;  
								end
							 else
							   begin
								  next_state=next_state; 
								end
						  end
						else
				        begin
				          next_state=next_state;
				        end
					 end
				end
			 else
				begin
		     //发送有效载荷部分，即 payload。
		       payload_zz_flag=1'b0;
		       r_fsm_data=s_dwh_data;
		     //由于蓝牙设备可以发送不同长度的 payload，所以每次在 r_cnt 计数到 27 时，都会从 TX-RAM 中取出 32bits的 payload；
		       if(r_cnt==8'd0)
				   begin
					  vld_flag_uncoded_dwh=1'b1;
			        vld_flag_uncoded_crc=1'b1;
					  r_fsm_data_vld=1'b0;
					end
				 else if(r_cnt==8'd1)
				   begin
					  r_fsm_data_vld=1'b1;
					end
				 else if(r_cnt==8'd8 && r_bytes==8'd1)
			      begin
               //RAM_CS2=0;
					  RAM_OE2=0;
					  vld_flag_uncoded_dwh=1'b0;
			        vld_flag_uncoded_crc=1'b0;
					  next_state=s_wait_crc;		
			      end
		       else if(r_cnt==8'd16 && r_bytes==8'd2)
			      begin
               //RAM_CS2=0;
					  RAM_OE2=0;
					  vld_flag_uncoded_dwh=1'b0;
			        vld_flag_uncoded_crc=1'b0;
					  next_state=s_wait_crc;
			      end	
		       else if(r_cnt==8'd24 && r_bytes==8'd3)
			      begin
               //RAM_CS2=0;
					  RAM_OE2=0;
					  vld_flag_uncoded_dwh=1'b0;
			        vld_flag_uncoded_crc=1'b0;
					  next_state=s_wait_crc;
			      end		  
			    else if(r_cnt==8'd28)
			      begin
			        RAM_A2=RAM_A2+7'b1;
                 RAM_CS2=1;
					  RAM_WEN2=0;
					  RAM_OE2=1;
					  next_state=s_tx_pdu_payload;
				   //从 TX-RAM 中取出 32bits的 payload
			      end
			    else if(r_cnt==8'd29)
			      begin
				     PAYLOAD=ram_d2;
					  next_state=s_tx_pdu_payload;
			      end
			    else if(r_cnt==8'd32)
			      begin
			        payload_zz_flag=1'b1;
					  r_bytes=r_bytes-8'd4;
					  vld_flag_uncoded_dwh=1'b0;
			        vld_flag_uncoded_crc=1'b0;
                 if(r_bytes==0)  
					    begin
					      RAM_OE2=0;
							next_state=s_wait_crc;
					    end
					  else    
					    begin
						   next_state=next_state;
						 end
			      end
			    else next_state=next_state;
			  end
		  //在 r_cnt 计数到 31 时，把取出的 32bits payload 装入移位寄存器中，同时r_bytes 减 4。
		  //以此类推，直到 payload 全部发送完成，状态机才跳转至 s_wait_crc 状态，同时关闭该模块的输出使能信号。 
		  
		  //发送期间，用 r_bytes 指示 TX-RAM 中还有多少字节的 payload 没有被发送。
		  //如果设备发送报文中 payload 的长度为（4n+1）Bytes，则当 r_cnt 第（4n+1）次计数到7 时，发送完成。
		  //同理，payload 的长度为（4n+2）、（4n+3）、（4n+4）Bytes 时，当 r_cnt第（4n+1）次计数到 15, 23, 31 时，发送完成。 
        //next_state=s_wait_crc;		 
		  end
     s_wait_crc:  //公共部分
	     begin
		    if((BLE_TYPE==3'b100))
			   begin
				  vld_zz_flag=1'b0;
				  r_switch_crc_coded=1'b0;
				  if(s_2)
				    begin
						if(r_cnt==8'd0)
						  begin
						    r_fsm_data=code_data_8[0];
                      if(next_state==s_tx_term2)
							   begin
								  vld_flag_coded_dwh=1'b0;
								  vld_flag_coded=1'b0;
								  r_cnt_cnt=8'd0;
								end
							 else if(r_cnt_cnt==8'd0)
							   begin
								  r_fsm_data_vld=1'b0;
								  vld_flag_coded_dwh=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;	  
								end							
							 else if(r_cnt_cnt==8'd24)
							   begin
								  vld_flag_coded_dwh=1'b0;
								  vld_flag_coded=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd25)
							   begin
								  next_state=s_tx_term2;
								  vld_flag_coded=1'b0;
								  r_cnt_cnt=8'd0;
								end
							 else 
							   begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
								end
						  end
						else if(r_cnt==8'd1)
				        begin
						    r_fsm_data_vld = (r_cnt_cnt==2) ? 1'd1 : r_fsm_data_vld;
				          vld_flag_coded=1'b0;
							 vld_flag_coded_dwh=1'b0;
				          r_fsm_data=code_data_8[7];
					     end
						else if((r_cnt==8'd2)|(r_cnt==8'd3)|(r_cnt==8'd4)|(r_cnt==8'd5)|(r_cnt==8'd6)|(r_cnt==8'd7))
						  begin
						    r_fsm_data=code_data_8[8'd8-r_cnt];
						  end
						else
						  begin
							 next_state=next_state;
						  end
					 end
				  else
				    begin
					   if(r_cnt==8'd0)
						  begin
						    r_fsm_data=code_data_2[0];
                      if(next_state==s_tx_term2)
							   begin
								  vld_flag_coded_dwh=1'b0;
								  vld_flag_coded=1'b0;
								  r_cnt_cnt=8'd0;
								end
							 else if(r_cnt_cnt==8'd0)
							   begin
								  r_fsm_data_vld=1'b0;
								  vld_flag_coded_dwh=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;	  
								end							
							 else if(r_cnt_cnt==8'd24)
							   begin
								  vld_flag_coded_dwh=1'b0;
								  vld_flag_coded=1'b1;
								  r_cnt_cnt=r_cnt_cnt+8'd1;
								end
							 else if(r_cnt_cnt==8'd25)
							   begin
								  next_state=s_tx_term2;
								  vld_flag_coded=1'b0;
								  r_cnt_cnt=8'd0;
								end
							 else 
							   begin
								  vld_flag_coded=1'b1;
							     vld_flag_coded_dwh=1'b1;
				              r_cnt_cnt=r_cnt_cnt+8'd1;
								end
						  end
						else if(r_cnt==8'd1)
				        begin
						    r_fsm_data_vld = (r_cnt_cnt==2) ? 1'd1 : r_fsm_data_vld;
				          vld_flag_coded=1'b0;
							 vld_flag_coded_dwh=1'b0;
				          r_fsm_data=code_data_2[1];
					     end
						else
						  begin
							 next_state=next_state;
						  end
					 end
				end
			 else
			   begin
				  r_switch_crc=1'b0;
	           r_fsm_data=s_dwh_data;
				  if(r_cnt==8'd0)
				    begin
					   vld_flag_uncoded_dwh=1'b1;
					   r_fsm_data_vld=1'b0;
					 end
				  else if(r_cnt==8'd1)
				    begin
					   r_fsm_data_vld=1'b1;
					 end
			     else if(r_cnt==8'd24)  
				    begin
					   vld_flag_uncoded_dwh=1'b0;
					   next_state=s_end;
					 end
			     else 
          		 begin
					   next_state=next_state;
					 end
			   end
		  end
     s_tx_term2: 
	     begin
		    //r_coded_en_2=1'b0;
			 //r_coded_en_3=1'b1;
			 if(s_2)
			   begin
				  if(r_cnt==8'd0)
					 begin
						r_fsm_data=code_data_8[0];
                  if(next_state==s_end)
						  begin
							 vld_flag_coded=1'b0;
						    r_cnt_cnt=8'd0;
						  end
						else if(r_cnt_cnt==8'd0)
						  begin
						    r_fsm_data_vld=1'b0;
							 vld_flag_coded=1'b1;
				          r_cnt_cnt=r_cnt_cnt+8'd1;			 
						  end
						else if(r_cnt_cnt==8'd3)
						  begin
						    next_state=s_end;
							 r_cnt_cnt=8'd0;
						  end
	               else 
                    begin
						    vld_flag_coded=1'b1;
							 r_cnt_cnt=r_cnt_cnt+8'd1;
		              end
					  end
				  else if(r_cnt==8'd1)
				    begin
					   r_fsm_data_vld=1'b1;
					   vld_flag_coded=1'b0;
						r_fsm_data=code_data_8[7];
					 end
				  else if((r_cnt==8'd2)|(r_cnt==8'd3)|(r_cnt==8'd4)|(r_cnt==8'd5)|(r_cnt==8'd6)|(r_cnt==8'd7))
				    begin
					   r_fsm_data=code_data_8[8'd8-r_cnt];
					 end
				  else 
				    begin
					   next_state=next_state;
				    end
				end
			 else
			   begin
				  if(r_cnt==8'd0)
					 begin
						r_fsm_data=code_data_2[0];
                  if(next_state==s_end)
						  begin
							 vld_flag_coded=1'b0;
						    r_cnt_cnt=8'd0;
						  end
					   else if(r_cnt_cnt==8'd0)
						  begin
						    r_fsm_data_vld=1'b0;
							 vld_flag_coded=1'b1;
							 r_cnt_cnt=r_cnt_cnt+8'd1;
						  end
						else if(r_cnt_cnt==8'd3)
						  begin
						    next_state=s_end;
							 r_cnt_cnt=8'd0;
						  end
	               else 
                    begin
						    vld_flag_coded=1'b1;
							 r_cnt_cnt=r_cnt_cnt+8'd1;
		              end
					  end
				  else if(r_cnt==8'd1)
				    begin
					   r_fsm_data_vld=1'b1;
					   vld_flag_coded=1'b0;
						r_fsm_data=code_data_2[1];
					 end
				  else 
				    begin
					   next_state=next_state;
				    end
				end
		  end
     s_end: 
	     begin
		  //此状态是为了给 PKA 模块中的的数据传送留出充足的时间，当把数据完整的发送出去之后，跳转到 s_reset 状态，同时把白化模块的使能信号置为无效状态。
			 r_fsm_data_vld=1'b0;
			 next_state=s_reset;
			 //r_coded_en_3=1'b0;
			 r_coded_en=1'b0;
			 r_switch_crc=0;
			 r_switch_dwh=0;
			 r_switch_crc_coded=0;
			 r_switch_dwh_coded=0;
		  end		  
     s_reset: 
	     begin
		  //此状态是为了给 RIF 模块中的的数据传送留出充足的时间，当把数据完整的发送出去之后，跳转到 s_idle 状态。
		  //同时把 r_rst_tx 置为 1，用来关闭发送的时钟，并对一些信号进行初始化操作。 
          r_fsm_data=1'b0;
			 r_fsm_data_vld=1'b0;
			 next_state=s_idle;
			 r_rst_tx_reg=1'b1;
			 PAYLOAD=32'd0;
			 payload_zz_flag=1'b0;
			 vld_zz_flag=1'b0;
			 r_cnt_cnt=8'd0;
			 vld_flag_coded=1'b0;
			 vld_flag_coded_dwh=1'b0;
			 vld_flag_coded_crc=1'b0;
			 vld_flag_uncoded_dwh=1'b0;
			 vld_flag_uncoded_crc=1'b0;
			 //r_coded_en_1=1'b0;
			 //r_coded_en_2=1'b0;
			 //r_coded_en_3=1'b0;
			 r_coded_en=1'b0;
		  end
	  default:
       begin
		   next_state=s_idle;
		 end
	  endcase
	  
	  //PAYLOAD=RAM_D;
 end
/*
 //当读使能有效，把所读数据读取到payload的寄存器中
 always@(RAM_REN)
  begin
   PAYLOAD=RAM_D;
  end
*/
 always@(posedge pka_1or2m_gck,negedge rst_n)
	if(!rst_n)
	 begin
	  current_state<=s_reset;
	  r_cnt<=8'd0;
	  r_tx_shift_reg<=32'd0;
	 end
	else if(current_state==next_state)
	 begin
	  current_state<=next_state;
	  
	  case(current_state)
	   s_tx_preamble:      
		  begin
		    r_cnt<=r_cnt+8'd1;
			 r_tx_shift_reg<={r_tx_shift_reg[0], r_tx_shift_reg[31:1]};
		  end
		s_tx_access:
		  begin
		    if(BLE_TYPE==3'b100)
			   begin
				  r_cnt<=(r_cnt==8'd7) ? 8'd0 : (r_cnt+8'd1);
				  r_tx_shift_reg<=(vld_flag_coded) ? {1'b0, r_tx_shift_reg[31:1]} : r_tx_shift_reg;
				end
          else 
			   begin
				  r_cnt<=r_cnt+8'd1;
			     r_tx_shift_reg<={1'b0, r_tx_shift_reg[31:1]};
				end
		  end
		s_tx_ci:
		  begin
		    r_cnt<=(r_cnt==8'd7) ? 8'd0 : (r_cnt+8'd1);
			 r_tx_shift_reg<=(vld_flag_coded) ? {1'b0, r_tx_shift_reg[31:1]} : r_tx_shift_reg;
		  end
		s_tx_term1:
		  begin
		    r_cnt<=(r_cnt==8'd7) ? 8'd0 : (r_cnt+8'd1);
			 r_tx_shift_reg<=(vld_flag_coded) ? {1'b0, r_tx_shift_reg[31:1]} : r_tx_shift_reg;
		  end
		s_tx_pdu_header:
		  begin
		    if(BLE_TYPE==3'b100)
			   begin
				  if(s_2)  r_cnt<=(r_cnt==8'd7) ? 8'd0 : (r_cnt+8'd1);
				  else     r_cnt<=(r_cnt==8'd1) ? 2'd0 : (r_cnt+8'd1);
				  //r_tx_shift_reg<=(vld_flag_coded) ? {1'b0, r_tx_shift_reg[31:1]} : r_tx_shift_reg;
				  r_tx_shift_reg<=(vld_flag_coded_dwh) ? {1'b0, r_tx_shift_reg[31:1]} : r_tx_shift_reg;
				end
          else 
			   begin
				  r_cnt<=r_cnt+8'd1;
			     r_tx_shift_reg<={1'b0, r_tx_shift_reg[31:1]};
				end		  
		  end
		s_tx_pdu_payload:   
		  begin
		    if(BLE_TYPE==3'b100)
			   begin
				  if(s_2)  r_cnt<=(r_cnt==8'd7) ? 8'd0 : (r_cnt+8'd1);
				  else     r_cnt<=(r_cnt==8'd1) ? 2'd0 : (r_cnt+8'd1);
				  
				  if(payload_zz_flag)
				     r_tx_shift_reg <= PAYLOAD[31:0];
				  else if(vld_flag_coded_dwh)
				     r_tx_shift_reg <= {1'b0, r_tx_shift_reg[31:1]};
				  else
				     r_tx_shift_reg <= r_tx_shift_reg;
				end
			 else
			   begin
			     r_cnt<=(payload_zz_flag) ? 8'd0 : (r_cnt+8'd1);
              r_tx_shift_reg<=(payload_zz_flag) ? PAYLOAD[31:0] : {1'b0, r_tx_shift_reg[31:1]};
				end
		  end
		s_wait_crc:
		  begin
		    if(BLE_TYPE==3'b100)
			   begin
				  if(s_2)  r_cnt<=(r_cnt==8'd7) ? 8'd0 : (r_cnt+8'd1);
				  else     r_cnt<=(r_cnt==8'd1) ? 2'd0 : (r_cnt+8'd1);
				  
				  r_tx_shift_reg<=(vld_flag_coded_dwh) ? {r_tx_shift_reg[30:0],1'b0} : r_tx_shift_reg;
				end
			 else
			   begin
			     r_cnt<=r_cnt+8'd1;
			     r_tx_shift_reg<={r_tx_shift_reg[30:0],1'b0};
				end
		  end
		s_tx_term2:
		  begin
		    if(s_2)  r_cnt<=(r_cnt==8'd7) ? 8'd0 : (r_cnt+8'd1);
			 else     r_cnt<=(r_cnt==8'd1) ? 2'd0 : (r_cnt+8'd1);
			 
			 r_tx_shift_reg<=(vld_flag_coded) ? {1'b0, r_tx_shift_reg[31:1]} : r_tx_shift_reg;
		  end
		default:        
		  begin
		    r_cnt<=r_cnt+8'd1;
			 r_tx_shift_reg<={1'b0, r_tx_shift_reg[31:1]};
		  end
	  endcase
 
	 end
	else
	 begin
	  current_state<=next_state;
	  r_cnt<=8'd0;
	  
	  case(next_state)
	   s_tx_preamble:    r_tx_shift_reg <= Preamble[31:0];
	   s_tx_access:      r_tx_shift_reg <= BLE_ACC_ADDR[31:0];
		s_tx_ci:          r_tx_shift_reg[1:0] <= BLE_CI[1:0];
		s_tx_term1:       r_tx_shift_reg[2:0] <= BLE_TERM1[2:0];
		s_tx_term2:       r_tx_shift_reg <= {29'd0,BLE_TERM2[2:0]};
		s_tx_pdu_header:  r_tx_shift_reg[15:0] <= (BLE_ADV_STATE) ? BLE_DATA_HEADER[15:0] : BLE_ADV_HEADER[15:0]; 
	   s_tx_pdu_payload:	r_tx_shift_reg <= (payload_zz_flag) ? PAYLOAD[31:0] : r_tx_shift_reg;
		s_wait_crc:       begin
		                    if(BLE_TYPE==3'b100) r_tx_shift_reg <= {r_crc_lfsr_coded[23:0],8'd0};
								  else r_tx_shift_reg <= {r_crc_lfsr[23:0],8'd0};
		                  end
		default:          r_tx_shift_reg <= 32'd0;
	  endcase
	 
	 end
endmodule