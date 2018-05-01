#!/bin/bash
#set -x  # echo on

# Usage:
#  $ ./changes.sh -p=~/repo
#  $ ./changes.sh --projects=~/repo
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

repo_cnt=0

for dir in $(find "$projects_dir" -type d); do
	if [[ $dir != *"/.git"* ]]; then
		if [ -d "$dir/.git" ]; then
			((++repo_cnt))
			cd $dir
			if [ ! -z "$(git status --porcelain)" ]; then
				echo "$dir has changes!"
			fi
		fi
	fi
done

echo "Number of repositories: $repo_cnt"

