BINARY = rom.bin
ASM = vasm_6502_oldstyle

build: $(BINARY)

flash:
	minipro -p AT28C256 -w $(BINARY)

dump:
	minipro -p AT28C256 -r $(BINARY)

$(BINARY): main.asm
	$(ASM)  main.asm -Fbin -c02 -esc -dotdir -o $(BINARY) 
