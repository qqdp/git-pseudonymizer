# Git Pseudonymizer

Pseudonymize or Anonymize one or more git repositories.

## Description

This tool removes identifying data like names and email addresses from git repositories and replaces it with random generated data. The email address is used as an identifier and will always result in the same generated name/email replacement in a specific git repository. You can choose between pseudonymization and anonymization:

Pseudonymization will result in the same replacement for each original email address accross all provided git repositories with an option to keep the information about original email addresses and use the same generated data in future runs.

Anonymization will do the same replacement, but will always generate a new name/email combination for each given repository no matter if the original email address was detected before or not.

## Disclaimer

This tool was created to pseudonymize personal git repositories in order to process data anonymously - Please use it responsible.

Local changes made using this tool are permanent and can't be reverted.

## Features

Implemented:

* Remove identifying data from git logs
* The current implementation is only working for one person git repositories. It will replace all names and email addresses based on the email address used in the latest commit.

Planned:

* Individual detection and pseudonymization of all author email addresses in a single git log
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
   git-pseudonymizer.sh --mode * --repo-folder * --repo-folder-direct * --rm-mailmap
   ```

## Flags

You have to run this tool with at least one of the repo-folder flags. You will then be asked to enter the mode and mailmap preference into the console step by step.

Providing --mode and --repo-folder/--repo-folder-direct will run the tool without any console prompts.

#### --mode

1 = Pseudonymization, 2 = Anonymization

- Example: `--mode 1`

#### --repo-folder (required)

Provide the path to a folder containing one or more git repositories. Should not be used with --repo-folder-direct.

- Example: `--repo-folder /path/to/folder`

#### --repo-folder-direct (required)

Provide the direct path for a single git repository. Should not be used with --repo-folder.

- Example: `--repo-folder-direct /path/to/repo`

#### --rm-mailmap (optional)

This flag will force the removal of all generated mailmap files. Using --mode 2 will always remove these files. Not setting this flag in --mode 1 will keep all mailmap files.

- Example: `--repo-folder-direct /path/to/repo`

## Version History

* 0.1.0
  * Initial Release

## Author

https://github.com/qqdp

## License

This project is licensed under the MIT License.