BINARY = rom.bin
ASM = vasm_6502_oldstyle

build: $(BINARY)

flash:
	minipro -p AT28C256 -w $(BINARY)

dump:
	minipro -p AT28C256 -r $(BINARY)

tty:
	sudo picocom -b 9600 -d 8 -p 2 -f n -y n /dev/ttyUSB1

$(BINARY): main.asm
	$(ASM)  main.asm -Fbin -c02 -esc -dotdir -o $(BINARY) 
