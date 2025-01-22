# EasyGit Command Line Utility

**EasyGit** is a set of simple shell commands to streamline your Git workflow and improve efficiency when working with repositories. The commands provided in this script allow you to easily open directories, view recent Git commits, push changes to remote repositories, and more. Each command is designed to be customizable and provide helpful log messages during execution.

## Table of Contents
1. [Setup](#setup)
2. [Commands](#commands)
    - [ghere](#ghere)
    - [glog](#glog)
    - [gpush](#gpush)
    - [gttw](#gttw)
    - [ghelp](#ghelp)
3. [Configuration](#configuration)
4. [Help](#help)

## Setup

### Initialization (`ginit`)
The script starts by checking if the required directories and configuration files exist. If they do not, it sets them up for you:

1. **Creates the directory** `C:/easygit` if it doesn't exist.
2. **Creates the configuration file** `easygit.config` with default values.

### Configuration (`gconfig`)
This command helps you set up the configuration for your Git environment:
- Creates `C:/easygit` if it doesn't exist.
- Creates the `easygit.config` file.
- Adds default settings such as `DEFAULT_WORKSTATION` and `DEFAULT_COMMIT_NUMBERS`.

### Default Configuration (`gdefaultvalues`)
Reads the configuration from `easygit.config` and sets the `DEFAULT_WORKSTATION` and `DEFAULT_COMMIT_NUMBERS` variables to the values stored in the configuration.

## Commands

### `ghere`
Open a directory in your file explorer.

#### Usage:
```
ghere [<directory>] [-nv | --no-verbose] [-h | --help]
```

#### Options:
- `<directory>`: Directory to open (default: current directory `.`).
- `-nv, --no-verbose`: Disable log messages (verbose mode off).
- `-h, --help`: Show help message.

#### Example:
- `ghere`: Opens the current directory with log messages.
- `ghere ./my-folder`: Opens `./my-folder` with log messages.
- `ghere -nv ./my-folder`: Opens `./my-folder` without log messages.

---

### `glog`
Display a summary of recent Git commits with customizable options.

#### Usage:
```
glog [-n | --number <number>] [-nv | --no-verbose] [-h | --help]
```

#### Options:
- `-n, --number <number>`: Specify the number of commits to display (default: 10).
- `-nv, --no-verbose`: Disable detailed commit information (verbose mode off).
- `-h, --help`: Show help message.

#### Example:
- `glog`: Display the last 10 commits with verbose details.
- `glog -n 5`: Display the last 5 commits with verbose details.
- `glog --number 20 -nv`: Display the last 20 commits without verbose details.

---

### `gpush`
Push your local changes to the remote repository.

#### Usage:
```
gpush [-t | --test] [-nv | --no-verbose] [-h | --help]
```

#### Options:
- `-t, --test`: Perform a dry run (no actual changes will be made).
- `-nv, --no-verbose`: Disable detailed push information (verbose mode off).
- `-h, --help`: Show help message.

#### Example:
- `gpush`: Push the current branch with verbose details.
- `gpush -t`: Perform a dry run, no changes will be pushed.
- `gpush -nv`: Push the current branch without verbose details.

---

### `gttw`
Change to the specified workstation directory.

#### Usage:
```
gttw [-nv | --no-verbose] [-h | --help]
```

#### Options:
- `-nv, --no-verbose`: Disable detailed information (verbose mode off).
- `-h, --help`: Show help message.

#### Example:
- `gttw`: Change to the default workstation directory with verbose details.
- `gttw -nv`: Change to the default workstation directory without verbose details.

---

### `ghelp`
Displays a summary of all available commands in EasyGit.

#### Usage:
```
ghelp
```

---

## Configuration

### `easygit.config`
The configuration file is located at `C:/easygit/easygit.config`. It contains the following parameters:
- **DEFAULT_WORKSTATION**: The default directory to change to (if not provided).
- **DEFAULT_COMMIT_NUMBERS**: The number of commits to show by default (10).

The configuration file is automatically created when you run the `gconfig` command.

## Help

If you need help with any command, simply append `-h` or `--help` to the command, for example:

```
ghere -h
glog --help
gpush --help
gttw -h
```

This will display detailed help about the specific command.

---

**Enjoy a smoother Git experience with EasyGit!**