{ fetchFromGitHub
, python3
, stdenv
, zip
, factorio-utils
, allRecommendedMods ? true
, allOptionalMods ? false
, ...
}:
let
  bobsPack = stdenv.mkDerivation {
    name = "bobsmods-collection";
    preferLocalBuild = true;
    nativeBuildInputs = [ python3 zip ];
    src = fetchFromGitHub {
      owner = "modded-factorio";
      repo = "bobsmods";
      rev = "bf2d70e5dc976952bad3a4d364db54bf7616768d";
      hash = "sha256-Z8O544LDBL6QA73RNG26FO3ZxXyVtSnJ1TO+npLY56s=";
    };
    buildPhase = ''
      mkdir -p $out/mods
      python3 ./bob_mod_builder.py -m $out
      cd $out/mods
      for mod in *; do
        find $mod | zip -@ $mod.zip
      done
      mv *.zip $out/
      cd $out
      rm -rf mods
    '';
  };
  mkBobMod = name: version: stdenv.mkDerivation {
    name = "bob${name}";
    inherit version;
    src = bobsPack;
    preferLocalBuild = true;
    buildPhase = ''
      mkdir -p $out
      cp $src/bob${name}_${version}.zip $out/
    '';
    # FIXME: deps
    deps = [];
  };
in
{
  bobassembly = mkBobMod "assembly" "1.1.6";
  bobclasses = mkBobMod "classes" "1.1.5";
  bobelectronics = mkBobMod "electronics" "1.1.6";
  bobenemies = mkBobMod "enemies" "1.1.6";
  bobequipment = mkBobMod "equipment" "1.1.6";
  bobgreenhouse = mkBobMod "greenhouse" "1.1.6";
  bobinserters = mkBobMod "inserters" "1.1.7";
  boblibrary = mkBobMod "library" "1.1.6";
  boblogistics = mkBobMod "logistics" "1.1.6";
  bobmining = mkBobMod "mining" "1.1.6";
  bobmodules = mkBobMod "modules" "1.1.6";
  bobores = mkBobMod "ores" "1.1.6";
  bobplates = mkBobMod "plates" "1.1.6";
  bobpower = mkBobMod "power" "1.1.7";
  bobrevamp = mkBobMod "revamp" "1.1.6";
  bobtech = mkBobMod "tech" "1.1.6";
  bobvehicleequipment = mkBobMod "vehicleequipment" "1.1.6";
  bobwarfare = mkBobMod "warfare" "1.1.6";
}
