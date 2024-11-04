#!/usr/bin/env bash
#set -x  # echo on

# Usage:
#  $ ./push-to-all-remotes.sh -b=master
#  $ ./push-to-all-remotes.sh -b=main

default_branch="master"
should_force="false"

for i in "$@"; do
	case $i in
		-b=*|--branch=*)
			default_branch="${i#*=}"
			shift # past argument=value
			;;
		--force)
			should_force="true"
			shift # past argument with no value
			;;
	esac
done

if [ ! -z "$(git status --porcelain)" ]; then
  echo "$(pwd) has changes!"
  exit
fi

branches_cnt=$(git branch | wc -l)
if [ "$branches_cnt" -gt "1" ]; then
  echo "There are more branches than one!"
  exit
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$default_branch" != "$current_branch" ]; then
  echo "The current branch has different name than '$default_branch'!"
  exit
fi

git remote show | while read remote_name; do
  fetch_url=$(git remote get-url $remote_name)
  push_url=$(git remote get-url --push $remote_name)

  if [ "$should_force" == "true" ]
  then 
    echo "git push $push_url $default_branch:$default_branch --force"
    git push $push_url $default_branch:$default_branch --force
  else 
    echo "git push $push_url $default_branch:$default_branch"
    git push $push_url $default_branch:$default_branch
  fi

done
