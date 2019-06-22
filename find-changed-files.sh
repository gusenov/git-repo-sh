#!/bin/bash

for i in "$@"; do
    case $i in
        -r=*|--repo1=*)
            repo1="${i#*=}"
            eval repo1=$repo1
            shift # past argument=value
            ;;
        -b=*|--branch1=*)
            branch1="${i#*=}"
            shift # past argument=value
            ;;
        -s=*|--start1=*)
            start1="${i#*=}"
            shift # past argument=value
            ;;
        -e=*|--end1=*)
            end1="${i#*=}"
            shift # past argument=value
            ;;

        -f=*|--repo2=*)
            repo2="${i#*=}"
            eval repo2=$repo2
            shift # past argument=value
            ;;
        -d=*|--branch2=*)
            branch2="${i#*=}"
            shift # past argument=value
            ;;
        -o=*|--start2=*)
            start2="${i#*=}"
            shift # past argument=value
            ;;
        -z=*|--end2=*)
            end2="${i#*=}"
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

comm -12 \
     <(./show-changed-files.sh --path="$repo1" \
                               --branch_name="$branch1" \
                               --start_commit="$start1" \
                               --end_commit="$end1") \
     <(./show-changed-files.sh --path="$repo2" \
                               --branch_name="$branch2" \
                               --start_commit="$start2" \
                               --end_commit="$end2")
