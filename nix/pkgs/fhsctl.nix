{
  pkgs ? import <nixpkgs> { },
}:
let
  script = "''\"$cmd\" \"\$@\"''";
in
pkgs.writeShellScriptBin "fhsctl" ''
  # Main script execution
  # This script is designed to create and manage a FHS (Filesystem Hierarchy Standard) environment
  # for running commands with specific packages. It allows users to specify packages and a command
  # to be executed within this environment.
  #
  # Usage:
  #   $0 [...packages] -- command [...arguments]
  #
  # Parameters:
  #   [...packages]: A list of Nix packages to include in the FHS environment.
  #   command: The command to be executed within the FHS environment.
  #   [...arguments]: Arguments to be passed to the command.
  #
  # Example:
  #   $0 pkg1 pkg2 -- mycommand --arg1 --arg2
  #
  # Important considerations:
  # - The script uses a temporary Nix expression file to define the FHS environment.
  # - The FHS environment is created using `buildFHSUserEnv` from Nixpkgs.
  # - The script handles errors and provides a help message if the command fails.

  set -eu -o pipefail

  # Help function
  # Displays usage information and exits with a non-zero status code.
  # This function is invoked when the script encounters an error or when the user requests help.

  function help {
      echo "$0 [...packages] -- command [...arguments]"
      exit 1
  }

  # Exit handler function
  # This function is triggered on script exit. It checks the exit status and invokes the help function
  # if the exit status is non-zero, indicating an error.

  function exitHandler {
      [ "0" != "$?" ] && help
  }

  trap 'exitHandler' exit

  # Package collection loop
  # Collects the list of packages to be included in the FHS environment.
  # The loop continues until it encounters the delimiter "--" which separates packages from the command.

  packages=""
  while [ ! "$1" == "--" ]
  do
      packages="$packages $1"
      shift
  done
  shift # ignore --

  # Temporary file creation
  # Creates a temporary file to store the Nix expression that defines the FHS environment.
  # The file is used to instantiate and build the FHS environment.

  tempfile=$(mktemp /tmp/fhsctl-XXXXXX.nix)
  cmd="$(readlink $(which $1) -m)";shift
  fhsname="fhsctl-$RANDOM"

  echo $tempfile

  # Error handling
  # Disables the error trap temporarily to allow the script to proceed even if an error occurs.
  # This is necessary to avoid premature termination during the Nix expression generation.

  trap - ERR

  # Nix expression generation
  # Writes the Nix expression to the temporary file. The expression defines the FHS environment
  # using `buildFHSUserEnv` and includes the specified packages and command.

  echo 'with import <nixpkgs> {};' >> $tempfile
  echo 'buildFHSUserEnv {' >> $tempfile
  echo "name = \"$fhsname\";" >> $tempfile
  echo "targetPkgs = pkgs: with pkgs; [" >> $tempfile
  echo "$packages" >> $tempfile
  echo "];" >> $tempfile
  echo "runScript = ${script};" >> $tempfile
  echo "}" >> $tempfile

  # FHS environment instantiation and execution
  # Instantiates the FHS environment using `nix-instantiate` and `nix-store -r`.
  # The resulting environment is then used to execute the specified command with its arguments.

  out=$(nix-store -r $(nix-instantiate $tempfile))

  $out/bin/$fhsname "$@"
''
