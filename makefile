.PHONY: all run test clean

CL65 ?= cl65
SIM65 ?= sim65

all: test.prg

test.prg: test.s
	$(CL65) -t sim6502 -o $@ $<

run: test.prg
	@$(SIM65) test.prg; value=$$?; printf 'Low byte (decimal): %s\n' "$$value"

# sim65 returns only one byte as its exit status. Assemble a second
# copy of the program that returns the high byte instead.
test: test.prg
	@$(CL65) -t sim6502 --asm-define RETURN_HIGH -o test-high.prg test.s
	@$(SIM65) test.prg > /dev/null; low=$$?; \
	  $(SIM65) test-high.prg > /dev/null; high=$$?; \
	  printf 'Low byte:  %s (expected 88)\nHigh byte: %s (expected 70)\n' "$$low" "$$high"; \
	  test "$$low" -eq 88 && test "$$high" -eq 70

clean:
	rm -f test.prg test-high.prg test.o
