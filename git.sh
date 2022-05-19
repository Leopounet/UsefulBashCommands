github_path="$HOME/.github_ubc"
GREEN='\033[0;32m'
RED='\033[0;31m'
DEFAULT='\033[0m'

# lists all registered git repositories
function list_all_github {
	n="0"
	while read line; do
		echo $n "->" $line
		n=$((n + 1))
	done < $github_path
}

# adds a new github repository
function add_github {
	path=$(realpath "$1")
	
	if [[ ! -f $github_path ]]; then
		touch $github_path
	fi
	
	if [[ ! -d "$path" ]]; then
		echo -e "${RED}Invalid directory!${DEFAULT}"
		return 0
	fi

	if [[ ! -d "$path/.git" ]]; then
		echo -e "${RED}Not a github directory!${DEFAULT}"
		return 0
	fi

	while read line; do
		if [[ "$line" = "$path" ]]; then
			echo -e "${RED}Already registered!${DEFAULT}"
			return 0;
		fi
	done < $github_path

	echo $path >> $github_path
}

# removes by name a registered git repository
function remove_github {
	path=$(realpath "$1")

	if [[ ! -f $github_path ]]; then
		echo -e "${RED}No directory registered!${DEFAULT}"
		return 0
	fi
	
	tmp_file="___tmp_github.txt"
	touch $tmp_file

	while read line; do
		if [[ "$line" != "$path" ]]; then
			echo $line >> $tmp_file
		else
			echo -e "${GREEN}Discarded directory successfully!${DEFAULT}"
		fi
	done < $github_path

	rm "$github_path"
	mv "$tmp_file" "$github_path"
}

# removes by index a registered git repository
function nremove_github {

	if [[ ! -f $github_path ]]; then
		echo -e "${RED}No directory registered!${DEFAULT}"
		return 0
	fi

	n=$1
	tmp_file="___tmp_github.txt"
	touch $tmp_file
	
	while read line; do
		if [[ "$n" != "0" ]]; then
			echo $line >> $tmp_file
		else
			echo -e "${GREEN}Discarded directory number $n successfully!${DEFAULT}"
		fi
		n=$(($n - 1))
	done < $github_path

	rm "$github_path"
	mv "$tmp_file" "$github_path"
}

# pushs all registered git repositories
function push_all_github {
 	while read line; do
	 	echo "--------------------------------------------------------------------------------"
	 	echo -e "${GREEN}Pushing $line ...${DEFAULT}"
		if [[ ! -d "$line" ]]; then
			echo "${RED}Directory: $line does not exist, can not pull!"
		else
			git -C "$line" add "$line/"*
			git -C "$line" commit -m "Auto-push!"
			git -C "$line" push
		fi
	done < $github_path

	echo -e "${GREEN}Done!${DEFAULT}"
}

# pulls all registered git repositories
function pull_all_github {
	while read line; do
		echo "--------------------------------------------------------------------------------"
	 	echo -e "${GREEN}Pulling $line ...${DEFAULT}"
		git -C "$line" pull
	done < $github_path

	echo -e "${GREEN}Done!${DEFAULT}"
}