{ config, pkgs, ... }:

{
  # bind-mount music dir so it's readable for mopidy
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems."/opt/mopidy-music" = {
    fsType = "fuse.bindfs";
    device = "/var/lib/nextcloud/data/kity/files/music/library";
    options = [ "ro" "force-user=mopidy" ];
  };

  services.mopidy = {
    enable = true;

    extensionPackages = with pkgs.mopidyPackages; [
      mopidy-iris
      mopidy-local
    ];

    configuration = ''
      [file]
      enable = false

      [local]
      media_dir = /opt/mopidy-music

      [http]
      hostname = 10.100.0.1

      [audio]
      output = lamemp3enc quality=0 ! shout2send async=false mount=mopidy ip=10.100.0.1 port=8000 password=hackme
    '';
  };

  services.icecast = {
    enable = true;
    admin.password = "hackme";
    hostname = "10.100.0.1";
    listen.address = "10.100.0.1";

    extraConf = let
      sox = pkgs.sox.override { enableLame = true; };
      webroot = pkgs.runCommandNoCC "webroot" {} ''
        mkdir $out
        cp ${pkgs.icecast}/share/icecast/web/* $out

        # 1 second of silence
        ${sox}/bin/sox -n -r 44100 -c 2 -L $out/silence.mp3 trim 0.0 1.0
      '';
    in ''
      <paths>
        <webroot>${webroot}</webroot>
      </paths>

      <mount>
        <mount-name>/mopidy</mount-name>
        <password>hackme</password>
        <fallback-mount>/silence.mp3</fallback-mount>
        <fallback-override>1</fallback-override>
      </mount>
    '';
  };

  services.nginx.virtualHosts."np.kity.wtf" = {
    forceSSL = true;
    useACMEHost = "kity.wtf";

    locations = {
      "= /" = {
        proxyPass = "http://10.100.0.1:8000/mopidy";
        extraConfig = ''
          limit_except GET { deny all; }
        '';
      };
    };
  };

  security.acme.certs."kity.wtf".extraDomains."np.kity.wtf" = null;
}
