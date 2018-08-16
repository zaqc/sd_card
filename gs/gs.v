module gs_tb();

	reg		[0:0]		clk;
	initial begin
		clk <= 1'b0;
		forever begin
			#10
			clk <= ~clk;
		end
	end
	
	reg		[0:0]		rst_n;
	reg		[0:0]		line_start;
	initial begin
		rst_n = 1'b0;
		line_start = 1'b0;
		$dumpfile("dumpfile.vcd");
		$dumpvars(0);
		#20
		rst_n = 1'b1;
		#20
		line_start = 1'b1;
		#20
		line_start = 1'b0;
		#2000
		$finish();
	end
	
	gs gs_unit(
		.rst_n(rst_n),
		.clk(clk)
	);
	
	draw_line draw_line_unit(
	//viewport viewport_unit(
		//.rst_n(rst_n),
		.clk(clk),
		
		.i_x1(16'sd100),
		.i_y1(16'sd20),
		.i_x2(16'sd40),
		.i_y2(-16'sd10),
		
		.i_start(line_start)
	);
	
endmodule

// memory manager

// command type = 4 bit 
// set_fb_addr(active_addr, width, height)	// 24 bit + 10 bit + 10 bit
// select_active_fb_addr(addr) // 24 bit
// line (x1, y1, x2, y2, color)	// 10 bit + 10 bit + 10 bit + 10 bit + 16 bit == 56 bit
// fill (x1, y1, x2, y2, color)	// 10 bit + 10 bit + 10 bit + 10 bit + 16 bit == 56 bit
// create_sprite (sprite_number, width, height, addr[24])	// 10 bit + 10 bit + 10 bit + 24 bit == 54 bit
// bitblt (x1, y1, x2, y2, sprite_number) 10 bit + 10 bit + 10 bit + 10 bit + 10 bit == 50 bit

module gs(
	input						rst_n,
	input						clk,
	
	output						o_div_tick
);
	assign o_div_tick = &{div};

	reg		[3:0]		div;
	reg		[0:0]		div_tick;
	always @(posedge clk or negedge rst_n)
		if(~rst_n) begin
			div <= 4'd0;
			div_tick <= 1'b0;
			$display("System RESET...");
		end
		else begin
			if(&{div}) begin
				div_tick <= 1'b1;
				$display("Clock");
			end
			else
				div_tick <= 1'b0;
			div <= div + 1'd1;
		end

endmodule
