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
      rev = "a327b4229c6fddcf39120b60521c78db9d18c152";
      sha256 = "0fsz02m4kl4lbvl5pp3i1wm1555prgmkwzci3p7a6r6y97x0cv98";
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
          Type = "forking";
          WorkingDirectory = "/opt/its";
        };
        path = with pkgs; [ tmux nettools ];
        script = ''
          find ${klh10}/bin -type f -executable -exec ln -sf {} ./ \;

          tmux new-session -d -s its ./kn10-ks-its dskdmp.ini
          sleep 1

          tmux send-keys -t its -l "go"
          tmux send-keys -t its Enter
          sleep 1

          tmux send-keys -t its -l "its"
          tmux send-keys -t its Enter Escape g
        '';
      };
    };

    networking.firewall.trustedInterfaces = [ "tun0" ];

    users.users.its = {
      shell = its-supdup;
    };
  }
