{
  description = "debin 12 + ngate + sakura + cryptopro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      debianImage = pkgs.fetchurl {
        url = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2";
        sha256 = "sha256-UQ8LwIFP4pjslExb+XWYaZst7AM/p5xoAsw6+JSCF94=";
      };

      userData = ./cloud-config.yaml;

      metaData = pkgs.writeText "meta-data" ''
        instance-id: debian-ngate-sakura
        local-hostname: debian-vm
      '';

runScript = pkgs.writeShellScriptBin "run-debian-vm" ''
        set -e
        WORK_IMG="debian-work.qcow2"
        SEED_IMG="seed.img"

        if [ -f "$WORK_IMG" ]; then
          echo "-----------------------------------------------------------"
          echo "   ИСПОЛЬЗУЕТСЯ СУЩЕСТВУЮЩИЙ ДИСК ($WORK_IMG)"
          echo "   Чтобы переустановить (сбросить): make clean && make run"
          echo "-----------------------------------------------------------"
          sleep 1
        else
          cp "${debianImage}" "$WORK_IMG"
          chmod +w "$WORK_IMG"
          ${pkgs.qemu}/bin/qemu-img resize "$WORK_IMG" 20G
        fi

        ${pkgs.cloud-utils}/bin/cloud-localds "$SEED_IMG" "${userData}" "${metaData}"

        # fake smbios
        QEMU_SMBIOS_ARGS=(
          -smbios type=1,manufacturer="GachimuchiCorp",product="gym",serial="300"
          -smbios type=2,manufacturer="Billy Herrington",product="E-ATX",serial="Nico Nico Douga",version="2.0"
          -smbios type=3,manufacturer="Leatherman",asset="Latex"
        )

        ${pkgs.qemu}/bin/qemu-system-x86_64 \
          -name "Debian-Sakura-VM" \
          -m 2G \
          -smp 1 \
          -enable-kvm \
          -cpu host \
          -hda "$WORK_IMG" \
          -drive file="$SEED_IMG",format=raw,if=virtio \
          -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::6080-:6080 \
          -device virtio-net-pci,netdev=net0 \
          -usb \
          -device usb-tablet \
          -device virtio-gpu-pci \
          -display vnc=localhost:0 \
          -serial stdio \
          "''${QEMU_SMBIOS_ARGS[@]}"
      '';

    in
    {
      apps.${system}.default = {
        type = "app";
        program = "${runScript}/bin/run-debian-vm";
      };
    };
}