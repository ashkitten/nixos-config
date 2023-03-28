{ qt5, fetchFromGitHub, meson, python3, python3Packages, pkg-config, glslang, ninja
, xorg, vulkan-loader, vulkan-headers }:

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

  nativeBuildInputs = [ meson python3 python3Packages.Mako pkg-config glslang ninja ];
  buildInputs = [ xorg.libX11 vulkan-loader vulkan-headers qt5.qtwebengine ];

  mesonFlags = [
    "-Duse_system_vulkan=enabled"
    "-Dvulkan_registry=${vulkan-headers}/share/vulkan/registry/vk.xml"
  ];
}
