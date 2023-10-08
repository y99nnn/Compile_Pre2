.PHONY: new, run, clean
new:
	yacc -o transform.c transform.y
	gcc transform.c -o transform
run:
	./transform
clean:
	rm -f transform transform.c
