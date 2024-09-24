{ pkgs }:
let
  inherit (builtins) length concatStringsSep;
  inherit (pkgs) lib cabextract writeShellScriptBin;
  inherit (lib) makeBinPath;
in
{
  # Main configuration parameters
  # This section defines the primary parameters that control the behavior of the script.
  # - is64bits: Determines if the script should use 64-bit or 32-bit Wine.
  # - wine: Specifies the Wine package to use, defaulting to 64-bit or 32-bit based on is64bits.
  # - wineFlags: Additional flags to pass to the Wine executable.
  # - executable: The main executable to run within the Wine environment.
  # - chdir: Directory to change to before running the executable.
  # - name: Name of the script and the Wine prefix.
  # - tricks: List of Winetricks to apply during setup.
  # - setupScript: Custom setup script to run during initialization.
  # - firstrunScript: Custom script to run on the first run of the Wine prefix.
  # - home: Custom home directory for the Wine environment.
  is64bits ? false,
  wine ? if is64bits then pkgs.wineWowPackages.stable else pkgs.wine,
  wineFlags ? "",
  executable,
  chdir ? null,
  name,
  tricks ? [ ],
  setupScript ? "",
  firstrunScript ? "",
  home ? "",
}:
let
  # Wine binary path
  # This variable constructs the path to the Wine binary based on whether the system is 64-bit or 32-bit.
  wineBin = "${wine}/bin/wine${if is64bits then "64" else ""}";

  # Required packages
  # Lists the necessary packages for the script to function, including Wine and cabextract.
  requiredPackages = [
    wine
    cabextract
  ];

  # Environment variables
  # Defines various environment variables used throughout the script.
  WINENIX_PROFILES = "$HOME/WINENIX_PROFILES";
  PATH = makeBinPath requiredPackages;
  NAME = name;
  HOME = if home == "" then "${WINENIX_PROFILES}/${name}" else home;
  WINEARCH = if is64bits then "win64" else "win32";

  # Setup hook
  # This hook initializes the Wine environment by running wineboot.
  setupHook = ''
    ${wine}/bin/wineboot
  '';

  # Winetricks hook
  # This section constructs a command to apply Winetricks if any are specified.
  tricksHook =
    if (length tricks) > 0 then
      let
        tricksStr = concatStringsSep " " tricks;
        tricksCmd = ''
          pushd $(mktemp -d)
            wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
            chmod +x winetricks
            ./winetricks ${tricksStr}
          popd
        '';
      in
      tricksCmd
    else
      "";

  # Main script generation
  # This section generates the main shell script that sets up and runs the Wine environment.
  script = writeShellScriptBin name ''
    export APP_NAME="${NAME}"
    export WINEARCH=${WINEARCH}
    export WINE_NIX="$HOME/.wine-nix" # define antes de definir $HOME senão ele vai gravar na nova $HOME a .wine-nix
    export WINE_NIX_PROFILES="${WINENIX_PROFILES}"
    export PATH=$PATH:${PATH}
    export HOME="${HOME}"
    mkdir -p "$HOME"
    export WINEPREFIX="$WINE_NIX/${name}"
    export EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX" "$WINE_NIX_PROFILES"
    ${setupScript}
    if [ ! -d "$WINEPREFIX" ] # if the prefix does not exist
    then
      ${setupHook}
      # ${wineBin} cmd /c dir > /dev/null 2> /dev/null # initialize prefix
      wineserver -w
      ${tricksHook}
      rm "$WINEPREFIX/drive_c/users/$USER" -rf
      ln -s "$HOME" "$WINEPREFIX/drive_c/users/$USER"
      ${firstrunScript}
    fi
    ${if chdir != null then ''cd "${chdir}"'' else ""}
    if [ ! "$REPL" == "" ]; # if $REPL is setup then start a shell in the context
    then
      bash
      exit 0
    fi

    ${wineBin} ${wineFlags} "$EXECUTABLE" "$@"
    wineserver -w
  '';
in
script
