{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./dconf.nix
    ./git.nix
    ./htop.nix
    ./neovim
    ./tmux
    ./vscode
    ./rofi.nix
    ./compression.nix
  ];
}
