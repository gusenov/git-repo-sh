#!/usr/bin/env bash

readonly default_branch="master"

git remote show | while read remote_name; do
  push_url=$(git remote get-url --push $remote_name)

  if [[ $push_url =~ "github" ]]; then
    provider="git@github.com"
  elif [[ $push_url =~ "gitlab" ]]; then
    provider="git@gitlab.com"
  elif [[ $push_url =~ "bitbucket" ]]; then
    provider="git@bitbucket.org"
  fi

  user_n_repo=$(echo "$push_url" | cut -d: -f2-)

  echo "git push "$provider:$user_n_repo" $default_branch:$default_branch"
  git push "$provider:$user_n_repo" $default_branch:$default_branch
done
