{ pkgs, config, ... }:
{
  imports = import <dotfiles/overlays/utils/lsName.nix> ./components;

  manual.manpages.enable = false;

  home.packages =
    let
      defaultPackages =
        with pkgs; [
          fortune
          calibre
          neofetch
          file
          arduino
          heroku
          lazydocker
          nix-index
          scrcpy
          sqlite
          libnotify
        ];
      customPackages =
        with pkgs; [
          usb_tixati
          minecraft
          ets2
          mspaint
          pinball
          documentNode
        ];
      masterPackages =
        with pkgs; [
          tdesktop
          youtube-dl
        ];
    in
    defaultPackages ++ customPackages ++ masterPackages;

  programs = {
    command-not-found.enable = true;
    jq.enable = true;
    obs-studio = {
      enable = true;
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  home.stateVersion = "20.03";
}
