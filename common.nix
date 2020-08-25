{ config, pkgs, ... }:

{
  imports = [
    ./tinc.nix
  ];

  boot = {
    cleanTmpDir = true;
    tmpOnTmpfs = true;
  };

  console = {
    font = "Lat2-Terminus12";
    useXkbConfig = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/Los_Angeles";

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
  };

  security.acme = {
    acceptTerms = true;
    email = "example@thisismyactual.email";
  };

  nixpkgs.config.allowUnfree = true;

  nix.buildCores = 0;
}
