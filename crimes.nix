# try this at home!
#
# log of previous poor choices:
# - Hellvetica

{ pkgs, ... }:

{
  environment.sessionVariables = {
    LD_PRELOAD = "${pkgs.callPackage ./packages/crimes {}}/lib/crimes.so";
  };

  # ideally the above LD_PRELOAD would be enough on its own
  # however, applications using pango seem to load the font on their own
  # which results in mismatched glyph information between freetype and pango
  # in the future maybe i can add pango hacks to the LD_PRELOAD shim and get
  # it to work that way?
  #
  # also i should actually add the crimefont to the system fonts
  # but i'll do that later
  fonts.fontconfig.localConf = ''
    <match target="pattern">
      <test qual="any" name="family" compare="not_eq"><string>Bad Handwriting</string></test>
      <edit name="family" mode="assign" binding="same"><string>Bad Handwriting</string></edit>
    </match>
  '';
}
