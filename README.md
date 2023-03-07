# Git Pseudonymizer

Pseudonymize or Anonymize one or more git repositories.

## Description

This tool removes identifying data like names and email addresses from git repositories and replaces it with generated data. The email address is used as an identifier and will always result in the same generated name/email replacement in a specific git repository. You can choose between pseudonymization and anonymization:

Pseudonymization will result in the same replacement for each original email address accross all provided git repositories with an option to keep the information about original email addresses and use the same generated data in future runs. If a already replaced author name appears again with a different email address, the data will be replaced with the same ID but with the next letter from the alphabet (e.g. "Student-1a" and "Student-1b").

Anonymization will do the same replacement, but will always generate a new name/email combination for each given repository no matter if the original email address was detected before or not.

## Disclaimer

This tool was created to pseudonymize personal git repositories in order to process data anonymously - Please use it responsible.

Local changes made using this tool are permanent and can't be reverted.

## Features

Implemented:

* Remove identifying data from git logs
* Set a custom name to be used to replace names and email addresses
* Blacklist email addresses to prevent specific authors not to be replaced

Planned:

* Detection and removal of identifying data from files

## Dependencies

* Linux or Windows with WSL / VM
* Git: `sudo apt install git`
* git-filter-repo: `sudo apt install git-filter-repo`

## Usage

1. Download the git-pseudonymizer.sh file

2. Set the needed permissions:
   
   ```shell
   chmod +x git-pseudonymizer.sh
   ```

3. Run the script in unix shell with or without flags:
   
   ```shell
   git-pseudonymizer.sh --mode * --repo-folder * --identifier * --blacklist * --rm-mailmap
   ```

## Flags

You have to run this tool with at least the repo-folder flag. You will then be asked to enter the mode, identifier, blacklist and mailmap preference into the console step by step.

Providing --repo-folder, --mode, --identifier and --blacklist will run the tool without any console prompts.

#### --mode

1 = Pseudonymization, 2 = Anonymization

- Example: `--mode 1`

#### --repo-folder (required)

Provide the path to a folder containing one or more git repositories.

- Example: `--repo-folder /path/to/folder`

#### --identifier (optional)

Provide a String to be used for Name/Email replacements.

- Example: `--identifier Student`

#### --blacklist (optional)

Provide email addresses in order to ignore specific authors (these will not be replaced). A blacklist file will be created in the provided folder.

- Example: `--blacklist example@example example2@example2`

#### --rm-mailmap (optional)

This flag will force the removal of all generated mailmap files. Using --mode 2 will always remove these files. Not setting this flag in --mode 1 will keep all mailmap files.

- Example: `--repo-folder-direct /path/to/repo`

## Version History

* 0.2.2
  * Add OS detection/handling

* 0.2.1
  * Prevention of empty identifier
  * Fix mailmap access across repositories

* 0.2.0
  * Detection of different authors
  * Option to set custom identifier
  * Option to blacklist email addresses

* 0.1.0
  * Initial Release

## Author

https://github.com/qqdp

## License

This project is licensed under the MIT License.