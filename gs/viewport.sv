// 
module viewport(
  input clk,
  
  input signed [15:0] i_x1,
  input signed [15:0] i_y1,
  input signed [15:0] i_x2,
  input signed [15:0] i_y2
);

  parameter	[3:0]		P_INSIDE = 4'b0000;
  parameter	[3:0]		P_LEFT = 4'b0001;
  parameter	[3:0]		P_RIGHT = 4'b0010;
  parameter	[3:0]		P_BOTTOM = 4'b0100;
  parameter	[3:0]		P_TOP = 4'b1000;
  
  parameter signed [15:0] xmin = 0;
  parameter signed [15:0] xmax = 799;
  parameter signed [15:0] ymin = 0;
  parameter signed [15:0] ymax = 479;
    
  function reg [3:0] OutCalc(
    input signed [15:0] x,
    input signed [15:0] y
  );
    reg [3:0] code;
    code = P_INSIDE;

    if(x < xmin) code = code | P_LEFT;
    if(x > xmax) code = code | P_RIGHT;
    if(y < ymin) code = code | P_TOP;
    if(y > ymax) code = code | P_BOTTOM;

    OutCalc = code;
  endfunction
  
  function [63:0] OutCode(
    input signed [15:0] x1,
    input signed [15:0] y1,
    input signed [15:0] x2,
    input signed [15:0] y2
  );
    reg [31:0] i;
    
    reg [3:0] oc1;
    reg [3:0] oc2;
    
    reg signed [31:0] dx;
    reg	signed [31:0] dy;
    reg	signed [31:0] tmp;
        
    for(i = 0; i < 3; i++) begin      
      oc1 = OutCalc(x1, y1);
      oc2 = OutCalc(x2, y2);

      if((oc1 != 4'd0 || oc2 != 4'd0) && ((oc1 & oc2) == 4'd0)) begin
        $display("need to calculate the intersection");
        $display("%d %d", oc1, oc2);
        
        dx = (x2 - x1);
        dy = (y2 - y1);
        
        $display(dx, dy);
        
        if(oc1 & P_LEFT) begin
          tmp = ((dy * (xmin - x1) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
          y1 = y1 + tmp;
          x1 = xmin;
        end        
        else
          if(oc1 & P_TOP) begin
            tmp = ((dx * (ymin - y1) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
            x1 = x1 + tmp;
            y1 = ymin;
          end
          else
            if(oc1 & P_RIGHT) begin
              tmp = ((dy * (xmax - x1) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
              y1 = y1 + tmp;
              x1 = xmax;
            end
            else
              if(oc1 & P_BOTTOM) begin
                tmp = ((dx * (ymax - y1) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
                x1 = x1 + tmp;
                y1 = ymax;
              end
       
        if(oc2 & P_LEFT) begin
          tmp = ((dy * (xmin - x2) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
          y2 = y2 + tmp;
          x2 = xmin;
        end        
        else
          if(oc2 & P_TOP) begin
            tmp = ((dx * (ymin - y2) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
            x2 = x2 + tmp;
            y2 = ymin;
          end
          else
            if(oc2 & P_RIGHT) begin
              tmp = ((dy * (xmax - x2) * 16'sd1000) / dx + 16'sd500) / 16'sd1000;
              y2 = y2 + tmp;
              x2 = xmax;
            end
            else
              if(oc2 & P_BOTTOM) begin
                tmp = ((dx * (ymax - y2) * 16'sd1000) / dy + 16'sd500) / 16'sd1000;
                x2 = x2 + tmp;
                y2 = ymax;
              end

        $display("new coord (%d %d)-(%d %d)", x1, y1, x2, y2);
      end 
      
    end
    
    OutCode = {x1, y1, x2, y2};
  endfunction
  
  reg [1:0] inited;
  initial inited = 0;
  
  reg [31:0] cnt1;
  initial cnt1 = 0;
  reg [31:0] cnt2;
  initial cnt2 = 0;
  
  reg [31:0] i;
  
  reg signed [15:0] l, t, r, b;
  
  always @ (posedge clk) begin
    if(inited != 2) begin
      
      if(inited == 0)
      //{l, t, r, b} = OutCode(i_x1, i_y1, i_x2, i_y2);
      
      $display("viewport: ", l, t, r, b);
            
      inited <= inited + 1;
      
      for(i = 2; i < 4; i = i + 1) begin
      	cnt1 <= cnt1 + i;
      	cnt2 = cnt2 + 1;
      	$display("%d %d", cnt1, cnt2);
      end      
    end
  end
  
endmodule

