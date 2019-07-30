{ lib, rustPlatform }:

rustPlatform.buildRustPackage {
  name = "initbeep";
  src = ./.;
  cargoSha256 = "1s98qg706iv4g3wlv6c0wbswf0hxg8kf3c0kwwfmm07qnk233m6z";
}
