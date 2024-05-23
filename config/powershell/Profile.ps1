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
