tema2: tema2.asm
	nasm -f elf32 -g -F dwarf -o tema2.o $<
	gcc -m32 -g -o $@ tema2.o

clean:
	rm -f tema2 tema2.o
