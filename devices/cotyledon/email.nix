{ config, lib, pkgs, ... }:

{
  imports = [
    ../../external/nixos-mailserver
  ];

  mailserver = {
    enable = true;
    fqdn = "humandomestication.guide";
    domains = [ "humandomestication.guide" ];

    loginAccounts = {
      "authors@humandomestication.guide" = {
        # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
        hashedPasswordFile = toString config.secrets.files.mailserver_password_authors.file;

        aliases = [
          "@humandomestication.guide"
        ];
      };
    };

    forwards = {
      "authors@humandomestication.guide" = "humandomesticationguide@gmail.com";
    };

    certificateScheme = "acme-nginx";
  };
}
