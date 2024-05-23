# Symlinks on Windows require administrator privileges
# This will reopen the script in an elevated shell if the current shell has insufficient privileges.
if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  # Get the path of the currently running PowerShell executable
  $psPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
  $currentArgs = $args -join ' '
  Start-Process -FilePath $psPath -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`" --no-color $currentArgs"
  Exit
}

$ErrorActionPreference = "Stop"

$CONFIG = "install.conf.yaml"
$DOTBOT_DIR = "dotbot"

$DOTBOT_BIN = "bin/dotbot"
$BASEDIR = $PSScriptRoot

Set-Location $BASEDIR
git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --recursive $DOTBOT_DIR

foreach ($PYTHON in ('python', 'python3')) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (& { $ErrorActionPreference = "SilentlyContinue"
            ![string]::IsNullOrEmpty((&$PYTHON -V))
            $ErrorActionPreference = "Stop" }) {
        # Run dotbot
        &$PYTHON $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN) -d $BASEDIR -c $CONFIG --plugin-dir dotbot-crossplatform $Args
        # If running in the console, wait for input before closing.
        if ($Host.Name -eq "ConsoleHost") {
            Write-Host "Press any key to continue..."
            # Make sure buffered input doesn't "press a key" and skip the ReadKey()
            $Host.UI.RawUI.FlushInputBuffer()
            $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
        }
        return
    }
}
Write-Error "Error: Cannot find Python."
