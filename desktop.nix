{ config, pkgs, lib, ... }:

{
  imports = [
    # (import ./external/lix-module/module.nix { lix = ./external/lix; })
    #./gnome-keyring.nix
    # ./external/kde2nix/nixos.nix
  ];

  boot = {
    initrd = {
      kernelModules = [ "pcspkr" ];

      # from https://blog.dhampir.no/content/fun-with-beep
      preDeviceCommands = ''
        ( exec -a @initbeep ${pkgs.callPackage ./files/initbeep {}}/bin/initbeep ) &
      '';
    };

    # kernelPatches = [
    #   {
    #     name = "amd-hdr";
    #     patch = pkgs.fetchpatch {
    #       url = "https://raw.githubusercontent.com/CachyOS/kernel-patches/5a45f714daba82a11feae0c8fad436d4b5832a0d/6.5/0001-amd-hdr.patch";
    #       sha256 = "sha256-/G48qHCYrsk6PQp5IaTBgfo4XjLcoJxa/LkTr2si2/4=";
    #     };
    #   }
    # ];
    
    kernelModules = [ "v4l2loopback" ];

    blacklistedKernelModules = [ "hid_steam" ];

    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="loopback"
    '';

    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        efiInstallAsRemovable = true;

        useOSProber = true;

        extraFiles = {
          "memtest.efi" = "${pkgs.memtest86plus}/memtest.efi";
        };

        extraEntries = ''
          menuentry "memtest86+" {
            chainloader /memtest.efi
          }
        '';
      };
    };

    binfmt.emulatedSystems = [
      "wasm32-wasi"
      "wasm64-wasi"
    ];
  };

  networking.networkmanager.enable = true;

  fonts = {
    packages = with pkgs; [
      source-code-pro
      terminus_font_ttf
      twitter-color-emoji
      corefonts
      aileron
      atkinson-hyperlegible
      fira-mono
    ];

    fontconfig = {
      defaultFonts = {
        emoji = [ "Twitter Color Emoji" ];
        serif = [ "Liberation Serif" "Twitter Color Emoji" ];
        sansSerif = [ "Liberation Sans" "Twitter Color Emoji" ];
        monospace = [ "Liberation Mono" "Twitter Color Emoji" ];
      };
      useEmbeddedBitmaps = true;
    };
  };

  programs = {
    adb.enable = true;
    ccache.enable = true;
    ssh.startAgent = true;
    light.enable = true;
    mosh.enable = true;
    zsh = {
      enable = true;
      promptInit = "
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
      ";
    };

    sway = {
      enable = true;
      extraPackages = with pkgs; [ swaylock swayidle xwayland ];
    };

    wireshark.enable = true;

    gamescope.enable = true;

    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;

        env = {
          DXVK_HDR = "1";
          ENABLE_GAMESCOPE_WSI = "1";
        };

        args = [
          "--hdr-enabled"
          "--hdr-itm-enable"
        ];
      };
    };

    hyprland.enable = true;

    kdeconnect.enable = true;
  };

  hardware = {
    opengl = {
      driSupport32Bit = true;
      # package = (pkgs.mesa.override { galliumDrivers = [ "radeonsi" "zink" "swrast" ]; }).drivers;
      # package32  = (pkgs.pkgsi686Linux.mesa.override { galliumDrivers = [ "radeonsi" "zink" "swrast" ]; }).drivers;
    };
    bluetooth.enable = true;

    # udev rules for steam hardware
    steam-hardware.enable = true;

    # xbox one controllers
    xone.enable = true;

    hackrf.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # for hdr
    gamescope-wsi

    # kvantum theme engine for kde
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum

    # https://github.com/NixOS/nixpkgs/issues/280826
    pcscliteWithPolkit.out
  ];

  environment.variables.QT_LOGGING_RULES = "kwin_*.debug=true";

  services = {
    pcscd.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;

    udev = {
      packages = with pkgs; [
        pentablet-driver
        yubikey-personalization
        qflipper
        chrysalis
      ];
      extraRules = ''
        # Trinket M0
        SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="001e", MODE="0666"

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

        # Qanba Drone
        KERNEL=="hidraw*", ATTRS{idVendor}=="2c22", ATTRS{idProduct}=="2000", MODE="0660", TAG+="uaccess"

        # Sony DualSense (USB)
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666"

        # Sony DualSense (Bluetooth)
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:054C:0CE6.*", MODE="0666"
      '';
    };

    physlock = {
      enable = true;
      allowAnyUser = true;
      lockOn = {
        suspend = false;
        hibernate = false;
      };
    };

    fwupd.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    # monado.enable = true;

    dbus.implementation = "broker";
  };

  # systemd.user.services.monado.environment.LH_DRIVER = "steamvr";

  systemd.services = {
    lock = {
      before = [ "sleep.target" ];
      wantedBy = [ "sleep.target" ];
      script = ''
        loginctl lock-sessions
      '';
    };
  };

  xdg.portal = {
    enable = true;

    # apparently resolves bugs involving programs opening inside FHS envs and such
    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      kdePackages.xdg-desktop-portal-kde
      # xdg-desktop-portal-wlr
    ];
  };

  users.users.ash = {
    isNormalUser = true;
    createHome = false;
    uid = 1000;
    extraGroups = [ "wheel" "disk" "systemd-journal" "dialout" "networkmanager" "video" "wireshark" ];
    shell = pkgs.zsh;
    linger = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    users.ash = ./home-manager;
  };

  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      trusted-users = [ "ash" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
}
