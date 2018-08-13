`timescale 1ns/10ps

module sd_reader(
	input					rst_n,
	input					clk,
	
	output					o_sd_run,
	
	input		[3:0]		i_sd_data,
	
	output		[7:0]		o_st_data,
	output					o_st_vld,
	input					i_st_rdy,	
	output					o_st_sop,
	output					o_st_eop,
	
	input					i_start_reading,
	
	input		[9:0]		i_buf_len
);

	assign o_sd_run = |{sd_wait};

	function [15:0] calc_crc;
		input reg [7:0] Data;
		input reg [15:0] crc;
		reg [7:0] d;
		reg [15:0] c;
		reg [15:0] newcrc;
		
		begin
			d = Data;
			c = crc;

			newcrc[0] = d[4] ^ d[0] ^ c[8] ^ c[12];
			newcrc[1] = d[5] ^ d[1] ^ c[9] ^ c[13];
			newcrc[2] = d[6] ^ d[2] ^ c[10] ^ c[14];
			newcrc[3] = d[7] ^ d[3] ^ c[11] ^ c[15];
			newcrc[4] = d[4] ^ c[12];
			newcrc[5] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[12] ^ c[13];
			newcrc[6] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[13] ^ c[14];
			newcrc[7] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[14] ^ c[15];
			newcrc[8] = d[7] ^ d[3] ^ c[0] ^ c[11] ^ c[15];
			newcrc[9] = d[4] ^ c[1] ^ c[12];
			newcrc[10] = d[5] ^ c[2] ^ c[13];
			newcrc[11] = d[6] ^ c[3] ^ c[14];
			newcrc[12] = d[7] ^ d[4] ^ d[0] ^ c[4] ^ c[8] ^ c[12] ^ c[15];
			newcrc[13] = d[5] ^ d[1] ^ c[5] ^ c[9] ^ c[13];
			newcrc[14] = d[6] ^ d[2] ^ c[6] ^ c[10] ^ c[14];
			newcrc[15] = d[7] ^ d[3] ^ c[7] ^ c[11] ^ c[15];
			calc_crc = newcrc;
		end
	endfunction
	
	reg		[2:0]		sd_wait;
	initial sd_wait <= 3'd0;
	reg		[9:0]		start_cntr;
	initial start_cntr <= 10'd0;
	reg		[0:0]		error_flag;
	initial error_flag <= 1'd0;
	
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			start_cntr <= 10'd0;
			error_flag <= 1'd0;
		end
		else
			if(sd_wait == 3'b001) begin
				if(start_cntr <= 5000)
					start_cntr <= start_cntr + 1'd1;
				else
					error_flag <= 1'd1;
			end
			else begin
				start_cntr <= 10'd0;
				error_flag <= 1'd0;
			end

	reg		[9:0]		recv_cntr;
	initial recv_cntr <= 10'd0;
	reg		[2:0]		bit_cntr;
	initial bit_cntr <= 3'd0;
	
	reg		[3:0]		bc_16;
	initial bc_16 <= 4'd0;
	
	wire				bc_clear;
	assign bc_clear = ~|{bit_cntr};
		
	wire	[7:0]		dw1;
	reg		[7:0]		dr1;
	initial dr1 <= 8'd0;
	assign dw1 = bc_clear ? {7'd0, i_sd_data[0]} : {dr1[6:0], i_sd_data[0]};

	wire	[7:0]		dw2;
	reg		[7:0]		dr2;
	initial dr2 <= 8'd0;
	assign dw2 = bc_clear ? {7'd0, i_sd_data[1]} : {dr2[6:0], i_sd_data[1]};
	
	wire	[7:0]		dw3;
	reg		[7:0]		dr3;
	initial dr3 <= 8'd0;
	assign dw3 = bc_clear ? {7'd0, i_sd_data[2]} : {dr3[6:0], i_sd_data[2]};

	wire	[7:0]		dw4;
	reg		[7:0]		dr4;
	initial dr4 <= 8'd0;
	assign dw4 = bc_clear ? {7'd0, i_sd_data[3]} : {dr4[6:0], i_sd_data[3]};
	
	wire	[7:0]		w_data;
	reg		[7:0]		r_data;
	initial r_data <= 8'd0;
	assign w_data = bit_cntr[0] ? {r_data[3:0], i_sd_data} : {4'd0, i_sd_data};
	always @ (posedge clk) r_data <= w_data;
	
	reg		[15:0]		crc1;
	initial crc1 <= 16'd0;
	reg		[15:0]		crc2;
	initial crc2 <= 16'd0;
	reg		[15:0]		crc3;
	initial crc3 <= 16'd0;
	reg		[15:0]		crc4;
	initial crc4 <= 16'd0;
	
	reg		[15:0]		in_crc1;
	initial in_crc1 <= 16'd0;
	reg		[15:0]		in_crc2;
	initial in_crc2 <= 16'd0;
	reg		[15:0]		in_crc3;
	initial in_crc3 <= 16'd0;
	reg		[15:0]		in_crc4;
	initial in_crc4 <= 16'd0;
	
	reg		[3:0]		crc_result;
	initial crc_result <= 4'd0;
	
	reg		[7:0]		out_buf[0:511];
	integer i;
	initial 
		for(i = 0; i < 512; i = i + 1) 
			out_buf[i] = 8'd0;
	
	reg		[0:0]		start_reading;
	initial start_reading <= 1'd0;
	
	always @ (posedge clk) start_reading <= i_start_reading;
			
	reg		[0:0]		data_vld;
	initial data_vld <= 1'd0;
	assign o_st_vld = data_vld;
	
	reg		[7:0]		out_data;
	initial out_data <= 8'd0;
	
	assign o_st_data = r_data;
	
	reg		[0:0]		start_packet;
	initial start_packet <= 1'b0;
	reg		[0:0]		end_packet;
	initial	end_packet <= 1'b0;
	reg		[0:0]		sp_sended;
	initial sp_sended <= 1'b0;
	
	assign o_st_sop = start_packet;
	assign o_st_eop = end_packet;
	
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			sd_wait <= 3'b000;
			recv_cntr <= 10'd0;
			bit_cntr <= 3'd0;
			bc_16 <= 4'd0;
			dr1 <= 8'd0;
			dr2 <= 8'd0;
			dr3 <= 8'd0;
			dr4 <= 8'd0;
			crc1 <= 16'd0;
			crc2 <= 16'd0;
			crc3 <= 16'd0;
			crc4 <= 16'd0;
			in_crc1 <= 16'd0;
			in_crc2 <= 16'd0;
			in_crc3 <= 16'd0;
			in_crc4 <= 16'd0;
			crc_result <= 4'd0;
			data_vld <= 1'd0;
			start_packet <= 1'b0;
			end_packet <= 1'b0;
			sp_sended <= 1'b0;
		end
		else
			if(error_flag) 
				sd_wait <= 3'b000;
			else
				case(sd_wait)
					3'b000: 
						if(i_start_reading & ~start_reading) begin
							sd_wait <= 3'b001;
							recv_cntr <= 10'd0;
							bit_cntr <= 3'd0;
							bc_16 <= 4'd0;
							dr1 <= 8'd0;
							dr2 <= 8'd0;
							dr3 <= 8'd0;
							dr4 <= 8'd0;
							crc1 <= 16'd0;
							crc2 <= 16'd0;
							crc3 <= 16'd0;
							crc4 <= 16'd0;
							in_crc1 <= 16'd0;
							in_crc2 <= 16'd0;
							in_crc3 <= 16'd0;
							in_crc4 <= 16'd0;
							crc_result <= 4'd0;
							data_vld <= 1'd0;
							start_packet <= 1'b0;
							end_packet <= 1'b0;
							sp_sended <= 1'b0;
						end
						
					3'b001: 
						if(i_sd_data == 4'b0000) begin
							sd_wait <= 3'b010;
							recv_cntr <= 10'd0;
							data_vld <= 1'd0;
						end
					
					3'b010:
						begin	
							if(bit_cntr[0])	begin
								out_data <= w_data;
								data_vld <= 1'd1;
								
								if(~sp_sended) begin
									sp_sended <= 1'b1;
									start_packet <= 1'b1;
								end	
																
								if(recv_cntr + 1'd1 < i_buf_len)
									recv_cntr <= recv_cntr + 1'd1;
								else begin
									$display("block received...");
									sd_wait <= 3'b011;
									bc_16 <= 4'd0;
									in_crc1 <= 16'd0;
									in_crc2 <= 16'd0;
									in_crc3 <= 16'd0;
									in_crc4 <= 16'd0;
									crc_result <= 4'd0;
									end_packet <= 1'b1;
								end
							end
							else begin
								start_packet <= 1'b0;
								data_vld <= 1'd0;
							end
							
							if(&{bit_cntr}) begin
								crc1 <= calc_crc(dw1, crc1);
								$display("crc1 = 0x%04X", crc1);
								crc2 <= calc_crc(dw2, crc2);
								$display("crc2 = 0x%04X", crc2);
								crc3 <= calc_crc(dw3, crc3);
								$display("crc3 = 0x%04X", crc3);
								crc4 <= calc_crc(dw4, crc4);
								$display("crc4 = 0x%04X", crc4);
							end
							
							dr1 <= dw1;
							dr2 <= dw2;
							dr3 <= dw3;
							dr4 <= dw4;

							bit_cntr <= bit_cntr + 1'd1;
						end
												
					3'b11:
						begin
							data_vld <= 1'b0;
							end_packet <= 1'b0;
							
							if(bc_16 < 4'd15) begin
								in_crc1 <= {in_crc1[14:0], i_sd_data[0]};
								in_crc2 <= {in_crc2[14:0], i_sd_data[1]};
								in_crc3 <= {in_crc3[14:0], i_sd_data[2]};
								in_crc4 <= {in_crc4[14:0], i_sd_data[3]};
								bc_16 <= bc_16 + 1'd1;
							end
							else begin
								sd_wait <= 2'b00;
								crc_result <= {
									{in_crc1[14:0], i_sd_data[0]} == crc1 ? 1'b0 : 1'b1,
									{in_crc2[14:0], i_sd_data[1]} == crc2 ? 1'b0 : 1'b1,
									{in_crc3[14:0], i_sd_data[2]} == crc3 ? 1'b0 : 1'b1,
									{in_crc4[14:0], i_sd_data[3]} == crc4 ? 1'b0 : 1'b1
								};
							end							
						end
				endcase

endmodule

