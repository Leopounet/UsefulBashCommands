function bindba {
    binsec -isa arm32 -arm-supported-modes thumb -disasm -disasm-o-dba "$1".dba $1
}

function binrun {
    binsec -isa arm32 -arm-supported-modes thumb -sse -sse-depth 1000000 -sse-script $1 $2
}