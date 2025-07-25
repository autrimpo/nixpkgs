{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  llvmPackages,
  go,
  xar,
  binaryen,
  avrdude,
  gdb,
  openocd,
  runCommand,
  tinygoTests ? [ "smoketest" ],
}:

let
  llvmMajor = lib.versions.major llvm.version;
  inherit (llvmPackages)
    llvm
    clang
    compiler-rt
    lld
    ;

  # only doing this because only on darwin placing clang.cc in nativeBuildInputs
  # doesn't build
  bootstrapTools = runCommand "tinygo-bootstrap-tools" { } ''
    mkdir -p $out
    ln -s ${lib.getBin clang.cc}/bin/clang $out/clang-${llvmMajor}
  '';
in

buildGoModule rec {
  pname = "tinygo";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "tinygo-org";
    repo = "tinygo";
    rev = "v${version}";
    hash = "sha256-I/9JXjt6aF/80Mh3iRgUYXv4l+m3XIpmKsIBviOuWCo=";
    fetchSubmodules = true;
    # The public hydra server on `hydra.nixos.org` is configured with
    # `max_output_size` of 3GB. The purpose of this `postFetch` step
    # is to stay below that limit and save 4.1GiB and 428MiB in output
    # size respectively. These folders are not referenced in tinygo.
    postFetch = ''
      rm -r $out/lib/cmsis-svd/data/{SiliconLabs,Freescale}
    '';
  };

  vendorHash = "sha256-juADakh+s8oEY9UXUwxknvVeL1TgB/zRi8Xtzt/4qPA=";

  patches = [
    ./0001-GNUmakefile.patch
  ];

  nativeCheckInputs = [ binaryen ];
  nativeBuildInputs = [
    makeWrapper
    lld
  ];
  buildInputs = [
    llvm
    clang.cc
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ xar ];

  doCheck = (stdenv.buildPlatform.canExecute stdenv.hostPlatform);
  inherit tinygoTests;

  allowGoReference = true;
  ldflags = [
    "-X github.com/tinygo-org/tinygo/goenv.TINYGOROOT=${placeholder "out"}/share/tinygo"
    "-X github.com/tinygo-org/tinygo/goenv.clangResourceDir=${clang.cc.lib}/lib/clang/${llvmMajor}"
  ];
  subPackages = [ "." ];

  # Output contains static libraries for different arm cpus
  # and stripping could mess up these so only strip the compiler
  stripDebugList = [ "bin" ];

  postPatch = ''
    # Borrow compiler-rt builtins from our source
    # See https://github.com/tinygo-org/tinygo/pull/2471
    mkdir -p lib/compiler-rt-builtins
    cp -a ${compiler-rt.src}/compiler-rt/lib/builtins/* lib/compiler-rt-builtins/

    substituteInPlace GNUmakefile \
      --replace "build/release/tinygo/bin" "$out/bin" \
      --replace "build/release/" "$out/share/"
  '';

  preBuild = ''
    export PATH=${bootstrapTools}:$PATH
    export HOME=$TMPDIR

    ldflags=("''$ldflags[@]/\"-buildid=\"")
  '';

  postBuild = ''
    # Move binary
    mkdir -p build
    mv $GOPATH/bin/tinygo build/tinygo

    # Build our own custom wasi-libc.
    # This is necessary because we modify the build a bit for our needs (disable
    # heap, enable debug symbols, etc).
    make wasi-libc \
      CLANG="${lib.getBin clang.cc}/bin/clang -resource-dir ${clang.cc.lib}/lib/clang/${llvmMajor}" \
      LLVM_AR=${lib.getBin llvm}/bin/llvm-ar \
      LLVM_NM=${lib.getBin llvm}/bin/llvm-nm

    make gen-device -j $NIX_BUILD_CORES

    export TINYGOROOT=$(pwd)
  '';

  checkPhase = lib.optionalString (tinygoTests != [ ] && tinygoTests != null) ''
    make ''${tinygoTests[@]} TINYGO="$(pwd)/build/tinygo" MD5SUM=md5sum XTENSA=0
  '';

  # GDB upstream does not support ARM darwin
  runtimeDeps = [
    go
    clang.cc
    lld
    avrdude
    openocd
    binaryen
  ]
  ++ lib.optionals (!(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64)) [ gdb ];

  installPhase = ''
    runHook preInstall

    make build/release USE_SYSTEM_BINARYEN=1

    wrapProgram $out/bin/tinygo \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://tinygo.org/";
    description = "Go compiler for small places";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      Madouura
      muscaln
    ];
  };
}
