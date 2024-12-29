{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "tantivy-go";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "tantivy-go";
    tag = "v${version}";
    hash = "sha256-IlGtyTjOAvmrbgmvy4NelTOgOWopxNta3INq2QcMEqY=";
  };

  cargoHash = "sha256-2fprQHpepF6n+aovq3U4JQue7xmTDUZMnzDLEgc7ock=";

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoRoot = "rust";
  buildAndTestSubdir = cargoRoot;

  meta = {
    description = "Tantivy go bindings";
    homepage = "https://github.com/anyproto/tantivy-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ autrimpo ];
  };
}
