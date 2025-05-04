{ rustPlatform }:

rustPlatform.buildRustPackage {
  name = "initbeep";
  src = ./.;
  cargoHash = "sha256-ye7LUiLpQMnGCT7/9qFXnnZMH4dgytPed6bLlaS1lyI=";
}
