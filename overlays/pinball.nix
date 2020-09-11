self: super:
with super;
# FIXME: Can't hear that lovely music and the sound effects
let
  pinball = pkgs.stdenv.mkDerivation rec {
    name = "mspinball";
    version = "1.0";
    src = pkgs.fetchurl {
      url = "https://archive.org/download/SpaceCadet_Plus95/Space_Cadet.rar";
      sha256 = "3cc5dfd914c2ac41b03f006c7ccbb59d6f9e4c32ecfd1906e718c8e47f130f4a";
    };
    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];
    unpackPhase = ''
      mkdir -p $out/share/mspinball
      cd $out/share/mspinball && ${pkgs.unrar}/bin/unrar x ${src}
    '';
    installPhase = ''
      makeWrapper ${pkgs.wineWowPackages.stable}/bin/wine $out/bin/pinball \
      --add-flags "$out/share/mspinball/PINBALL.exe" \
      # sed -i 's/WaveOutDevice=0/WaveOutDevice=1/' $out/share/mspinball/WAVEMIX.INF
    '';
  };
in
{
  pinball = pkgs.makeDesktopItem {
    name = "Pinball";
    desktopName = "Pinbal - Space Cadet";
    type = "Application";
    exec = "${pinball}/bin/pinball";
  };
}
