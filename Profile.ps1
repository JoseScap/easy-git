$global:DefaultWorkstation=
$global:DefaultCommitNumbers=

function Write-Log {
    param (
        [bool]$Verbose,
        [string]$Message
    )

    if (-not $Verbose) {
        return
    }
    Write-Host "*** EASYGIT: $Message"
}

function Disable-Log {
    Write-Log -Verbose:$false -Message "Verbose mode disabled."
}

function Initialize-EasyGit {
    $VerboseMode = $true
    Write-Log -Verbose:$VerboseMode -Message "Initializing."

    # Check if the easygit directory and config file exist
    if ((Test-Path "C:/easygit") -and (Test-Path "C:/easygit/easygit.ps.config")) {
        Write-Log -Verbose:$VerboseMode -Message "Everything is ready to work. 'C:/easygit' and 'easygit.ps.config' already exist."
        Write-Log -Verbose:$VerboseMode -Message "Reading config"
        Load-DefaultValues
        return
    }

    Configure-EasyGit
}

function Configure-EasyGit {
    $VerboseMode = $true
    Write-Log -Verbose:$VerboseMode -Message "Setting up initial config."

    # Create the directory if it doesn't exist
    if (-not (Test-Path "C:/easygit")) {
        Write-Log -Verbose:$VerboseMode -Message "Creating directory 'C:/easygit'."
        New-Item -ItemType Directory -Path "C:/easygit" | Out-Null
    }

    # Change to the directory
    Write-Log -Verbose:$VerboseMode -Message "Change working directory to root 'C:/easygit'"
    Set-Location "C:/easygit"

    # Create the config file
    Write-Log -Verbose:$VerboseMode -Message "Creating file 'easygit.ps.config'"
    New-Item -ItemType File -Path "C:/easygit/easygit.ps.config" | Out-Null

    # Add initial configurations to the config file
    Write-Log -Verbose:$VerboseMode -Message "Adding initial config to easygit.ps.config"
    Set-Content -Path "C:/easygit/easygit.ps.config" -Value "DEFAULT_WORKSTATION="
    Add-Content -Path "C:/easygit/easygit.ps.config" -Value "DEFAULT_COMMIT_NUMBERS=10"

    # Open the file with VSCode
    Write-Log -Verbose:$VerboseMode -Message "Opening file 'easygit.ps.config' with VSCode"
    Start-Process -FilePath "code" -ArgumentList "C:/easygit/easygit.ps.config"
}

function Load-DefaultValues {
    # Check if the config file exists
    if (-not (Test-Path "C:/easygit/easygit.ps.config")) {
        Write-Log -Verbose:$VerboseMode -Message "Config file 'easygit.ps.config' does not exist."
        return
    }

    # Read configurations from the config file
    $ConfigLines = Get-Content -Path "C:/easygit/easygit.ps.config"
    foreach ($Line in $ConfigLines) {
        if ($Line -match "^(.*?)=(.*)$") {
            $Key = $Matches[1]
            $Value = $Matches[2]
            switch ($Key) {
                "DEFAULT_WORKSTATION" { $global:DefaultWorkstation = $Value }
                "DEFAULT_COMMIT_NUMBERS" { $global:DefaultCommitNumbers = $Value }
                default { }
            }
        }
    }

    # Display loaded values (optional)
    Write-Log -Verbose:$VerboseMode -Message "Loaded config:"
    Write-Log -Verbose:$VerboseMode -Message "DEFAULT_WORKSTATION=$global:DefaultWorkstation"
    Write-Log -Verbose:$VerboseMode -Message "DEFAULT_COMMIT_NUMBERS=$global:DefaultCommitNumbers"
}


function GHere {
    param (
        [switch]$NoVerbose,
        [switch]$Help,
        [string]$Place = "."
    )

    if ($Help.IsPresent) {
        Write-Log -Verbose:$VerboseMode -Message "Showing menu for 'GHere' command."
        Show-GHereHelp
        return
    }

    $VerboseMode = -not $NoVerbose.IsPresent

    Write-Log -Verbose:$VerboseMode -Message "Open directory: $Place"
    Start-Process -FilePath "explorer.exe" -ArgumentList $Place
}

function Show-GHereHelp {
    Write-Host ""
    Write-Host "GHERE: Opens a specified directory in your file explorer."
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "    GHere [-Place <directory>] [-NoVerbose] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "    -Place <directory>         The directory to open (default: current directory '.')"
    Write-Host "    -NoVerbose                 Disable log messages (verbose mode off)"
    Write-Host "    -Help                      Display this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "    GHere                      # Opens the current directory with log messages"
    Write-Host "    GHere -Place './my-folder' # Opens './my-folder' with log messages"
    Write-Host "    GHere -NoVerbose           # Opens the current directory without log messages"
    Write-Host ""
    Write-Host "Notes:"
    Write-Host "    - If no directory is specified, the current directory is opened by default."
    Write-Host "    - Verbose mode shows additional logs, such as the directory being opened."
    Write-Host ""
}

