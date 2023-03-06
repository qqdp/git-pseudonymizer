#!/bin/bash

#
# ----------------------------------------------------
# Git Pseudonymizer
# ----------------------------------------------------
# Version 0.2.0
# ----------------------------------------------------
# https://github.com/qqdp/git-pseudonymizer
# ----------------------------------------------------
#

seperator="------------------------------------------------------"

color_green=$'\e[32m'
color_red=$'\e[31m'
color_white=$'\e[0m'

mode=
rm_mailmap=0
repo_folder=
identifier=
blacklist=

name_index=1
alphabet=( {a..z} )

while (("$#")); do
	case "$1" in
	--repo-folder)
		if [ "$2" ]
		then
			repo_folder="$2""/*"
		fi;;
	--repo-folder-direct)
		if [ "$2" ]
		then
			repo_folder="$2"
		fi;;
	--mode)
		if [ "$2" ]
		then
			mode="$2"
		fi;;
	--identifier)
		if [ "$2" ]
		then
			identifier="$2"
		fi;;
	--blacklist)
		if [ "$2" ]
		then
			blacklist="$2"
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
		echo "same name and email accross all repositories."
		echo $seperator
		echo "Anonymize:"
		echo "Original author name and email will be replaced by a"
		echo "new name and email per repository."
		echo $seperator
		read -p "1 = Pseudonymize | 2 = Anonymize: " mode
	fi
	if [ -z "$identifier" ]
	then
		echo $seperator
		echo ${color_green}"Enter a String to be used for Name/Email replacements"${color_white}
		echo $seperator
		echo "Example: 'Student' will result in the generation of"
		echo "'Student-1a <Student-1a@Student-1a>' for the first de-"
		echo "tected author. The same name with a different email"
		echo "will then result in 'Student-1b <Student-1b@Student-1b>'"
		echo "and a new author in 'Student-2a <Student-2a@Student-2a>'."
		echo $seperator
		read -p "Enter the indentifier: " identifier
	fi
	if [ -z "$blacklist" ]
	then
		echo $seperator
		echo ${color_green}"Enter email addresses to be blacklisted"${color_white}
		echo $seperator
		echo "You can enter email addresses to be ignored, the author"
		echo "information (Name/Email) will not be replaced."
		echo $seperator
		read -p "Enter email addresses seperated with a space: " blacklist
	fi	
	if [ "$rm_mailmap" -eq 0 ]
	then
		echo $seperator
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

function generate_mailmap () {

	echo $seperator
	echo $(basename "$PWD")
	echo $seperator

	for C in $(git log | grep commit\   | sed "s;commit ;;" | tac | xargs echo)
	do
		local temp_old_name=$(git show -s --format='%an' $C)
		local old_name=${temp_old_name// /}
		local old_email=$(git show -s --format='%ae' $C)
		local temp_filename=$old_name"_"$old_email"_mailmap"

		if grep -q $old_email "../blacklist"
		then
			continue
		elif [[ $old_name == *$identifier* ]]
		then
			continue
		else
			if test -f ../$temp_filename*
			then
				local old_filename=$(find . -name $temp_filename*)
				echo $(pseudonymize_git_log $old_filename)
			else
				if [ -f ../$old_name* ]
				then
					local old_filename=$(find .. -name $old_name*)
					local temp_name_index=${old_filename: -1}
					local count_name=$(ls ../ | grep $old_name* | wc -l)
					local new_name=$identifier"-"$temp_name_index${alphabet[$count_name]}
					local new_email=$new_name"@"$new_name
					local new_mailmap=$new_name" <"$new_email"> <"$old_email">"
					local final_filename=$temp_filename"_"$temp_name_index
					echo $new_mailmap >> ../$final_filename
					echo $(pseudonymize_git_log $final_filename)
				else
					local new_name=$identifier"-"$name_index${alphabet[0]}
					local new_email=$new_name"@"$new_name
					local new_mailmap=$new_name" <"$new_email"> <"$old_email">"
					local final_filename=$temp_filename"_"$name_index
					name_index=$(( name_index + 1 ))
					echo $new_mailmap >> ../$final_filename
					echo $(pseudonymize_git_log $final_filename)
				fi
			fi
		fi
	done

}

function pseudonymize_git_log () {
	local filename=$1
	
	echo $(git filter-repo --mailmap ../$1 --force)
	
	if [ "$mode" -eq 2 ]
	then
		rm ../$filename
	fi
}

cd ${repo_folder::-1}
echo $blacklist >> ./blacklist

for d in $repo_folder; do if [ ! -d "$d" ]; then continue; else (cd "$d" && generate_mailmap) fi; done

if [ "$rm_mailmap" -eq 1 ]
then
	cd ${repo_folder::-1}
	find -type f -name '*mailmap*' -delete
fi

echo $seperator