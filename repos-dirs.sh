#!/bin/bash
#set -x  # echo on

# Usage:
#  $ ./changes.sh -p=~/Source/Repos/
#  $ ./changes.sh --projects=~/Source/Repos/
#  $ ./changes.sh --default

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

for dir in $(find "$projects_dir" -type d | sort); do
	if [[ $dir != *"/.git"* ]]; then
		if [ -d "$dir/.git" ]; then
			echo "$dir" \
				| sed 's:^'"$projects_dir"'::'  # remove part of path.
		fi
	fi
done