function GLog {
    param (
        [int]$Number = $global:DefaultCommitNumbers,
        [switch]$NoVerbose,
        [switch]$Help
    )
    $VerboseMode = -not $NoVerbose.IsPresent
    Write-Log -Verbose:$VerboseMode -Message "Showing last $Number commits"

    if ($Help.IsPresent) {
        Write-Log -Verbose:$VerboseMode -Message "Showing menu for 'GLog' command."
        Show-GLogHelp
        return
    }

    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Log -Verbose:$VerboseMode -Message "This directory is not a Git repository."
        return
    }

    Write-Log -Verbose:$VerboseMode -Message "Showing last $Number commits"
    git log --oneline -n $Number
}

function Show-GLogHelp {
    Write-Host ""
    Write-Host "GLOG: Display a summary of recent Git commits with customizable options."
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "    GLog [-Number <cantidad>] [-NoVerbose] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "    -Number <cantidad>         Specify the number of commits to display (default: 10)"
    Write-Host "    -NoVerbose                 Disable detailed commit information (verbose mode off)"
    Write-Host "    -Help                      Display this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "    GLog                       # Display the last 10 commits with verbose details"
    Write-Host "    GLog -Number 5             # Display the last 5 commits with verbose details"
    Write-Host "    GLog -Number 20 -NoVerbose # Display the last 20 commits without verbose details"
    Write-Host ""
    Write-Host "Notes:"
    Write-Host "    - If you provide an invalid option or value, the command will display an error message."
    Write-Host "    - Verbose mode includes additional information such as commit messages, authors, etc."
    Write-Host ""
}

function GPush {
    param (
        [switch]$NoVerbose,
        [switch]$Test,
        [switch]$Help
    )

    $VerboseMode = -not $NoVerbose.IsPresent

    if ($Help.IsPresent) {
        Write-Log -Verbose:$VerboseMode -Message "Showing menu for 'GPush' command."
        Show-GPushHelp
        return
    }

    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Log -Verbose:$VerboseMode -Message "This directory is not a Git repository."
        return
    }

    $CurrentBranch = & git symbolic-ref --short HEAD
    Write-Log -Verbose:$VerboseMode -Message "Working on current branch: $CurrentBranch"

    if ($Test.IsPresent) {
        Write-Log -Verbose:$VerboseMode -Message "Dry run mode. Changes won't be applied."
        git push --tags --dry-run origin $CurrentBranch
    } else {
        git push --tags origin $CurrentBranch
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Log -Verbose:$VerboseMode -Message "Pushed successfully to branch $CurrentBranch."
    } else {
        Write-Log -Verbose:$VerboseMode -Message "Error: Failed to push to the origin."
        return
    }
}

function Show-GPushHelp {
    Write-Host ""
    Write-Host "GPUSH: Push the current branch to the remote repository with optional tags and modes."
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "    GPush [-NoVerbose] [-Test] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "    -NoVerbose                 Suppress detailed logs (verbose mode off)"
    Write-Host "    -Test                      Execute a dry run without applying changes"
    Write-Host "    -Help                      Display this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "    GPush                      # Push the current branch with verbose logs"
    Write-Host "    GPush -NoVerbose           # Push the current branch without verbose logs"
    Write-Host "    GPush -Test                # Perform a dry run of the push without applying changes"
    Write-Host "    GPush -Help                # Display this help message"
    Write-Host ""
    Write-Host "Notes:"
    Write-Host "    - The command checks if the current directory is a Git repository before execution."
    Write-Host "    - Verbose mode provides detailed logs during execution, unless disabled with -NoVerbose."
    Write-Host "    - Use -Test for testing push commands without actually making changes."
    Write-Host ""
}

function GTtw {
    param (
        [switch]$NoVerbose,
        [switch]$Help
    )
    $VerboseMode = -not $NoVerbose.IsPresent
    $Workstation = $global:DefaultWorkstation

    if ($Help.IsPresent) {
        Write-Log -Verbose:$VerboseMode -Message "Showing menu for 'GTtw' command."
        Show-GttwHelp
        return
    }

    Write-Log -Verbose:$VerboseMode -Message "Changing directory to: $Workstation"
    Set-Location -Path $Workstation
}

function Show-GttwHelp {
    Write-Host ""
    Write-Host "GTtw: Change to the specified workstation directory."
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "    GTtw [-NoVerbose] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "    -NoVerbose                  Suppress detailed logs (verbose mode off)"
    Write-Host "    -Help                       Display this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "    GTtw                        # Change to the default workstation directory with verbose details"
    Write-Host "    GTtw -NoVerbose             # Change to the default workstation directory without verbose details"
    Write-Host "    GTtw -Help                  # Show help message for 'GTtw' command"
    Write-Host ""
    Write-Host "Notes:"
    Write-Host "    - The command will change to the specified workstation directory (default: $DEFAULT_WORKSTATION)."
    Write-Host "    - Verbose mode shows additional information, such as the directory being changed to."
    Write-Host ""
}

