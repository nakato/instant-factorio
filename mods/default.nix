{ lib, fetchurl, callPackage, stdenv, zip, fetchFromGitHub
, factorio-utils
, allRecommendedMods ? true
, allOptionalMods ? false
}:
with lib;
let
  bobsmods = callPackage ./bobs.nix { };
  angelsmods = callPackage ./angels.nix {};
  modDrv = factorio-utils.modDrv { inherit allRecommendedMods allOptionalMods; };
  fetchFactorioMod = args: ((fetchurl args).overrideAttrs (o: {
    preHook = ''
      # Don't attempt to fetch from dl-mod.factorio.com, the endpoint requires auth.
      # Fail so we pretty print a failure
      exit 1
    '';
    failureHook = ''
      cat << EOF
      Resource is behind authentication, you must fetch and add to store manually.
      Fetch resource from:
        ${builtins.head o.urls}
      Then add to store with:
        nix-prefetch-url file://\''$HOME/Downloads/${o.name} --name ${o.name}
      EOF
    '';
  }));
in
rec {
  inherit (bobsmods) bobassembly bobclasses bobelectronics bobenemies bobequipment bobgreenhouse bobinserters boblibrary boblogistics bobmining bobmodules bobores bobplates bobpower bobrevamp bobtech bobvehicleequipment bobwarfare;
  inherit (angelsmods) angelsaddons-cab angelsaddons-mobility angelsaddons-nilaus angelsaddons-shred angelsaddons-storage angelsbioprocessing angelsindustries angelsinfiniteores angelspetrochem angelsrefining angelssmelting;

  discoScience = stdenv.mkDerivation {
    name = "DiscoScience";
    src = fetchFromGitHub {
      owner = "danielbrauer";
      repo = "DiscoScience";
      rev = "937e1858d137a0bdc26ce37b1246e3c530a878a4";
      hash = "sha256-XguzRHI471HtCShBEILNNFpsVWPEo1x7Gqgs9jpGkKY=";
    };
    nativeBuildInputs = [ zip ];
    buildPhase = ''
      mkdir DiscoScience_1.1.3
      cp -r info.json thumbnail.png changelog.txt locale src/* DiscoScience_1.1.3/
      find DiscoScience_1.1.3 | zip -@ DiscoScience_1.1.3.zip
    '';
    installPhase = ''
      mkdir -p $out
      cp DiscoScience_1.1.3.zip $out/
    '';
    deps = [];
  };

  factorissimo-2-notnotmellon = let
    zipname = "factorissimo-2-notnotmelon_1.2.3.zip";
  in stdenv.mkDerivation {
    name = "factorissimo-2-notnotmelon";
    src = ./blobs + "/${zipname}";
    dontUnpack = true;
    buildPhase = ''
      mkdir -p $out
      cp $src $out/${zipname}
    '';
    deps = [];
  };
  rso-mod = let
    zipname = "rso-mod_6.2.23.zip";
  in stdenv.mkDerivation {
    name = "rso-mod";
    src = ./blobs + "/${zipname}";
    dontUnpack = true;
    buildPhase = ''
      mkdir -p $out
      cp $src $out/${zipname}
    '';
    deps = [];
  };
}
