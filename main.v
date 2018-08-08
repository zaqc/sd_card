module main;

	reg		[0:0]		clk;
	initial clk = 0;
	always #10 clk = ~clk;
	
	reg		[0:0]		rst_n;
	initial rst_n = 0;

	initial begin
		rst_n = 1'd0;
		$dumpfile("dumpfile.vcd"); 
		$dumpvars(0);
		#20
		rst_n = 1'd1;
	end
	
	initial begin
		$display("start");
		#1000
		$finish();
	end
	
	reg		[15:0]		cntr;
	initial cntr = 16'd0;
	always @ (posedge clk)
		cntr <= cntr + 1'd1;
		
	reg		[15:0]		crc;
	initial crc = 0;
	
	reg		[7:0]		crc_in;
	initial crc_in = 8'd1;
	
	always @ (posedge clk)
		crc_in <= crc_in + 1'd1;

/*	
	always @ (posedge clk)
		crc <= calc_crc(crc_in, crc);
		
	always @ (posedge clk)
		$display("0x%04X", crc);
*/	

	reg		[0:0]		sw;
	reg		[3:0]		idat;
	integer i;
	reg		[0:0]		run_cntr;
	
	initial begin
		sw = 1'd0;
		run_cntr = 1'd0;
		idat = 4'hF;
		#30
		sw = 1'd1;
		#20
		sw = 1'd0;
		#20
		run_cntr = 1'd1;
	end
	
	always @(posedge clk) 
		if(run_cntr) idat <= idat + 1'd1;
	
	sd_reader sd_reader_unit(
		.rst_n(rst_n),
		.clk(clk),
				
		.i_start_writing(sw),
		.i_sd_data(idat),
		.i_buf_len(10'd8)
	);

	function [15:0] nextCRC16_D8;
		input [7:0] Data;
		input [15:0] crc;
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
			nextCRC16_D8 = newcrc;
		end
	endfunction
	
	initial $display("CRC16 = 0x%04X", nextCRC16_D8(8'd1, 16'd0));

endmodule
