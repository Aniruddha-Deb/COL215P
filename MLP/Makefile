GHDL = ghdl

FLAGS = "--std=08"

all:
	$(GHDL) -a $(FLAGS) shifter.vhd shifter_tb.vhd comparator.vhd comparator_tb.vhd reg.vhd register_tb.vhd mac.vhd mac_tb.vhd
	$(GHDL) -e $(FLAGS) shifter_tb 
	$(GHDL) -e $(FLAGS) comparator_tb
	$(GHDL) -e $(FLAGS) register_tb
	$(GHDL) -e $(FLAGS) mac_tb
	$(GHDL) -r $(FLAGS) shifter_tb --wave=shifer_tb.ghw --stop-time=20ns 
	$(GHDL) -r $(FLAGS) comparator_tb --wave=comparator_tb.ghw --stop-time=20ns 
	$(GHDL) -r $(FLAGS) register_tb --wave=register_tb.ghw --stop-time=20ns 
	$(GHDL) -r $(FLAGS) mac_tb --wave=mac_tb.ghw --stop-time=20ns