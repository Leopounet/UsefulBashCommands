function initpy {
    PLACEHOLDER="imaplaceholder"

    if [[ -z "$1" ]]; then
        echo "No directory name give!"
        echo "Usage: initpy <source directory name>"
        return 0
    fi

    if [[ "$1" =~ [^a-zA-Z0-9_\-] ]]; then
        echo "Invalid characters provided!"
        return 0
    fi

    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cp -r "$SCRIPT_DIR/__python/"* .
    mv "$PLACEHOLDER" "$1"
    sed -i "s/$PLACEHOLDER/$1/g" docs_conf.py
    sed -i "s/$PLACEHOLDER/$1/g" Makefile
    sed -i "s/$PLACEHOLDER/$1/g" setup.py
}