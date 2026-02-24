{
  config,
  lib,
  pkgs,
  ...
}:

{
  # kindle
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0666"
  '';

  # impermanent archlinux vm
  virtualisation.libvirtd.hooks.qemu = {
    "reset-overlay" = lib.getExe (
      pkgs.writeShellScriptBin "reset-overlay" (
        let
          imageDir = "/var/lib/libvirt/images";
        in
        ''
          BASE="${imageDir}/archlinux.qcow2"
          OVERLAY="${imageDir}/archoverlay.qcow2"
          if [[ "$1" == 'archlinux' && "$2" == "prepare" ]]; then
            rm "$OVERLAY"
            qemu-img create -f qcow2 -b "$BASE" -F qcow2 "$OVERLAY"
          fi
        ''
      )
    );
  };
}
