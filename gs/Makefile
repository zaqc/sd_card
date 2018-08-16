CC = iverilog
FLAGS = -Wall -Winfloop -g2005-sv
TARGET = test
SRC = gs.v draw_line.v viewport.sv memory_manager.v disp_controller.v

$(TARGET) : $(SRC) Makefile
	$(CC) $(FLAGS) -o $(TARGET) $(SRC)
	vvp $(TARGET)
#	gtkwave dumpfile.vcd cfg.gtkw

wave:
	gtkwave dumpfile.vcd cfg.gtkw
	
edit:
	gedit $(SRC) Makefile &
	
clean:
	rm -f $(TARGET) dumpfile.vcd

	
