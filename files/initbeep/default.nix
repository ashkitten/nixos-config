{ rustPlatform }:

rustPlatform.buildRustPackage {
  name = "initbeep";
  src = ./.;
  cargoSha256 = "1ab493n9pw39j3ahhnnljz987amxflx7agy9j7s6qkpf27kiwpz6";
}
