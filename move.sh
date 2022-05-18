function gth {
	cd /mnt/c/Users/t.de-castro/
}

function carm {
	arm-linux-gnueabihf-as -march=armv7-m -mcpu=cortex-m0 -mthumb -o __o.o $1
	arm-linux-gnueabihf-ld -o $2 __o.o
}

function rarm {
	LD_LIBRARY_PATH=/lib/arm-linux-gnueabihf qemu-arm $1
}
