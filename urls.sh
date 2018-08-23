#!/bin/bash
#set -x  # echo on

# Usage:
#  $ ./urls.sh -p=~/repo
#  $ ./urls.sh --projects=~/repo
#  $ ./urls.sh --default

projects_dir=.

for i in "$@"; do
	case $i in
		-p=*|--projects=*)
			projects_dir="${i#*=}"
			eval projects_dir=$projects_dir
			shift # past argument=value
			;;
		--default)
			projects_dir=.
			shift # past argument with no value
			;;
		*)
			# unknown option
			;;
	esac
done

echo "| Name | Push URL | Fetch URL |"
echo "| - | - | - |"

for dir in $(find "$projects_dir" -type d); do
	if [[ $dir != *"/.git"* ]]; then
		if [ -d "$dir/.git" ]; then
			cd $dir
			git remote show | while read remote_name; do
				fetch_url=$(git remote get-url $remote_name)
				push_url=$(git remote get-url --push $remote_name)
				echo "| $remote_name | $push_url | $fetch_url |"
      			done
		fi
	fi
done
