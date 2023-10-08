.PHONY: expr, run , clean
expr:
	yacc -o basic.c basic.y
	gcc basic.c -o basic
run:
	./basic
clean:
	rm -f basic basic.c
