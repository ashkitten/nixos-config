{ rustPlatform, fetchFromGitHub, pkg-config, libudev }:

rustPlatform.buildRustPackage {
  name = "g933-utils";
  src = fetchFromGitHub {
    owner = "ashkitten";
    repo = "g933-utils";
    rev = "b80cfd59fc41ae5d577c147311376dd7f7882493";
    sha256 = "06napzpk3nayzixb4l4fzdiwpgmcrsbc5j9m4qip1yn6dfkin3p0";
  };
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libudev ];
  cargoSha256 = "03x859n9m0dr96wx2kq16iizibq51anzl4mgyfkh5qvjbshhms1g";
}
