{ config, pkgs, lib, ... }:

{
  imports = [
    ./gnome-keyring.nix
  ];

  boot = {
    initrd = {
      kernelModules = [ "pcspkr" ];

      # from https://blog.dhampir.no/content/fun-with-beep
      preDeviceCommands = ''
        ( exec -a @initbeep ${pkgs.callPackage ./files/initbeep {}}/bin/initbeep ) &
      '';
    };

    kernelModules = [ "v4l2loopback" ];

    blacklistedKernelModules = [ "hid_steam" ];

    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="loopback"
    '';

    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";

        useOSProber = true;

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

  networking.networkmanager.enable = true;

  fonts = {
    fonts = with pkgs; [
      source-code-pro
      terminus_font_ttf
      twitter-color-emoji
      corefonts
      aileron
    ];

    fontconfig = {
      defaultFonts.emoji = [ "Twitter Color Emoji" ];
      useEmbeddedBitmaps = true;
    };
  };

  programs = {
    adb.enable = true;
    ccache.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "qt";
    };
    light.enable = true;
    mosh.enable = true;
    ssh.startAgent = true;
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
  };

  sound.enable = true;

  hardware = {
    opengl.driSupport32Bit = true;
    bluetooth.enable = true;

    # udev rules for steam hardware
    steam-hardware.enable = true;
  };

  services = {
    # needed for display manager
    xserver.enable = true;

    # steamvr doesn't work in wayland yet
    xserver.desktopManager.xfce.enable = true;

    udev = {
      packages = [ pkgs.yubikey-personalization ];
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
  };

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
    gtkUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  users.users.ash = {
    isNormalUser = true;
    createHome = false;
    uid = 1000;
    extraGroups = [ "wheel" "disk" "systemd-journal" "dialout" "networkmanager" "video" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    users.ash = ./home-manager;
  };

  nix.trustedUsers = [ "ash" ];

  security.sudo.extraConfig = ''
    Defaults!${pkgs.neovim}/bin/nvim env_keep+="HOME PATH"
    Defaults!${pkgs.git}/bin/git env_keep+="HOME"
  '';

  security.wrappers = {
    # for ffxiv ACT parsing
    "wine64" = {
      source = "${pkgs.wineStaging}/bin/wine64";
      capabilities = "cap_net_raw,cap_net_admin,cap_sys_ptrace+eip";
    };
  };

  nixpkgs.config = {
    wine.build = "wineWow";
  };

  nixpkgs.overlays = [
    (import ./external/nixpkgs-wayland)

    (self: super: {
      xdg-desktop-portal-wlr = super.xdg-desktop-portal-wlr.overrideAttrs (old: {
        src = super.fetchFromGitHub {
          owner = "columbarius";
          repo = "xdg-desktop-portal-wlr";
          rev = "730f3897bbbd5611a6b6ef2bb291002a804007d4";
          sha256 = "1c2a0sl3mpy9d19y0m6x0h3rbp73dg08502f4hysx97jrz6bzywh";
        };

        buildInputs = with super; old.buildInputs ++ [
          iniparser
        ];
      });
    })
  ];
}
