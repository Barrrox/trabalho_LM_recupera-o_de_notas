all:
	nasm -f elf64 teste.asm -o teste.o; gcc -m64 -no-pie -o teste teste.o -lm
	nasm -f elf64 AndreFranco-MatheusBarros.asm -o AndreFranco-MatheusBarros.o; gcc -m64 -no-pie -o AndreFranco-MatheusBarros AndreFranco-MatheusBarros.o -lm