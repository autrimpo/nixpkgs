{
  stdenv,
  buildPackages,
  fetchFromGitHub,
  lib,
  firefox-unwrapped,
  firefox-esr-unwrapped,
}:

let
  pname = "wasilibc";
  version = "22-unstable-2024-10-16";
in
stdenv.mkDerivation {
  inherit pname version;

  src = buildPackages.fetchFromGitHub {
    owner = "WebAssembly";
    repo = "wasi-libc";
    rev = "98897e29fcfc81e2b12e487e4154ac99188330c4";
    hash = "sha256-NFKhMJj/quvN3mR7lmxzA9w46KhX92iG0rQA9qDeS8I=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
    "share"
  ];

  # clang-13: error: argument unused during compilation: '-rtlib=compiler-rt' [-Werror,-Wunused-command-line-argument]
  postPatch = ''
    substituteInPlace Makefile \
      --replace "-Werror" ""
  '';

  preBuild = ''
    export SYSROOT_LIB=${builtins.placeholder "out"}/lib
    export SYSROOT_INC=${builtins.placeholder "dev"}/include
    export SYSROOT_SHARE=${builtins.placeholder "share"}/share
    mkdir -p "$SYSROOT_LIB" "$SYSROOT_INC" "$SYSROOT_SHARE"
    makeFlagsArray+=(
      "SYSROOT_LIB:=$SYSROOT_LIB"
      "SYSROOT_INC:=$SYSROOT_INC"
      "SYSROOT_SHARE:=$SYSROOT_SHARE"
      # https://bugzilla.mozilla.org/show_bug.cgi?id=1773200
      "BULK_MEMORY_SOURCES:="
    )

  '';

  enableParallelBuilding = true;

  # We just build right into the install paths, per the `preBuild`.
  dontInstall = true;

  preFixup = ''
    ln -s $share/share/undefined-symbols.txt $out/lib/wasi.imports
  '';

  passthru.tests = {
    inherit firefox-unwrapped firefox-esr-unwrapped;
  };

  meta = with lib; {
    changelog = "https://github.com/WebAssembly/wasi-sdk/releases/tag/wasi-sdk-${version}";
    description = "WASI libc implementation for WebAssembly";
    homepage = "https://wasi.dev";
    platforms = platforms.wasi;
    maintainers = with maintainers; [
      matthewbauer
      rvolosatovs
    ];
    license = with licenses; [
      asl20
      llvm-exception
      mit
    ];
  };
}
