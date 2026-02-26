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

  # impermanent qemu VMs
  virtualisation.libvirtd.hooks.qemu = {
    "reset-overlay" = lib.getExe (
      pkgs.writeShellScriptBin "reset-overlay" (
        let
          imageDir = "/var/lib/libvirt/images";
        in
        ''
          for vm in archlinux alpinelinux; do
            if [[ "$1" == "$vm" && "$2" == 'prepare' ]]; then
              overlay="''${vm%linux}overlay.qcow2"
              rm "${imageDir}/$overlay"
              qemu-img create -f qcow2 -b "${imageDir}/$vm.qcow2" -F qcow2 "${imageDir}/$overlay"
            fi
          done
        ''
      )
    );
  };
}
