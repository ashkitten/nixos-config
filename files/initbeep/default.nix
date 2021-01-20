{ rustPlatform }:

rustPlatform.buildRustPackage {
  name = "initbeep";
  src = ./.;
  cargoSha256 = "12lmwf62dxvw7kka0ssr653zqarsa88hs2ljr9qyj613vkhvdll9";
}
