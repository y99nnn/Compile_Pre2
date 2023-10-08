.PHONY: test clean

test:
	arm-linux-gnueabihf-gcc factorial.S -o factorial.out
	qemu-arm -L /usr/arm-linux-gnueabihf ./factorial.out

clean:
	rm -fr factorial.out