{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./compression.nix
    ./dconf.nix
    ./ets2.nix
    ./git.nix
    ./htop.nix
    ./kdeconnect.nix
    ./mspaint.nix
    ./neovim
    ./pinball.nix
    ./rclone.nix
    ./rofi.nix
    ./spotify.nix
    ./stremio.nix
    ./tmux
    ./usb_tixati.nix
    ./vscode
  ];
}
