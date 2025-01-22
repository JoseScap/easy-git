DEFAULT_WORKSTATION=
DEFAULT_COMMIT_NUMBERS=

ilog() {
    local verbose="$1"
    local message="$2"
    
    if [[ $verbose != "true" ]]; then
        return
    fi
    echo "*** EASYGIT: $message"
}

nolog() {
    ilog "false" "Verbose mode disabled."
}

ginit() {
    VERBOSE=true
    ilog $VERBOSE "Initializing."

    # Check if we have the easydirectory and .config file
    if [ -d "C:/easygit" ] && [ -f "C:/easygit/easygit.config" ]; then
        ilog $VERBOSE "Everything is ready to work. 'C:/easygit' and 'easygit.config' already exist."
        ilog $VERBOSE "Reading config"
        gdefaultvalues
        return 0
    fi

    gconfig
}

gconfig() {
    VERBOSE=true
    ilog $VERBOSE "Setting up initial config."
        
    # Verificar si la carpeta 'C:/easygit' existe, si no, crearla
    if [ ! -d "C:/easygit" ]; then
        ilog $VERBOSE "Creating directory 'C:/easygit'."
        mkdir -p "C:/easygit"
    fi

    # Cambiar al directorio
    ilog $VERBOSE "Change working directory to root 'C:/easygit'"
    cd "C:/easygit"
    
    # Crear el archivo '.config'
    ilog $VERBOSE "Creating file '.config'"
    touch easygit.config
    
    # Agregar configuraciones iniciales al archivo .config
    ilog $VERBOSE "Adding initial config to easygit.config"
    echo "DEFAULT_WORKSTATION=" > easygit.config
    echo "DEFAULT_COMMIT_NUMBERS=10" >> easygit.config

    # Abrir el archivo con VSCode
    ilog $VERBOSE "Opening file '.config' with VSCode"
    code easygit.config
}

gdefaultvalues() {
    # Verificar si el archivo easygit.config existe
    if [ ! -f "C:/easygit/easygit.config" ]; then
        ilog $VERBOSE "Config file 'easygit.config' does not exist."
        return 1
    fi

    # Leer las configuraciones desde el archivo easygit.config
    while IFS='=' read -r key value; do
        case "$key" in
            "DEFAULT_WORKSTATION")
                DEFAULT_WORKSTATION="$value"
                ;;
            "DEFAULT_COMMIT_NUMBERS")
                DEFAULT_COMMIT_NUMBERS="$value"
                ;;
            *)
                # Ignorar otras configuraciones o líneas vacías
                ;;
        esac
    done < "C:/easygit/easygit.config"

    # Mostrar los valores cargados (opcional)
    ilog $VERBOSE "Loaded config:"
    ilog $VERBOSE "DEFAULT_WORKSTATION=$DEFAULT_WORKSTATION"
    ilog $VERBOSE "DEFAULT_COMMIT_NUMBERS=$DEFAULT_COMMIT_NUMBERS"
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
    local NUMBER=$DEFAULT_COMMIT_NUMBERS
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
                    echo "Error: $1 value must be a number." >&2
                    return 1
                fi
                ;;
            -h|--help)
                HELP=true
                shift
                ;;
            *)
                echo "Use: glog [-n | --number <cantidad>] [-v | --verbose] [-h | --help]" >&2
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
                echo "Use: gpush [-v | --verbose] [-t | --test] [-h | --help]" >&2
                return 1
                ;;
        esac
    done

    local CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    ilog $VERBOSE "Working on current branch: $CURRENT_BRANCH"

    if [ $HELP = true ]; then
        ilog $VERBOSE "Showing menu for 'gpush' command."
        gpush_help
        return
    fi
    
    if [ $TEST == true ]; then
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
}

