{ stdenv, lib, callPackage, fetchurl, fetchFromGitLab, fetchpatch, nixosTests }:

let
  common = opts: callPackage (import ./common.nix opts) { };
in

rec {
  firefox = common rec {
    pname = "firefox";
    ffversion = "88.0";
    src = fetchurl {
      url = "mirror://mozilla/firefox/releases/${ffversion}/source/firefox-${ffversion}.source.tar.xz";
      sha512 = "f58f44f2f0d0f54eae5ab4fa439205feb8b9209b1bf2ea2ae0c9691e9e583bae2cbd4033edb5bdf4e37eda5b95fca688499bed000fe26ced8ff4bbc49347ce31";
    };

    meta = {
      description = "A web browser built from Firefox source tree";
      homepage = "http://www.mozilla.com/en-US/firefox/";
      maintainers = with lib.maintainers; [ eelco lovesegfault hexa ];
      platforms = lib.platforms.unix;
      badPlatforms = lib.platforms.darwin;
      broken = stdenv.buildPlatform.is32bit; # since Firefox 60, build on 32-bit platforms fails with "out of memory".
      # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
      license = lib.licenses.mpl20;
    };
    tests = [ nixosTests.firefox ];
    updateScript = callPackage ./update.nix {
      attrPath = "firefox-unwrapped";
      versionKey = "ffversion";
    };
  };

  firefox-esr-78 = common rec {
    pname = "firefox-esr";
    ffversion = "78.10.0esr";
    src = fetchurl {
      url = "mirror://mozilla/firefox/releases/${ffversion}/source/firefox-${ffversion}.source.tar.xz";
      sha512 = "5e2cf137dc781855542c29df6152fa74ba749801640ade3cf01487ce993786b87a4f603d25c0af9323e67c7e15c75655523428c1c1426527b8623c7ded9f5946";
    };

    meta = {
      description = "A web browser built from Firefox Extended Support Release source tree";
      homepage = "http://www.mozilla.com/en-US/firefox/";
      maintainers = with lib.maintainers; [ eelco hexa ];
      platforms = lib.platforms.unix;
      badPlatforms = lib.platforms.darwin;
      broken = stdenv.buildPlatform.is32bit; # since Firefox 60, build on 32-bit platforms fails with "out of memory".
      # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
      license = lib.licenses.mpl20;
    };
    tests = [ nixosTests.firefox-esr ];
    updateScript = callPackage ./update.nix {
      attrPath = "firefox-esr-78-unwrapped";
      versionKey = "ffversion";
    };
  };

  librewolf =
    let
      librewolfCommon = fetchFromGitLab {
        owner = "librewolf-community";
        repo = "browser/common";
        rev = "9120ca6c6709673b0188a081ec6383c4db75d169";
        sha512 = "820a2c3509a5da6e8b5c9b72a8507d1003906c5c62af7b0ab5ade760805b7bcd52b94a70ef4ed78b78acab4064a82cbfba76495907c4e50c8e9d7636da462f6f";
      };
    in
    common rec {
      pname = "librewolf";
      ffversion = "88.0";
      src = fetchurl {
        url = "mirror://mozilla/firefox/releases/${ffversion}/source/firefox-${ffversion}.source.tar.xz";
        sha512 = "f58f44f2f0d0f54eae5ab4fa439205feb8b9209b1bf2ea2ae0c9691e9e583bae2cbd4033edb5bdf4e37eda5b95fca688499bed000fe26ced8ff4bbc49347ce31";
      };

      meta = {
        description = "Community-maintained fork of Firefox, focused on privacy, security and freedom.";
        homepage = "https://librewolf-community.gitlab.io/";
        maintainers = with lib.maintainers; [ superwhiskers ];
        platforms = lib.platforms.unix;
        badPlatforms = lib.platforms.darwin;
        broken = stdenv.buildPlatform.is32bit; # ditto the above
        license = lib.licenses.mpl20;
      };
      extraConfigureFlags = [
        "--enable-hardening"
        "--enable-rust-simd"

        # branding
        "--with-app-name=librewolf"
        "--with-app-basename=LibreWolf"
        "--with-branding=browser/branding/librewolf"
        "--with-distribution-id=io.gitlab.librewolf-community"
      ];
      unmozillaedDefault = true;
      privacySupportDefault = true;
      enableOfficialBrandingDefault = false;
      customBranding = "${librewolfCommon}/source_files/browser/branding/librewolf";
      binaryName = "librewolf";
    };
}
