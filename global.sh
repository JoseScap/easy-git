# aqui() {
#     explorer "."
# }

# gl() {
#     # Valores por defecto
#     NUM_COMMITS=10
#     VERBOSE=false

#     # Parsear los argumentos
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             -n|--number)
#                 if [[ "$2" =~ ^[0-9]+$ ]]; then
#                     NUM_COMMITS="$2"
#                     shift 2
#                 else
#                     echo "Error: -n value must be a number." >&2
#                     return 1
#                 fi
#                 ;;
#             -v|--verbose)
#                 VERBOSE=true
#                 shift
#                 ;;
#             *)
#                 echo "Use: gl [-n | --number <cantidad>] [-v | --verbose]" >&2
#                 return 1
#                 ;;
#         esac
#     done

#     # Comando git log
#     if [ "$VERBOSE" = true ]; then
#         echo "Showing last $NUM_COMMITS commits"
#     fi

#     git log --oneline -n "$NUM_COMMITS"
# }

# gp() {
#     # Function to display error message and exit
#     die() {
#         echo "$1" >&2
#         return 1
#     }

#     # Function to log messages if verbose mode is enabled
#     log() {
#         if [ "$VERBOSE" = true ]; then
#             echo "$1"
#         fi
#     }

#     # Check if the current directory is a Git repository
#     log "Checking if the current directory is a Git repository..."
#     if ! git rev-parse --is-inside-work-tree &>/dev/null; then
#         die "Error: This directory is not a Git repository."
#         return 1
#     fi

#     # Get the current branch
#     CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
#     log "Current branch: $CURRENT_BRANCH"

#     # Check for verbose flag
#     VERBOSE=false
#     if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
#         VERBOSE=true
#         shift
#         log "Verbose mode enabled."
#     fi

#     # Push tags to the origin
#     log "Pushing to the origin..."
#     git push --tags origin "$CURRENT_BRANCH"
#     if [ $? -eq 0 ]; then
#         log "Pushed successfully to branch $CURRENT_BRANCH."
#     else
#         die "Error: Failed to push to the origin."
#     fi
# }

gt() {
    # Function to display error message and exit
    die() {
        echo "$1" >&2
        return 1
    }

    # Function to log messages if verbose mode is enabled
    log() {
        if [ "$VERBOSE" = true ]; then
            echo "$1"
        fi
    }

    # Check for verbose flag
    VERBOSE=false
    if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
        VERBOSE=true
        shift
        log "Verbose mode enabled."
    fi

    # Ensure the current directory is a git repository
    log "Checking if the current directory is a Git repository..."
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        die "Error: This directory is not a Git repository."
        return 1
    fi

    # Get the latest tag
    log "Fetching the latest tag..."
    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
    if [ -z "$LATEST_TAG" ]; then
        die "Error: No tags found in the repository."
    fi
    log "Latest tag found: $LATEST_TAG"

    # Determine the formatting (single or double digits)
    if [[ "$LATEST_TAG" =~ ^([0-9]{2})\.([0-9]{2})\.([0-9]{2})$ ]]; then
        FORMAT="double"
        log "Detected double-digit format."
    elif [[ "$LATEST_TAG" =~ ^([0-9])\.([0-9])\.([0-9])$ ]]; then
        FORMAT="single"
        log "Detected single-digit format."
    else
        die "Error: Tag format not recognized. Supported formats: xx.xx.xx or x.x.x."
    fi

    # Parse the latest tag into major, minor, and patch numbers
    IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST_TAG"
    log "Parsed tag into: Major=$MAJOR, Minor=$MINOR, Patch=$PATCH"

    # Increment based on the flag
    case "$1" in
        -m|--major)
            log "Incrementing major version..."
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        "")
            log "Incrementing patch version..."
            PATCH=$((PATCH + 1))
            ;;
        *)
            die "Usage: gt [--verbose | -v] [--major | -m]"
            ;;
    esac

    # Create the new tag based on the detected format
    if [ "$FORMAT" = "double" ]; then
        NEW_TAG=$(printf "%02d.%02d.%02d" "$MAJOR" "$MINOR" "$PATCH")
    else
        NEW_TAG=$(printf "%d.%d.%d" "$MAJOR" "$MINOR" "$PATCH")
    fi
    log "New tag to be created: $NEW_TAG"

    echo "Creating new tag: $NEW_TAG"
    git tag "$NEW_TAG"
    log "Tag $NEW_TAG created successfully."
}

