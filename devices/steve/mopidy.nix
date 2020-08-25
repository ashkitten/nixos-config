{ config, pkgs, ... }:

{
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;

    configFile = pkgs.writeText "default.pa" ''
      load-module module-native-protocol-unix
      load-module module-null-sink sink_name=icecast
    '';
  };


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
      mopidy-youtube
    ];

    configuration = ''
      [local]
      media_dir = /opt/mopidy-music

      [youtube]
      enabled = true

      [http]
      hostname = 10.100.0.1

      [audio]
      output = pulsesink device=icecast
    '';
  };

  systemd.services."mopidy".serviceConfig.Group = "audio";

  systemd.services."icecast-stream" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "icecast.service" "pulseaudio.service" ];
    bindsTo = [ "icecast.service" ];
    wants = [ "pulseaudio.service" ];
    serviceConfig.User = "nobody";
    serviceConfig.Group = "audio";

    environment.GST_PLUGIN_SYSTEM_PATH = with pkgs.gst_all_1; "${gst-plugins-base}/lib/gstreamer-1.0:${gst-plugins-good}/lib/gstreamer-1.0";

    script = ''
     ${pkgs.gst_all_1.gstreamer.dev}/bin/gst-launch-1.0 pulsesrc device=icecast.monitor ! audioconvert ! opusenc bitrate=192000 ! oggmux ! shout2send mount=mopidy ip=10.100.0.1 port=8000 password=hackme
    '';
  };

  services.icecast = {
    enable = true;
    admin.password = "hackme";
    hostname = "10.100.0.1";
    listen.address = "10.100.0.1";

    extraConf = ''
      <authentication>
        <source-password>hackme</source-password>
      </authentication>
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
