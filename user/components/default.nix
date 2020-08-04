{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./dconf.nix
    ./git.nix
    ./htop.nix
    ./neovim
    ./tmux
    ./vscode.nix
    ./rofi.nix
    ./compression.nix
    ./windows.nix
  ];
}
