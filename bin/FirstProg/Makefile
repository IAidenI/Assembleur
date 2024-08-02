FILE=auth

Assemble:
	@echo "Compiling..."
	nasm -f elf32 $(FILE).asm -o $(FILE).o
	ld -m elf_i386 -o $(FILE) $(FILE).o