function GLgtm {
    param (
        [switch]$NoVerbose,
        [switch]$Help
    )

    $VerboseMode = -not $NoVerbose.IsPresent

    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Log -Verbose:$VerboseMode -Message "This directory is not a Git repository."
        return 1
    }

    if ($Help.IsPresent) {
        Write-Log -Verbose:$VerboseMode -Message "Showing menu for 'GLgtm' command."
        Show-GLgtmHelp
        return
    }

    Write-Log -Verbose:$VerboseMode -Message "This work looks good to me, I'll proceed to push to master."

    GPush
    GLog
}

function Show-GLgtmHelp {
    Write-Host "Usage: GLgtm [-NoVerbose] [-Help]"
    Write-Host ""
    Write-Host "This command performs a quick review of the work and, if everything looks good,"
    Write-Host "proceeds to perform a 'git push' and then shows the Git log."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -NoVerbose             Disables verbose mode."
    Write-Host "  -Help                  Shows this help message."
    Write-Host ""
    Write-Host "Actions performed:"
    Write-Host "  - If the -NoVerbose option is not specified, the command provides additional information"
    Write-Host "    during the process, including a confirmation message."
    Write-Host "  - If the -NoVerbose option is specified, detailed messages are omitted."
    Write-Host "  - Performs a 'git push' to the 'master' branch and then runs 'git log'."
}

function GMaster {
    param (
        [switch]$NoVerbose,
        [switch]$Help
    )

    $VerboseMode = -not $NoVerbose.IsPresent
    $MainBranch = ""

    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Log -Verbose:$VerboseMode -Message "This directory is not a Git repository."
        return 1
    }

    $branches = git branch
    if ($branches | Select-String -Pattern "main") {
        $MainBranch = "main"
    } elseif ($branches | Select-String -Pattern "master") {
        $MainBranch = "master"
    } else {
        Write-Log -Verbose:$VerboseMode -Message "Error: Neither 'main' nor 'master' branches found."
        return 1
    }

    if ($Help.IsPresent) {
        Write-Log -Verbose:$VerboseMode -Message "Showing menu for 'GMaster' command."
        Show-GMasterHelp
        return
    }

    # Verificar si hay cambios pendientes
    Write-Log -Verbose:$VerboseMode -Message "Checking for uncommitted changes..."
    $status = git status --porcelain
    if ($status) {
        Write-Host "Error: You have uncommitted changes. Please commit or stash them before running this command."
        return 1
    }

    # Cambiar a la rama principal
    Write-Log -Verbose:$VerboseMode -Message "Switching to the '$MainBranch' branch..."
    git checkout "$MainBranch" || {
        Write-Host "Error: Could not switch to '$MainBranch' branch."
        return 1
    }

    # Hacer un git pull
    Write-Log -Verbose:$VerboseMode -Message "Pulling the latest changes from '$MainBranch'..."
    git pull || {
        Write-Host "Error: Could not pull changes from '$MainBranch'."
        return 1
    }

    # Ejecutar el comando gl con verbose por defecto
    Write-Log -Verbose:$VerboseMode -Message "Executing 'GLog' command with verbose mode..."
    GLog
}

function Show-GMasterHelp {
    Write-Host ""
    Write-Host "GMaster: Updates and synchronizes the local 'master' branch."
    Write-Host ""
    Write-Host "Usage: GMaster [-NoVerbose] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -NoVerbose             Disable verbose mode for minimal output."
    Write-Host "  -Help                  Show this help message."
    Write-Host ""
    Write-Host "This command ensures that the local 'master' branch is up-to-date with the latest changes from the remote repository."
    Write-Host "It checks for uncommitted changes, switches to the 'master' branch, performs a pull from the remote, and then runs the 'GLog' command."
    Write-Host ""
}

function GHelp {
    Write-Host ""
    Write-Host "EASYGIT is a library of commands to simplify your workflow"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host ""
    Write-Host "GHere: Opens the current directory in your file explorer. Use '-Help' for details."
    Write-Host "GLog: Displays a summary of recent Git commits. Use '-Help' for details."
    Write-Host "GPush: Pushes your changes to the remote repository. Use '-Help' for details."
    Write-Host "GTtw: Changes directory to the specified workstation directory. Use '-Help' for details."
    Write-Host "GLgtm: Pushes your changes directly to the master branch and then shows the Git log. Use '-Help' for details."
    Write-Host "GMaster: Updates and synchronizes the local 'master' branch with the remote repository. Use '-Help' for details."
    Write-Host ""
}

Initialize-EasyGit