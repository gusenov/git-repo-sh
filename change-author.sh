#!/bin/bash
#set -x  # echo on

# Usage:
#  $ ./change-author.sh -p=~/repo/my -o="Abbas Gussenov" -n="Аббас Гусенов" -e="gusenov@live.ru"
#  $ ./change-author.sh --projects=~/repo/my --old="Abbas Gussenov" --new="Аббас Гусенов" --email="gusenov@live.ru"
#  $ ./change-author.sh --default

projects_dir=.

for i in "$@"; do
	case $i in
		-p=*|--projects=*)
			projects_dir="${i#*=}"
			eval projects_dir=$projects_dir
			shift # past argument=value
			;;
    -o=*|--old=*)
			old_name="${i#*=}"
			shift # past argument=value
			;;
    -n=*|--new=*)
			new_name="${i#*=}"
			shift # past argument=value
			;;
    -e=*|--email=*)
			email="${i#*=}"
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

cd "$projects_dir"
pwd

git filter-branch -f --commit-filter '
        if [ "$GIT_COMMITTER_NAME" = "'"$old_name"'" ];
        then
                GIT_COMMITTER_NAME="'"$new_name"'";
                GIT_AUTHOR_NAME="'"$new_name"'";
                GIT_COMMITTER_EMAIL="'"$email"'";
                GIT_AUTHOR_EMAIL="'"$email"'";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD
