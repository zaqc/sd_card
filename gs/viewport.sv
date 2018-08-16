// 
module viewport(
  input clk,
  
  input signed [15:0] i_x1,
  input signed [15:0] i_y1,
  input signed [15:0] i_x2,
  input signed [15:0] i_y2, 
  
  output signed [15:0] o_x1,
  output signed [15:0] o_y1,
  output signed [15:0] o_x2,
  output signed [15:0] o_y2,
  
  input	i_start,
  output o_ready
);

  assign o_ready = ~&{inited};

  parameter	[3:0]		P_INSIDE = 4'b0000;
  parameter	[3:0]		P_LEFT = 4'b0001;
  parameter	[3:0]		P_RIGHT = 4'b0010;
  parameter	[3:0]		P_BOTTOM = 4'b0100;
  parameter	[3:0]		P_TOP = 4'b1000;
  
  parameter signed [15:0] xmin = 16'sd0;
  parameter signed [15:0] xmax = 16'sd799;
  parameter signed [15:0] ymin = 16'sd0;
  parameter signed [15:0] ymax = 16'sd479;
    
  function reg [3:0] OutCalc(
    input signed [15:0] x,
    input signed [15:0] y,
    input [2:0] from
  );  	
    reg [3:0] code;
    code = 	
    	(x < xmin) ? P_LEFT : P_INSIDE |
    	(x > xmax) ? P_RIGHT : P_INSIDE |
    	(y < ymin) ? P_TOP : P_INSIDE |
    	(y > ymax) ? P_BOTTOM : P_INSIDE;
    	
    $display("x=%d y=%d x_min=%d y_min=%d x_max=%d y_max=%d result=%d %d", x, y, xmin, ymin, xmax, ymax, code, from);

    OutCalc = code;
  endfunction
  
  function [63:0] OutCode(
  	input [3:0] oc1,
    input [3:0] oc2,
    
    input signed [15:0] x1,
    input signed [15:0] y1,
    input signed [15:0] x2,
    input signed [15:0] y2
  );
    reg [31:0] i;
    
    reg signed [31:0] dx;
    reg	signed [31:0] dy;
    reg	signed [31:0] tmp;
        
    reg signed [15:0] rx1;
    reg	signed [15:0] ry1;
    reg signed [15:0] rx2;
    reg	signed [15:0] ry2;
    
    rx1 = x1;
    ry1 = y1;
    rx2 = x2;
    ry2 = y2;
        
    dx = (x2 - x1);
    dy = (y2 - y1);
    
    $display(dx, dy);
    
		if(|{oc1}) begin
			if(oc1 & P_LEFT) begin
				tmp = ((dy * (xmin - x1) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
				ry1 = y1 + tmp;
				rx1 = xmin;
			end        
			else
				if(oc1 & P_TOP) begin
					tmp = ((dx * (ymin - y1) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
					$display("TMP = %d", tmp);
					rx1 = x1 + tmp;
					ry1 = ymin;
				end
				else
					if(oc1 & P_RIGHT) begin
						tmp = ((dy * (xmax - x1) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
						ry1 = y1 + tmp;
						rx1 = xmax;
					end
					else
						if(oc1 & P_BOTTOM) begin
							tmp = ((dx * (ymax - y1) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
							rx1 = x1 + tmp;
							ry1 = ymax;
						end
		end
	
		if(|{oc2}) begin
			if(oc2 & P_LEFT) begin
				tmp = ((dy * (xmin - x2) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
				ry2 = y2 + tmp;
				rx2 = xmin;
			end        
			else
				if(oc2 & P_TOP) begin
					tmp = ((dx * (ymin - y2) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
					$display("TMP = %d", tmp);
					rx2 = x2 + tmp;
					ry2 = ymin;
				end
				else
					if(oc2 & P_RIGHT) begin
						tmp = ((dy * (xmax - x2) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
						ry2 = y2 + tmp;
						rx2 = xmax;
					end
					else
						if(oc2 & P_BOTTOM) begin
							tmp = ((dx * (ymax - y2) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
							rx2 = x2 + tmp;
							ry2 = ymax;
						end
		end
	
		$display("new coord (%d %d)-(%d %d)", rx1, ry1, rx2, ry2);

		OutCode = {rx1, ry1, rx2, ry2};
	endfunction
  
	reg [3:0] inited;
	initial inited = 0;

	reg [31:0] cnt1;
	initial cnt1 = 0;
	reg [31:0] cnt2;
	initial cnt2 = 0;

	reg [31:0] i;

	reg signed [15:0] l, t, r, b;

	reg [3:0] tmp_oc1;
	reg [3:0] tmp_oc2;

	reg signed [15:0] x1;
	reg signed [15:0] y1;
	reg signed [15:0] x2;
	reg signed [15:0] y2;
	
	reg [0:0] prev_start;
	always @ (posedge clk) prev_start <= i_start;

	always @ (posedge clk)
		if((~|{inited} & i_start & ~prev_start) | (|{inited})) begin
		
			if(inited == 0) begin      
				tmp_oc1 = OutCalc(i_x1, i_y1, 1);
				tmp_oc2 = OutCalc(i_x2, i_y2, 2);
			end
			else begin
				tmp_oc1 = OutCalc(x1, y1, 3);
				tmp_oc2 = OutCalc(x2, y2, 4);
			end

			if((tmp_oc1 != 4'd0 || tmp_oc2 != 4'd0) && ((tmp_oc1 & tmp_oc2) == 4'd0)) begin
				$display("need to calculate the intersection");
				$display("%d %d", tmp_oc1, tmp_oc2);

				if(inited == 0)
					{x1, y1, x2, y2} <= OutCode(tmp_oc1, tmp_oc2, i_x1, i_y1, i_x2, i_y2);
				else
					{x1, y1, x2, y2} <= OutCode(tmp_oc1, tmp_oc2, x1, y1, x2, y2);            	

				inited <= inited + 1;
			end
			else begin
				inited <= 4'd0;
				$display("viewport: ", x1, y1, x2, y2);
			end
		end

endmodule

