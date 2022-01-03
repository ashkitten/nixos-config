{ rustPlatform, fetchFromGitHub, pkgconfig, gnome3, sqlcipher }:

rustPlatform.buildRustPackage {
  name = "radical-native";
  src = fetchFromGitHub {
    owner = "stoically";
    repo = "radical-native";
    rev = "bb61bc8535fc2c9d7b7ccdafbc0d7466d0fdba4b";
    sha256 = "0h9iyn82g887ssc88ccz9n60r4bdqj6g757g9ghg4xd147k9g4zn";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ gnome3.libsecret sqlcipher ];
  cargoSha256 = "1xldddz6qnl9xv9ppvl5dcj4fds2b6294jdq8zyiai8pdabqj278";
}
