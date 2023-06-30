{
  inputs = { 
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , ...
    }@attrs:
    let
      nixosSystemModules = [
        {
          nixpkgs.overlays = [];
        }
      ];
      nixosSystem =
        { modules
        , specialArgs ? {}
        , ...
        }@config: nixpkgs.lib.nixosSystem (
          config
          // {
            specialArgs = attrs // specialArgs;
            modules = modules ++ nixosSystemModules;
          }
          );
    in
    {
      nixosConfigurations = {
        vultr = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ nixpkgs, ... }:
            {
              imports = [
                "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
              ];
              boot.loader.grub.device = "/dev/vda";
              boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
              boot.initrd.kernelModules = [ "nvme" ];
              fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };
            })

            ({config, lib, pkgs, ...}: {
              system.stateVersion = lib.mkDefault "22.11";
              boot.tmp.cleanOnBoot = true;
              zramSwap.enable = true;
              networking.hostName = "vultr";
              networking.domain = "guest";
              services.openssh.enable = true;
              services.openssh.settings.PasswordAuthentication = false;
              services.openssh.settings.KbdInteractiveAuthentication = false;
              users.users.root.openssh.authorizedKeys.keys = [
                ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDUyf0Fie0bEwlcChI46EO5cutOyD1o7/PieWhHpwhJ nakato@misumaru'' 
              ];

              environment.systemPackages = with pkgs; [
                factorio-headless
                git vim
              ];
              nix.settings.experimental-features = [ "nix-command" "flakes" ];

              nixpkgs.config.allowUnfree = true;

              systemd.services.factorio.serviceConfig.TimeoutStartSec = 600;
              systemd.services.factorio.preStart = lib.mkForce ''
                test -e /var/lib/factorio/saves/default.zip && exit 0
                until [ -e /var/lib/factorio/factorio-backup.tar ]; do sleep 1; done
                ${pkgs.gnutar}/bin/tar -C /var/lib/factorio -xf /var/lib/factorio/factorio-backup.tar
              '';
              services.factorio = {
                enable = true;
                openFirewall = true;
                admins = [ "nakatoio" "mattheww" ];
                public = false;
                lan = false;
                game-password = "RecycleAlienGuts";
                autosave-interval = 10;

                mods =
                  let
                    pkgMods = pkgs.callPackage ./mods { };
                  in
                    with pkgMods;
                    [
                      angelsaddons-cab
                      angelsaddons-mobility
                      angelsaddons-nilaus
                      angelsaddons-shred
                      angelsaddons-storage
                      angelsbioprocessing
                      angelsindustries
                      angelsinfiniteores
                      angelspetrochem
                      angelsrefining
                      angelssmelting

                      bobassembly
                      bobclasses
                      bobelectronics
                      bobenemies
                      bobequipment
                      bobgreenhouse
                      bobinserters
                      boblibrary
                      boblogistics
                      bobmining
                      bobmodules
                      bobores
                      bobplates
                      bobpower
                      bobrevamp
                      bobtech
                      bobvehicleequipment
                      bobwarfare

                      discoScience
                      factorissimo-2-notnotmellon
                      rso-mod
                    ];
              };
            })
          ];
        };
      };
    };
}
