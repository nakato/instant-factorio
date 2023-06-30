# Instant Factorio via NixOS Lustrate

Lustrate info reference [nixos manual](https://nixos.org/manual/nixos/stable/#sec-installing-from-other-distro)
Cloud Lustate reference [nixos-infect](https://github.com/elitak/nixos-infect)

## Vultr

Startup Script:
```
#!/bin/sh

apt-get update
apt-get install -y bzip2 xz-utils curl wget git

export USER="root"
export HOME="/root"

mkdir -p -m 0755 /nix

git clone https://github.com/nakato/instant-factorio /etc/nixos

export NIX_CHANNEL=nixos-22.11

groupadd nixbld -g 30000 || true
for i in {1..10}; do
  useradd -c "Nix build user $i" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(which nologin)" "nixbld$i" || true
done

curl -L https://nixos.org/nix/install | sh -s -- --no-channel-add

. ~/.nix-profile/etc/profile.d/nix.sh

nix --extra-experimental-features nix-command --extra-experimental-features flakes build --profile /nix/var/nix/profiles/system /etc/nixos#nixosConfigurations.vultr.config.system.build.toplevel

touch /etc/NIXOS
cat << EOF > /etc/NIXOS_LUSTRATE
etc/nixos
EOF

mv /boot /boot.bak

/nix/var/nix/profiles/system/bin/switch-to-configuration boot

reboot
```
