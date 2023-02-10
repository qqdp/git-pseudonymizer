#!/bin/bash

#
# ----------------------------------------------------
# Git Pseudonymizer
# ----------------------------------------------------
# Version 0.1.0
# ----------------------------------------------------
# https://github.com/qqcz/git-pseudonymizer
# ----------------------------------------------------
#

seperator="------------------------------------------------------"

color_green=$'\e[32m'
color_red=$'\e[31m'
color_white=$'\e[0m'

mode=
rm_mailmap=0
repo_folder=

while (("$#")); do
	case "$1" in
	--repo-folder)
		if [ "$2" ]
		then
			repo_folder="$2""/*"
			echo $repo_folder
		fi;;
	--repo-folder-direct)
		if [ "$2" ]
		then
			repo_folder="$2"
			echo $repo_folder
		fi;;
	--mode)
		if [ "$2" ]
		then
			mode="$2"
		fi;;
	--rm-mailmap)
		rm_mailmap=1
	esac
	shift
done

if [ -z "$repo_folder" ]
then
	echo $seperator
	echo "Please provide a valid path using --repo-folder or --repo-folder-direct"
	echo $seperator
	exit 1
else
	if [ -z "$mode" ]
	then
			echo $seperator
			echo ${color_red}"THIS TOOL WILL OVERWRITE ALL GIT LOGS IN THE SELECTED"
			echo "FOLDER! THIS PROCESS CAN'T BE REVERTED, PLEASE MAKE"
			echo "SURE TO CREATE BACKUPS!"${color_white}
			read -p "Press enter to continue"
			echo $seperator
			echo ${color_green}"SELECT YOUR MODE"${color_white}
			echo $seperator
			echo "Pseudonymize:"
			echo "Original author name and email will be replaced by the"
			echo "same random name and email accross all repositories."
			echo $seperator
			echo "Anonymize:"
			echo "Original author name and email will be replaced by a"
			echo "new random name and email per repository."
			echo $seperator
			read -p "1 = Pseudonymize | 2 = Anonymize: " mode
			echo $seperator
			if [ "$rm_mailmap" -eq 0 ]
			then
				case $mode in
				[1]*)
					echo ${color_red}"Please consider to delete all generated mailmap files"
					echo "if you don't plan to pseudonymize git repositories"
					echo "from the same author/s in the future. These files can"
					echo "be used to identify the original author/s!"${color_green}
					echo "Keep these files if you want to pseudonymize more git"
					echo "repositories from the same author/s in the future and"
					echo "want to use the same generated name and email."${color_white}
					echo $seperator
					read -p "Do you want to remove mailmap files? [y/n]: " user_confirm
					case $user_confirm in
					[Yy]*)
						rm_mailmap=1
						;;
					[Nn]*)
						rm_mailmap=0
						;;
					*)
					esac
					;;
				[2]*)
					echo ${color_green}"Generated mailmap files will be deleted automatically"
					echo "since these could be used to identify the original"
					echo "author/s!"${color_white}
					read -p "Press enter to continue"
					;;
				*)
				esac
			fi
	fi
fi

function random_string {
    local default_length=16
    local length=${1:-$default_length}
	
    LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c $length
}

function generate_mailmap () {
	local old_email=$1
	local new_email=$(random_string)"@"$(random_string)".com"
	local new_name=$(random_string)
	local new_mailmap=$new_name" <"$new_email"> <"$old_email">"
	local filename=$old_email"_mailmap"
	
	echo $seperator
	echo $(basename "$PWD")
	echo $seperator
	
	if test -f ../$filename
	then
		echo $(pseudonymize_git_log $filename)
	else
		echo $new_mailmap >> ../$filename
		echo $(pseudonymize_git_log $filename)
	fi
}

function pseudonymize_git_log () {
	local filename=$1
	
	echo $(git filter-repo --mailmap ../$1 --force)
	
	if [ "$mode" -eq 2 ]
	then
		rm ../$filename
	fi
}

for d in $repo_folder; do if [ ! -d "$d" ]; then continue; else (cd "$d" && generate_mailmap $(git log -1 --pretty=format:'%ae')) fi; done

if [ "$rm_mailmap" -eq 1 ]
then
	find -type f -name '*mailmap*' -delete
fi

echo $seperator