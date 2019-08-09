{ config, pkgs, ... }:

let
  klh10 = with pkgs; stdenv.mkDerivation {
    name = "klh10";
    src = fetchFromGitHub {
      owner = "PDP-10";
      repo = "klh10";
      rev = "fcf812e4d700cfc387e7452e1bfb40ad895c3c2c";
      sha256 = "06lx7gnxw8hbfzr2dbwkkp58yjcwrynafy9vshrwny6z6fzvli0i";
    };

    buildInputs = [ autoconf makeWrapper ];

    makeFlags = [
      "-C" "bld-ks-its"
      "CONFFLAGS_USR=-DKLH10_DEV_DPTM03=0"
    ];

    configurePhase = ''
      mkdir tmp && cd tmp
      ../autogen.sh --bindir=$out/bin
    '';

    preInstall = ''
      mkdir -p $out/bin
    '';

    postInstall = ''
      rm -d $out/bin/flushed
    '';
  };

  supdup = with pkgs; stdenv.mkDerivation {
    name = "supdup";
    src = fetchFromGitHub {
      owner = "PDP-10";
      repo = "supdup";
      rev = "bf801b9cc7194c78fb765a7fd01fc9326527b7dd";
      sha256 = "02wqii9c6xwp2i9ydarr00mx71m52m2nrgxsq8wbn1s3pc141lcg";
    };

    buildInputs = [ ncurses ];

    preInstall = ''
      mkdir -p $out/bin
      export PREFIX=$out
    '';
  };

  its-supdup = pkgs.writeScriptBin "its-supdup" ''
    #!${pkgs.runtimeShell}
    # disable automatic conversion of things to unicode
    export LC_CTYPE=C
    exec ${supdup}/bin/supdup 192.168.1.100
  '' // { shellPath = "/bin/its-supdup"; };
in
  {
    systemd.services = {
      its = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/opt/its";
        };
        path = with pkgs; [ sudo ];
        script = ''
          find ${klh10}/bin -type f -executable -exec ln -sf {} ./ \;
          ./kn10-ks-its dskdmp.ini
        '';
      };
    };

    networking.firewall.trustedInterfaces = [ "tun0" ];

    users.users.its = {
      shell = its-supdup;
    };
  }
