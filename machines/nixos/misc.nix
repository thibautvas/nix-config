{
  config,
  lib,
  pkgs,
  ...
}:

{
  # impermanent qemu VMs
  virtualisation.libvirtd.hooks.qemu = {
    "reset-overlay" = lib.getExe (
      pkgs.writeShellScriptBin "reset-overlay" (
        let
          imageDir = "/var/lib/libvirt/images";
        in
        ''
          for vm in archlinux debian; do
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
