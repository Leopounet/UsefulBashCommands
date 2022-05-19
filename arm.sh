function carm {
    if [[ -z "$1" ]]; then
        echo "No first input given!"
        return 0
    fi

    if [[ -z "$2" ]]; then
        echo "No second input given!"
        return 0
    fi

	arm-linux-gnueabi-as -march=armv7-m -o __o.o "$1"
	arm-linux-gnueabi-ld -o "$2" __o.o
}

function rarm {
    if [[ -z "$1" ]]; then
        echo "No input given!"
        return 0
    fi

	qemu-arm -L /usr/arm-linux-gnueabi -cpu cortex-m7 "$1"
}

function bearm {
    if [[ -f "$1" ]]; then
        echo "File already exists!"
        return 0
    fi

    if [[ -z "$1" ]]; then
        echo "No input given!"
        return 0
    fi

    echo ".arch armv7-m" >> "$1"
    echo ".cpu cortex-m7" >> "$1"
    echo ".syntax unified" >> "$1"
    echo ".thumb" >> "$1"
    echo ".text" >> "$1"
    echo ".global _start" >> "$1"
    echo "" >> "$1"
    echo ".align 2" >> "$1"
    echo ".thumb_func" >> "$1"
    echo "" >> "$1"
    echo "" >> "$1"
    echo "_start:" >> "$1"
    echo -e "\tmov r0, #1" >> "$1"
    echo -e "\tldr r1, =string" >> "$1"
    echo -e "\tmov r2, #12" >> "$1"
    echo -e "\tmov r7, #4" >> "$1"
    echo -e "\tsvc #0" >> "$1"
    echo "end:" >> "$1"
    echo -e "\tb end" >> "$1"
    echo "" >> "$1"
    echo ".data" >> "$1"
    echo "string: .asciz \"Example works!\n\"" >> "$1"
}