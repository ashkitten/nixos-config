{ stdenv, lib, fetchgit, fetchurl, makeWrapper, linkFarmFromDrvs
, dotnet-sdk_3, dotnetCorePackages, dotnetPackages
, icu, zlib
}:

let
  runtimeDeps = [
    icu
    zlib
  ];
in
  stdenv.mkDerivation rec {
    pname = "ffmt";
    version = "0.9.3.2";

    src = fetchgit {
      url = "https://github.com/fosspill/FFXIV_Modding_Tool";
      rev = "v${version}";
      sha256 = "13k006h4ih9jfk7g2wr1081i2sn9n2sqfyckcq1dgc9s44pbzki7";
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

      dotnet restore --source nixos --runtime linux-x64 xivModdingFramework/xivModdingFramework/xivModdingFramework.csproj
      dotnet restore --source nixos --runtime linux-x64 FFXIV_Modding_Tool/FFXIV_Modding_Tool.csproj

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      dotnet build xivModdingFramework/xivModdingFramework/xivModdingFramework.csproj \
        --no-restore \
        --configuration Release \
        --runtime linux-x64 \
        -o FFXIV_Modding_Tool/references/

      dotnet build FFXIV_Modding_Tool/FFXIV_Modding_Tool.csproj \
        --no-restore \
        --configuration Release \
        --runtime linux-x64

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      dotnet publish FFXIV_Modding_Tool/FFXIV_Modding_Tool.csproj \
        --no-build \
        --configuration Release \
        --self-contained \
        --runtime linux-x64 \
        --output $out/lib/ffmt

      makeWrapper $out/lib/ffmt/ffmt $out/bin/ffmt \
        --set DOTNET_ROOT "${dotnetCorePackages.netcore_3_1}" \
        --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeDeps}"

      runHook postInstall
    '';

    dontStrip = true;
  }
