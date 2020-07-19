{ rustPlatform, fetchFromGitHub, pkgconfig, libudev }:

rustPlatform.buildRustPackage {
  name = "g933-utils";
  src = fetchFromGitHub {
    owner = "ashkitten";
    repo = "g933-utils";
    rev = "b80cfd59fc41ae5d577c147311376dd7f7882493";
    sha256 = "06napzpk3nayzixb4l4fzdiwpgmcrsbc5j9m4qip1yn6dfkin3p0";
  };
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libudev ];
  cargoSha256 = "091bdj90md7yhca8kcil970c1mgx1iap5lcmcqwg0miadbvwjzqy";
}
