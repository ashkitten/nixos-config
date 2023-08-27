{ config, pkgs, ... }:

{
  imports = [
    ./tinc.nix
  ];

  boot = {
    tmp.cleanOnBoot = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };

  console = {
    font = "Lat2-Terminus12";
    useXkbConfig = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8";
    };
  };

  time.timeZone = "America/New_York";

  hardware = {
    # just update both
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
  };

  services = {
    openssh.enable = true;

    zfs = {
      autoSnapshot = {
        enable = true;
        flags = "-k -p --utc";
      };
      autoScrub.enable = true;
    };

    prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "zfs" ];
      };
    };

    nginx.appendHttpConfig = ''
      add_header X-Clacks-Overhead "GNU Natalie Nguyen";
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "example@thisismyactual.email";
  };
  
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDZ9/PV++mSSGXeRbS/Pd4Df81cv/7Ds8WlQGmI2yth cardno:12 286 835"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9COf2nf4uFGq7WGcVYFpaeTn6cXyg5v99mMb3H4ZnH"
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.cores = 0;
}
