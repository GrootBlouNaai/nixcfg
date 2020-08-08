{ pkgs, ... }:
let
  cfg = import ../config.nix;
in
{
  allowUnfree = cfg.allowUnfree;
  packageOverrides = import ../apps;
}
