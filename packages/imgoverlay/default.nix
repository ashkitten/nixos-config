{ qt5, fetchFromGitHub, meson, python3, python3Packages, pkgconfig, glslang, ninja
, xlibs, vulkan-loader, vulkan-headers }:

qt5.mkDerivation rec {
  pname = "imgoverlay";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "nowrep";
    repo = "imgoverlay";
    rev = "v${version}";
    sha256 = "1qxylc44jdnl170qwi870qfs59z21jiga0s77p1hx17h2kls84yn";
  };

  strictDeps = true;

  nativeBuildInputs = [ meson python3 python3Packages.Mako pkgconfig glslang ninja ];
  buildInputs = [ xlibs.libX11 vulkan-loader vulkan-headers qt5.qtwebengine ];

  mesonFlags = [
    "-Duse_system_vulkan=enabled"
    "-Dvulkan_registry=${vulkan-headers}/share/vulkan/registry/vk.xml"
  ];
}
