{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
  ];

  boot = {
    cleanTmpDir = true;

    initrd = {
      kernelModules = [ "pcspkr" ];

      # from https://blog.dhampir.no/content/fun-with-beep
      preDeviceCommands = ''
        ( exec -a @initbeep ${pkgs.callPackage ./files/initbeep {}}/bin/initbeep ) &
      '';
    };

    blacklistedKernelModules = [ "hid_steam" ];

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";

        extraFiles = {
          "memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
        };

        extraEntries = ''
          menuentry "Memtest86" {
            chainloader /memtest86.efi
          }
        '';
      };
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      extraConfig = ''
        [main]
        rc-manager=resolvconf
      '';
    };

    firewall = {
      allowedTCPPorts = [ 655 ];
      allowedUDPPorts = [ 655 ];
      trustedInterfaces = [ "tinc.t0" ];
    };
  };

  i18n = {
    consoleFont = "Lat2-Terminus12";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };

  time.timeZone = "America/Los_Angeles";

  environment = {
    variables = {
      LC_TIME = "en_DK.UTF-8";
    };
  };

  fonts = {
    fonts = with pkgs; [
      source-code-pro
      terminus_font
      twemoji-color-font
    ];
    fontconfig.ultimate.enable = true;
  };

  programs = {
    adb.enable = true;
    ccache.enable = true;
    gnupg.agent.enable = true;
    light.enable = true;
    mosh.enable = true;
    ssh.startAgent = true;
    zsh = {
      enable = true;
      promptInit = "
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
      ";
    };
  };

  sound.enable = true;

  hardware = {
    # just update both
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;

    pulseaudio = {
      enable = true;
      zeroconf.discovery.enable = true;
      package = pkgs.pulseaudioFull;
    };

    opengl.driSupport32Bit = true;
    bluetooth.enable = true;
  };

  services = {
    openssh.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "compose:menu";

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };

    compton = {
      enable = true;
      backend = "glx";
      vSync = true;
    };

    udev.extraRules = ''
      # Keyboardio Model 01
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0"

      # Logitech devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", MODE="0666"

      # Roccat devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1e7d", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1e7d", MODE="0666"

      # Unbind Tyon joystick driver
      SUBSYSTEM=="usb", ATTR{bInterfaceNumber}=="02", ATTRS{idVendor}=="1e7d", ATTRS{idProduct}=="2e4a|2e4b", RUN+="${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/echo -n %k >/sys$${DEVPATH}/driver/unbind'"

      # Allow access to gamecube adapter
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"

      # Extra rules for steam stuff
      ${builtins.readFile ./files/steam-udev.rules}
    '';

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

    physlock = {
      enable = true;
      allowAnyUser = true;
      lockOn = {
        suspend = false;
        hibernate = false;
      };
    };

    tinc.networks.t0 = {
      extraConfig = ''
        ConnectTo = steve
        Autoconnect = yes
        LocalDiscovery = yes
      '';

      hosts = {
        steve = ''
          Address = 192.99.10.126
          Ed25519PublicKey = Ra66u8aLrlVnoO5ZPKzngIzPOsYLILOGJWy49Bje1fI
          Subnet = 10.100.0.1/32
        '';
        boson = ''
          Ed25519PublicKey = X4MR570GYD3rff4cMv8x/2OTDZrcCrobf8chG890WuK
          Subnet = 10.100.0.2/32
        '';
        fucko = ''
          Ed25519PublicKey = 6EneoCfLtLJ1nBG+oLtYsDQcmYNNkuHLS3fY3IZVxFJ
          Subnet = 10.100.0.3/32
        '';
        electron = ''
          Ed25519PublicKey = YvrM+BgYWG3g5YN/oe2D+yZDzM19roOAYceYAz+mJNA
          Subnet = 10.100.0.4/32
        '';
      };
    };
  };

  systemd.services = {
    lock = {
      before = [ "sleep.target" ];
      wantedBy = [ "sleep.target" ];
      script = ''
        loginctl lock-sessions
      '';
    };

    "network-link-tinc.t0".wantedBy = [ "sys-subsystem-net-devices-tinc.t0.device" ];
    "network-addresses-tinc.t0".wantedBy = [ "sys-subsystem-net-devices-tinc.t0.device" ];
  };

  users.users.ash = {
    isNormalUser = true;
    createHome = false;
    uid = 1000;
    extraGroups = [ "wheel" "disk" "systemd-journal" "dialout" "networkmanager" "video" ];
    shell = pkgs.zsh;
  };

  home-manager.users.ash = import ./home-manager pkgs;

  security.sudo.extraConfig = ''
    Defaults!${pkgs.neovim}/bin/nvim env_keep+="HOME PATH"
    Defaults!${pkgs.git}/bin/git env_keep+="HOME"
  '';

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
    wine.build = "wineWow";
  };

  nix = {
    buildCores = 0;
    gc.automatic = true;
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/nix/var/nix/profiles/per-user/root/channels/nixos-config/devices/${config.networking.hostName}"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  system.stateVersion = "19.03";
}
