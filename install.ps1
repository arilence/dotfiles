# Symlinks on Windows require administrator privileges
# This will reopen the script in an elevated shell if the current shell has insufficient privileges.
if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  # Get the path of the currently running PowerShell executable
  $psPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
  $currentArgs = $args -join ' '
  Start-Process -FilePath $psPath -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`" --no-color $currentArgs"
  Exit
}

function wait-before-exit {
    # If running in the console, wait for input before closing.
    if ($Host.Name -eq "ConsoleHost") {
        Write-Host "Press any key to continue..."
        # Make sure buffered input doesn't "press a key" and skip the ReadKey()
        $Host.UI.RawUI.FlushInputBuffer()
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
    }
}

# Load secrets
$Env:SOPS_AGE_KEY = "op://Personal/SOPS Age Key/password"

$ErrorActionPreference = "Stop"

$CONFIG = "install.conf.yaml"
$DOTBOT_DIR = "dotbot"

$DOTBOT_BIN = "bin/dotbot"
$BASEDIR = $PSScriptRoot

Set-Location $BASEDIR
git submodule update --recursive --remote
git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --recursive $DOTBOT_DIR

winget import --no-upgrade --accept-package-agreements --accept-source-agreements -i winget.json
if ($LastExitCode -ne 0) {
    Write-Error "Error: Winget install failed."
    wait-before-exit
    return
}

# Reload environment after installing applications with winget
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

foreach ($PYTHON in ('python', 'python3')) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (& { $ErrorActionPreference = "SilentlyContinue"
            ![string]::IsNullOrEmpty((&$PYTHON -V))
            $ErrorActionPreference = "Stop" }) {
        # Run dotbot
        # 1Password by default buffers command execution, which results in a confusing blank screen for the entire dotbot installation.
        # `--no-masking` "fixes" this issue but creates another issue of potentially leaking secrets (Haven't seen any leaked yet)
        op run --no-masking -- $PYTHON $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN) -d $BASEDIR -c $CONFIG `
        --plugin-dir dotbot-crossplatform `
        --plugin-dir dotbot-scoop `
        $Args
        wait-before-exit
        return
    }
}
Write-Error "Error: Cannot find Python."
