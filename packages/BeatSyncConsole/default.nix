{ stdenv, lib, fetchgit, fetchurl, makeWrapper, linkFarmFromDrvs
, dotnet-sdk_3, dotnetCorePackages, dotnetPackages
, icu, openssl, zlib
}:

let
  runtimeDeps = [
    icu
    openssl
    zlib
  ];
in
  stdenv.mkDerivation rec {
    pname = "BeatSyncConsole";
    version = "0.9.1";

    src = fetchgit {
      url = "https://github.com/Zingabopp/BeatSync";
      rev = version;
      sha256 = "0l4k2p9c0mypig4ilyqavjjyiqvv5bprg7gr8x5cb4xkl2025yh4";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ dotnet-sdk_3 dotnetPackages.Nuget makeWrapper ];

    nugetDeps = linkFarmFromDrvs "${pname}-nuget-deps" (import ./deps.nix {
      fetchNuGet = { name, version, sha256 }: fetchurl {
        name = "nuget-${name}-${version}.nupkg";
        url = "https://www.nuget.org/api/v2/package/${name}/${version}";
        inherit sha256;
      };
    });

    configurePhase = ''
      runHook preConfigure

      export HOME=$(mktemp -d)
      export DOTNET_CLI_TELEMETRY_OPTOUT=1
      export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

      nuget sources Add -Name nixos -Source "$PWD/nixos"
      nuget init "$nugetDeps" "$PWD/nixos"

      # FIXME: https://github.com/NuGet/Home/issues/4413
      mkdir -p $HOME/.nuget/NuGet
      cp $HOME/.config/NuGet/NuGet.Config $HOME/.nuget/NuGet

      dotnet restore --source "$PWD/nixos" --runtime linux-x64 BeatSyncConsole/BeatSyncConsole.csproj

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      dotnet build BeatSyncConsole/BeatSyncConsole.csproj \
        --no-restore \
        --configuration Release \
        --runtime linux-x64 \
        -p:PublishProfile=linux-x64

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      dotnet publish BeatSyncConsole/BeatSyncConsole.csproj \
        --no-build \
        --configuration Release \
        --self-contained \
        --runtime linux-x64 \
        --output $out/lib/beatsync \
        -p:PublishProfile=linux-x64

      makeWrapper $out/lib/beatsync/BeatSyncConsole $out/bin/BeatSyncConsole \
        --set DOTNET_ROOT "${dotnetCorePackages.netcore_3_1}" \
        --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeDeps}" \
        --add-flags "-c ~/.config/BeatSyncConsole/configs -L ~/.config/BeatSyncConsole/logs"

      runHook postInstall
    '';

    dontStrip = true;
  }
