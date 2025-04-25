{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "any-sync-node";
  version = "0.7.3";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-UT0U83E4F69VgCbHiATr9lWy8QxKH9a8qzTNWmmHL+U=";
  };

  vendorHash = "sha256-bmOXsCIofybZKPCUgSZSom9TI2vmVatjNaX7jrDyddQ=";

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
