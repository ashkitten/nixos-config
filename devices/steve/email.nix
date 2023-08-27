{ config, lib, pkgs, ... }:

{
  imports = [
    ../../external/nixos-mailserver
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.kity.wtf";
    domains = [ "kity.wtf" ];

    loginAccounts = {
      "kity@kity.wtf" = {
        # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
        hashedPasswordFile = toString config.secrets.files.mailserver_password_kity.file;

        aliases = [
          "@kity.wtf"
        ];
      };
    };

    certificateScheme = "acme-nginx";
  };
}
