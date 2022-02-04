{ config, pkgs, ... }:

{
  imports = [
    ./tinc.nix
  ];

  boot = {
    cleanTmpDir = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };

  console = {
    font = "Lat2-Terminus12";
    useXkbConfig = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/New_York";

  environment.variables = {
    LC_TIME = "en_DK.UTF-8";
  };

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

  nixpkgs.config.allowUnfree = true;

  nix.settings.cores = 0;
}
