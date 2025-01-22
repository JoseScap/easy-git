ilog() {
    local verbose="$1"
    local message="$2"
    
    if [[ $verbose != "true" ]]; then
        return
    fi
    echo "EASYGIT: $message"
}

nolog() {
    ilog "false" "Verbose mode disabled."
}

ghere() {
    local VERBOSE="true"
    local PLACE="."

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -nv|--no-verbose)
                VERBOSE="false"
                shift
                ;;
            *)
                PLACE="$1"
                shift
                ;;
        esac
    done

    ilog $VERBOSE "Open directory: $PLACE"
    explorer "$PLACE"
}

ghere_help() {
    echo ""
    echo "GHERE: Opens a specified directory in your file explorer."
    echo ""
    echo "Usage:"
    echo "    ghere [<directory>] [-nv | --no-verbose] [-h | --help]"
    echo ""
    echo "Options:"
    echo "    <directory>                The directory to open (default: current directory '.')"
    echo "    -nv, --no-verbose          Disable log messages (verbose mode off)"
    echo "    -h, --help                 Display this help message"
    echo ""
    echo "Examples:"
    echo "    ghere                     # Opens the current directory with log messages"
    echo "    ghere ./my-folder         # Opens './my-folder' with log messages"
    echo "    ghere -nv ./my-folder     # Opens './my-folder' without log messages"
    echo "    ghere --no-verbose        # Opens the current directory without log messages"
    echo ""
    echo "Notes:"
    echo "    - If no directory is specified, the current directory is opened by default."
    echo "    - Verbose mode shows additional logs, such as the directory being opened."
    echo ""
}

glog () {
    local VERBOSE=true
    local NUMBER=10
    local HELP=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -nv|--no-verbose)
                VERBOSE=false
                shift
                ;;
            -n|--number)
                if [[ "$2" =~ ^[0-9]+$ ]]; then
                    NUMBER="$2"
                    shift 2
                else
                    ilog $VERBOSE "Error: $1 value must be a number." >&2
                    return 1
                fi
                ;;
            -h|--help)
                HELP=true
                shift
                ;;
            *)
                ilog $VERBOSE "Use: glog [-n | --number <cantidad>] [-v | --verbose]" >&2
                return 1
                ;;
        esac
    done

    if [ $HELP = true ]; then
        ilog $VERBOSE "Showing menu for 'glog' command."
        glog_help
        return
    fi

    ilog $VERBOSE "Showing last $NUMBER commits"
    git log --oneline -n $NUMBER
}

glog_help() {
    echo ""
    echo "GLOG: Display a summary of recent Git commits with customizable options."
    echo ""
    echo "Usage:"
    echo "    glog [-n | --number <cantidad>] [-nv | --no-verbose] [-h | --help]"
    echo ""
    echo "Options:"
    echo "    -n, --number <cantidad>     Specify the number of commits to display (default: 10)"
    echo "    -nv, --no-verbose           Disable detailed commit information (verbose mode off)"
    echo "    -h, --help                  Display this help message"
    echo ""
    echo "Examples:"
    echo "    glog                       # Display the last 10 commits with verbose details"
    echo "    glog -n 5                  # Display the last 5 commits with verbose details"
    echo "    glog --number 20 -nv       # Display the last 20 commits without verbose details"
    echo "    glog -nv                   # Display the last 10 commits without verbose details"
    echo ""
    echo "Notes:"
    echo "    - If you provide an invalid option or value, the command will display an error message."
    echo "    - Verbose mode includes additional information such as commit messages, authors, etc."
    echo ""
}

gpush() {
    local VERBOSE=true
    local TEST=false
    local HELP=false

    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        ilog $VERBOSE "This directory is not a Git repository."
        return 1
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -nv|--no-verbose)
                VERBOSE=false
                shift
                ;;
            -t|--test)
                TEST=true
                shift
                ;;
            -h|--help)
                HELP=true
                shift
                ;;
            *)
                echo "Use: gpush [-n | --number <cantidad>] [-v | --verbose] [-h | --help]" >&2
                return 1
                ;;
        esac
    done

    local CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    ilog $VERBOSE "Working on current branch: $CURRENT_BRANCH"

    
    if [ "$TEST" == "true" ]; then
        ilog $VERBOSE "Dry run mode. Changes won't be applied."
        git push --tags --dry-run origin "$CURRENT_BRANCH"
    else
        git push --tags origin "$CURRENT_BRANCH"
    fi

    if [ $? -eq 0 ]; then
        ilog $VERBOSE "Pushed successfully to branch $CURRENT_BRANCH."
    else
        ilog "Error: Failed to push to the origin."
        return 1;
    fi
}}

ghelp() {
    echo ""
    echo "EASYGIT is a library of commands to simplify your workflow"
    echo ""
    echo "Commands:"
    echo ""
    echo "ghere: Opens the current directory in your file explorer. Use '-h' or '--help' for details."
    echo "glog: Displays a summary of recent Git commits. Use '-h' or '--help' for details."
    echo ""
}

ilog true "Initialized"