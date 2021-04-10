{ pkgs ? import <nixpkgs> { } }:
pkgs.writeShellScriptBin "pkg" ''
  set -euf -o pipefail
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
  
  if [ $# == 0 ]; then
    COMMAND=" "
  else
    COMMAND="$1";shift
  fi

  case "$COMMAND" in
      install)
          if [ $# == 0 ]; then
            error no package specified for install
          fi
          nix-env -iA "$1" -f '<nixpkgs>'
      ;;
      list)
          nix-env --query
      ;;
      update)
          pushd ~/.dotfiles
              nix flake update --update-input nixpkgs
          popd
      ;;
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
      uninstall)
          if [ $# == 0 ]; then
            pkg uninstall $(pkg list | dmenu) || error no package to uninstall
          fi
          nix-env --uninstall "$@"
      ;;
      show)
        if [ $# == 0 ]; then
          error no package specified to show
        fi

        PKGNAME="$1";shift
        JSON="$(nix eval --impure --expr "with import <nixpkgs> {}; pkgs.$PKGNAME.meta" --json)"

        function jsonkey {
            echo "$JSON" | jq -r "$@"
        }
        function exists {
            [ ! "$(echo "$JSON" | jq -r "if .$1 == null then \"\" else .$1 end")" == "" ]
        }
        
        function jsonflag {
            printf "$(bold $(jsonkey "select(.$1) | \"$1 \""))"
        }

        echo "$(bold $PKGNAME)"
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
    *)
      usage
      error no arguments specified
    ;;
  esac
''
