{ config, pkgs, ... }:

{
  imports = [
    ./gnome-keyring.nix
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

  networking.networkmanager.enable = true;

  fonts = {
    fonts = with pkgs; [
      source-code-pro
      terminus_font_ttf
      twitter-color-emoji
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
      pinentryFlavor = "gnome3";
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
    pulseaudio = {
      enable = true;
      zeroconf.discovery.enable = true;
      package = pkgs.pulseaudioFull;
    };

    opengl.driSupport32Bit = true;
    bluetooth.enable = true;

    # udev rules for steam hardware
    steam-hardware.enable = true;
  };

  services = {
    dbus.socketActivated = true;

    # needed for display manager
    xserver.enable = true;


    udev.extraRules = ''
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
    '';

    physlock = {
      enable = true;
      allowAnyUser = true;
      lockOn = {
        suspend = false;
        hibernate = false;
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

  nixpkgs.config = {
    android_sdk.accept_license = true;
    wine.build = "wineWow";
  };

  nixpkgs.overlays = [
    (import ./external/nixpkgs-wayland)

    (self: super: rec {
      vulkan-headers = super.vulkan-headers.overrideAttrs (oldAttrs: rec {
        version = "1.2.135";
        src = super.fetchFromGitHub {
          owner = "KhronosGroup";
          repo = "Vulkan-Headers";
          rev = "v${version}";
          sha256 = "17vmdl476gg6vvffafwkjqm2cimgz3d8xymli99dsqf4whiv27av";
        };
      });

      vulkan-loader = (super.vulkan-loader.override { inherit vulkan-headers; }).overrideAttrs (oldAttrs: rec {
        version = "1.2.135";
        src = super.fetchFromGitHub {
          owner = "KhronosGroup";
          repo = "Vulkan-Loader";
          rev = "v${version}";
          sha256 = "1sk00zmx6x7w8m3i79jzk9b44v5vpjayjba6g0j5wn76ai7nbhq4";
        };
      });
    })
  ];
}
