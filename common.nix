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
      allowedUDPPorts = [ 51820 ];
      trustedInterfaces = [ "wg0" ];
    };

    interfaces.wg0.ipv4.routes = [
      { address = "10.100.0.0"; prefixLength = 24; via = "10.100.0.1"; }
    ];

    wireguard.interfaces = {
      wg0 = {
        # ips defined in device-specific configuration
        listenPort = 51820;
        privateKeyFile = "/root/wireguard-keys/private";
        peers = [
          { # steve
            publicKey = "9VebGMpVY5c2t5p3OQpUaZWSxDGTeSp22T0Qe4Ibulw=";
            allowedIPs = [ "10.100.0.0/24" ];
            endpoint = "kity.wtf:51820";
            persistentKeepalive = 25;
          }
          { # boson
            publicKey = "D1iFPGEU9wKJdVZx5zqvpF6kwWMHikGw8HnwZ9S11XY=";
            allowedIPs = [ "10.100.0.2/32" ];
            endpoint = "2601:600:8980:e61:95ac:21d4:6f12:c4ca:51820";
          }
          { # fucko
            publicKey = "WdBWpIPArhXenahamPNUV2iDzM5t6uBdRus5aCPfXn0=";
            allowedIPs = [ "10.100.0.3/32" ];
          }
          { # electron
            publicKey = "aBgWHULMX6gfNfQ6fXmVIB0dCeOn9Tse8vDtDVX1WVA=";
            allowedIPs = [ "10.100.0.4/32" ];
          }
        ];
      };
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
  };

  systemd = {
    services = {
      lock = {
        before = [ "sleep.target" ];
        wantedBy = [ "sleep.target" ];
        script = ''
          loginctl lock-sessions
        '';
      };
    };
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

  system = {
    stateVersion = "19.03";
    autoUpgrade.enable = true;
  };
}
