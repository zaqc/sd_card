CC = iverilog
FLAGS = -Wall -Winfloop -g2005-sv

project : gs.v draw_line.v viewport.v
	$(CC) $(FLAGS) -o test gs.v draw_line.v viewport.sv
	vvp test
	gtkwave dumpfile.vcd cfg.gtkw

clean:
	rm -f test dumpfile.vcd

	
