# Powershell Set-Alias doesn't support commands with arguments,
# Using a function with `[alias]` is the recommended workaround.
function ls-to-eza {
  [alias('ls')]
  param(
    # Passes all arguments to eza command
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
  )

  eza.exe --group-directories-first $Passthrough
}

function lazygit {
  [alias('lg')]
  param(
    # Passes all arguments to lazygit command
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
  )

  lazygit.exe $Passthrough
}

function neovim {
  [alias('vim')]
  param(
    # Passes all arguments to neovim command
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
  )

  nvim.exe $Passthrough
}

function git-diff {
  [alias('gd')]
  param(
    # Passes all arguments to command
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
  )

  git.exe diff $Passthrough
}

function git-status {
  [alias('gs')]
  param(
    # Passes all arguments to command
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
  )

  git.exe status $Passthrough
}

function git-commit {
  param(
    # Passes all arguments to command
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
  )

  git.exe commit $Passthrough
}
# `gc` is already an alias for `Get-Content`. Setting -Force overwrites the alias.
Set-Alias -Name gc -Value git-commit -Force

function git-log {
  param(
    # Passes all arguments to command
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
  )

  git.exe log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $Passthrough
}
# `gl` is already an alias for `Get-Location`. Setting -Force overwrites the alias.
Set-Alias -Name gl -Value git-log -Force

# Adds Make to PATH
$env:PATH += ";C:\Program Files (x86)\GnuWin32\bin"
