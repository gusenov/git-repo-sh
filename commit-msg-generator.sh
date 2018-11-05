#!/bin/bash

#set -x  # echo on

# Usage:
#  $ ./commit-msg-generator.sh -p=~/repo
#  $ ./commit-msg-generator.sh --projects=~/repo
#  $ ./commit-msg-generator.sh --default

function buildFilesListString {
	local -n files_list=$1
	local len=${#files_list[@]}
	for (( i=0; i<len; i++ )); do
		file_name="${files_list[$i]}"
		if (( i < len-1 )); then
			echo -n "'$file_name', "
		else
			echo -n "'$file_name'"
		fi
	done
}

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

cd "$projects_dir"
pwd

git for-each-ref --format='%(refname:short)' refs/heads/ | while read branch_name; do
	#echo "branch_name = $branch_name"

	for commit_id in $(git rev-list "$branch_name"); do
		#echo "commit_id = $commit_id"

		declare -a all_files=()

		SAVEIFS=$IFS  # Save current IFS
		IFS=$'\n'     # Change IFS to new line.
		all_files=( $(git show --pretty="" --name-status "$commit_id") )
		IFS=$SAVEIFS  # Restore IFS


		declare -a all=()
		declare -a added=()
		declare -a modified=()
		declare -a deleted=()

		for (( i=0; i<${#all_files[@]}; i++ )); do
			file_name_and_status="${all_files[$i]}"

			#echo "file_name_and_status = $file_name_and_status"
			file_status=$(echo "$file_name_and_status" | awk -F"\t" '{ print $1 }')
			file_name=$(echo "$file_name_and_status" | awk -F"\t" '{ print $2 }')
			#echo "file_name = $file_name, file_status = $file_status"

			all+=( "$file_name" )

			case "$file_status" in
				('A')
					added+=( "$file_name" )
					#echo "added[-1] = ${added[-1]}"
					#echo "added = ${added[@]}"
					;;
				('M')
					modified+=( "$file_name" )
					#echo "modified[-1] = ${modified[-1]}"
					#echo "modified = ${modified[@]}"
					;;
				('D')
					deleted+=( "$file_name" )
					#echo "deleted[-1] = ${deleted[-1]}"
					#echo "deleted = ${deleted[@]}"
					;;
			esac

		done

		commit_message=""
		if [ -n "$all" ]; then
			commit_message="FILES: $(buildFilesListString all).\n"
		fi

		if [ -n "$added" ]; then
			if [ -n "$commit_message" ]; then commit_message="${commit_message}\n"; fi
			commit_message="${commit_message}ADDED: $(buildFilesListString added)."
		fi

		if [ -n "$modified" ]; then
			if [ -n "$commit_message" ]; then commit_message="${commit_message}\n"; fi
			commit_message="${commit_message}MODIFIED: $(buildFilesListString modified)."
		fi

		if [ -n "$deleted" ]; then
			if [ -n "$commit_message" ]; then commit_message="${commit_message}\n"; fi
			commit_message="${commit_message}DELETED: $(buildFilesListString deleted)."
		fi

		#echo "$commit_message"
		#echo "//---------------------------------------------------------------------"

		git filter-branch -f --msg-filter \
		"if test \$GIT_COMMIT = '$commit_id'
		then
		    echo \"$commit_message\"; else cat
		fi"

	done

done
