{ rustPlatform, fetchFromGitHub, pkgconfig, gnome3, sqlcipher }:

rustPlatform.buildRustPackage {
  name = "radical-native";
  src = fetchFromGitHub {
    owner = "stoically";
    repo = "radical-native";
    rev = "c1216f85a1da9df559217e02b33c90c343348705";
    sha256 = "1hinfa07gpfnvlk4wy0fql9q6wvnxa2dbvl9zqkkcfbzc4sl5zlm";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ gnome3.libsecret sqlcipher ];
  cargoSha256 = "0l8kq6mfvbpb52avlxvbqq0dpv5r41dkfp9b8jqal3x16d5k47qk";
}
