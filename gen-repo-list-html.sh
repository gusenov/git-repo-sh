#!/bin/bash

#set -x  # echo on

# Usage:
#  $ ./gen-repo-list-html.sh -p="~/repo" -r="~/repo/lang/sh/git-repo-sh/repo-list.html"
#  $ ./gen-repo-list-html.sh --projects="~/repo" --result="~/repo/lang/sh/git-repo-sh/repo-list.html"

for i in "$@"; do
	case $i in
		-p=*|--projects=*)
			projects_dir="${i#*=}"
			eval projects_dir=$projects_dir
			shift # past argument=value
			;;
    -r=*|--result=*)
			result_file="${i#*=}"
			eval result_file=$result_file
			shift # past argument=value
			;;
		--default)
			projects_dir=""
      result_file=""
			shift # past argument with no value
			;;
		*)
			# unknown option
			;;
	esac
done

echo "projects_dir = '$projects_dir'"
echo "result_file = '$result_file'"

[ -z "$projects_dir" ] && exit
[ -z "$result_file" ] && exit

[ -f "$result_file" ] && rm "$result_file"

cat << EOF > "$result_file"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <table width="100%" border="1" cellspacing="0" cellpadding="4">
        <caption></caption>
        <thead>
            <tr>
                <th scope="col" rowspan="2">Path</th>
                <th scope="col" rowspan="2"></th>
                <th scope="col" colspan="3">Remote</th>
            </tr>
            <tr>
                <th scope="col">Name</th>
                <th scope="col">Fetch</th>
                <th scope="col">Push</th>
            </tr>
        </thead>
        <tbody>
EOF

for dir in $(find "$projects_dir" -type d); do
	if [[ $dir != *"/.git"* ]]; then
		if [ -d "$dir/.git" ]; then
			cd $dir
      echo "$dir"

      has_changes=''
      if [ ! -z "$(git status --porcelain)" ]; then
				has_changes='💾'
			fi

      remote_cnt=$(git remote show | wc -l)
      if [ "$remote_cnt" -gt "0" ]; then
        first_columns='<td scope="row" rowspan="'$remote_cnt'">'$dir'</td><td rowspan="'$remote_cnt'">'$has_changes'</td>'
        git remote show | while read remote_name; do
          fetch_url=$(git remote get-url $remote_name)
          push_url=$(git remote get-url --push $remote_name)
cat << EOF >> "$result_file"
            <tr>
                $first_columns
                <td>$remote_name</td>
EOF
          first_columns=""
          if [ "$fetch_url" = "$push_url" ]; then
cat << EOF >> "$result_file"
                <td colspan="2">$fetch_url</td>
            </tr>
EOF
          else
cat << EOF >> "$result_file"
                <td>$fetch_url</td>
                <td>$push_url</td>
            </tr>
EOF
          fi
        done
      else
cat << EOF >> "$result_file"
            <tr>
                <td scope="row">$dir</td>
                <td>$has_changes</td>
                <td scope="row" colspan="3"></td>
            </tr>
EOF
      fi

		fi
	fi
done

cat << EOF >> "$result_file"
        </tbody>
        <tfoot>
            <tr>
                <td></td>
            </tr>
        </tfoot>
    </table>
</body>
</html>
EOF