gf() {
    # Default value for verbose mode
    VERBOSE=false

    # Function to show usage manual
    usage() {
        echo "Usage: gf <subcommand> [options]"
        echo ""
        echo "Available subcommands:"
        echo "  lt       Remove the latest tag created (the largest one if multiple tags exist on the same commit)."
        echo "  help     Show this usage manual."
        echo ""
        echo "Options:"
        echo "  -v, --verbose   Enable verbose mode."
        echo ""
        echo "Examples:"
        echo "  gf lt -v    Remove the latest tag with verbose output."
        echo "  gf help     Show this usage manual."
    }

    # Function to log messages if verbose mode is enabled
    log() {
        if [ "$VERBOSE" = true ]; then
            echo "$1"
        fi
    }

    # Function to remove the latest tag
    fix_last_tag() {
        log "Fetching the most recent tags..."
        TAGS=$(git tag --sort=-creatordate)

        if [ -z "$TAGS" ]; then
            echo "Error: No tags found in the repository."
            return 1
        fi

        # Get the latest commit associated with tags
        log "Finding the last commit associated with tags..."
        LAST_COMMIT=$(git rev-list -n 1 "$(echo "$TAGS" | head -n 1)")
        TAGS_ON_LAST_COMMIT=$(git tag --points-at "$LAST_COMMIT")

        if [ -z "$TAGS_ON_LAST_COMMIT" ]; then
            echo "Error: No tags associated with the latest commit."
            return 1
        fi

        log "Tags found on the latest commit: $TAGS_ON_LAST_COMMIT"

        # Find the largest tag based on version
        HIGHEST_TAG=$(echo "$TAGS_ON_LAST_COMMIT" | tr ' ' '\n' | sort -t. -k1,1nr -k2,2nr -k3,3nr | head -n 1)

        if [ -z "$HIGHEST_TAG" ]; then
            echo "Error: Could not determine the largest tag."
            return 1
        fi

        log "The largest tag found: $HIGHEST_TAG"
        echo "Deleting the largest tag: $HIGHEST_TAG"
        git tag -d "$HIGHEST_TAG" && git push origin ":refs/tags/$HIGHEST_TAG"
        echo "Tag deleted successfully."
    }

    # Parse options and subcommands
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            lt)
                SUBCOMMAND="lt"
                shift
                ;;
            help|""|-h|--help)
                usage
                return 0
                ;;
            *)
                echo "Error: Unknown subcommand or option '$1'"
                echo ""
                usage
                return 1
                ;;
        esac
    done

    # Execute subcommands
    case "$SUBCOMMAND" in
        lt)
            fix_last_tag
            ;;
        *)
            echo "Error: No valid subcommand provided."
            echo ""
            usage
            return 1
            ;;
    esac
}


joya() {
    # combina gt + gp
    gt "-v"
    gp "-v"
    gl "-v"
}

# pala() {
#     # Cambiar al directorio de trabajo
#     cd C:/fix-commits || die "Error: No se pudo cambiar al directorio C:/fix-commits"
#     echo "Ahora estás en el directorio C:/fix-commits"
# }

master() {
    VERBOSE=true

    # Función para loguear mensajes si está habilitado el modo verbose
    log() {
        if [ "$VERBOSE" = true ]; then
            echo "$1"
        fi
    }

    # Verificar si hay cambios pendientes
    log "Checking for uncommitted changes..."
    if ! git diff-index --quiet HEAD --; then
        echo "Error: You have uncommitted changes. Please commit or stash them before running this command."
        return 1
    fi

    # Cambiar a la rama master
    log "Switching to the 'master' branch..."
    git checkout master || {
        echo "Error: Could not switch to 'master' branch."
        return 1
    }

    # Hacer un git pull
    log "Pulling the latest changes from 'master'..."
    git pull || {
        echo "Error: Could not pull changes from 'master'."
        return 1
    }

    # Ejecutar el comando gl con verbose por defecto
    log "Executing 'gl' command with verbose mode..."
    gl -v
}

pull() {
    VERBOSE=true

    # Función para loguear mensajes si está habilitado el modo verbose
    log() {
        if [ "$VERBOSE" = true ]; then
            echo "$1"
        fi
    }

    # Verificar si la carpeta actual es un repositorio Git
    log "Checking if the current directory is a Git repository..."
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: This directory is not a Git repository."
        return 1
    fi

    # Obtener la rama actual
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    log "Current branch: $CURRENT_BRANCH"

    # Realizar git pull
    log "Attempting to pull the latest changes from branch '$CURRENT_BRANCH'..."
    if git pull --no-rebase --ff-only origin "$CURRENT_BRANCH"; then
        log "Pull completed successfully (Fast-forward merge)."
        RESULT="Pull successful."
    else
        log "Conflicts detected. Aborting pull..."
        git merge --abort
        RESULT="Pull aborted due to conflicts."
    fi

    # Mostrar resultado del pull
    echo "$RESULT"

    # Ejecutar el comando gl al final
    gl -v
}
