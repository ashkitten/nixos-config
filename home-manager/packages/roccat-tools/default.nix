{ rustPlatform, fetchFromGitHub, pkgconfig, libudev }:

rustPlatform.buildRustPackage {
  name = "roccat-tools";
  src = fetchFromGitHub {
    owner = "ashkitten";
    repo = "roccat-tools";
    rev = "08d5d6a224314bc207d34109354aaa86954851b9";
    sha256 = "1n1lnrkbc4gk7pf3ssr47da5n0hwnwsh329vrgkshak3wfyi7fpg";
  };
  buildInputs = [ pkgconfig libudev ];
  cargoSha256 = "1x5jzranclcqjbmm37jm0gmjpi3s30ah6k6sjklsasy9hbjliiyp";
}
