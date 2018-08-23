#!/bin/bash
#set -x  # echo on

# Usage:
#  $ ./push-if-need.sh -p=~/repo
#  $ ./push-if-need.sh --projects=~/repo
#  $ ./push-if-need.sh --default

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

for dir in $(find "$projects_dir" -type d); do
	if [[ $dir != *"/.git"* ]]; then
		if [ -d "$dir/.git" ]; then
			cd $dir
			git remote show | while read remote_name; do
				fetch_url=$(git remote get-url $remote_name)
				push_url=$(git remote get-url --push $remote_name)

				git for-each-ref --format='%(refname:short)' refs/heads/ | while read branch_name; do
					upstream="$remote_name/$branch_name"

					if [ -z "$(git branch -r | grep $upstream)" ]; then
						echo "cd $dir"
						echo "git push -u $remote_name $branch_name:$branch_name"
						echo "git branch --set-upstream-to=$upstream $branch_name"
						echo ""
					else
						local_revision=$(LANG=en git rev-parse $branch_name)
						remote_revision=$(LANG=en git rev-parse "$upstream")
						if [ "$local_revision" != "$remote_revision" ]; then
							echo "cd $dir"
							echo "git push --tags $remote_name $branch_name:$branch_name"
							echo ""
						fi
					fi
				done

      			done
		fi
	fi
done
