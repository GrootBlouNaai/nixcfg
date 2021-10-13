flake: self: super:
let
  cfg = flake.outputs.extraArgs.cfg;
  recursiveUpdate = super.lib.recursiveUpdate;
  cp = f: (super.callPackage f) {};
  dotenv = cp flake.inputs.dotenv;
  wrapDotenv = (file: script:
    let
      dotenvFile = ((toString cfg.rootPath) + "/secrets/" + (toString file));
      command = super.writeShellScript "dotenv-wrapper" script;
    in ''
      ${dotenv}/bin/dotenv "@${toString dotenvFile}" -- ${command} "$@"
    '');

  reduceJoin = items:
    if (builtins.length items) > 0 then
      (recursiveUpdate (builtins.head items) (reduceJoin (builtins.tail items)))
    else
    {};
in reduceJoin [
  super
  rec {
    # gambeta, mudar depois
    electron_13 = super.electron;

    inherit dotenv;
    inherit wrapDotenv;

    lib = {
      inherit reduceJoin;
      maintainers = import "${flake.inputs.nixpkgsLatest}/maintainers/maintainer-list.nix";
    };
    latest = import flake.inputs.nixpkgsLatest {};
    p2k = cp flake.inputs.pocket2kindle;
    redial_proxy = cp flake.inputs.redial_proxy;
    send2kindle = cp flake.inputs.send2kindle;
    comma = cp flake.inputs.comma;
    wrapVSCode = args: import flake.inputs.nix-vscode (args // {pkgs = super;});
    discord = cp "${flake.inputs.nixpkgsLatest}/pkgs/applications/networking/instant-messengers/discord/default.nix";
    dart = cp "${flake.inputs.nixpkgsLatest}/pkgs/development/interpreters/dart/default.nix";
    hugo = cp "${flake.inputs.nixpkgsLatest}/pkgs/applications/misc/hugo/default.nix";
    flutter = (cp "${flake.inputs.nixpkgsLatest}/pkgs/development/compilers/flutter/default.nix").stable;
    tor-browser-bundle-bin = (cp "${flake.inputs.nixpkgsLatest}/pkgs/applications/networking/browsers/tor-browser-bundle-bin/default.nix");
    obsidian = (cp "${flake.inputs.nixpkgsLatest}/pkgs/applications/misc/obsidian/default.nix");
    ventoy-bin = cp "${flake.inputs.nixpkgsLatest}/pkgs/tools/cd-dvd/ventoy-bin/default.nix";
    arcan = cp ./packages/arcan.nix;
    c4me = cp ./packages/c4me;
    encore = cp ./packages/encore.nix;
    xplr = cp ./packages/xplr.nix;
    personal-utils = cp ./packages/personal-utils.nix;
    nixwrap = cp ./packages/nixwrap.nix;
    custom_neovim = cp ./packages/neovim/package.nix;
    wineApps = {
      wine7zip = cp ./packages/wineApps/7zip.nix;
      cs_extreme = cp ./packages/wineApps/cs_extreme.nix;
      dead_space = cp ./packages/wineApps/dead_space.nix;
      gta_sa = cp ./packages/wineApps/gta_sa.nix;
      among_us = cp ./packages/wineApps/among_us.nix;
      ets2 = cp ./packages/wineApps/ets2.nix;
      mspaint = cp ./packages/wineApps/mspaint.nix;
      pinball = cp ./packages/wineApps/pinball.nix;
      sosim = cp ./packages/wineApps/sosim.nix;
      tora = cp ./packages/wineApps/tora.nix;
      nfsu2 = cp ./packages/wineApps/nfsu2.nix;
      flatout2 = cp ./packages/wineApps/flatout2.nix;
      watchdogs2 = cp ./packages/wineApps/watchdogs2.nix;
      rimworld = cp ./packages/wineApps/rimworld.nix;
    };
    fhsctl = cp ./packages/fhsctl.nix;
    comby = cp ./packages/comby.nix;
    custom = {
      ncdu = cp ./packages/custom/ncdu.nix;
      neovim = cp ./packages/custom/neovim;
      rofi = cp ./packages/custom/rofi.nix;
      tixati = cp ./packages/custom/tixati.nix;
      vscode = cp ./packages/custom/vscode;
      send2kindle = cp ./packages/custom/send2kindle.nix;
    };
    minecraft = cp ./packages/minecraft.nix;
    peazip = cp ./packages/peazip.nix;
    pkg = cp ./packages/pkg.nix;
    stremio = cp ./packages/stremio.nix;
    wrapWine = cp ./packages/wrapWine.nix;
    preload = cp ./packages/preload.nix;
    python3Packages = cp ./packages/python3Packages.nix;
    nodePackages = cp ./modules/node_clis/package_data/default.nix;

    nur = import flake.inputs.nur {
      inherit (super) pkgs;
      nurpkgs = super.pkgs;
    };
  }
]
