{ fetchFromGitHub
, rsync
, stdenv
, zip
, factorio-utils
, allRecommendedMods ? true
, allOptionalMods ? false
, ...
}:
let
  angelsPack = stdenv.mkDerivation {
    name = "angels-collection";
    preferLocalBuild = true;
    nativeBuildInputs = [ rsync zip ];
    src = fetchFromGitHub {
      owner = "Arch666Angel";
      repo = "mods";
      rev = "v1.1.2a";
      hash = "sha256-y3y0mbG4dxoSHJ+53W/5z/ffpUm1D4ICkGsfIfOuHtg=";
    };
    buildPhase = ''
      bash build_angelmods.sh
    '';
    installPhase = ''
      mkdir -p $out
      cp *.zip $out/
    '';
  };
  mkAngelsMod = name: version: stdenv.mkDerivation {
    name = "angel${name}";
    inherit version;
    src = angelsPack;
    preferLocalBuild = true;
    buildPhase = ''
      mkdir -p $out
      cp $src/angels${name}_${version}.zip $out/
    '';
    # FIXME: deps
    deps = [];
  };
in
{
  angelsaddons-cab = mkAngelsMod "addons-cab" "0.2.8";
  angelsaddons-liquidrobot = mkAngelsMod "addons-liquidrobot" "0.2.1"; # Not on mod portal
  angelsaddons-mobility = mkAngelsMod "addons-mobility" "0.0.11";
  angelsaddons-nilaus = mkAngelsMod "addons-nilaus" "0.3.13";
  angelsaddons-shred = mkAngelsMod "addons-shred" "0.2.8";
  angelsaddons-storage = mkAngelsMod "addons-storage" "0.0.10";
  angelsbioprocessing = mkAngelsMod "bioprocessing" "0.7.24";
  angelsdev-unit-test = mkAngelsMod "dev-unit-test" "0.0.1";
  angelsexploration = mkAngelsMod "exploration" "0.3.15";
  angelsindustries = mkAngelsMod "industries" "0.4.18";
  angelsinfiniteores = mkAngelsMod "infiniteores" "0.9.10";
  angelspetrochem = mkAngelsMod "petrochem" "0.9.24";
  angelsrefining = mkAngelsMod "refining" "0.12.4";
  angelssmelting = mkAngelsMod "smelting" "0.6.21";
}
