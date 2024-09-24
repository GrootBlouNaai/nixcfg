{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) writeShellScriptBin;
in
writeShellScriptBin "pkg" ''
    # Script initialization
    # This script is a convenient wrapper around nix-env, providing additional functionalities:
    # - Installation and uninstallation of packages
    # - Listing installed packages
    # - Updating nixpkgs version in a flake
    # - Updating specific flake inputs
    # - Displaying detailed information about a package
    # The script uses ANSI escape codes for formatting output.

    set -euf -o pipefail

    # Utility functions for text formatting
    # These functions are used to format text output in the terminal:
    # - `bold`: Makes the text bold
    # - `red`: Colors the text red
    # - `error`: Displays an error message in red and exits the script

    function bold {
        echo -e "$(tput bold)$@$(tput sgr0)"
    }
    function red {
        echo -e "\033[0;31m$@\033[0m"
    }
    function error {
      echo -e "$(red error): $*"
      exit 1
    }

    # Usage information
    # This function provides a detailed description of the script's usage,
    # including available commands and their purposes.

    function usage {
  echo "$(bold "$0"): Convenient wrapper around nix-env
  - $(bold "install"): install given package name
  - $(bold "list"): list installed packages by nix-env
  - $(bold "update"): bump nixpkgs version in flake
  - $(bold "update-inputs"): bump given flake input
  - $(bold "uninstall"): uninstall given package
  - $(bold "show"): show information about a given package
  "
    }

    # Command parsing
    # This section checks if any command is provided and assigns it to the `COMMAND` variable.
    # If no command is provided, it defaults to an empty string.

    if [ $# == 0 ]; then
      COMMAND=" "
    else
      COMMAND="$1";shift
    fi

    # Command execution
    # This section handles the execution of different commands based on the value of `COMMAND`.
    # Each case corresponds to a specific functionality of the script.

    case "$COMMAND" in
        # Package installation
        # Installs the specified package using `nix-env`.
        # If no package is specified, it raises an error.

        install)
            if [ $# == 0 ]; then
              error no package specified for install
            fi
            PACKAGE="$1"; shift
            nix-env -iA "$PACKAGE" -f '<nixpkgs>' "$@"
        ;;

        # List installed packages
        # Lists all installed packages using `nix-env`.

        list)
            nix-env --query
        ;;

        # Update nixpkgs version in flake
        # Updates the nixpkgs version in the flake located at `~/.dotfiles`.

        update)
            pushd ~/.dotfiles
                nix flake update --update-input nixpkgs
            popd
        ;;

        # Update specific flake inputs
        # Updates the specified flake inputs located at `~/.dotfiles`.
        # If no input is specified, it raises an error.

        update-inputs)
            if [ $# == 0 ]; then
              error no input specified
            fi
            pushd ~/.dotfiles
                for input in "$@"
                do
                    nix flake update --update-input $input
                done
            popd
        ;;

        # Uninstall package
        # Uninstalls the specified package using `nix-env`.
        # If no package is specified, it prompts the user to select one using `dmenu`.

        uninstall)
            if [ $# == 0 ]; then
              PKG="$(pkg list | dmenu 2> /dev/null)" 2> /dev/null ||  error no package to uninstall
              pkg uninstall "$PKG"
            fi
            nix-env --uninstall "$@"
        ;;

        # Show package information
        # Displays detailed information about the specified package.
        # If no package is specified, it raises an error.

        show)
          if [ $# == 0 ]; then
            error no package specified to show
          fi

          PKGNAME="$1";shift
          JSON="$(nix eval --impure --expr "with import <nixpkgs> {}; pkgs.$PKGNAME.meta // {inherit ({version = \"not defined\";} // pkgs.$PKGNAME) version;}" --json)"

          function jsonkey {
              echo "$JSON" | jq -r "$@"
          }
          function exists {
              [ ! "$(echo "$JSON" | jq -r "if .$1 == null then \"\" else .$1 end")" == "" ]
          }
        
          function jsonflag {
              printf "$(bold $(jsonkey "select(.$1) | \"$1 \""))"
          }

          echo "$(bold $PKGNAME) ($(jsonkey ".version"))"
          exists  description && echo -e "$(jsonkey ".description")"
          exists longDescription && echo -e "\n$(jsonkey ".longDescription")"

          printf "\n$(bold "flags"): "
          jsonflag unfree
          jsonflag insecure
          jsonflag available
          jsonflag broken
          jsonflag unsupported

          printf "\n"

          exists licenses && echo "$(tput bold)licenses$(tput sgr0): $(jsonkey '.license | map(.shortName) | join(" ")')"
          exists homepage && echo "$(tput bold)homepage$(tput sgr0): $(jsonkey .homepage)"

          exists platforms && echo "$(tput bold)platforms$(tput sgr0): $(jsonkey '.platforms | join(" ")')"

          echo -e "\n$(bold "Defined at"): $(jsonkey .position)"
      ;;

      # Default case
      # If an unknown command is provided, it displays the usage information and raises an error.

      *)
        usage
        error no arguments specified
      ;;
    esac
''
