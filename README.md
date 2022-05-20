# UsefulBashCommands

Add this to the .bashrc to automatically add all the listed commands here :

```sh
# custom commands
shdir="$HOME/Desktop/UsefulBashCommands/"

for filename in $shdir*.sh; do
        if [[ -f "$filename" ]]; then
                source "$filename"
        fi
done
```
