{ qt5, fetchFromGitHub, meson, python3, python3Packages, pkgconfig, glslang, ninja
, xlibs, vulkan-loader, vulkan-headers }:

qt5.mkDerivation rec {
  pname = "imgoverlay";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "nowrep";
    repo = "imgoverlay";
    #rev = "v${version}";
    rev = "80ce31692c6ec99ca79d4965cb2eea19a61fc443";
    sha256 = "19axqzqxqlblskz9xhchgbi7d6s324q9vxjlf6v11jxccdchkda8";
  };

  strictDeps = true;

  nativeBuildInputs = [ meson python3 python3Packages.Mako pkgconfig glslang ninja ];
  buildInputs = [ xlibs.libX11 vulkan-loader vulkan-headers qt5.qtwebengine ];

  mesonFlags = [
    "-Duse_system_vulkan=enabled"
    "-Dvulkan_registry=${vulkan-headers}/share/vulkan/registry/vk.xml"
  ];
}
