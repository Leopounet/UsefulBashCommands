function initlatex {
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cp -r "$SCRIPT_DIR/__latex/"* .
}

function initbeamer {
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cp -r "$SCRIPT_DIR/__beamer/"* .
}