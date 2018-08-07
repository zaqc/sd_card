CC = iverilog
FLAGS = -Wall -Winfloop

project: main.v
	$(CC) $(FLAGS) -o test main.v sd_reader.v
	vvp test
	gtkwave dumpfile.vcd cfg.gtkw

clean:
	rm -f test dumpfile.vcd

