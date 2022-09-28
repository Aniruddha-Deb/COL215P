GHDL = ghdl

SRC = reg.vhd shifter.vhd comparator.vhd mac.vhd led_driver.vhd rom.vhd ram.vhd controller.vhd
DEP = $(patsubst %.vhd,deps/%.d,$(SRC))

all: $(DEP)
	$(GHDL) -a controller_tb.vhd
	$(GHDL) -e controller_tb
	$(GHDL) -r controller_tb  --max-stack-alloc=16384 --wave=waves/controller_tb.ghw --stop-time=20000ns

deps/%.d: %.vhd
	$(GHDL) -a $<