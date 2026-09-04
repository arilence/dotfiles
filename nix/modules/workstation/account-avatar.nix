{ config, ... }:

let
  accountAvatar = ../../assets/avatar.png;
  userName = config.users.users.anthony.name;
in
{
  # AccountsService provides this account picture to display managers and
  # desktop environments, including both Noctalia Greeter and GNOME.
  systemd.tmpfiles.rules = [
    "f+ /var/lib/AccountsService/users/${userName} 0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${userName}\\n"
    "L+ /var/lib/AccountsService/icons/${userName} - - - - ${accountAvatar}"
  ];
}
