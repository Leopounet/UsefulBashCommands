function newchar {
	if [ -z "$1" ]; then
    		echo "No argument supplied"
		return
	fi
	touch "$1"
	echo -e "# Name\n\n" > "$1"
	echo -e "### General\n\n" >> "$1"
	echo -e "### Traits\n\n" >> "$1"
	echo -e "### Flaws\n\n" >> "$1"
	echo -e "### Goals\n\n" >> "$1"
}
