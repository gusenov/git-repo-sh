#!/bin/bash

for i in "$@"; do
    case $i in
        -p=*|--path=*)
            projects_dir="${i#*=}"
            eval projects_dir=$projects_dir
            shift # past argument=value
            ;;
        -b=*|--branch_name=*)
            branch="${i#*=}"
            shift # past argument=value
            ;;
        -s=*|--start_commit=*)
            start_commit="${i#*=}"
            shift # past argument=value
            ;;
        -e=*|--end_commit=*)
            end_commit="${i#*=}"
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

result_file_list=""

start=false
for commit in $(git rev-list $branch | tac); do
    if [ "$commit" == "$start_commit" ]; then
        start=true
    fi
    if [ "$start" = true ]; then
        files=$(git diff-tree --no-commit-id --name-only -r "$commit")
        #files=$(git diff-tree --no-commit-id --name-status -r "$commit")
        if [ -z "$result_file_list" ]; then
            result_file_list="$files"
        else
            result_file_list="$result_file_list\n$files"
        fi
    fi
    if [ "$commit" == "$end_commit" ]; then
        break
    fi
done

echo -e "$result_file_list" | sort -u
