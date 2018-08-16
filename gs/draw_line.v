// Code your design here
module draw_line(
	input					clk,

	input signed [15:0]	i_x1,
	input signed [15:0]	i_y1,
	input signed [15:0]	i_x2,
	input signed [15:0]	i_y2,

	output				o_set_pixel,
	output signed [15:0]	o_x,
	output signed [15:0]	o_y,

	input					i_start,
	output				o_ready
);
	assign o_ready = draw_state == DS_NONE ? 1'b1 : 1'b0;
	assign o_set_pixel = draw_state == DS_DRAW || draw_state == DS_DUMMY ? 1'b1 : 1'b0;
	assign o_x = x;
	assign o_y = y;

	wire signed [15:0] dx;
	wire signed [15:0] dy;

	assign dx = (i_x1 < i_x2) ? i_x2 - i_x1 : i_x1 - i_x2;
	assign dy = (i_y1 < i_y2) ? i_y2 - i_y1 : i_y1 - i_y2;

	wire swap_xy;
	assign swap_xy = (dx < dy) ? 1'b1 : 1'b0;

	wire signed [15:0] x1;
	wire signed [15:0] y1;
	wire signed [15:0] x2;
	wire signed [15:0] y2;

	assign {x1, y1, x2, y2} = swap_xy ? 
		((i_y1 < i_y2) ? {i_y1, i_x1, i_y2, i_x2} : {i_y2, i_x2, i_y1, i_x1}) : 
		((i_x1 < i_x2) ? {i_x1, i_y1, i_x2, i_y2} : {i_x2, i_y2, i_x1, i_y1});

	reg signed [15:0] x;
	reg signed [15:0] y;
	reg signed [31:0] err;

	parameter [3:0] DS_NONE = 4'd0;
	parameter [3:0] DS_START = 4'd1;
	parameter [3:0] DS_DRAW = 4'd2;
	parameter [3:0] DS_DUMMY = 4'd3;

	reg [3:0] draw_state;

	initial draw_state = DS_NONE;

	always @ (posedge clk) begin
		case(draw_state)
			DS_NONE: 
				begin
					$display("ds_none");
					draw_state <= DS_START;
				end
				
			DS_START: 
				begin
					if(i_start) begin
						$display("ds_start dx=%d dy=%d", dx, dy);
						draw_state <= DS_DRAW;
						err <= -(dx / 2);
						x <= x1;
						y <= y1;
					end
				end
			DS_DRAW: 
				begin
					if(x <= x2) begin
						x <= x + 1;

						if(swap_xy) begin
							$display("swp put pixel (%d, %d)", y, x);                        

							if(err + dx >= 0) begin
								err <= err + dx - dy;
								if(y1 < y2)
									y <= y + 1;
								else
									y <= y - 1;
							end
							else
								err <= err + dx;
						end
						else begin
							$display("put pixel (%d, %d)", x, y);

							if(err + dy >= 0) begin
								err <= err + dy - dx;
								if(y1 < y2)
									y <= y + 1;
								else
									y <= y - 1;
							end
							else
								err <= err + dy;
						end
					end
					else begin
						draw_state <= DS_DUMMY;
					end
				end
			DS_DUMMY: 
				begin
					draw_state <= DS_NONE;
					$display("idle state");
					//$finish;
				end      
		endcase
	end
  
endmodule

