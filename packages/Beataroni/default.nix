{ stdenv, lib, fetchgit, fetchurl, makeWrapper, linkFarmFromDrvs
, dotnet-sdk_5, dotnetCorePackages, dotnetPackages
, icu, openssl, xorg, fontconfig
}:

let
  runtimeDeps = [
    icu
    openssl
    xorg.libX11
    fontconfig
  ];
in
  stdenv.mkDerivation rec {
    pname = "Beataroni";
    version = "1.2.0";

    src = fetchgit {
      url = "https://github.com/geefr/beatsaber-linux-goodies";
      rev = version;
      sha256 = "0bibklfr41l7xgszzbac68h9x5sibx6blgjciz5nqc4qm20ns8qg";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ dotnet-sdk_5 dotnetPackages.Nuget makeWrapper ];

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

      dotnet restore --source "$PWD/nixos" --runtime linux-x64 Beataroni/Beataroni/Beataroni.csproj

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      dotnet build Beataroni/Beataroni/Beataroni.csproj \
        --no-restore \
        --configuration Release \
        --runtime linux-x64 \
        -p:PublishProfile=linux-x64

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      dotnet publish Beataroni/Beataroni/Beataroni.csproj \
        --no-build \
        --configuration Release \
        --self-contained \
        --runtime linux-x64 \
        --output $out/lib/beataroni \
        -p:PublishProfile=linux-x64

      makeWrapper $out/lib/beataroni/Beataroni $out/bin/Beataroni \
        --set DOTNET_ROOT "${dotnetCorePackages.netcore_3_1}" \
        --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeDeps}" \
        --add-flags "-c ~/.config/BeatSyncConsole/configs -L ~/.config/BeatSyncConsole/logs"

      runHook postInstall
    '';

    dontStrip = true;
  }
