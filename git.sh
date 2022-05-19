github_path="$HOME/.github_ubc"

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
		echo "Invalid directory!"
		return 0
	fi

	if [[ ! -d "$path/.git" ]]; then
		echo "Not a github directory!"
		return 0
	fi

	while read line; do
		if [[ "$line" = "$path" ]]; then
			echo "Already registered!"
			return 0;
		fi
	done < $github_path

	echo $path >> $github_path
}

# removes by name a registered git repository
function remove_github {
	path=$(realpath "$1")

	if [[ ! -f $github_path ]]; then
		echo "No directory registered!"
		return 0
	fi
	
	tmp_file="___tmp_github.txt"
	touch $tmp_file

	while read line; do
		if [[ "$line" != "$path" ]]; then
			echo $line >> $tmp_file
		else
			echo "Discarded directory successfully!"
		fi
	done < $github_path

	rm "$github_path"
	mv "$tmp_file" "$github_path"
}

# removes by index a registered git repository
function nremove_github {
	n=$1

	tmp_file="___tmp_github.txt"
	touch $tmp_file
	
	while read line; do
		if [[ "$n" != "0" ]]; then
			echo $line >> $tmp_file
		else
			echo "Discarded directory number $n successfully!"
		fi
		n=$(($n - 1))
	done < $github_path

	rm "$github_path"
	mv "$tmp_file" "$github_path"
}

# pushs all registered git repositories
function push_all_github {
 	while read line; do
		if [[ ! -d "$line" ]]; then
			echo "Directory: $line does not exist, can not pull!"
		else
			git -C "$line" add "$line/"*
			git -C "$line" commit -m "Auto-push!"
			git -C "$line" push
		fi
	done < $github_path
}

# pulls all registered git repositories
function pull_all_github {
	while read line; do
		git -C "$line" pull
	done < $github_path
}