{
  lib,
  stdenv,
  fetchFromGitHub,
  electron,
  nodejs,
  pnpm_9,
  python3,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aonsoku";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "victoralvesf";
    repo = "aonsoku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/6mFMZu15daIrB1yw4xN0KXFl3ZYsLNKxAk3Bkc5jlg=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-k9ay1dJZn9aJF/J++t7sC3H++gf7EWtEOUVdZjrbdlY=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_9.configHook
    python3
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    export npm_config_nodedir=${electron.headers}

    pnpm electron:build
    pnpm electron-builder \
      --dir \
      -c.asarUnpack="**/*.node" \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern desktop client for Navidrome/Subsonic servers";
    homepage = "https://github.com/victoralvesf/aonsoku";
    changelog = "https://github.com/victoralvesf/aonsoku/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "Aonsoku";
  };
})
