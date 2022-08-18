SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

# ARM CODE RELATED

function cthumb {
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

function carm {
    if [[ -z "$1" ]]; then
        echo "No first input given!"
        return 0
    fi

    if [[ -z "$2" ]]; then
        echo "No second input given!"
        return 0
    fi

	arm-linux-gnueabi-as -o __o.o "$1"
	arm-linux-gnueabi-ld -o "$2" __o.o
}

# C CODE RELATED

function gccarm {
    if [[ -z "$1" ]]; then
        echo "No first input given!"
        return 0
    fi

    if [[ -z "$2" ]]; then
        echo "No second input given!"
        return 0
    fi

    arm-linux-gnueabi-gcc -mthumb -mcpu=cortex-m3 -march=armv7-m -nostdlib -o "$@"
}

function oarm {
    if [[ -z "$1" ]]; then
        echo "No first input given!"
        return 0
    fi

    if [[ -z "$2" ]]; then
        echo "No second input given!"
        return 0
    fi

    arm-linux-gnueabi-objdump -lSd "$1" > "$2"
}

function chfile {
    if [[ -z "$1" ]]; then
        echo "No input given!"
        return 0
    fi

    touch "$1".c
    touch "$1".h

    hfile=${1^^}"_H_"

    echo "#ifndef ${hfile}" >> "$1".h
    echo "#define ${hfile}" >> "$1".h
    echo "" >> "$1".h
    echo "" >> "$1".h
    echo "" >> "$1".h
    echo "#endif" >> "$1".h

    echo -e "#include \"$1.h\"" >> "$1".c
}

# RUNNING RELATED

function rthumb {
    if [[ -z "$1" ]]; then
        echo "No input given!"
        return 0
    fi

	qemu-arm -L /usr/arm-linux-gnueabi "$1"
}

function rarm {
    if [[ -z "$1" ]]; then
        echo "No input given!"
        return 0
    fi

	qemu-arm -L /usr/arm-linux-gnueabi "$1"
}

# DEBUG RELATED

function darm {
    if [[ ! -f "$1" ]]; then
        echo "File does not exist!"
        return 0
    fi

    gnome-terminal -- qemu-arm -L /usr/arm-linux-gnueabihf -g 1234 "$1"

    gdb-multiarch -q --nh -ex "set architecture arm" -ex "set sysroot /usr/arm-linux-gnueabi" -ex "file $1" -ex "target remote localhost:1234" -ex "break _start";
}

function darm_args {
    if [[ ! -f "$1" ]]; then
        echo "File does not exist!"
        return 0
    fi

    gnome-terminal -- qemu-arm -L /usr/arm-linux-gnueabihf -g 1234 "$1"

    gdb-multiarch -q --nh -ex "set architecture arm" -ex "set sysroot /usr/arm-linux-gnueabi" -ex "file $1" -ex "target remote localhost:1234" -ex "break _start" "${@:2}";
}

function arm_cpsr {
    python3 "$SCRIPT_DIR"/__pyscripts/cpsr.py "$1"
}

# EXAMPLE GENERATORS

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
    echo -e "\t@ Supervisor call to print (r7 = 4)" >> "$1"
    echo -e "\tmov r0, #1" >> "$1"
    echo -e "\tldr r1, =string" >> "$1"
    echo -e "\tmov r2, #15" >> "$1"
    echo -e "\tmov r7, #4" >> "$1"
    echo -e "\tsvc #0" >> "$1"
    echo -e "\t@ Supervisor call to print (r7 = 1)" >> "$1"
    echo -e "\tmov r7, #1" >> "$1"
    echo -e "\tmov r0, #0" >> "$1"
    echo -e "\tsvc #0" >> "$1"
    echo "" >> "$1"
    echo ".data" >> "$1"
    echo "string: .asciz \"Example works!\n\"" >> "$1"
}

