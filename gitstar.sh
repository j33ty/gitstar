#!/bin/bash
set -e

git_remote="git@github.com:username/repo.git"
git_user_name="username"
git_user_email="lulz@email.com"
end_date="24-01-19"

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

# create_commit $Year-Month-Day #Count
create_commit() {
	echo "$2 on $1" >> commit.md
	hour=$(get_random_num 10 20)
	minute=$(get_random_num 10 59)
	second=$(get_random_num 10 59)
	export GIT_COMMITTER_DATE="$1 $hour:$minute:$second"
	export GIT_AUTHOR_DATE="$1 $hour:$minute:$second"
	git add commit.md -f
	git commit --date="$1 $hour:$minute:$second" -m "$2 on $1"
}

run_gitsploit() {
	git clone $git_remote; cd gitsploit
	git config user.name $git_user_name
	git config user.email $git_user_email
	newDate=$(date '+%y-%m-%d')
	counter=1
	while [ "$newDate" != $end_date ]; do
		newDate=$(date -v -${counter}d '+%d-%m-%y')
		counter=$((counter + 1))
		local limit
		if [[ $(date -j -f "%d-%m-%y" $newDate "+%u") -lt 6 ]] ; then
			limit=$(get_random_num $weekday_commit_min $weekday_commit_max $weekday_rest_allowed)
		else
			limit=$(get_random_num $weekend_commit_min $weekend_commit_max $weekend_rest_allowed)
		fi

		for i in $(seq 1 $limit); do
			create_commit $newDate $i
		done
	done
	git push origin master
}

cleanup() {
	echo "Unsetting GIT_COMMITTER_DATE: " $GIT_COMMITTER_DATE
	unset GIT_COMMITTER_DATE
	echo "Unsetting GIT_AUTHOR_DATE: " $GIT_COMMITTER_DATE
	unset GIT_AUTHOR_DATE
	git rm commit.md
	git commit -am "cleanup"
	git push origin master
}

on_err() {
	printf "\nError Occured"
}

on_exit() {
	printf "\nDone making you a Gitstar!"
}

run_gitsploit
cleanup

trap on_err ERR
trap on_exit EXIT

