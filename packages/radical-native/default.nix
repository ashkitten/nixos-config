{ rustPlatform, fetchFromGitHub, pkgconfig, gnome3, sqlcipher }:

rustPlatform.buildRustPackage {
  name = "radical-native";
  src = /home/ash/Projects/Not-Mine/radical-native;
  #src = fetchFromGitHub {
  #  owner = "stoically";
  #  repo = "radical-native";
  #  rev = "b7ee434a63d6cbe7c21d2b6fdb7193d6d03bb9ba";
  #  sha256 = "1yy6rzy5xxsx98vqcn7wg2w80fdzgv9mqjdnafjkpw8hrj2s6lz8";
  #};

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ gnome3.libsecret sqlcipher ];
  cargoSha256 = "03y2y29zs6lxhdm5naydl5iwpv6piw54kq9xv6yni0afjg9r8mmp";
}