function becarm {
    if [[ -f "$1" ]]; then
        echo "File already exists!"
        return 0
    fi

    if [[ -z "$1" ]]; then
        echo "No input given!"
        return 0
    fi

    echo "void _exit(int exit_code) {" >> "$1"
    echo -e "\t__asm(\"MOV r7, #1\");" >> "$1"
    echo -e "\t__asm(\"MOV r0, #0\");" >> "$1"
    echo -e "\t__asm(\"svc #0\");" >> "$1"
    echo -e "\twhile(1) ;" >> "$1"
    echo "}" >> "$1"
    echo "" >> $"$1"
    echo "int _start() {" >> "$1"
    echo -e "\t_exit(0);" >> "$1"
    echo "}" >> "$1"
}

function becmarm {
    if [[ -f "CMakeLists.txt" ]]; then
        echo "File already exists!"
        return 0
    fi

    echo -e "cmake_minimum_required (VERSION 2.8.12)" >> "CMakeLists.txt"
    echo -e "project (APP)" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "# VARIABLES" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "set(FULL_SRC_DIR \"\${CMAKE_CURRENT_SOURCE_DIR}/src/\")" >> "CMakeLists.txt"
    echo -e "set(REL_SRC_DIR \"src/\")" >> "CMakeLists.txt"
    echo -e "set(C_FILES \"\")" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "# allows to loop through all subdirectories" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "MACRO(SUBDIRLIST result curdir)" >> "CMakeLists.txt"
    echo -e "FILE(GLOB children RELATIVE \${curdir} \${curdir}/*)" >> "CMakeLists.txt"
    echo -e "SET(dirlist \"\")" >> "CMakeLists.txt"
    echo -e "FOREACH(child \${children})" >> "CMakeLists.txt"
    echo -e "\tIF(IS_DIRECTORY \${curdir}/\${child})" >> "CMakeLists.txt"
    echo -e "\tLIST(APPEND dirlist \${child})" >> "CMakeLists.txt"
    echo -e "\tENDIF()" >> "CMakeLists.txt"
    echo -e "ENDFOREACH()" >> "CMakeLists.txt"
    echo -e "SET(\${result} \${dirlist})" >> "CMakeLists.txt"
    echo -e "ENDMACRO()" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "# get all SRC sub directories" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "SUBDIRLIST(SUBDIRS \${FULL_SRC_DIR})" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "# get all .c files" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "FILE(GLOB files \${REL_SRC_DIR}/*.c)" >> "CMakeLists.txt"
    echo -e "list(APPEND C_FILES \${files})" >> "CMakeLists.txt"
    echo -e "FILE(GLOB files \${REL_SRC_DIR}/*.h)" >> "CMakeLists.txt"
    echo -e "list(APPEND C_FILES \${files})" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "FOREACH(sd \${SUBDIRS})" >> "CMakeLists.txt"
    echo -e "\tFILE(GLOB files \${REL_SRC_DIR}\${sd}/*.c)" >> "CMakeLists.txt"
    echo -e "\tlist(APPEND C_FILES \${files})" >> "CMakeLists.txt"
    echo -e "ENDFOREACH()" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "message(STATUS \"Files: \")" >> "CMakeLists.txt"
    echo -e "FOREACH(file \${C_FILES})" >> "CMakeLists.txt"
    echo -e "\tmessage(\"\t\t\${file}\")" >> "CMakeLists.txt"
    echo -e "ENDFOREACH()" >> "CMakeLists.txt"
    echo -e "" >> "CMakeLists.txt"
    echo -e "add_custom_target(build COMMAND arm-linux-gnueabi-gcc -mthumb -mcpu=cortex-m3 -march=armv7-m -nostdlib -o main \${C_FILES}" >> "CMakeLists.txt"
    echo -e "\t\t\t\t\t\tCOMMAND bash -c \"arm-linux-gnueabi-objdump -lSd main >> main.s\")" >> "CMakeLists.txt"
}