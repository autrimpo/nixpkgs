{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "any-sync-node";
  version = "0.6.1";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-vek3RdFvj/AuoEI4KT65U/Omh641XBWacinFAIfUiPg=";
  };

  vendorHash = "sha256-SqizuimBHcvUsWBBgSDlH9L5Ej1ND7mSP10PVPoTgSM=";

  env.CGO_ENABLED = "1";

  subPackages = [
    "cmd"
  ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/any-sync-node
  '';

  meta = {
    homepage = "https://github.com/anyproto/any-sync-node";
    description = "Implementation of node from any-sync protocol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ autrimpo ];
    mainProgram = "any-sync-node";
  };
}
