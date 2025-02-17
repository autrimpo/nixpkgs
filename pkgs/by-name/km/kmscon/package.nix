{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  meson,
  libtsm,
  systemd,
  libxkbcommon,
  libdrm,
  libGLU,
  libGL,
  pango,
  pixman,
  pkg-config,
  docbook_xsl,
  libxslt,
  libgbm,
  ninja,
  buildPackages,
}:

stdenv.mkDerivation rec {
  pname = "kmscon";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "Aetf";
    repo = "kmscon";
    rev = "v${version}";
    sha256 = "sha256-8owyyzCrZVbWXcCR+RA+m0MOrdzW+efI+rIMWEVEZ1o=";
  };

  strictDeps = true;

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  buildInputs = [
    libGLU
    libGL
    libdrm
    libtsm
    libxkbcommon
    pango
    pixman
    systemd
    libgbm
  ];

  nativeBuildInputs = [
    meson
    ninja
    docbook_xsl
    pkg-config
    libxslt # xsltproc
  ];

  # Remove the patches attrlist once the package is bumped to something newer than both of these patches
  patches = [
    (fetchpatch {
      name = "0001-tests-fix-warnings.patch";
      url = "https://github.com/Aetf/kmscon/commit/b65f4269b03de580923ab390bde795e7956b633f.patch";
      sha256 = "sha256-ngflPwmNMM/2JzhV+hHiH3efQyoSULfqEywzWox9iAQ=";
    })
    (fetchpatch {
      # https://github.com/Aetf/kmscon/pull/96
      name = "0002-runtime-fix-logout.patch";
      url = "https://github.com/Aetf/kmscon/commit/a81941f4464e6f9cee75bfb8a1db88c253ede33d.patch";
      sha256 = "sha256-geWu8MVsHKs8VHauh5Tf9eWJrdA5+0bPFAQ32T6Xsqg=";
    })
  ];

  # _FORTIFY_SOURCE requires compiling with optimization (-O)
  env.NIX_CFLAGS_COMPILE =
    lib.optionalString stdenv.cc.isGNU "-O" + " -Wno-error=maybe-uninitialized"; # https://github.com/Aetf/kmscon/issues/49

  configureFlags = [
    "--enable-multi-seat"
    "--disable-debug"
    "--enable-optimizations"
    "--with-renderers=bbulk,gltex,pixman"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "KMS/DRM based System Console";
    mainProgram = "kmscon";
    homepage = "https://www.freedesktop.org/wiki/Software/kmscon/";
    license = licenses.mit;
    maintainers = with maintainers; [ omasanori ];
    platforms = platforms.linux;
  };
}