gpush_help() {
    echo ""
    echo "GPUSH: Push your local Git changes to the remote repository."
    echo ""
    echo "Usage:"
    echo "    gpush [-t | --test] [-nv | --no-verbose] [-h | --help]"
    echo ""
    echo "Options:"
    echo "    -t, --test                  Perform a dry run (no actual changes will be made)"
    echo "    -nv, --no-verbose           Disable detailed push information (verbose mode off)"
    echo "    -h, --help                  Display this help message"
    echo ""
    echo "Examples:"
    echo "    gpush                       # Push the current branch with verbose details"
    echo "    gpush -t                    # Perform a dry run, no changes will be pushed"
    echo "    gpush --test                # Perform a dry run, no changes will be pushed"
    echo "    gpush -nv                   # Push the current branch without verbose details"
    echo ""
    echo "Notes:"
    echo "    - If you provide an invalid option or value, the command will display an error message."
    echo "    - Verbose mode includes additional information such as the current branch and push status."
    echo "    - The test mode will simulate the push without actually making any changes."
    echo ""
}

gttw() {
    local VERBOSE=true
    local HELP=false
    local WORKSTATION=$DEFAULT_WORKSTATION

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -nv|--no-verbose)
                VERBOSE=false
                shift
                ;;
            -h|--help)
                HELP=true
                shift
                ;;
            *)
                echo "Use: gttw [-v | --verbose] [-h | --help]" >&2
                return 1
                ;;
        esac
    done

    if [ $HELP = true ]; then
        ilog $VERBOSE "Showing menu for 'gttw' command."
        gttw_help
        return
    fi

    ilog $VERBOSE "Change directory to: $WORKSTATION"
    cd "$WORKSTATION"
}

gttw_help() {
    echo ""
    echo "GTTW: Change to the specified workstation directory."
    echo ""
    echo "Usage:"
    echo "    gttw [-nv | --no-verbose] [-h | --help]"
    echo ""
    echo "Options:"
    echo "    -nv, --no-verbose           Disable detailed information (verbose mode off)"
    echo "    -h, --help                  Display this help message"
    echo ""
    echo "Examples:"
    echo "    gttw                        # Change to the default workstation directory with verbose details"
    echo "    gttw -nv                    # Change to the default workstation directory without verbose details"
    echo "    gttw -h                     # Show help message for 'gttw' command"
    echo ""
    echo "Notes:"
    echo "    - If you provide an invalid option or value, the command will display an error message."
    echo "    - Verbose mode includes additional information about the directory being changed to."
    echo ""
}

glgtm() {
    local VERBOSE=true
    local HELP=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -nv|--no-verbose)
                VERBOSE=false
                shift
                ;;
            -h|--help)
                HELP=true
                shift
                ;;
            *)
                echo "Use: glgtm [-nv | --no-verbose] [-h | --help]" >&2
                return 1
                ;;
        esac
    done

    if [ $HELP = true ]; then
        ilog $VERBOSE "Showing menu for 'glgtm' command."
        glgtm_help
        return
    fi

    ilog $VERBOSE "This work looks good to me, I'll proceed to push to master."

    gpush
    glog
}

glgtm_help() {
    echo "Usage: glgtm [-nv | --no-verbose] [-h | --help]"
    echo ""
    echo "This command performs a quick review of the work and, if everything looks good,"
    echo "proceeds to perform a 'git push' and then shows the Git log."
    echo ""
    echo "Options:"
    echo "  -nv, --no-verbose   Disables verbose mode."
    echo "  -h, --help           Shows this help message."
    echo ""
    echo "Actions performed:"
    echo "  - If the -nv option is not specified, the command provides additional information"
    echo "    during the process, including a confirmation message."
    echo "  - If the -nv option is specified, detailed messages are omitted."
    echo "  - Performs a 'git push' to the 'master' branch and then runs 'git log'."
}


ghelp() {
    echo ""
    echo "EASYGIT is a library of commands to simplify your workflow"
    echo ""
    echo "Commands:"
    echo ""
    echo "ghere: Opens the current directory in your file explorer. Use '-h' or '--help' for details."
    echo "glog: Displays a summary of recent Git commits. Use '-h' or '--help' for details."
    echo "gpush: Pushes your changes to the remote repository. Use '-h' or '--help' for details."
    echo "gttw: Changes directory to the specified workstation directory. Use '-h' or '--help' for details."
    echo "glgtm: Pushes your changes directly to the master branch and then shows the Git log. Use '-h' or '--help' for details."
    echo ""
}

ginit