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
	initial begin
		rst_n = 1'b0;
		$dumpfile("dumpfile.vcd");
		$dumpvars(0);
		#20
		rst_n = 1'b1;
		#1000
		$finish();
	end
	
	gs gs_unit(
		.rst_n(rst_n),
		.clk(clk)
	);
endmodule

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
