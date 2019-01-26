#!/bin/bash
set -e

git_user_name="username"
git_user_email="email@email.com"
start_date="2018-02-21" # Y-m-d
end_date=$(date '+%Y-%m-%d') # Today

# weekday rules
weekday_commit_min=0
weekday_commit_max=12
weekday_rest_allowed=true

# weekend rules
weekend_commit_min=0
weekend_commit_max=3
weekend_rest_allowed=true

# get_random_num $start $end $biased_number
get_random_num() {
	if [ -z "$3" ] && [[ $3 -eq true ]]; then
		echo $(jot -r 1 $1 $2)
	else
		local result=$(jot -r 1 $1 $2)
		if [[ $result%3 -eq 0 ]]; then
			echo 0
		else
			echo $result
		fi
	fi
}

# create_commit $Y-m-d $Count
create_commit() {
	echo "$2 on $1" >> commit.md
	local hour=$(get_random_num 10 20)
	local minute=$(get_random_num 10 59)
	local second=$(get_random_num 10 59)
	export GIT_COMMITTER_DATE="$1 $hour:$minute:$second"
	export GIT_AUTHOR_DATE="$1 $hour:$minute:$second"
	git add commit.md -f
	git commit --date="$1 $hour:$minute:$second" -m "$2 on $1" >/dev/null
}

# run_gitstar runs loop over time and creates commits
run_gitstar() {
	mkdir gitsploit; cd gitsploit
	git init
	git config user.name $git_user_name
	git config user.email $git_user_email
	local commit_date=$start_date
	local counter=1
	while [ "$commit_date" != $end_date ]; do
		local limit
		if [[ $(date -j -f "%Y-%m-%d" $commit_date "+%u") -lt 6 ]] ; then
			limit=$(get_random_num $weekday_commit_min $weekday_commit_max $weekday_rest_allowed)
		else
			limit=$(get_random_num $weekend_commit_min $weekend_commit_max $weekend_rest_allowed)
		fi

		for i in $(seq 1 $limit); do
			printf "\nOn Date: $commit_date"
			create_commit $commit_date $i
		done
		commit_date=$(date -j -v +${counter}d -f "%Y-%m-%d" "$start_date" "+%Y-%m-%d")
		counter=$((counter + 1))
	done
}

# cleanup envs and files for previous commit and create a new commit
cleanup() {
	printf "\nUnsetting Vars and Cleaning up!"
	unset GIT_COMMITTER_DATE
	unset GIT_AUTHOR_DATE
	git rm commit.md >/dev/null
	git commit -am "Cleanup" >/dev/null
}

on_err() {
	printf "\nError Occured"
}

on_exit() {
	printf "\nDone making you a Gitstar! Now, Set your remote repo and Push the repo using 'git push origin master'"
}

run_gitstar
cleanup

trap on_err ERR
trap on_exit EXIT

