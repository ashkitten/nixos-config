{ rustPlatform }:

rustPlatform.buildRustPackage {
  name = "initbeep";
  src = ./.;
  cargoSha256 = "1822p71dxwlgfjsd5864z1iwp5jrnkdkkx0ysbi713q1n3xf8a2s";
}
